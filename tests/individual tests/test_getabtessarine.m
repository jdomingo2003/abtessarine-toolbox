% =========================================================================
% abtessarine_Toolbox - Unit Test
% Target Function: getabtessarine.m (Global Environment Retrieval)
% =========================================================================
% This script verifies the accurate retrieval of topological parameters 
% from the root application data, and strictly tests the safety mechanisms 
% that prevent execution in uninitialized environments.
% =========================================================================

clear; clc;

disp('===================================================================');
disp('--- STARTING UNIT TEST: getabtessarine.m ---');
disp('===================================================================');

%% TEST 1: Accurate State Retrieval
disp('TEST 1: Parameter Storage and Retrieval Verification');
try
    % Set unique floating-point topological parameters
    expected_alpha = -3.14159;
    expected_beta  = 2.71828;
    
    % Manually inject into the root environment (simulating setabtessarine)
    setappdata(0, 'Tessarine_Alpha', expected_alpha);
    setappdata(0, 'Tessarine_Beta', expected_beta);
    
    % Attempt retrieval
    [a, b] = getabtessarine();
    
    % Verify exact floating-point match
    if (a == expected_alpha) && (b == expected_beta)
        disp('   [OK] Topological parameters correctly retrieved from the global environment.');
    else
        error('Data corruption during retrieval. Expected (%g, %g), Got (%g, %g).', ...
              expected_alpha, expected_beta, a, b);
    end
    
catch ME
    fprintf('   [FAILED] %s\n', ME.message);
end
disp('-------------------------------------------------------------------');

%% TEST 2: Uninitialized Environment Safety (Error Handling)
disp('TEST 2: Unconfigured Environment Exception Handling');
try
    % Purge the global parameters to simulate a fresh, uninitialized MATLAB session
    if isappdata(0, 'Tessarine_Alpha'), rmappdata(0, 'Tessarine_Alpha'); end
    if isappdata(0, 'Tessarine_Beta'),  rmappdata(0, 'Tessarine_Beta'); end
    
    % Attempt retrieval (This MUST fail)
    [a, b] = getabtessarine();
    
    % If we reach this line, the safety mechanism failed
    error('Safety mechanism failed: Function returned data from a purged environment.');
    
catch ME
    % Verify that it failed for the correct reason
    if contains(ME.identifier, 'NotConfigured')
        disp('   [OK] Exception successfully intercepted: Uninitialized environment blocked.');
    else
        fprintf('   [FAILED] Unexpected error thrown: %s\n', ME.identifier);
    end
end
disp('-------------------------------------------------------------------');

%% CLEANUP: Restore standard environment to avoid breaking subsequent tests
disp('CLEANUP: Restoring Standard Topology...');
setappdata(0, 'Tessarine_Alpha', -1);
setappdata(0, 'Tessarine_Beta', 1);
disp('   [OK] Standard (-1, 1) tessarine space restored.');

disp('===================================================================');
disp('--- TEST SUITE COMPLETED SUCCESSFULLY ---');
disp('===================================================================');