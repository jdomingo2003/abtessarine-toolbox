% =========================================================================
% abtessarine_Toolbox - Example 8
% Application: Color Image In-painting via Hypercomplex SVT
% =========================================================================
% This script demonstrates how the native SVD capabilities of the toolbox
% can be used to elegantly reconstruct a corrupted standard test image 
% (the classic "mandrill") using a Low-Rank Singular Value Thresholding 
% (SVT) approach.
% =========================================================================

clear; clc; close all;

disp('===================================================================');
disp('  Application: Hypercomplex Color Image In-painting (Mandrill)     ');
disp('===================================================================');

% -------------------------------------------------------------------------
% 1. Load Standard Test Image (Mandrill)
% -------------------------------------------------------------------------
disp('1. Loading standard test image and embedding into tessarine...');

load mandrill; 
I_rgb = im2double(ind2rgb(X, map));
I_rgb = imresize(I_rgb, [256, 256]); % Resize for fast processing

R = I_rgb(:,:,1);
G = I_rgb(:,:,2);
B = I_rgb(:,:,3);

% Set topological parameters (alpha = -1, beta = 1)
setabtessarine(-1, 1);

% Embed RGB channels into a pure hypercomplex tessarine (Real part A = 0)
Z_orig = abtessarine(zeros(256), R, G, B);

% -------------------------------------------------------------------------
% 2. Corrupt the Image (Simulate Missing Data)
% -------------------------------------------------------------------------
disp('2. Simulating 35% missing data (corruption)...');
missing_rate = 0.35; % 35% es ideal para que el mandril se reconstruya nítido
Mask = rand(256, 256) > missing_rate; % 1=known, 0=missing

Z_corrupted = Z_orig;
Z_corrupted.B = Z_corrupted.B .* Mask;
Z_corrupted.C = Z_corrupted.C .* Mask;
Z_corrupted.D = Z_corrupted.D .* Mask;

I_corrupted = cat(3, Z_corrupted.B, Z_corrupted.C, Z_corrupted.D);

% -------------------------------------------------------------------------
% 3. Iterative Singular Value Thresholding (SVT)
% -------------------------------------------------------------------------
disp('3. Starting Native Hypercomplex SVT Matrix Completion...');
Z_recovered = Z_corrupted;

% The "Sweet Spot" for high-frequency natural images
iterations = 50;  
rank_k = 60;     

tic;
for iter = 1:iterations
    % Native Hypercomplex SVD 
    [U, S, V] = svd(Z_recovered);
    
    % Truncate Singular Values (Low-Rank regularization)
    S_trunc = abtzeros(256, 256);
    for i = 1:rank_k
        S_trunc(i,i) = S(i,i);
    end
    
    % Reconstruct Low-Rank Matrix natively
    Z_low = U * S_trunc * V';
    
    % Data Consistency Update
    Z_recovered.B = Z_orig.B .* Mask + Z_low.B .* (~Mask);
    Z_recovered.C = Z_orig.C .* Mask + Z_low.C .* (~Mask);
    Z_recovered.D = Z_orig.D .* Mask + Z_low.D .* (~Mask);
    
    if mod(iter, 10) == 0
        fprintf('   Iteration %d/%d completed...\n', iter, iterations);
    end
end
elapsed_time = toc;
fprintf('   -> In-painting completed natively in %.2f seconds.\n', elapsed_time);

I_recovered = cat(3, max(0, min(1, Z_recovered.B)), ...
                     max(0, min(1, Z_recovered.C)), ...
                     max(0, min(1, Z_recovered.D)));

% -------------------------------------------------------------------------
% 4. Display Results
% -------------------------------------------------------------------------
disp('4. Generating figure...');
figure('Name', 'Color Image In-painting Results', 'Color', 'w', 'Position', [100 100 1200 400]);

subplot(1, 3, 1);
imshow(I_rgb);
title('Original Image (Mandrill)', 'FontSize', 14, 'FontWeight', 'bold');

subplot(1, 3, 2);
imshow(I_corrupted);
title(sprintf('Corrupted (%.0f%% Missing)', missing_rate*100), 'FontSize', 14, 'FontWeight', 'bold');

subplot(1, 3, 3);
imshow(I_recovered);
title(sprintf('Recovered (Iter: %d, Rank: %d)', iterations, rank_k), 'FontSize', 14, 'FontWeight', 'bold');

disp('-------------------------------------------------------------------');