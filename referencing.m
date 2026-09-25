clear;
clc;

%% ============================================================
%  COMMON REFERENCE ANALYSIS
%  QSM vs QSMacc
% =============================================================

baseDir = '/mnt/NAS_diNardo/QSMcomparison/QSMxT_proc/qsm/derivatives';
baseDir_acc = '/mnt/NAS_diNardo/QSMcomparison/QSMxT_proc/qsm_acc/derivatives';

subjects = {  
'sub-01'
'sub-02'
'sub-03'
'sub-04'
'sub-06'
'sub-07'
'sub-08'
'sub-09'
'sub-010'
'sub-011'
'sub-013'
'sub-014'
'sub-015'
'sub-016'
'sub-017'
'sub-018'
'sub-019'
'sub-020'
'sub-021'
'sub-022'
'sub-023'
'sub-025'
'sub-026'
'sub-028'
'sub-029'
'sub-030'
'sub-031'
'sub-032'
'sub-033'
'sub-034'
'sub-035'
'sub-036'
'sub-037'
'sub-038'};

% % Standard QSM dir
qsmDir = fullfile(baseDir,'qsmxt-workflow');
% 
% % Accelerated QSM dir
qsmaccDir = fullfile(baseDir_acc,'qsmxt-workflow');

%% ------------------------------------------------------------
% Output
% ------------------------------------------------------------
folder = '/mnt/NAS_diNardo/QSMcomparison/SciRe/for_rev';
outDir = fullfile(folder, 'common_reference_analysis');

if ~exist(outDir, 'dir')
    mkdir(outDir);
end
rtsPattern    = '*_echo-1_part-phase_MEGRE_scaled_B0_normalized_pdf_rts.nii';
maskPattern   = '*voxelquality_mask-intermediate.nii';
%% ------------------------------------------------------------
% Find QSM maps
% ------------------------------------------------------------

% fQSM = dir(fullfile(baseDirQSM, ...
%     '**', '*B0_normalized_pdf_rts.nii'));
% 
% fQSMacc = dir(fullfile(baseDirQSMacc, ...
%     '**', '*B0_normalized_pdf_rts.nii'));

% Remove possible _ref files accidentally matched
% fQSM = fQSM(~contains({fQSM.name}, '_rts_ref'));
% fQSMacc = fQSMacc(~contains({fQSMacc.name}, '_rts_ref'));
% 
% fprintf('QSM maps found: %d\n', numel(fQSM));
% fprintf('QSMacc maps found: %d\n', numel(fQSMacc));

%% ------------------------------------------------------------
% Prepare results
% ------------------------------------------------------------

results = [];

%% ============================================================
% Loop subjects
% =============================================================

for s = 1:length(subjects)
    subj = subjects{s};

    fprintf('\n============================================\n');
    fprintf('Subject %s\n',subj);
    fprintf('============================================\n');

    %% --------------------------------------------------------
    % Read images
    % --------------------------------------------------------
