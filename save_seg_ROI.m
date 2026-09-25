clear all
close all
clc
load('//mnt/NAS_diNardo/QSMcomparison/SciRe/for_rev/newLUT.mat');
folder = '/mnt/NAS_diNardo/QSMcomparison/SciRe/for_rev/qsm_acc_T1conv_output_TGV/segmentations/qsm/';
folder_2 = '/mnt/NAS_diNardo/QSMcomparison/SciRe/for_rev/qsm_acc_T1conv_output_TGV/roi_seg/';
d = dir([folder, 'sub-*']);
for i = 1 : length(d)
    disp(['Processing: ', d(i).name])
    % for j = 1 : length(newLUT)
    %     system(['export FSLOUTPUTTYPE=NIFTI; /home/federica/fsl/bin/fslmaths ' ...              
    %         folder, d(i).name, '/anat/', d(i).name, '_space-qsm_dseg.nii ', ' -thr ', ...
    %         num2str(cell2mat(newLUT(j,1))),' -uthr ', num2str(cell2mat(newLUT(j,1))), ' -bin ', ...
    %         folder, d(i).name, '/', [d(i).name, '-', char(newLUT(j,2)), '_PETtoT1.nii']]);
    % end
    mkdir([folder_2, extractBefore(d(i).name,'_')]);
    
    for j = 1 : length(newLUT)
        system(['export FSLOUTPUTTYPE=NIFTI; /home/federica/fsl/bin/fslmaths ' ...             
            folder, d(i).name, ' -thr ', num2str(cell2mat(newLUT(j,1))),' -uthr ', num2str(cell2mat(newLUT(j,1))), ' -bin ', ...
            folder_2, extractBefore(d(i).name, '_'), '/', extractBefore(d(i).name,'_'), '-', char(newLUT(j,2)), '.nii']);
    end
end
%% ROI union
% clear all
% close all
% clc
% load('/mnt/NAS_diNardo/QSM_radiomics/newLUT.mat');
% folder = '/mnt/NAS_diNardo/QSM_radiomics/subjs/derivatives/qsmxt-2025-06-27-075301/';
% d = dir([folder, 'sub-*']);
% for i = 1 : length(d)
%     r = dir([folder, d(i).name, '/', '*.nii']); 
%     for j = 1 : length(r)
%         disp(['Processing roi: ', r(j).name])
%         system(['export FSLOUTPUTTYPE=NIFTI; /home/federica/fsl/bin/fslmaths ' ...
%             folder, d(i).name, '/', r(1).name, ' -add ', r(2).name, ' -bin ', ...
%             folder, d(i).name, '/', [d(i).name, '-', r(1).name(13:end-4), '.nii']]);
%         system(['export FSLOUTPUTTYPE=NIFTI; /home/federica/fsl/bin/fslmaths ' ...
%             folder, d(i).name, '/', r(3).name, ' -add ', r(4).name, ' -bin ', ...
%             folder, d(i).name, '/', [d(i).name, '-', r(3).name(15:end-4), '.nii']]);
%     end
% end

%% QSM values extraction
clear all
close all
clc
folder_qsm = '/mnt/NAS_diNardo/QSMcomparison/SciRe/for_rev/qsm_acc_T1conv_output_TGV/qsm/';
qsm_file = dir([folder_qsm, '*.nii']);
folder = '/mnt/NAS_diNardo/QSMcomparison/SciRe/for_rev/qsm_acc_T1conv_output_TGV/roi_seg/';
d = dir([folder, 'sub-*']);
for i = 1 : length(d)
    disp(['Processing sub: ', d(i).name])
    for k = 1 : length(qsm_file)
        if strcmp(d(i).name, extractBefore(qsm_file(k).name, '_'))
            %qsm_file = dir([folder_qsm, '*.nii']);
            qsm_data = xff([folder_qsm, qsm_file(k).name,]);
            roi_file = dir([folder, d(i).name, '/*.nii']);
            for j = 1 : length(roi_file)
                roi_data = xff([folder, d(i).name,'/', roi_file(j).name]);
                disp(['ROI Nr: ', num2str(j),'/',num2str(length(roi_file)), ' ', roi_file(j).name(1:end-4)])
                roi_datavec = qsm_data.VoxelData(find(roi_data.VoxelData>0));
                roi_datavec(find(roi_datavec == 0))=[];
                roi_datavec(find(isnan(roi_datavec)))=[];
                dlmwrite([folder, d(i).name,'/', roi_file(j).name(1:end-4), '.txt'], roi_datavec);
            end
        end
    end
