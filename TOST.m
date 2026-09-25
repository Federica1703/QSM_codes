%% TOST
clear all
close all

% QSM = mean_d_roiunion_new;
% QSMacc = mean_dACC_roiunion_T1conv;
% QSM = mean_p_roiunion_new;
% QSMacc = mean_pACC_roiunion_T1conv;
% QSM = median_d_roiunion_new; 
% QSMacc = median_dACC_roiunion_T1conv;
% QSM = median_p_roiunion_new;
% QSMacc = median_pACC_roiunion_T1conv;
% QSM = w_mean_d_roiunion_new;
% QSMacc = w_mean_dACC_roiunion_T1conv;
% QSM = w_mean_p_roiunion_new;
% QSMacc = w_mean_pACC_roiunion_T1conv;
% QSM = w_median_d_roiunion_new;
% QSMacc = w_median_dACC_roiunion_T1conv;
QSM = w_median_p_roiunion_new;
QSMacc = w_median_pACC_roiunion_T1conv;
equivalent = [];
for i = 1: 14
d = QSMacc(:,i) - QSM(:,i);
%delta = 0.005;
delta = 0.025;

n = length(d);
meanDiff = mean(d);
sdDiff = std(d);
se = sdDiff / sqrt(n);

m = 14*2;                   % multiple comparisons corr
alpha = 0.05;
alpha_bonf = alpha / m;
tcrit = tinv(1 - alpha_bonf, n-1);

% tcrit = tinv(0.95, n-1);  % 95% CI
CI_low = meanDiff - tcrit * se;
CI_high = meanDiff + tcrit * se;

fprintf('Mean difference = %.6f ppm\n', meanDiff);
fprintf('95%% CI = [%.6f, %.6f] ppm\n', CI_low, CI_high);

equivalent_temp = (CI_low > -delta) && (CI_high < delta);
equivalent = [equivalent,equivalent_temp];
end

fprintf('Equivalent = %d\n', equivalent);