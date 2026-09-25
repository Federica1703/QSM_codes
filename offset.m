%% ============================================================
%  QSM vs QSMacc - PRE AND POST REFERENCING ANALYSIS
%  ============================================================

clear;
clc;

%% --------------------- PATHS -------------------------------

% Sub dir
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

%% -----------------------------------------------------------
% FILE NAMES
% 
% ------------------------------------------------------------

rtsPattern    = '*_echo-1_part-phase_MEGRE_scaled_B0_normalized_pdf_rts.nii';
rtsRefPattern = '*_echo-1_part-phase_MEGRE_scaled_B0_normalized_pdf_rts_ref.nii';

maskPattern   = '*voxelquality_mask-intermediate.nii';


%% --------------------- OUTPUT -------------------------------

results = table();

%% ============================================================
% LOOP SUBJECTS
% ============================================================

for s = 1:length(subjects)

    subj = subjects{s};

    fprintf('\n============================================\n');
    fprintf('Processing %s\n', subj);
    fprintf('============================================\n');

    %% --------------------------------------------------------
    % FIND QSM FILES
    % ---------------------------------------------------------

    qsmSearchDir = fullfile(qsmDir,subj,subj,'qsmxt');
    accSearchDir = fullfile(qsmaccDir,subj,subj,'qsmxt');

    % RTS
    fQSM = dir(fullfile(qsmSearchDir,...
        '**',rtsPattern));
    fQSM = fQSM(2);

    fACC = dir(fullfile(accSearchDir,...
        '**',rtsPattern));
    fACC = fACC(2);

    % RTS reference
    fQSMref = dir(fullfile(qsmSearchDir,...
        '**',rtsRefPattern));
    fQSMref = fQSMref(1); %il 2 è twopass

    fACCref = dir(fullfile(accSearchDir,...
        '**',rtsRefPattern));
    fACCref = fACCref(1); %il 2 è twopass

    % Masks
    fMaskQSM = dir(fullfile(qsmSearchDir,...
        '**',maskPattern));

    fMaskACC = dir(fullfile(accSearchDir,...
        '**',maskPattern));


    %% --------------------------------------------------------
    % FILE CHECK
    % ---------------------------------------------------------

    if isempty(fQSM) || isempty(fACC)
        warning('%s: RTS files not found',subj);
        continue;
    end

    if isempty(fQSMref) || isempty(fACCref)
        warning('%s: referenced RTS files not found',subj);
        continue;
    end

    if isempty(fMaskQSM) || isempty(fMaskACC)
        warning('%s: masks not found',subj);
        continue;
    end


    %% --------------------------------------------------------
    % LOAD IMAGES
    % ---------------------------------------------------------

    QSM = double(niftiread( ...
        fullfile(fQSM(1).folder,fQSM(1).name)));

    QSMacc = double(niftiread( ...
        fullfile(fACC(1).folder,fACC(1).name)));

    QSMref = double(niftiread( ...
        fullfile(fQSMref(1).folder,fQSMref(1).name)));

    QSMaccref = double(niftiread( ...
        fullfile(fACCref(1).folder,fACCref(1).name)));

    maskQSM = niftiread( ...
        fullfile(fMaskQSM(1).folder,fMaskQSM(1).name)) > 0;

    maskACC = niftiread( ...
        fullfile(fMaskACC(1).folder,fMaskACC(1).name)) > 0;


    %% --------------------------------------------------------
    % COMMON MASK
    % ---------------------------------------------------------

    commonMask = maskQSM & maskACC;

    % Elimina NaN / Inf
    commonMask = commonMask & ...
        isfinite(QSM) & ...
        isfinite(QSMacc) & ...
        isfinite(QSMref) & ...
        isfinite(QSMaccref);


    %% ========================================================
    % 1. PRE-REFERENCING
    % ========================================================

    Dpre = QSM - QSMacc;

    Dpre_valid = Dpre(commonMask);

    meanDiff_pre = mean(Dpre_valid);
    sdDiff_pre   = std(Dpre_valid);
    RMSE_pre     = sqrt(mean(Dpre_valid.^2));
    MAE_pre      = mean(abs(Dpre_valid));


    %% --------------------------------------------------------
    % SIGN CHANGES PRE
    % ---------------------------------------------------------

    posQSM_pre = QSM > 0;
    posACC_pre = QSMacc > 0;

    negQSM_pre = QSM < 0;
    negACC_pre = QSMacc < 0;

    signChange_pre = ...
        ((posQSM_pre & negACC_pre) | ...
         (negQSM_pre & posACC_pre)) & commonMask;

    pctSignChange_pre = ...
        100 * nnz(signChange_pre) / nnz(commonMask);


    %% --------------------------------------------------------
    % DICE POSITIVE PRE
    % ---------------------------------------------------------

    posQSM_pre = posQSM_pre & commonMask;
    posACC_pre = posACC_pre & commonMask;

    denom = nnz(posQSM_pre) + nnz(posACC_pre);

    if denom > 0
        DicePos_pre = ...
            2 * nnz(posQSM_pre & posACC_pre) / denom;
    else
        DicePos_pre = NaN;
    end


    %% --------------------------------------------------------
    % DICE NEGATIVE PRE
    % ---------------------------------------------------------

    negQSM_pre = negQSM_pre & commonMask;
    negACC_pre = negACC_pre & commonMask;

    denom = nnz(negQSM_pre) + nnz(negACC_pre);

    if denom > 0
        DiceNeg_pre = ...
            2 * nnz(negQSM_pre & negACC_pre) / denom;
    else
        DiceNeg_pre = NaN;
    end


    %% --------------------------------------------------------
    % GLOBAL OFFSETS PRE
    % ---------------------------------------------------------

    meanQSM_pre = mean(QSM(commonMask));
    meanACC_pre = mean(QSMacc(commonMask));

    offsetDiff_pre = meanQSM_pre - meanACC_pre;


    %% ========================================================
    % 2. POST-REFERENCING
    % ========================================================

    Dref = QSMref - QSMaccref;

    Dref_valid = Dref(commonMask);

    meanDiff_ref = mean(Dref_valid);
    sdDiff_ref   = std(Dref_valid);
    RMSE_ref     = sqrt(mean(Dref_valid.^2));
    MAE_ref      = mean(abs(Dref_valid));


    %% --------------------------------------------------------
    % SIGN CHANGES POST
    % ---------------------------------------------------------

    posQSM_ref = QSMref > 0;
    posACC_ref = QSMaccref > 0;

    negQSM_ref = QSMref < 0;
    negACC_ref = QSMaccref < 0;

    signChange_ref = ...
        ((posQSM_ref & negACC_ref) | ...
         (negQSM_ref & posACC_ref)) & commonMask;

    pctSignChange_ref = ...
        100 * nnz(signChange_ref) / nnz(commonMask);


    %% --------------------------------------------------------
    % DICE POSITIVE POST
    % ---------------------------------------------------------

    posQSM_ref = posQSM_ref & commonMask;
    posACC_ref = posACC_ref & commonMask;

    denom = nnz(posQSM_ref) + nnz(posACC_ref);

    if denom > 0
        DicePos_ref = ...
            2 * nnz(posQSM_ref & posACC_ref) / denom;
    else
        DicePos_ref = NaN;
    end


    %% --------------------------------------------------------
    % DICE NEGATIVE POST
    % ---------------------------------------------------------

    negQSM_ref = negQSM_ref & commonMask;
    negACC_ref = negACC_ref & commonMask;

    denom = nnz(negQSM_ref) + nnz(negACC_ref);

    if denom > 0
        DiceNeg_ref = ...
            2 * nnz(negQSM_ref & negACC_ref) / denom;
    else
        DiceNeg_ref = NaN;
    end


    %% --------------------------------------------------------
    % GLOBAL OFFSETS POST
    % ---------------------------------------------------------

    meanQSM_ref = mean(QSMref(commonMask));
    meanACC_ref = mean(QSMaccref(commonMask));

    offsetDiff_ref = meanQSM_ref - meanACC_ref;


    %% ========================================================
    % SAVE RESULTS
    % ========================================================

    newRow = table( ...
        {subj}, ...
        meanDiff_pre, sdDiff_pre, RMSE_pre, MAE_pre, ...
        DicePos_pre, DiceNeg_pre, pctSignChange_pre, ...
        meanQSM_pre, meanACC_pre, offsetDiff_pre, ...
        meanDiff_ref, sdDiff_ref, RMSE_ref, MAE_ref, ...
        DicePos_ref, DiceNeg_ref, pctSignChange_ref, ...
        meanQSM_ref, meanACC_ref, offsetDiff_ref, ...
        'VariableNames',{ ...
        'Subject', ...
        'MeanDiff_pre','SDDiff_pre','RMSE_pre','MAE_pre', ...
        'DicePos_pre','DiceNeg_pre','SignChange_pre', ...
        'MeanQSM_pre','MeanQSMacc_pre','OffsetDiff_pre', ...
        'MeanDiff_ref','SDDiff_ref','RMSE_ref','MAE_ref', ...
        'DicePos_ref','DiceNeg_ref','SignChange_ref', ...
        'MeanQSM_ref','MeanQSMacc_ref','OffsetDiff_ref'});

    results = [results; newRow];

