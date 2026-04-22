% =========================================================================
% EXAMPLE 1: Color Image Compression via Hypercomplex SVD
% =========================================================================
% This script demonstrates the application of the abtessarine_Toolbox for
% multidimensional signal processing. It computes the SVD of a color image
% preserving cross-channel correlation.

clear classes; clc; close all;
fprintf('--- Running Example 1: Hypercomplex SVD Compression ---\n');

% 1. Set the classical tessarine environment (alpha = -1, beta = 1)
setabtessarine(-1, 1);

% 2. Load and prepare the image
disp('Loading image and mapping to hypercomplex space...');
img_raw = imread('peppers.png');
img = imresize(img_raw, [128, 128]); % Resize for fast demonstration
img_double = double(img) / 255;      % Normalize to [0, 1]

% Map RGB and Luminance to the four hypercomplex branches
R = img_double(:,:,1);
G = img_double(:,:,2);
B = img_double(:,:,3);
L = rgb2gray(img_double); 

Img_Tensor = abtessarine(R, G, B, L);

% 3. Compute the full Hypercomplex SVD
disp('Computing full SVD (this may take a few seconds)...');
[U, S, V] = svd(Img_Tensor);

% 4. Evaluate different levels of compression
k_values = [10, 30, 60]; % Number of singular values to keep
figure('Name', 'Hypercomplex SVD Image Compression', 'Position', [100, 100, 1000, 350]);

% Plot original
subplot(1, length(k_values)+1, 1);
imshow(img_double);
title('Original Image');

for idx = 1:length(k_values)
    k = k_values(idx);
    S_comp = S;
    
    % Truncate lower singular values across all dimensions
    S_comp.A(k+1:end, :) = 0; S_comp.B(k+1:end, :) = 0;
    S_comp.C(k+1:end, :) = 0; S_comp.D(k+1:end, :) = 0;
    
    % Reconstruct the image
    Img_Recon = U * S_comp * V';
    
    % Extract RGB channels for visualization
    img_out = cat(3, Img_Recon.A, Img_Recon.B, Img_Recon.C);
    img_out = max(0, min(1, img_out)); % Clip to valid range [0,1]
    
    % Calculate Frobenius error
    err = norm(Img_Tensor - Img_Recon, 'fro');
    fprintf('Compression with k=%2d -> Error: %8.2f\n', k, err);
    
    % Plot reconstructed image
    subplot(1, length(k_values)+1, idx+1);
    imshow(img_out);
    title(sprintf('k = %d\nErr = %.1f', k, err));
end

disp('Example 1 completed successfully.');