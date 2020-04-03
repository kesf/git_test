addpath(genpath('/data/project3/kesf/tools_matlab/matlab_paths/'))
call_ncviewcolors

DDfix = 50 ;
dir_gr = '/data/project3/kesf/tools_matlab/applications/papers/UrbanNut/compare/submission/graphics/';
link_cpt='/data/project3/kesf/tools_matlab/matlab_paths/cpt_all/ncl/';
cptc = 'WhViBlGrYeOrRe' ;

%% LOAD GRID
%grd = '/data/project4/kesf/ROMS/L2_SCB/grid_3/roms_grd.nc' ;
%% LOAD GRID
Simu =2 ; % 1 for L1 , 0 for L0, 2 for L2-SCB
[pm pn lon_rho lat_rho lon_psi lon_psi f mask_rho h angle NY NX NZ] = loadgrid(Simu);
    theta_s = 6.0;
    theta_b = 3.0;
    hc = 250;
    sc_type = 'new2012'; % for my zlevs4!!
minlon = min(lon_rho(:)) ;
maxlon = max(lon_rho(:)) ;
minlat = min(lat_rho(:)) ;
maxlat = max(lat_rho(:)) ;


%% AREA
area = 1./(pm.*pn); % m2
area3d = repmat(area,1,1,NZ);
area3d = permute(area3d, [3 1 2]);
area3dv = repmat(area,1,1,NZ+1);
area3dv = permute(area3dv, [3 1 2]);

%% pollution

name1 = 'NITRIF_int_0_to_30';
name2 = 'NITRIF_int_30_to_60';
name3 = 'TOT_PROD_int_0_to_30';
name4 = 'TOT_PROD_int_30_to_60';
ncvar1 = 'NITRIF';
ncvar2 = 'TOT_PROD';
repout = '/data/project3/kesf/tools_matlab/applications/pollution/terrestrial/potw/bgc_rate/';
fout1 =   ([repout,name1,'.nc']);
fout2 =   ([repout,name2,'.nc']);
fout3 =   ([repout,name3,'.nc']);
fout4 =   ([repout,name4,'.nc']);

nitrif1 = ncread(fout1,ncvar1);
nitrif2 = ncread(fout2,ncvar1);
tot_prod1 = ncread(fout3,ncvar2);
tot_prod2 = ncread(fout4,ncvar2);

nitrif = nitrif1+nitrif2 ;
tot_prod = tot_prod1 + tot_prod2 ;

nitrif = squeeze(nitrif(:,:,1:35)) ;
tot_prod = squeeze(tot_prod(:,:,1:35)) ;

date = [datenum(1997,2:12,15) datenum(1998,1:12,15) datenum(1999,1:12,15)];
month = str2num(datestr(date,'mm'));

%% natural
name1 = 'NITRIF_int_0_to_30';
name2 = 'NITRIF_int_30_to_60';
name3 = 'TOT_PROD_int_0_to_30';
name4 = 'TOT_PROD_int_30_to_60';

ncvar1 = 'NITRIF';
ncvar2 = 'TOT_PROD';
repout = '/data/project3/kesf/tools_matlab/applications/pollution/terrestrial/potw/bgc_rate/';
fout1 =   ([repout,name1,'_nat.nc']);
fout2 =   ([repout,name2,'_nat.nc']);
fout3 =   ([repout,name3,'_nat.nc']);
fout4 =   ([repout,name4,'_nat.nc']);

nitrif1 = ncread(fout1,ncvar1);
nitrif2 = ncread(fout2,ncvar1);
tot_prod1 = ncread(fout3,ncvar2);
tot_prod2 = ncread(fout4,ncvar2);

nitrif_nat = nitrif1+nitrif2 ;
tot_prod_nat = tot_prod1 + tot_prod2 ;

nitrif_nat = squeeze(nitrif_nat(:,:,2:36)) ;
tot_prod_nat = squeeze(tot_prod_nat(:,:,2:36)) ;

date_nat = [datenum(1997,2:12,15) datenum(1998,1:12,15) datenum(1999,1:12,15)];
month_nat = str2num(datestr(date_nat,'mm'));

%%
type = 2 ;
dist1 = 0 ;
dist2 = 20 ;
Lat1 = 33.77 ;
Lat2 = 34.04 ;
 [mask_box mask_boxr] = Domasqq(type,Lat1,Lat2,dist1,dist2) ;
mask_box = mask_box';
mask_reg{4} = mask_box ;


mnitrif = squeeze(nanmean(nitrif,3)) ;
mtot_prod = squeeze(nanmean(tot_prod,3)) ;

mnitrif_nat = squeeze(nanmean(nitrif_nat,3)) ;
mtot_prod_nat = squeeze(nanmean(tot_prod_nat,3)) ;

diff_nitrif = mnitrif - mnitrif_nat ;
diff_tot_prod = mtot_prod - mtot_prod_nat ;

fig  = figure('visible','on','position',[0 0 1000 350]);
subplot 121
                m_proj('mercator','long',[-119.1 -117.9],'lat',[33.5 34.1]);
