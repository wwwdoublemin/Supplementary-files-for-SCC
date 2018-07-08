% This script is used for the production of figures and tables in the manuscript
% Please modify the value of OBJ on Line 26 to produce certain figure or table 

% INPUT ARGUMENT
% Please designate the figure or table to be reproduced 
% e.g., 'F2' (Figure 2) or 'T1' (Table 1)
OBJ='F6';
%-----------------------------------------------------

% Produce  Figure 2
if strcmp(OBJ,'F2')==1
    % load data
    load('./data/cluster_m.mat');
    
    % Estimate the regression coefficients using the SCC method 
    [beta_hat_SCC]=SCC_spatial_regression(x(8,:,:),y(8,:),lon,lat,beta,1,[]);
    
    % Estimate the regression coefficients using the GWR method
    info.dtype='gaussian';
    info.bmin=0.01^2;
    info.bmax=2^2;
    [beta_hat_GWR]=GWR_spatial_regression(x(8,:,:),y(8,:),lon,lat,beta,1,info);
    
    beta_hat_SCC=squeeze(beta_hat_SCC);
    beta_hat_GWR=squeeze(beta_hat_GWR);
    
    % Plot Figure
    load('./data/colormap.mat');
    subplot(3,3,1);
    scatter(lon,lat,20,beta(:,1),'fill');
    caxis([-5,5])
    subplot(3,3,2);
    scatter(lon,lat,20,beta(:,2),'fill'); 
    caxis([-5,5])
    subplot(3,3,3);
    scatter(lon,lat,20,beta(:,3),'fill');
    caxis([-5,5])
    subplot(3,3,4);
    scatter(lon,lat,20,beta_hat_GWR(:,1),'fill');
    caxis([-5,5])
    subplot(3,3,5);
    scatter(lon,lat,20,beta_hat_GWR(:,2),'fill');
    caxis([-5,5])
    subplot(3,3,6);
    scatter(lon,lat,20,beta_hat_GWR(:,3),'fill');
    caxis([-5,5])
    subplot(3,3,7);
    scatter(lon,lat,20,beta_hat_SCC(:,1),'fill');
    caxis([-5,5])
    subplot(3,3,8);
    scatter(lon,lat,20,beta_hat_SCC(:,2),'fill');  
    caxis([-5,5])
    subplot(3,3,9);
    scatter(lon,lat,20,beta_hat_SCC(:,3),'fill');
    caxis([-5,5])
    colormap(cmap_scatterplot)
end
%--------------------------------------------------------------------------


% Produce  Figure 3 and Table 1
if strcmp(OBJ,'F3')==1||strcmp(OBJ,'T1')==1

   
    MSE_SCC=nan(100,3);% MSE of estimation for SCC in each simulation 
    MSE_GWR=nan(100,3);% MSE of estimation for GWR in each simulation 
    
    % Estimate the regression coefficients using the SCC method 
    load('./data/cluster_w.mat');
    [~,MSE]=SCC_spatial_regression(x,y,lon,lat,beta,100,[]);
    MSE_SCC(:,1)=mean(MSE,2);
    
    load('./data/cluster_m.mat');
    [~,MSE]=SCC_spatial_regression(x,y,lon,lat,beta,100,[]);
    MSE_SCC(:,2)=mean(MSE,2);
    
    load('./data/cluster_s.mat');
    [~,MSE]=SCC_spatial_regression(x,y,lon,lat,beta,100,[]);
    MSE_SCC(:,3)=mean(MSE,2); 
    
    % Estimate the regression coefficients using the GWR method
    info.dtype='gaussian';
    info.bmin=0.01^2;
    info.bmax=2^2;
    
    load('./data/cluster_w.mat');
    [~,MSE]=GWR_spatial_regression(x,y,lon,lat,beta,100,info);
    MSE_GWR(:,1)=mean(MSE,2);

    load('./data/cluster_m.mat');
    [~,MSE]=GWR_spatial_regression(x,y,lon,lat,beta,100,info);
    MSE_GWR(:,2)=mean(MSE,2);
    
    load('./data/cluster_s.mat');
    [~,MSE]=GWR_spatial_regression(x,y,lon,lat,beta,100,info);
    MSE_GWR(:,3)=mean(MSE,2);
    
    % Plot Figure
    n=3;
    posn=1:3*n;
    posn(3:3:end)=[];
    data=nan(100,2*n);
    for i=1:n
        data(:,(i-1)*2+1)=MSE_GWR(:,i);
        data(:,i*2)=MSE_SCC(:,i);
    end
    
    labels = repmat({'GWR','SCC'},n,1)';
    labels=labels(:);
    boxplot(data,'positions',posn,'labels',labels);
    set(findobj(gca,'Type','text'),'FontSize',14)
    set(findobj(gca,'type','line'),'linew',2)

    % Plot Table
    [mean(MSE_GWR)',mean(MSE_SCC)']
