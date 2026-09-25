clear all
close all
clc
%% Load data


% load('QSM_data.mat')
% load('QSMacc_data.mat')



% QSM = mean_d_roiunion_new;
% QSMacc = mean_dACC_roiunion_new;
% QSM = mean_p_roiunion_new;
% QSMacc = mean_pACC_roiunion_new;
% QSM = median_d_roiunion_new;
% QSMacc = median_dACC_roiunion_new;
% QSM = median_p_roiunion_new;
% QSMacc = median_pACC_roiunion_new;
% QSM = w_mean_d_roiunion_new;
% QSMacc = w_mean_dACC_roiunion_new;
% QSM = w_mean_p_roiunion_new;
% QSMacc = w_mean_pACC_roiunion_new;
% QSM = w_median_d_roiunion_new;
% QSMacc = w_median_dACC_roiunion_new;
% QSM = w_median_p_roiunion_new;
% QSMacc = w_median_pACC_roiunion_new;

data.mean_d.QSM   = mean_d_roiunion_new;
data.mean_d.QSMacc = mean_dACC_roiunion_new;
data.mean_p.QSM   = mean_p_roiunion_new;
data.mean_p.QSMacc = mean_pACC_roiunion_new;
data.median_d.QSM   = median_d_roiunion_new;
data.median_d.QSMacc = median_dACC_roiunion_new;
data.median_p.QSM   = mean_p_roiunion_new;
data.median_p.QSMacc = mean_pACC_roiunion_new;
data.w_mean_d.QSM   = w_mean_d_roiunion_new;
data.w_mean_d.QSMacc = w_mean_dACC_roiunion_new;
data.w_mean_p.QSM   = w_mean_p_roiunion_new;
data.w_mean_p.QSMacc = w_mean_pACC_roiunion_new;
data.w_median_d.QSM   = w_median_d_roiunion_new;
data.w_median_d.QSMacc = w_median_dACC_roiunion_new;
data.w_median_p.QSM   = w_median_p_roiunion_new;
data.w_median_p.QSMacc = w_median_pACC_roiunion_new;
%% Define metrics

%metrics = {'mup','mun','Mep','Men','muwp','muwn','Mewp','Mewn'};

%% Initialize results table

%slope_results = nan(14,8);

%% Regression

metrics = fieldnames(data);

slope_table = nan(14,length(metrics));

for m = 1:length(metrics)

    QSM = data.(metrics{m}).QSM;
    QSMacc = data.(metrics{m}).QSMacc;

    for roi = 1:14

        x = QSM(:,roi);
        y = QSMacc(:,roi);

        valid = ~isnan(x) & ~isnan(y);

        x = x(valid);
        y = y(valid);

        mdl = fitlm(x,y);

        slope_table(roi,m) = mdl.Coefficients.Estimate(2);

    end
end

slope_table = array2table(slope_table, ...
    'VariableNames', metrics);

slope_table.ROI = (1:14)';
slope_table = movevars(slope_table,'ROI','Before',1);

writetable(slope_table,'QSM_QSMacc_slopes.xlsx');

%%clear slope_results


%% POOLED
% Define QSM matrices

QSM = {
    mean_d_roiunion_new
    mean_p_roiunion_new
    median_d_roiunion_new
    median_p_roiunion_new
    w_mean_d_roiunion_new
    w_mean_p_roiunion_new
    w_median_d_roiunion_new
    w_median_p_roiunion_new
};

%% Define QSMacc matrices

QSMacc = {
    mean_dACC_roiunion_new
    mean_pACC_roiunion_new
    median_dACC_roiunion_new
    median_pACC_roiunion_new
    w_mean_dACC_roiunion_new
    w_mean_pACC_roiunion_new
    w_median_dACC_roiunion_new
    w_median_pACC_roiunion_new
};

%% Names of metrics

metrics = {
    'Mean_d'
    'Mean_p'
    'Median_d'
    'Median_p'
    'WeightedMean_d'
    'WeightedMean_p'
    'WeightedMedian_d'
    'WeightedMedian_p'
};

%% Pooled regression

slope = nan(8,1);
CI_low = nan(8,1);
CI_high = nan(8,1);
R2 = nan(8,1);

for m = 1:8

    % Current metric
    x = QSM{m}(:);
    y = QSMacc{m}(:);

    % Remove NaN
    valid = ~isnan(x) & ~isnan(y);

    x = x(valid);
    y = y(valid);

    % Linear regression
    mdl = fitlm(x,y);

    % Slope
    slope(m) = mdl.Coefficients.Estimate(2);

    % 95% CI
    CI = coefCI(mdl,0.05);
    CI_low(m) = CI(2,1);
    CI_high(m) = CI(2,2);

    % R2
    R2(m) = mdl.Rsquared.Ordinary;

end

%% Create results table

results = table(metrics, slope, CI_low, CI_high, R2);

disp(results)

%% Save

writetable(results,'QSM_QSMacc_pooled_regression.xlsx');
