addpath(genpath('/data/project3/kesf/tools_matlab/matlab_paths/'))
call_ncviewcolors

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
dir_gr = '/data/project3/kesf/tools_matlab/applications/papers/UrbanNut/compare/submission/graphics/';
rep = '/data/project3/kesf/tools_matlab/applications/extract_2d/outputs/';
time = datenum(1997,2,1):datenum(2000,12,31);
date = time(1:1064);
%%%%%%%%%

%% extract time series
% CHLA
extract_mask
mask = masklac ;
rep = '/data/project3/kesf/tools_matlab/applications/extract_2d/outputs/';
var = ncread([rep,'macrosystis_growthdepth_L2nat.nc'],'var');
varn = ncread([rep,'macrosystis_growthdepth_L2.nc'],'var');
var = var(:,:,1:1064);
varn = varn(:,:,1:1064);

%% 
for i=1:1064
vari = var(:,:,i)';
var_mean(i) = nanmean(vari(mask==1)) ;
var_min(i) = nanmin(vari(mask==1)) ;
var_max(i) = nanmax(vari(mask==1)) ;

vari = varn(:,:,i)';
varn_mean(i) = nanmean(vari(mask==1)) ;
varn_min(i) = nanmin(vari(mask==1)) ;
varn_max(i) = nanmax(vari(mask==1)) ;
end

[mean_var1 var_var1 sk_var1 ku_var1] = climato_ts(var_mean,date) ;
[mean_var2 var_var2 sk_var2 ku_var2] = climato_ts(varn_mean,date) ;

ddata2 = 100.*(mean_var1-mean_var2)./mean_var2 ;
ddata = mean_var1-mean_var2 ;


col1 = [0.4 0.8 0.4];
col2 = [0.2 0.4 0.8];
col3 = [1.0 0.2 0.4];
col4 = [0.6 0.8 1.0];
col5 = [0.2 0.2 0.2];
lwdt = 5 ;
sz = 14 ;

 data = [mean_var1'  mean_var2'] ;

minlon = -119.3 ;
maxlon = -118.2 ;
minlat = 33.6 ;
maxlat = 34.2 ;

fig = figure('visible','on','position',[50 50 1200 500]);
subplot(2,2,1)
                hold on
                m_proj('mercator','long',[minlon maxlon],'lat',[minlat maxlat]);
%                m_proj('mercator','long',[-120.6 -119],'lat',[33.8 34.8]);
                m_pcolor(lon_rho,lat_rho,mask) ; shading flat
[c m] =         m_contour(lon_rho,lat_rho,-abs(h) ,[-100 -500 -1000] ,'k' ) ;
                clabel(c,m,'FontSize',9,'Color','red','LabelSpacing',400)
                m_gshhs_h('patch',[.9 .9 .9]);
                m_grid('linewi',1,'tickdir','out','FontSize',12,'xtick',3);
title('Domain')