hold on
                m_pcolor(lon_rho,lat_rho,(mnitrif')) ; shading interp
%                m_contourf(lon,lat,maxvar,50 , 'edgecolor','none') ;
%                cptcmap([link_cpt,cptc])
		cmap = cmocean('haline');
                colormap(cmap)
                title(['[ANTH]'])
                caxis([0 4e-5])
                set(gca,'fontname','Courier','fontsize',14)
                m_gshhs_h('patch',[.9 .9 .9]);
                m_grid('linewi',1,'tickdir','out','FontSize',12,'xtick',3);

subplot 122
                m_proj('mercator','long',[-119.1 -117.9],'lat',[33.5 34.1]);
hold on
                m_pcolor(lon_rho,lat_rho,(mnitrif_nat')) ; shading interp
%                m_contourf(lon,lat,maxvar,50 , 'edgecolor','none') ;
%                cptcmap([link_cpt,cptc])
                cmap = cmocean('haline');
                colormap(cmap)
                cb = colorbar;
                p=get(cb,'position');
                set(cb,'position',[p(1)+0.06 p(2)+.12 p(3)/3 p(4)/1.5]);
                ylabel(cb, 'mmol m^{-2} s^{-1}')
		title('[CTRL]')
                sgtitle('Nitrification rate - Average 1997-2000 [0 - 60m depth]')
%                set(cb,'ytick',log10([0.01 0.1 1 5 10]),'yticklabel',[0.01 0.1 1 5 10],'tickdir','out');
                caxis([0 4e-5])
                set(gca,'fontname','Courier','fontsize',14)
                m_gshhs_h('patch',[.9 .9 .9]);
                m_grid('linewi',1,'tickdir','out','FontSize',12,'xtick',3);


figure_file_name = [dir_gr,'Mean_nitrification'] ;
printpng(figure_file_name)



fig  = figure('visible','on','position',[0 0 1000 350]);
subplot 121
                m_proj('mercator','long',[-119.1 -117.9],'lat',[33.5 34.1]);
hold on
                m_pcolor(lon_rho,lat_rho,(mtot_prod')) ; shading interp
%                m_contourf(lon,lat,maxvar,50 , 'edgecolor','none') ;
%                cptcmap([link_cpt,cptc])
colormap(m_colmap('jet','step',100));
%                cmap = cmocean('tempo');
%                colormap(flipud(cmap))
                title(['[ANTH]'])
                caxis([5e-4 18e-4])
                set(gca,'fontname','Courier','fontsize',14)
                m_gshhs_h('patch',[.9 .9 .9]);
                m_grid('linewi',1,'tickdir','out','FontSize',12,'xtick',3);

subplot 122
                m_proj('mercator','long',[-119.1 -117.9],'lat',[33.5 34.1]);
hold on
                m_pcolor(lon_rho,lat_rho,(mtot_prod_nat')) ; shading interp
%                m_contourf(lon,lat,maxvar,50 , 'edgecolor','none') ;
%                cptcmap([link_cpt,cptc])
		colormap(m_colmap('jet','step',100));
%                cmap = cmocean('tempo');
%                colormap(flipud(cmap))
                cb = colorbar;
                p=get(cb,'position');
                set(cb,'position',[p(1)+0.06 p(2)+.12 p(3)/3 p(4)/1.5]);
                ylabel(cb, 'mmol m^{-2} s^{-1}')
                title('[CTRL]')
                sgtitle('NPP rate - Average 1997-2000 [0 - 60m depth]')
%                set(cb,'ytick',log10([0.01 0.1 1 5 10]),'yticklabel',[0.01 0.1 1 5 10],'tickdir','out');
                caxis([5e-4 18e-4])
                set(gca,'fontname','Courier','fontsize',14)
                m_gshhs_h('patch',[.9 .9 .9]);
                m_grid('linewi',1,'tickdir','out','FontSize',12,'xtick',3);

figure_file_name = [dir_gr,'Mean_NPP'] ;
printpng(figure_file_name)

return

fig  = figure('visible','on','position',[0 0 1150 600]);
subplot 111
                m_proj('mercator','long',[-119.1 -117.9],'lat',[33.5 34.1]);
hold on
                m_contourf(lon_rho,lat_rho,(mtot_prod'),30 , 'edgecolor','none') ;
%                m_contourf(lon,lat,maxvar,50 , 'edgecolor','none') ;
%                cptcmap([link_cpt,cptc])
		colormap(bright)
                cb = colorbar;
                p=get(cb,'position');
                set(cb,'position',[p(1)+0.03 p(2) p(3)/3 p(4)/1.1]);
                ylabel(cb, 'mmol m^{-2} s^{-1}')
                title(['Primary production [0 - 60m depth]'])
                sgtitle('Average 1997-2000')
		caxis([0 20e-4])
%                sgtitle([datestr(date,'dd mm yyyy')])
%                set(cb,'ytick',log10([0.01 0.1 1 5 10]),'yticklabel',[0.01 0.1 1 5 10],'tickdir','out');
%                caxis([log10(0.01) log10(10)])
                set(gca,'fontname','Courier','fontsize',14)
                m_gshhs_h('patch',[.9 .9 .9]);
                m_grid('linewi',1,'tickdir','out','FontSize',12,'xtick',3);

figure_file_name = [dir_gr,'Mean_npp'] ;
printpng(figure_file_name)

return







figure_file_name = [dir_gr,'Mean_nitrification_diff'] ;
printpng(figure_file_name)