qsmSearchDir = fullfile(qsmDir,subj,subj,'qsmxt');
    accSearchDir = fullfile(qsmaccDir,subj,subj,'qsmxt');

    % RTS
    fQSM = dir(fullfile(qsmSearchDir,...
        '**',rtsPattern));
    fQSM = fQSM(2);

    fACC = dir(fullfile(accSearchDir,...
        '**',rtsPattern));
    fACC = fACC(2);

    QSM = double(niftiread( ...
        fullfile(fQSM(1).folder,fQSM(1).name)));

    QSMacc = double(niftiread( ...
        fullfile(fACC(1).folder,fACC(1).name)));

    % QSMref = double(niftiread( ...
    %     fullfile(fQSMref(1).folder,fQSMref(1).name)));
    % 
    % QSMaccref = double(niftiread( ...
    %     fullfile(fACCref(1).folder,fACCref(1).name)));

    % maskQSM = niftiread( ...
    %     fullfile(fMaskQSM(1).folder,fMaskQSM(1).name)) > 0;
    % 
    % maskACC = niftiread( ...
    %     fullfile(fMaskACC(1).folder,fMaskACC(1).name)) > 0;

    % RTS reference
    % fQSMref = dir(fullfile(qsmSearchDir,...
    %     '**',rtsRefPattern));
    % fQSMref = fQSMref(1); %il 2 è twopass
    % 
    % fACCref = dir(fullfile(accSearchDir,...
    %     '**',rtsRefPattern));
    % fACCref = fACCref(1); %il 2 è twopass

    % Masks
    % fMaskQSM = dir(fullfile(qsmSearchDir,...
    %     '**',maskPattern));
    % 
    % fMaskACC = dir(fullfile(accSearchDir,...
    %     '**',maskPattern));
    % 
    % qsmPath    = fullfile(fQSM(s).folder,fQSM(s).name);
    % qsmaccPath = fullfile(fQSMacc(s).folder,fQSMacc(s).name);
    % 
    % infoQSM    = niftiinfo(qsmPath);
    % infoQSMacc = niftiinfo(qsmaccPath);
    % 
    % QSM    = double(niftiread(infoQSM));
    % QSMacc = double(niftiread(infoQSMacc));

    %% --------------------------------------------------------
    % Check dimensions
    % --------------------------------------------------------

    if ~isequal(size(QSM),size(QSMacc))

        warning('Different dimensions for subject %d. Skipping.',s);
        continue;

    end

    %% --------------------------------------------------------
    % Common valid mask
    %
    % Both maps must contain finite values.
    % Exclude zero background.
    % --------------------------------------------------------

    commonMask = isfinite(QSM) & ...
                 isfinite(QSMacc) & ...
                 QSM ~= 0 & ...
                 QSMacc ~= 0;

    %% --------------------------------------------------------
    % Whole-brain mean before referencing
    % --------------------------------------------------------

    meanQSM_pre = mean(QSM(commonMask),'omitnan');
    meanACC_pre = mean(QSMacc(commonMask),'omitnan');

    offsetDiff_pre = meanQSM_pre - meanACC_pre;

    %% ========================================================
    % COMMON REFERENCE
    %
    % One single reference calculated from BOTH acquisitions
    % ========================================================

    commonReference = ...
        (meanQSM_pre + meanACC_pre) / 2;

    QSM_common = QSM - commonReference;
    QSMacc_common = QSMacc - commonReference;

    %% --------------------------------------------------------
    % Verify that the reference is identical
    % --------------------------------------------------------

    meanQSM_common = mean(QSM_common(commonMask),'omitnan');
    meanACC_common = mean(QSMacc_common(commonMask),'omitnan');

    %% --------------------------------------------------------
    % Difference map
    % --------------------------------------------------------

    D_common = QSM_common - QSMacc_common;

    Dvals = D_common(commonMask);

    meanDiff_common = mean(Dvals,'omitnan');

    RMSE_common = sqrt(mean(Dvals.^2,'omitnan'));

    %% --------------------------------------------------------
    % Sign changes after common reference
    % --------------------------------------------------------

    signChange_common = ...
        (QSM_common > 0) ~= (QSMacc_common > 0);

    signChange_common = ...
        signChange_common & commonMask;

    nSignChange = sum(signChange_common(:));

    nCommon = sum(commonMask(:));

    signChange_percent = ...
        100 * nSignChange / nCommon;

    %% --------------------------------------------------------
    % Dice positive
    % --------------------------------------------------------

    posQSM = QSM_common > 0 & commonMask;
    posACC = QSMacc_common > 0 & commonMask;

    intersectionPos = sum(posQSM(:) & posACC(:));

    dicePos = ...
        2 * intersectionPos / ...
        (sum(posQSM(:)) + sum(posACC(:)));

    %% --------------------------------------------------------
    % Dice negative
    % --------------------------------------------------------

    negQSM = QSM_common < 0 & commonMask;
    negACC = QSMacc_common < 0 & commonMask;

    intersectionNeg = sum(negQSM(:) & negACC(:));

    diceNeg = ...
        2 * intersectionNeg / ...
        (sum(negQSM(:)) + sum(negACC(:)));

    %% --------------------------------------------------------
    % Difference in absolute susceptibility for
    % sign-changing voxels
    % --------------------------------------------------------

    Dsign = abs(D_common(signChange_common));

    if ~isempty(Dsign)

        meanAbsDiff_sign = mean(Dsign,'omitnan');
        medianAbsDiff_sign = median(Dsign,'omitnan');

    else

        meanAbsDiff_sign = NaN;
        medianAbsDiff_sign = NaN;

    end

    %% --------------------------------------------------------
    % Mean absolute susceptibility in sign-changing voxels
    % --------------------------------------------------------

    QSM_sign = QSM_common(signChange_common);
    ACC_sign = QSMacc_common(signChange_common);

    meanAbsQSM_sign = ...
        mean(abs(QSM_sign),'omitnan');

    meanAbsACC_sign = ...
        mean(abs(ACC_sign),'omitnan');

    %% --------------------------------------------------------
    % Store
    % --------------------------------------------------------

    [~,subjectName] = fileparts(subjects{s});

    results(s).Subject = string(subjectName);

    results(s).MeanQSM_pre = meanQSM_pre;
    results(s).MeanQSMacc_pre = meanACC_pre;

    results(s).OffsetDiff_pre = offsetDiff_pre;

    results(s).CommonReference = commonReference;

    results(s).MeanQSM_common = meanQSM_common;
    results(s).MeanQSMacc_common = meanACC_common;

    results(s).MeanDifference_common = meanDiff_common;
    results(s).RMSE_common = RMSE_common;

    results(s).Dice_positive_common = dicePos;
    results(s).Dice_negative_common = diceNeg;

    results(s).SignChange_percent_common = ...
        signChange_percent;

    results(s).MeanAbsDiff_sign = ...
        meanAbsDiff_sign;

    results(s).MedianAbsDiff_sign = ...
        medianAbsDiff_sign;

    results(s).MeanAbsQSM_sign = ...
        meanAbsQSM_sign;

    results(s).MeanAbsQSMacc_sign = ...
        meanAbsACC_sign;

    results(s).N_common_voxels = nCommon;
    results(s).N_sign_change = nSignChange;