end
%--------------------------------------------------------------------------


% Produce Table 2
if strcmp(OBJ,'T2')==1

   
    % Rand Index with weak spatial correlation in covariates    
    load('./data/cluster_w.mat');
    [beta_hat]=SCC_spatial_regression(x,y,lon,lat,beta,100,[]);
    [RI_w]=SCC_RI_loop(beta,beta_hat);
    
    % Rand Index with moderate spatial correlation in covariates 
    load('./data/cluster_m.mat');
    [beta_hat]=SCC_spatial_regression(x,y,lon,lat,beta,100,[]);
    [RI_m]=SCC_RI_loop(beta,beta_hat);
    
    % Rand Index with strong spatial correlation in covariates 
    load('./data/cluster_s.mat');
    [beta_hat]=SCC_spatial_regression(x,y,lon,lat,beta,100,[]);
    [RI_s]=SCC_RI_loop(beta,beta_hat);
    
    [RI_w';RI_m';RI_s']
end
%--------------------------------------------------------------------------


% Produce  Figure 4
if strcmp(OBJ,'F4')==1
    
    s1=dir('./output_R/genlasso_out*.nc');
    s2=dir('./output_R/genlasso_dc_out*.nc');
    
    if length(s1)==100&&length(s2)==100
        load('./data/cluster_w.mat');
    else
        load('./data/cluster_w.mat');
        SCC_R_write(x,y,lon,lat,'./output_R/lasso',1);
        SCC_R_write(x,y,lon,lat,'./output_R/genlasso_dc',-1);
        SCC_R_write(x,y,lon,lat,'./output_R/genlasso',-2);
        warning(['Performing SCC-KNN and SCC-RNN requires solving a generalized lasso problem.' ...
            ' This is done using R software as there is no matlab package available.' ... 
            ' Therefore, to produce Figure 4, please first run the R script SCC_KNN_RNN.R' ... 
            ' included in this folder. After that, rerunning the matlab script will produce' ...
            ' the boxplots in Figure 4. Note that it may take a few days to finish the 100 simulations.'])
    end
    
    

    


    %-------------------------------------------------------------
    % please run the R script SCC_KNN_RNN.R included in this folder.
    %-------------------------------------------------------------
    
    % Load the estimates of SCC-KNN computed from R
    [~,MSE]=SCC_R_read('./output_R/genlasso_out',100,beta,x,y);
    MSE_SCC_KNN=mean(MSE,2);
    
    % Load the estimates of SCC-RNN computed from R
    [~,MSE]=SCC_R_read('./output_R/genlasso_dc_out',100,beta,x,y);
    MSE_SCC_RNN=mean(MSE,2);
    
    % Estimate the regression coefficients using the SCC-MST method 
    [~,MSE]=SCC_spatial_regression(x,y,lon,lat,beta,100,[]);
    MSE_SCC_MST=mean(MSE,2);
       
    % Estimate the regression coefficients using the GWR method
    info.dtype='gaussian';
    info.bmin=0.01^2;
    info.bmax=2^2;
    
    [~,MSE]=GWR_spatial_regression(x,y,lon,lat,beta,100,info);
    MSE_GWR=mean(MSE,2);
    
    data=[MSE_SCC_MST,MSE_SCC_RNN,MSE_SCC_KNN,MSE_GWR];
    labels={'SCC-MST','SCC-RNN','SCC-KNN','GWR'};
    boxplot(data,'positions',1:4,'labels',labels);
    set(findobj(gca,'Type','text'),'FontSize',14)
    set(findobj(gca,'type','line'),'linew',2)
end
%--------------------------------------------------------------------------

% Produce  Figure 5
if strcmp(OBJ,'F5')==1
    % load data
    load('./data/smooth_m.mat');
    
    % Estimate the regression coefficients using the SCC method 
    [beta_hat_SCC]=SCC_spatial_regression(x(72,:,:),y(72,:),lon,lat,beta,1,[]);
    
    % Estimate the regression coefficients using the GWR method
    info.dtype='gaussian';
    info.bmin=0.01^2;
    info.bmax=2^2;
    [beta_hat_GWR]=GWR_spatial_regression(x(72,:,:),y(72,:),lon,lat,beta,1,info);
    
    beta_hat_SCC=squeeze(beta_hat_SCC);
    beta_hat_GWR=squeeze(beta_hat_GWR);
    
    % Plot Figure
    load('./data/colormap.mat');
    subplot(3,3,1);
    scatter(lon,lat,20,beta(:,1),'fill');
    caxis([-5,5])
    subplot(3,3,2);
    scatter(lon,lat,20,beta(:,2),'fill'); 
    caxis([-5,5])
    subplot(3,3,3);
    scatter(lon,lat,20,beta(:,3),'fill');
    caxis([-5,5])
    subplot(3,3,4);
    scatter(lon,lat,20,beta_hat_GWR(:,1),'fill');
    caxis([-5,5])
    subplot(3,3,5);
    scatter(lon,lat,20,beta_hat_GWR(:,2),'fill');
    caxis([-5,5])
    subplot(3,3,6);
    scatter(lon,lat,20,beta_hat_GWR(:,3),'fill');
    caxis([-5,5])
    subplot(3,3,7);
    scatter(lon,lat,20,beta_hat_SCC(:,1),'fill');
    caxis([-5,5])
    subplot(3,3,8);
    scatter(lon,lat,20,beta_hat_SCC(:,2),'fill');  
    caxis([-5,5])
    subplot(3,3,9);
    scatter(lon,lat,20,beta_hat_SCC(:,3),'fill');
    caxis([-5,5])
    colormap(cmap_scatterplot)
end
%--------------------------------------------------------------------------

% Produce  Figure 6 and Table 3
if strcmp(OBJ,'F6')==1||strcmp(OBJ,'T3')==1

   
    MSE_SCC=nan(100,3);% MSE of estimation for SCC in each simulation 
    MSE_GWR=nan(100,3);% MSE of estimation for GWR in each simulation 
    
    % Estimate the regression coefficients using the SCC method 
    load('./data/smooth_w.mat');
    [~,MSE]=SCC_spatial_regression(x,y,lon,lat,beta,100,[]);
    MSE_SCC(:,1)=mean(MSE,2);
    
    load('./data/smooth_m.mat');
    [~,MSE]=SCC_spatial_regression(x,y,lon,lat,beta,100,[]);
    MSE_SCC(:,2)=mean(MSE,2);
    
    load('./data/smooth_s.mat');
    [~,MSE]=SCC_spatial_regression(x,y,lon,lat,beta,100,[]);
    MSE_SCC(:,3)=mean(MSE,2); 
    
    % Estimate the regression coefficients using the GWR method
    info.dtype='gaussian';
    info.bmin=0.01^2;
    info.bmax=2^2;
    
    load('./data/smooth_w.mat');
    [~,MSE]=GWR_spatial_regression(x,y,lon,lat,beta,100,info);
    MSE_GWR(:,1)=mean(MSE,2);

    load('./data/smooth_m.mat');
    [~,MSE]=GWR_spatial_regression(x,y,lon,lat,beta,100,info);
    MSE_GWR(:,2)=mean(MSE,2);
    
    load('./data/smooth_s.mat');
    [~,MSE]=GWR_spatial_regression(x,y,lon,lat,beta,100,info);
    MSE_GWR(:,3)=mean(MSE,2);
    
    % Plot Figure
    n=3;
    posn=1:3*n;
    posn(3:3:end)=[];
    data=nan(100,2*n);
    for i=1:n
        data(:,(i-1)*2+1)=MSE_GWR(:,i);
        data(:,i*2)=MSE_SCC(:,i);
    end
    
    labels = repmat({'GWR','SCC'},n,1)';
    labels=labels(:);
    boxplot(data,'positions',posn,'labels',labels);
    set(findobj(gca,'Type','text'),'FontSize',14)
    set(findobj(gca,'type','line'),'linew',2)
    
    % Plot Table
    [mean(MSE_GWR)',mean(MSE_SCC)']
end
%--------------------------------------------------------------------------


% Produce  Figure 7
if strcmp(OBJ,'F7')==1
    % load data
    load('./data/hybird_m.mat');
    
    xnew=x;
    xnew(:,:,3)=1;
    betanew=beta;
    betanew(:,3)=1;
    
    % Estimate the regression coefficients using the SCC method 
    [beta_hat_SCC]=SCC_spatial_regression(xnew(6,:,:),y(6,:),lon,lat,betanew,1,[]);
    
    % Estimate the regression coefficients using the SCC-T method 
    [beta_hat_SCCT]=SCC_T_spatial_regression(x(6,:,:),y(6,:),lon,lat,beta,phi,1,[]);
    
    % Estimate the regression coefficients using the GWR method
    info.dtype='gaussian';
    info.bmin=0.01^2;
    info.bmax=2^2;
    [beta_hat_GWR]=GWR_spatial_regression(xnew(6,:,:),y(6,:),lon,lat,betanew,1,info);
    
    beta_hat_SCC=squeeze(beta_hat_SCC);
    beta_hat_SCCT=squeeze(beta_hat_SCCT);
    beta_hat_GWR=squeeze(beta_hat_GWR);
    
    % Plot Figure
    load('./data/colormap.mat');
    subplot(2,4,1);
    scatter(lon,lat,20,beta(:,1),'fill');
    caxis([-5,5])
    subplot(2,4,2);
    scatter(lon,lat,20,beta_hat_GWR(:,1),'fill'); 
    caxis([-5,5])
    subplot(2,4,3);
    scatter(lon,lat,20,beta_hat_SCC(:,1),'fill'); 
    caxis([-5,5])
    subplot(2,4,4);
    scatter(lon,lat,20,beta_hat_SCCT(:,1),'fill'); 
    caxis([-5,5])
    subplot(2,4,5);
    scatter(lon,lat,20,beta(:,2),'fill');
    caxis([-5,5])
    subplot(2,4,6);
    scatter(lon,lat,20,beta_hat_GWR(:,2),'fill');
    caxis([-5,5])
    subplot(2,4,7);
    scatter(lon,lat,20,beta_hat_SCC(:,2),'fill');
    caxis([-5,5])
    subplot(2,4,8);
    scatter(lon,lat,20,beta_hat_SCCT(:,2),'fill');
    caxis([-5,5])
    colormap(cmap_scatterplot)
end
%--------------------------------------------------------------------------



% Produce  Figure 8 and Table 4
if strcmp(OBJ,'F8')==1||strcmp(OBJ,'T4')==1

   
    MSE_SCC=nan(100,3);% MSE of estimation for SCC in each simulation 
    MSE_SCCT=nan(100,3);% MSE of estimation for SCC-T in each simulation 
    MSE_GWR=nan(100,3);% MSE of estimation for GWR in each simulation 
    

    
    % Estimate the regression coefficients using the SCC method 
    load('./data/hybird_w.mat');
    xnew=x;
    xnew(:,:,3)=1;
    betanew=beta;
    betanew(:,3)=1;
    
    [~,MSE]=SCC_spatial_regression(xnew,y,lon,lat,betanew,100,[]);
    MSE_SCC(:,1)=mean(MSE(:,1:end-1),2);
    
    load('./data/hybird_m.mat');
    xnew=x;
    xnew(:,:,3)=1;
    betanew=beta;
    betanew(:,3)=1;
    [~,MSE]=SCC_spatial_regression(xnew,y,lon,lat,betanew,100,[]);
    MSE_SCC(:,2)=mean(MSE(:,1:end-1),2);
    
    load('./data/hybird_s.mat');
    xnew=x;
    xnew(:,:,3)=1;
    betanew=beta;
    betanew(:,3)=1;
    [~,MSE]=SCC_spatial_regression(xnew,y,lon,lat,betanew,100,[]);
    MSE_SCC(:,3)=mean(MSE(:,1:end-1),2); 
    
    % Estimate the regression coefficients using the SCC-T method 
    load('./data/hybird_w.mat');
    [~,MSE]=SCC_T_spatial_regression(x,y,lon,lat,beta,phi,100,[]);
    MSE_SCCT(:,1)=mean(MSE,2);
    
    load('./data/hybird_m.mat');
    [~,MSE]=SCC_T_spatial_regression(x,y,lon,lat,beta,phi,100,[]);
    MSE_SCCT(:,2)=mean(MSE,2);
    
    load('./data/hybird_s.mat');
    [~,MSE]=SCC_T_spatial_regression(x,y,lon,lat,beta,phi,100,[]);
    MSE_SCCT(:,3)=mean(MSE,2);     
    
    % Estimate the regression coefficients using the GWR method
    info.dtype='gaussian';
    info.bmin=0.01^2;
    info.bmax=2^2;
    
    load('./data/hybird_w.mat');
    xnew=x;
    xnew(:,:,3)=1;
    betanew=beta;
    betanew(:,3)=1;
    [~,MSE]=GWR_spatial_regression(xnew,y,lon,lat,betanew,100,info);
    MSE_GWR(:,1)=mean(MSE(:,1:end-1),2);

    load('./data/hybird_m.mat');
    xnew=x;
    xnew(:,:,3)=1;
    betanew=beta;
    betanew(:,3)=1;
    [~,MSE]=GWR_spatial_regression(xnew,y,lon,lat,betanew,100,info);
    MSE_GWR(:,2)=mean(MSE(:,1:end-1),2);
    
    load('./data/hybird_s.mat');
    xnew=x;
    xnew(:,:,3)=1;
    betanew=beta;
    betanew(:,3)=1;
    [~,MSE]=GWR_spatial_regression(xnew,y,lon,lat,betanew,100,info);
    MSE_GWR(:,3)=mean(MSE(:,1:end-1),2);
    
    
    
    % Plot Figure
    n=3;
    posn=1:4*n;
    posn(4:4:end)=[];
    data=nan(100,3*n);
    for i=1:n
        data(:,(i-1)*3+1)=MSE_GWR(:,i);
        data(:,(i-1)*3+2)=MSE_SCC(:,i);
        data(:,(i-1)*3+3)=MSE_SCCT(:,i);
    end
    
    labels = repmat({'GWR','SCC','SCC-T'},n,1)';
    labels=labels(:);
    boxplot(data,'positions',posn,'labels',labels);
    set(findobj(gca,'Type','text'),'FontSize',14)
    set(findobj(gca,'type','line'),'linew',2)
    
    % Plot Table
    [mean(MSE_GWR)',mean(MSE_SCC)',mean(MSE_SCCT)']
end
%--------------------------------------------------------------------------

% Produce Figure 9
if strcmp(OBJ,'F9')==1
    load('./data/data_Figure9.mat');
    subplot(2,1,1);
    contourf(lat(120:601),-depth,temp(120:601,:)',50,'linestyle','none');
    subplot(2,1,2);
    contourf(lat(120:601),-depth,salt(120:601,:)',50,'linestyle','none');
    colormap('jet');
end
%--------------------------------------------------------------------------

% Produce Figure 10
if strcmp(OBJ,'F10')==1
    load('./data/TS_data.mat');
    [TS_SCC,TS_GWR]=SCC_WOA_data_application(latn,depthn,temp,salt);
    subplot(2,1,1)
    scatter(latn,-depthn,20,TS_SCC,'fill');
    caxis([-0.2,0.2]);
    subplot(2,1,2)
    scatter(latn,-depthn,20,TS_GWR,'fill');
    caxis([-0.2,0.2]);
    colormap('jet');
end

% Produce Figure 11
if strcmp(OBJ,'F11')==1
    load('./data/TS_data.mat');
    load('./data/colormap.mat');
    [TS_SCC,TS_GWR]=SCC_WOA_data_application(latn,depthn,temp,salt);
    [F,TS_SCC_g,latg,depthg]=SCC_TS_gradient(latn,depthn,TS_SCC);
    scatter(latn,-depthn,20,F,'fill')
    caxis([2,6])
    colormap(cmap_F);
    colorbar
    hold on
    contour(latg(:,1),-depthg(1,:),TS_SCC_g','levellist',0,'linestyle','--','linewidth',2,'color',[0,0,0]);
end