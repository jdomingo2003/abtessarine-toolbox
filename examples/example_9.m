% =========================================================================
% abtessarine_Toolbox - Example 9
% Application: High-Resolution Color Image Denoising via Hypercomplex TSVD
% =========================================================================
% This script demonstrates a non-iterative application of the toolbox's 
% native SVD. It removes additive Gaussian noise from a high-resolution 
% synthetic vibrant color test image generated natively in MATLAB.
% =========================================================================

clear; clc; close all;

disp('===================================================================');
disp('  Application: High-Res Vibrant Image Denoising (TSVD)             ');
disp('===================================================================');

% -------------------------------------------------------------------------
% 1. Generate High-Res Vibrant Mathematical Test Image
% -------------------------------------------------------------------------
disp('1. Generating 512x512 vibrant color test image...');

% N=512 for high-resolution processing
N = 512; 
[X, Y] = meshgrid(linspace(-5, 5, N), linspace(-5, 5, N));

% Generate a complex mathematical pattern with varying spatial frequencies
% This creates intricate shapes that are mathematically low-rank.
Z = sin(X.^2 + Y) + cos(X + Y.^2) + sin(X.*Y/2) + cos(sqrt(X.^2 + Y.^2));

% Normalize between 0 and 1
Z_norm = (Z - min(Z(:))) / (max(Z(:)) - min(Z(:)));

% Convert to an RGB image using a high-contrast colormap ('jet')
% This provides a vast array of distinct colors across the spectrum.
I_rgb = ind2rgb(round(Z_norm * 255) + 1, jet(256));

R = I_rgb(:,:,1);
G = I_rgb(:,:,2);
B = I_rgb(:,:,3);

% -------------------------------------------------------------------------
% 2. Add Artificial Gaussian Noise (Sensor Noise Simulation)
% -------------------------------------------------------------------------
disp('2. Adding additive Gaussian noise...');
noise_level = 0.10; % Variance of the noise

% Adding noise independently to each channel
R_noisy = R + noise_level * randn(N, N);
G_noisy = G + noise_level * randn(N, N);
B_noisy = B + noise_level * randn(N, N);

I_noisy = cat(3, R_noisy, G_noisy, B_noisy);

% -------------------------------------------------------------------------
% 3. Hypercomplex Denoising (Truncated SVD)
% -------------------------------------------------------------------------
disp('3. Performing Native Hypercomplex TSVD...');

% Set topological parameters (alpha = -1, beta = 1)
setabtessarine(-1, 1);

% Embed noisy RGB channels into a pure hypercomplex tessarine
Z_noisy = abtessarine(zeros(N), R_noisy, G_noisy, B_noisy);

% Since the image is mathematically smooth (composed of sin/cos), a low 
% rank captures almost 100% of the structural color patterns while 
% perfectly discarding the high-frequency random noise.
rank_k = 40; % Sweeter spot for this complex pattern

tic;
% 3A. Compute Native Hypercomplex SVD (Single pass, HPC capability)
[U, S, V] = svd(Z_noisy);

% 3B. Hard thresholding (Truncate singular values to discard noise)
S_trunc = abtzeros(N, N);
for i = 1:rank_k
    S_trunc(i,i) = S(i,i);
end

% 3C. Reconstruct the denoised image natively
Z_denoised = U * S_trunc * V';
elapsed_time = toc;

fprintf('   -> Denoising of 512x512 image completed natively in %.2f seconds.\n', elapsed_time);

% Extract and clamp channels for visualization
I_denoised = cat(3, max(0, min(1, Z_denoised.B)), ...
                    max(0, min(1, Z_denoised.C)), ...
                    max(0, min(1, Z_denoised.D)));

% -------------------------------------------------------------------------
% 4. Display Results
% -------------------------------------------------------------------------
disp('4. Generating figure...');
figure('Name', 'High-Res Vibrant Denoising Results', 'Color', 'w', 'Position', [100 100 1400 450]);

subplot(1, 3, 1);
imshow(I_rgb);
title('Original Vibrant Image (512x512)', 'FontSize', 13, 'FontWeight', 'bold');

subplot(1, 3, 2);
imshow(max(0, min(1, I_noisy)));
title(sprintf('Noisy Image (\\sigma = %.2f)', noise_level), 'FontSize', 13, 'FontWeight', 'bold');

subplot(1, 3, 3);
imshow(I_denoised);
title(sprintf('Denoised (TSVD, Rank: %d)', rank_k), 'FontSize', 13, 'FontWeight', 'bold');

disp('-------------------------------------------------------------------');