end

%% Estimate paramagnetic and diamagnetic mean and median
clear all
close all
clc
folder = '/mnt/NAS_diNardo/QSMcomparison/SciRe/for_rev/qsm_acc_T1conv_output_TGV/roi_seg/';
d = dir([folder, 'sub-*']);
for i = 1 : length(d)
    t = dir([folder, d(i).name,'/*.txt']);
    for j = 1 : length(t)
        data = load([folder, d(i).name, '/', t(j).name]);
        N(i,j) = length(data);
        indp = find(data>0);      % indici dei positivi
        indd = find(data<0);      % indici dei negativi
        par = data(indp);         % paramagnetic
        N_p(i,j) = length(par);
        dia = data(indd);         % diamagnetic
        N_d(i,j) = length(dia);
        mean_pACC_TGV(i,j) = mean(par);
        median_pACC_TGV(i,j) = median(par);
        mean_dACC_TGV(i,j) = mean(dia);
        median_dACC_TGV(i,j) = median(dia);
        % st_mean_ACC(i,j) = mean(data);
        % st_median_ACC(i,j) = median(data);
    end
end

save mean_paramACC_TGV.mat mean_pACC_TGV
save median_paramACC_TGV.mat median_pACC_TGV
save mean_diamACC_TGV.mat mean_dACC_TGV
save median_diamACC_TGV.mat median_dACC_TGV
% save Num_voxelACC.mat N
% save Nvoxel_paramACC.mat N_p
% save Nvoxel_diamACC.mat N_d
% save st_mean_ACC.mat st_mean_ACC
% save st_median_ACC.mat st_median_ACC

%% Mean and median weighted
% weights
warning('off','all')
warning
folder = '/mnt/NAS_diNardo/QSMcomparison/SciRe/for_rev/qsm_acc_T1conv_output_TGV/roi_seg/';
d = dir([folder, 'sub-*']);
for i = 1 : length(d)
    t = dir([folder, d(i).name,'/*.txt']);
    for j = 1 : length(t)
        data = load([folder, d(i).name, '/', t(j).name]);
        h=histogram(data,'Normalization','pdf');
        values=h.Values;
        edges=h.BinEdges;
        for k=1:length(edges)-1
            area_bins(k)=(edges(k+1)-edges(k))*values(k);
        end
        ind_param=find(edges>0);
        ind_diam=find(edges<0);
        par_amount=sum(area_bins(ind_param:end));
        dia_amount=sum(area_bins(ind_diam:end));
        PARam(i,j)=par_amount;
        DIAam(i,j)=dia_amount;
        % amount = sum(area_bins(:));
        % weights(i,j) = amount;
    end
end
% save PARAM_amountACC.mat PARam
% save DIAM_amountACC.mat DIAam
% save st_weights.mat weights

% % % % % % Load weights matrices
% % % % % PAR_amount = load('PARAM_amount.mat'); PARam = PAR_amount.PARam;
% % % % % DIA_amount = load('DIAM_amount.mat'); DIAam = DIA_amount.DIAam;
% % % % % % Load mean and median matrices for each ROI
% % % % % meanp = load('mean_param.mat'); mean_p = meanp.mean_p;
% % % % % medianp = load('median_param.mat'); median_p = medianp.median_p;
% % % % % meand = load('meandiam.mat'); mean_d = meand.mean_d;
% % % % % mediand = load('median_diam.mat'); median_d = mediand.median_d;

