% =========================================================================
% EXAMPLE 4: Hypercomplex Machine Learning (ELM Classifier)
% =========================================================================
% This script compares a standard Real-Valued network layer against an 
% alpha-beta Tessarine network layer using an Extreme Learning Machine (ELM) approach.

clear classes; clc; close all;
fprintf('--- Running Example 4: Hypercomplex vs Real-Valued Network ---\n\n');

% 1. Setup the environment
setabtessarine(-1, 1);

% 2. Define Network Parameters
num_samples = 4000;    % Number of training samples
num_features = 50;     % Number of input features per sample
num_targets = 10;      % Number of output classes/targets

fprintf('Generating synthetic multidimensional dataset...\n');
% Generate Hypercomplex training data (Features and Targets)
H_tess = abtrandn(num_samples, num_features);
T_tess = abtrandn(num_samples, num_targets);

% =========================================================================
% METHOD A: TRADITIONAL REAL-VALUED NETWORK (Unfolded approach)
% =========================================================================
% To process 4D data with standard real networks, dimensions are concatenated
H_real = [H_tess.A, H_tess.B, H_tess.C, H_tess.D]; 
T_real = [T_tess.A, T_tess.B, T_tess.C, T_tess.D];

fprintf('Training Real-Valued Network...\n');
tic;
% Solve the overdetermined system using standard real pseudo-inverse
W_real = H_real \ T_real; 
time_real = toc;

% Calculate number of independent scalar parameters
params_real = numel(W_real); 

% Calculate reconstruction error (Mean Squared Error)
Pred_real = H_real * W_real;
error_real = norm(T_real - Pred_real, 'fro') / num_samples;

% =========================================================================
% METHOD B: ALPHA-BETA TESSARINE NETWORK (Proposed Toolbox)
% =========================================================================
fprintf('Training alpha-beta Tessarine Network...\n');
tic;
% Solve natively using the overloaded backslash operator
W_tess = H_tess \ T_tess; 
time_tess = toc;

% Calculate number of independent scalar parameters (4 scalars per hypercomplex weight)
params_tess = num_features * num_targets * 4; 

% Calculate error
Pred_tess = H_tess * W_tess;
% Extract real components for a fair error comparison
diff_A = T_tess.A - Pred_tess.A; diff_B = T_tess.B - Pred_tess.B;
diff_C = T_tess.C - Pred_tess.C; diff_D = T_tess.D - Pred_tess.D;
error_tess = sqrt(sum(diff_A(:).^2 + diff_B(:).^2 + diff_C(:).^2 + diff_D(:).^2)) / num_samples;

% =========================================================================
% DISPLAY RESULTS FOR THE ARTICLE TABLE
% =========================================================================
fprintf('\n======================================================\n');
fprintf('                EXPERIMENTAL RESULTS\n');
fprintf('======================================================\n');
fprintf('1. STANDARD REAL-VALUED NETWORK:\n');
fprintf('   - Trainable Parameters: %d\n', params_real);
fprintf('   - Training Time:        %.4f seconds\n', time_real);
fprintf('   - Mean Squared Error:   %.4f\n\n', error_real);

fprintf('2. ALPHA-BETA TESSARINE NETWORK:\n');
fprintf('   - Trainable Parameters: %d\n', params_tess);
fprintf('   - Training Time:        %.4f seconds\n', time_tess);
fprintf('   - Mean Squared Error:   %.4f\n', error_tess);
fprintf('======================================================\n');
