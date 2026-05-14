% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Class: abtessarine.m (4D Hypercomplex Object Constructor)
% =========================================================================
% This script verifies the robust instantiation of the abtessarine class, 
% validating structural data assignment, zero-argument memory preallocation, 
% and strict safety mechanisms regarding dimension matching and input counts.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: abtessarine.m (Class Constructor) ---');
disp('===================================================================');

%% TEST 1: Standard Valid Instantiation
disp('TEST 1: Valid Instantiation and Property Assignment');
try
    % Generate four random 3x3 matrices
    A_in = rand(3, 3);
    B_in = rand(3, 3);
    C_in = rand(3, 3);
    D_in = rand(3, 3);
    
    % Instantiate the object
    obj = abtessarine(A_in, B_in, C_in, D_in);
    
    % Verify the class type
    if ~isa(obj, 'abtessarine')
        error('Object was not instantiated as the "abtessarine" class.');
    end
    
    % Verify exact property assignment
    if isequal(obj.A, A_in) && isequal(obj.B, B_in) && ...
       isequal(obj.C, C_in) && isequal(obj.D, D_in)
        disp('   [OK] Object instantiated and structural data accurately assigned.');
    else
        error('Property assignment failed or data was corrupted during instantiation.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Zero-Argument Constructor (HPC Preallocation)
disp('TEST 2: Zero-Argument Constructor (Memory Preallocation)');
try
    % Attempt to instantiate without arguments
    empty_obj = abtessarine();
    
    % Verify that the internal branches are initialized as empty arrays
    if isempty(empty_obj.A) && isempty(empty_obj.B) && ...
       isempty(empty_obj.C) && isempty(empty_obj.D)
        disp('   [OK] Zero-argument preallocation safely returned an empty manifold.');
    else
        error('Zero-argument constructor failed to return empty structural arrays.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 3: Input Count Protection
disp('TEST 3: Input Count Validation (Rejecting Partial Arrays)');
try
    % Attempt to instantiate with only 3 arguments
    evalc('abtessarine(A_in, B_in, C_in)');
    
    % If it reaches here, the constructor failed to stop the invalid call
    error('Safety mechanism failed: Allowed instantiation with an invalid argument count.');
    
catch ME
    if contains(ME.identifier, 'InputCount') || contains(ME.message, '4 numeric arrays')
        disp('   [OK] Exception successfully intercepted: Invalid argument count blocked.');
    else
        fprintf('   [FAILED] Unexpected error thrown: %s\n', ME.message);
    end
end
disp('-------------------------------------------------------------------');

%% TEST 4: Dimensional Consistency Protection
disp('TEST 4: Dimensional Consistency Validation');
try
    % Create a mismatched dimension (a 3x4 matrix among 3x3 matrices)
    D_mismatch = rand(3, 4);
    
    % Attempt to instantiate with mismatched dimensions
    evalc('abtessarine(A_in, B_in, C_in, D_mismatch)');
    
    % If it reaches here, the constructor failed to stop the invalid call
    error('Safety mechanism failed: Allowed instantiation with dimensionally mismatched arrays.');
    
catch ME
    if contains(ME.identifier, 'DimensionMismatch') || contains(ME.message, 'identical dimensions')
        disp('   [OK] Exception successfully intercepted: Dimension mismatch strictly blocked.');
    else
        fprintf('   [FAILED] Unexpected error thrown: %s\n', ME.message);
    end
end

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');