%Create weighted mean and median matrices
w_mean_pACC_TGV = mean_pACC_TGV.*PARam;
w_median_pACC_TGV = median_pACC_TGV.*PARam;
w_mean_dACC_TGV = mean_dACC_TGV.*DIAam;
w_median_dACC_TGV = median_dACC_TGV.*DIAam;
% w_st_mean_ACC = st_mean_ACC.*weights;
% w_st_median_ACC = st_median_ACC.*weights;

save w_mean_paramACC_TGV.mat w_mean_pACC_TGV
save w_median_paramACC_TGV.mat w_median_pACC_TGV
save w_mean_diamACC_TGV.mat w_mean_dACC_TGV
save w_median_diamACC_TGV.mat w_median_dACC_TGV
% save w_st_mean_ACC.mat w_st_mean_ACC
% save w_st_median_ACC.mat w_st_median_ACC

%% Statistcs
load('mean_d_ROIunion_TGV.mat');
load('mean_p_ROIunion_TGV.mat');
load('median_d_ROIunion_TGV.mat');
load('median_p_ROIunion_TGV.mat');
load('w_mean_d_ROIunion_TGV.mat');
load('w_mean_p_ROIunion_TGV.mat');
load('w_median_d_ROIunion_TGV.mat');
load('w_median_p_ROIunion_TGV.mat');
load('mean_dACC_ROIunion_TGV.mat');
load('mean_pACC_ROIunion_TGV.mat');
load('median_dACC_ROIunion_TGV.mat');
load('median_pACC_ROIunion_TGV.mat');
load('w_mean_dACC_ROIunion_TGV.mat');
load('w_mean_pACC_ROIunion_TGV.mat');
load('w_median_dACC_ROIunion_TGV.mat');
load('w_median_pACC_ROIunion_TGV.mat');
% normality
m = median_p_ROIunion_TGV;
h = zeros(1,size(m,2));
for i = 1 : size(m,2)
    h(i) = kstest(m(:,i));
end
find(h(h==0))

% ranksum
m = mean_p_roiunion_TGV;
mACC = mean_pACC_roiunion_TGV;
p = zeros(1,size(m,2));
for i = 1 : size(m,2)
    p(i) = ranksum(m(:,i), mACC(:,i));
end
p(p<0.05)

%% ICC between qsm anc qsm_acc in each ROI
% m = mean_d_roiunion_new;
% mACC = mean_dACC_roiunion_new;
% m = mean_p_roiunion_new;
% mACC = mean_pACC_roiunion_new;
% m = median_d_roiunion_new;
% mACC = median_dACC_roiunion_new;
% m = median_p_roiunion_new;
% mACC = median_pACC_roiunion_new;
% m = w_mean_d_roiunion_new;
% mACC = w_mean_dACC_roiunion_new;
% m = w_mean_p_roiunion_new;
% mACC = w_mean_pACC_roiunion_new;
% m = w_median_d_roiunion_new;
% mACC = w_median_dACC_roiunion_new;
m = w_median_p_roiunion_new;
mACC = w_median_pACC_roiunion_new;
for i = 1 : size(m,2)
    [coeff(i),LB(i),UB(i)] = ICC([m(:,i),mACC(:,i)], 'C-1', 0.05, 0);
end
vert = {'Accumbens', 'Amygdala', 'Caudate', 'Hippocampus', 'Pallidum', 'Putamen', ...
    'Thalamus', 'ACC', 'PCC', 'Frontal-ctx', 'Parietal-ctx', 'Temporal-ctx', 'Occipital-ctx', 'Enthorinal-ctx'};