end

%% ============================================================
% Convert to table
% =============================================================

T = struct2table(results);

%% ------------------------------------------------------------
% Save
% ------------------------------------------------------------

csvFile = fullfile(outDir,'common_reference_results.csv');

writetable(T,csvFile);

fprintf('\n============================================\n');
fprintf('RESULTS SAVED\n');
fprintf('%s\n',csvFile);
fprintf('============================================\n');

%% ============================================================
% GROUP SUMMARY
% =============================================================

fprintf('\n===== COMMON REFERENCE GROUP SUMMARY =====\n');

fprintf('Mean difference: %.6f ppm\n', ...
    mean(T.MeanDifference_common,'omitnan'));

fprintf('RMSE: %.6f ppm\n', ...
    mean(T.RMSE_common,'omitnan'));

fprintf('Dice positive: %.4f\n', ...
    mean(T.Dice_positive_common,'omitnan'));

fprintf('Dice negative: %.4f\n', ...
    mean(T.Dice_negative_common,'omitnan'));

fprintf('Sign changes: %.2f %%\n', ...
    mean(T.SignChange_percent_common,'omitnan'));

fprintf('\n===== OFFSET =====\n');

fprintf('Mean pre-reference QSM: %.6f ppm\n', ...
    mean(T.MeanQSM_pre,'omitnan'));

fprintf('Mean pre-reference QSMacc: %.6f ppm\n', ...
    mean(T.MeanQSMacc_pre,'omitnan'));

fprintf('Mean offset difference: %.6f ppm\n', ...
    mean(T.OffsetDiff_pre,'omitnan'));