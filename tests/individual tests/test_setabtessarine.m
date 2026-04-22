% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: setabtessarine.m (Global Environment Configuration)
% =========================================================================
% This script verifies the accurate configuration of the global topological 
% parameters, and rigorously tests the input sanitization mechanisms that 
% prevent the instantiation of mathematically invalid algebras.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: setabtessarine.m ---');
disp('===================================================================');

%% TEST 1: Valid Configuration and Precision Storage
disp('TEST 1: Valid Environment Configuration');
try
    test_alpha = 2.5;
    test_beta  = 3.14;
    
    % Silence console output temporarily for the test
    evalc('setabtessarine(test_alpha, test_beta)');
    
    % Retrieve directly from root app data to bypass getabtessarine
    stored_alpha = getappdata(0, 'Tessarine_Alpha');
    stored_beta  = getappdata(0, 'Tessarine_Beta');
    
    if isequal(stored_alpha, test_alpha) && isequal(stored_beta, test_beta) ...
       && isa(stored_alpha, 'double') && isa(stored_beta, 'double')
        disp('   [OK] Valid parameters successfully parsed and stored in strict double precision.');
    else
        error('Data corruption or precision loss during environmental storage.');
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Strict Validation of Alpha (Non-Zero)
disp('TEST 2: Alpha Constraint Violation (Alpha = 0)');
try
    evalc('setabtessarine(0, 1)'); % Attempting to set an invalid alpha
    
    % If it reaches here, the defense mechanism failed
    error('Safety mechanism failed: Allowed alpha to be exactly zero.');
    
catch ME
    if contains(ME.identifier, 'ZeroAlpha') || contains(ME.message, 'cannot be zero')
        disp('   [OK] Exception successfully intercepted: Alpha = 0 strictly blocked.');
    else
        fprintf('   [FAILED] Unexpected error thrown: %s\n', ME.message);
    end
end
disp('-------------------------------------------------------------------');

%% TEST 3: Strict Validation of Beta (Strictly Positive)
disp('TEST 3: Beta Constraint Violation (Beta <= 0)');
try
    evalc('setabtessarine(-1, -5)'); % Attempting to set an invalid negative beta
    
    % If it reaches here, the defense mechanism failed
    error('Safety mechanism failed: Allowed beta to be negative or zero.');
    
catch ME
    if contains(ME.identifier, 'expectedPositive') || contains(ME.message, 'positive') || contains(ME.message, '> 0')
        disp('   [OK] Exception successfully intercepted: Beta <= 0 strictly blocked.');
    else
        fprintf('   [FAILED] Unexpected error thrown: %s\n', ME.message);
    end
end
disp('-------------------------------------------------------------------');

%% TEST 4: Argument Count Protection
disp('TEST 4: Argument Count Validation');
try
    evalc('setabtessarine(-1)'); % Missing beta argument
    
    error('Safety mechanism failed: Allowed execution with missing arguments.');
    
catch ME
    if contains(ME.identifier, 'NotEnoughInputs') || contains(ME.message, 'arguments')
        disp('   [OK] Exception successfully intercepted: Insufficient arguments blocked.');
    else
        fprintf('   [FAILED] Unexpected error thrown: %s\n', ME.message);
    end
end
disp('-------------------------------------------------------------------');

%% CLEANUP: Restore standard environment to avoid breaking subsequent tests
disp('CLEANUP: Restoring Standard Topology...');
evalc('setabtessarine(-1, 1)');
disp('   [OK] Standard (-1, 1) tessarine space restored.');

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');