coeffwmedianp_CI_Ck = [coeff' LB' UB'];
save coeffwmedianp_CI_Ck.mat coeffwmedianp_CI_Ck
%%
% Graphic
ICC_values = coeffwmediand_new(:,1);
lim1= 0.6;
lim2 = 0.75;
scatter(1:length(ICC_values), ICC_values, 'filled', 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'black');
%xlabel('ROIs');
ylabel('ICC Diamagnetic weighted median');
title('ICC values between QSM and QSM accelerated sequences for each ROIs');
xticks(1:length(ICC_values));
xticklabels({'Accumbens', 'Amygdala', 'Caudate', 'Hippocampus', 'Pallidum', 'Putamen', ...
    'Thalamus', 'ACC', 'PCC', 'Frontal-ctx', 'Parietal-ctx', 'Temporal-ctx', 'Occipital-ctx', 'Enthorinal-ctx'});
yline(lim1, '--r', 'Good Consistency', 'LineWidth', 1);
yline(lim2, '--b', 'Excellent Consistency', 'LineWidth', 1);
for i = 1:14
    xline(i, 'k', 'LineWidth', 0.1);
end

%% CoV interscan
m = w_mean_d_roiunion_TGV;
mACC = w_mean_dACC_roiunion_TGV;
for i = 1 : size(m,2)
    CoV(i) = abs(200.*((mean(m(:,i))-mean(mACC(:,i)))./(mean(m(:,i))+mean(mACC(:,i)))));
end

CoVwmeand_TGV = CoV;
save CoVwmeand_TGV.mat CoVwmeand_TGV
%%
% Graphic
CoV_values = CoVwmeand;
lim1 = 10;
lim2 = 20;
scatter(1:length(CoV_values), CoV_values, 'filled', 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'black');
%xlabel('ROIs');
ylabel('CoV Diamagnetic weighted mean [%]');
title('CoV values between QSM and QSM accelerated sequences for each ROIs');
xticks(1:length(CoV_values));
xticklabels({'Accumbens', 'Amygdala', 'Caudate', 'Hippocampus', 'Pallidum', 'Putamen', ...
    'Thalamus', 'ACC', 'PCC', 'Frontal-ctx', 'Parietal-ctx', 'Temporal-ctx', 'Occipital-ctx', 'Enthorinal-ctx'});
yline(lim1, '--r', '10% Low variability', 'LineWidth', 1);
yline(lim2, '--b', '20% Moderate variability', 'LineWidth', 1);
ylim([0 25])
for i = 1:14    
    xline(i, 'k', 'LineWidth', 0.1);
end

%% Bland-Altman
% QSM = mean_d_roiunion_TGV;
% QSMacc = mean_dACC_roiunion_TGV;
% QSM = mean_p_roiunion_TGV;
% QSMacc = mean_pACC_roiunion_TGV;
% QSM = median_d_roiunion_TGV;
% QSMacc = median_dACC_roiunion_TGV;
% QSM = median_p_roiunion_TGV;
% QSMacc = median_pACC_roiunion_TGV;
% QSM = w_mean_d_roiunion_TGV;
% QSMacc = w_mean_dACC_roiunion_TGV;
% QSM = w_mean_p_roiunion_TGV;
% QSMacc = w_mean_pACC_roiunion_TGV;
QSM = w_median_d_roiunion_new;
QSMacc = w_median_dACC_roiunion_new;
% QSM = w_median_p_roiunion_T1conv;
% QSMacc = w_median_pACC_roiunion_T1conv;

vert = {'Accumbens', 'Amygdala', 'Caudate', 'Hippocampus', ...
    'Pallidum', 'Putamen', 'Thalamus', 'ACC', 'PCC', ...
    'Frontal-ctx', 'Parietal-ctx', 'Temporal-ctx', ...
    'Occipital-ctx', 'Entorhinal-ctx'};


meanDifference = zeros(14,1);
corrP = zeros(14,1);
RPC = zeros(14,1);


BA_results = cell(14,1);
BA_figures = cell(14,1);


for i = 1 : 14
     [rpc, fig, sstruct] = BlandAltman(QSM(:,i),QSMacc(:,i));
    
    meanDifference(i) = sstruct.differenceMean;
    corrP(i) = sstruct.corrP;
    RPC(i) = rpc;

    BA_results{i} = sstruct;
    BA_figures{i} = fig;

   
    fprintf('%-18s  Mean difference = %.6f   corrP = %.6f   RPC = %.6f\n', ...
        vert{i}, meanDifference(i), corrP(i), RPC(i));
end