end


%% ============================================================
% SAVE TABLE
% ============================================================
folder = '/mnt/NAS_diNardo/QSMcomparison/SciRe/for_rev';
outFile = fullfile(folder,...
    'QSM_vs_QSMacc_referencing_analysis.csv');

writetable(results,outFile);

fprintf('\n============================================\n');
fprintf('ANALYSIS COMPLETED\n');
fprintf('Results saved in:\n%s\n',outFile);
fprintf('============================================\n');


%% ============================================================
% GROUP SUMMARY
% ============================================================

fprintf('\n\n===== GROUP SUMMARY =====\n');

fprintf('\nPRE-REFERENCING\n');
fprintf('Mean difference: %.6f\n',mean(results.MeanDiff_pre,'omitnan'));
fprintf('RMSE:            %.6f\n',mean(results.RMSE_pre,'omitnan'));
fprintf('Dice positive:   %.4f\n',mean(results.DicePos_pre,'omitnan'));
fprintf('Dice negative:   %.4f\n',mean(results.DiceNeg_pre,'omitnan'));
fprintf('Sign changes:    %.2f %%\n',mean(results.SignChange_pre,'omitnan'));

fprintf('\nPOST-REFERENCING\n');
fprintf('Mean difference: %.6f\n',mean(results.MeanDiff_ref,'omitnan'));
fprintf('RMSE:            %.6f\n',mean(results.RMSE_ref,'omitnan'));
fprintf('Dice positive:   %.4f\n',mean(results.DicePos_ref,'omitnan'));
fprintf('Dice negative:   %.4f\n',mean(results.DiceNeg_ref,'omitnan'));
fprintf('Sign changes:    %.2f %%\n',mean(results.SignChange_ref,'omitnan'));

fprintf('\nOFFSET DIFFERENCE\n');
fprintf('Pre-reference:  %.6f\n',mean(results.OffsetDiff_pre,'omitnan'));
fprintf('Post-reference: %.6f\n',mean(results.OffsetDiff_ref,'omitnan'));
