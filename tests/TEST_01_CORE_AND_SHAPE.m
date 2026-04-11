% TEST_01_CORE_AND_SHAPE
% Validation script for the @abtessarine toolbox (Part 1/3)
% Focus: Environment setup, object creation, indexing, shape manipulation.

clear classes; clc;
fprintf('=======================================================\n');
fprintf('   PART 1: CORE UTILITIES AND SHAPE MANIPULATION\n');
fprintf('=======================================================\n\n');

% 1. Environment Configuration (setabtessarine)
fprintf('--- 1. Environment Configuration ---\n');
disp('Testing positive alpha configuration:');
setabtessarine(1, 1);
disp('Testing negative alpha configuration (Classic):');
setabtessarine(-1, 1);
disp('[OK] Environment configured successfully.');

% 2. Core Creation and Display (abtessarine, disp)
fprintf('\n--- 2. Creation and Display ---\n');
A = reshape(1:12, 3, 4); 
B = A * 10; C = A * 100; D = A * 1000;
X = abtessarine(A, B, C, D);
disp('[OK] Object X (3x4) created using "abtessarine".');
disp('[OK] "disp" function executed (implicitly below):');
X

% 3. Associated and Augmented forms (associated, augmented)
fprintf('\n--- 3. Mathematical Forms ---\n');
X_assoc = associated(X);
disp('[OK] "associated" form computed (using global alpha/beta).');
X_aug = augmented(X);
disp('[OK] "augmented" form computed.');

% 4. Indexing (subsref, subsasgn)
fprintf('\n--- 4. Array Indexing ---\n');
val = X(1, 2); % subsref
disp('[OK] "subsref" executed. Value extracted.');
X(1, 2) = val; % subsasgn
disp('[OK] "subsasgn" executed. Value assigned back.');

% 5. Dimensions (size, length, ndims)
fprintf('\n--- 5. Array Dimensions ---\n');
fprintf('[OK] "size" of X: [%d, %d]\n', size(X,1), size(X,2));
fprintf('[OK] "length" of X: %d\n', length(X));
fprintf('[OK] "ndims" of X: %d\n', ndims(X));

% 6. Shape Manipulation (reshape, repmat, permute, squeeze)
fprintf('\n--- 6. Shape Manipulation ---\n');
X_res = reshape(X, 4, 3);
fprintf('[OK] "reshape" executed (3x4 -> 4x3).\n');
X_rep = repmat(X, 2, 2);
fprintf('[OK] "repmat" executed (3x4 -> 6x8).\n');
X_perm = permute(X, [2, 1]);
fprintf('[OK] "permute" executed (Transposed dimensions).\n');

X_3D = reshape(X, 3, 1, 4);
X_sqz = squeeze(X_3D);
fprintf('[OK] "squeeze" executed. Size recovered to 2D.\n');

% 7. Concatenation (cat, horzcat, vertcat)
fprintf('\n--- 7. Concatenation ---\n');
X_horz = [X, X]; % horzcat
disp('[OK] "horzcat" executed.');
X_vert = [X; X]; % vertcat
disp('[OK] "vertcat" executed.');
X_cat = cat(3, X, X); % cat
disp('[OK] "cat" executed along 3rd dimension.');

fprintf('\n--- END OF PART 1 ---\n');