subplot(2,2,2)
hold on ; box on
b = bar(1:12 , data,'FaceColor','flat')
b(1).FaceColor = col3;
b(2).FaceColor = col4;
%title('O_{2} source-sinks [40-80m depth')
ylabel('m')
xlim([0.5 12.5])
ylim([25 40])
set(gca,'xtick',([1 2 3 4 5 6 7 8 9 10 11 12]),'xticklabel',['Jan';'Feb';'Mar';'Apr';'Mai';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'],'tickdir','out');
set(gca,'fontsize',sz-1)
legend('CTRL','ANTH','fontsize',sz ,'orientation','hor','location','north')
title('Climatology')

subplot(2,2,3)
hold on ; box on
b = bar(1:12 , ddata2,'FaceColor','flat')
b.FaceColor = col5;
title('Difference %')
ylabel('%')
xlim([0.5 12.5])
set(gca,'xtick',([1 2 3 4 5 6 7 8 9 10 11 12]),'xticklabel',['Jan';'Feb';'Mar';'Apr';'Mai';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'],'tickdir','out');
set(gca,'fontsize',sz-1)

subplot(2,2,4)
hold on ; box on
ts = var_mean-varn_mean;
areashade(date(:),ts(:) ,0,'r')
plot(date , var_mean-varn_mean,'color',col5)
title('Absolute difference')
ylabel('m')
ylim([0 15])
%xlim([0.5 12.5])
datetick('x','yyyy')
%set(gca,'xtick',([1 2 3 4 5 6 7 8 9 10 11 12]),'xticklabel',['Jan';'Feb';'Mar';'Apr';'Mai';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'],'tickdir','out');
set(gca,'fontsize',sz-1)

sgtitle('Growth depth of \it{Macrocystis pyrifera}')

figure_file_name = [dir_gr,'fig_Macrocystis'] ;
printpng(figure_file_name)

return



% compare NO3 and NH4 in the MLD
fig  = figure('visible','on','position',[0 0 1000 300]);
subplot 111
hold on 
ts = 100.*amm_mld_meantsc3./(amm_mld_meantsc3+nit_mld_meantsc3) ;
areashade(time(:),ts(:) ,0,'r')
hold on
h1 = plot(time(:) , ts(:) ,'-k')
ylabel('%')
axis tight
datetick('x','m')
box on
title('Los Angeles coast')
ylim([0 100])
text(time(30) , 75 ,'NO_{3}^{-}','color','y','fontsize',20)
text(time(280) , 15 ,'NH_{4}^{+}','color','y','fontsize',20)
sgtitle('Fraction of NH_{4}^{+} and NO_{3}^{-} @ MLD','fontsize',14)
set(gca,'fontsize',14)
box on
set(gca,'Color','k')

figure_file_name = [dir_gr,'fig04c'] ;
printpng(figure_file_name)


fig  = figure('visible','on','position',[0 0 1000 300]);
subplot 111
hold on
ts1 = amm_mld_maxtsc3 ;
areashade(time(:),ts1(:) ,0,'r')
alpha(.3)
areashade(time(:),amm_mld_meantsc3(:) ,0,'r')
legend('Mean','Variability','fontsize',14)
%plot(time,amm_mld_meantsc3 ,'-k')
ylabel('mmol N m^{-3}')
axis tight
datetick('x','m')
box on
title('Los Angeles coast')
sgtitle('Concentration of NH_{4}^{+} @ MLD','fontsize',14)
set(gca,'fontsize',14)
box on

figure_file_name = [dir_gr,'fig04b'] ;
printpng(figure_file_name)


minlon = -119 ;
maxlon = -117.7 ;
minlat = 33.5 ;
maxlat = 34.1 ;
cmin = log10(0.05);
cmax = log10(30);

%mxnit_mld = squeeze(nanmax(squeeze(nit_mld(:,:,120:130)),[],3)) ;
%wmxnit_mld = squeeze(nanmax(squeeze(wnit_mld(:,:,120:130)),[],3)) ;
mxamm_mld =  squeeze(nanmax(amm_mld(:,:,1:30),[],3)) ;
%wmxamm_mld = squeeze(nanmeax(wamm_mld(:,:,1:30),[],3)) ;

fig = figure('visible','on' , 'position',[0 0 700 400])
data2 = mxamm_mld' ;
data2(data2==0)=NaN ;
subplot 111
                m_proj('mercator','long',[minlon maxlon],'lat',[minlat maxlat]);
                m_contourf(lon_rho,lat_rho, log10(data2), 20, 'edgecolor','none')
                colormap(parula);
                cb = colorbar;
                ylabel(cb, '[mmol N m^{-3}]')
                title('Winter')
                caxis([cmin cmax])
                set(cb,'ytick',log10([0.05 .5 1 5 10 20]),'yticklabel',[0.05 .5 1 5 10 20],'tickdir','out');
                set(gca,'fontsize',14)
                m_gshhs_h('patch',[.9 .9 .9]);
                m_grid('linewi',1,'tickdir','out','FontSize',14,'xtick',3);
        sgtitle('Concentration of NH_{4}^{+} @ MLD')

figure_file_name = [dir_gr,'fig04e'] ;
printpng(figure_file_name)


cmin = log10(2);
cmax = log10(10);
fig = figure('visible','on' , 'position',[0 0 700 400])
data2 = chl' ;
data2(data2==0)=NaN ;
subplot 111
                m_proj('mercator','long',[minlon maxlon],'lat',[minlat maxlat]);
                m_contourf(lon_rho,lat_rho, log10(data2), 20, 'edgecolor','none')
		cmap = cmocean('tempo') ;
                colormap(cmap);
                cb = colorbar;
                ylabel(cb, '[mg chl m^{-3}]')
                title('Winter')
                caxis([cmin cmax])
                set(cb,'ytick',log10([1 2 5 10 20]),'yticklabel',[1 2 5 10 20],'tickdir','out');
                set(gca,'fontsize',14)
                m_gshhs_h('patch',[.9 .9 .9]);
                m_grid('linewi',1,'tickdir','out','FontSize',14,'xtick',3);
        sgtitle('Concentration of chlorophyll @ surface')

figure_file_name = [dir_gr,'fig04f'] ;
printpng(figure_file_name)
%close all

%% NITROGEN BUDGET
load /data/project3/kesf/tools_matlab/applications/BGCbudget_Package/outputs_N_l2_scb_0-30m/MATBGCF.mat

PHOTO_NO3 = MATBGCF.PHOTO_NO3 ;
PHOTO_NH4 = MATBGCF.PHOTO_NH4 ;

PHOTO_NO3m =  squeeze(nanmean(PHOTO_NO3,3)) ;
PHOTO_NH4m =  squeeze(nanmean(PHOTO_NH4,3)) ;

cmin = 0;
cmax = log10(15);
fig = figure('visible','on' , 'position',[0 0 700 400])
data2 = 86400.*PHOTO_NO3m' ;
data2(data2==0)=NaN ;
subplot 111
                m_proj('mercator','long',[minlon maxlon],'lat',[minlat maxlat]);
                m_contourf(lon_rho,lat_rho, log10(data2), 30, 'edgecolor','none')
                cmap = cmocean('haline') ;
                colormap(cmap);
                cb = colorbar;
                ylabel(cb, '[mmol N m^{-2} d^{-1}]')
                title('All years')
                caxis([cmin cmax])
                set(cb,'ytick',log10([1 2 5 10 15]),'yticklabel',[1 2 5 10 15],'tickdir','out');
                set(gca,'fontsize',14)
                m_gshhs_h('patch',[.9 .9 .9]);
                m_grid('linewi',1,'tickdir','out','FontSize',14,'xtick',3);
        sgtitle('Average rate of NO_{3}^{-} uptake [0 - 30m]')
figure_file_name = [dir_gr,'fig04c'] ;
printpng(figure_file_name)


fig = figure('visible','on' , 'position',[0 0 700 400])
data2 = 86400.*PHOTO_NH4m' ;
data2(data2==0)=NaN ;
subplot 111
                m_proj('mercator','long',[minlon maxlon],'lat',[minlat maxlat]);
                m_contourf(lon_rho,lat_rho, log10(data2), 30, 'edgecolor','none')
                cmap = cmocean('haline') ;
                colormap(cmap);
                cb = colorbar;
                ylabel(cb, '[mg chl m^{-3}]')
                title('All years')
                caxis([cmin cmax])
                set(cb,'ytick',log10([1 2 5 10 15]),'yticklabel',[1 2 5 10 15],'tickdir','out');
                set(gca,'fontsize',14)
                m_gshhs_h('patch',[.9 .9 .9]);
                m_grid('linewi',1,'tickdir','out','FontSize',14,'xtick',3);
        sgtitle('Average rate of Nh_{4}^{+} uptake [0 - 30m]')
figure_file_name = [dir_gr,'fig04d'] ;
printpng(figure_file_name)











