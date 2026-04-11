function [alpha, beta] = getabtessarine()
% GETABTESSARINE Retrieves the global alpha and beta parameters.
    
    alpha = getappdata(0, 'Tessarine_Alpha');
    beta  = getappdata(0, 'Tessarine_Beta');
    
    if isempty(alpha) || isempty(beta)
        error('abtessarine:NotConfigured', ...
              'Parameters not set. Run setabtessarine(alpha, beta) first.');
    end
end