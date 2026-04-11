function disp(obj)
% DISP Overloads the display method for the abtessarine class.
%
%   Displays the object instance. If the internal components evaluate to 
%   1x1 scalars, it outputs the linear algebraic equation. If they are 
%   matrices, it outputs the four component arrays in a structured format.
%
%   Designed to minimize operational overhead while providing a clear 
%   command-line interface.

%   See also SUBSREF, SUBSASGN.

    % --- 1. MULTIDIMENSIONAL ARRAY HANDLING ---
    % When rendering an array of abtessarine objects, display the dimensional 
    % signature rather than saturating the console with matrix streams.
    if ~isscalar(obj)
        sz = size(obj);
        dimStr = sprintf('%dx', sz);
        dimStr(end) = ''; % Remove the trailing 'x' character
        fprintf('  %s array of abtessarine objects.\n\n', dimStr);
        return;
    end
    
    % --- 2. EMPTY OBJECT HANDLING ---
    % Safely process uninitialized memory allocations.
    if isempty(obj.A)
        fprintf('  Empty abtessarine object.\n\n');
        return;
    end
    
    % --- 3. SCALAR REPRESENTATION (Algebraic Format) ---
    % Evaluates and formats scalar components into a clean algebraic equation, 
    % automatically resolving sign overlaps (e.g., preventing "+ -").
    if isscalar(obj.A)
        fprintf('  abtessarine scalar:\n\n');
        
        % Sign resolution logic
        signB = '+'; valB = obj.B; if valB < 0, signB = '-'; valB = abs(valB); end
        signC = '+'; valC = obj.C; if valC < 0, signC = '-'; valC = abs(valC); end
        signD = '+'; valD = obj.D; if valD < 0, signD = '-'; valD = abs(valD); end
        
        fprintf('    %g %s %g*i %s %g*j %s %g*k\n\n', ...
                obj.A, signB, valB, signC, valC, signD, valD);
        return;
    end
    
    % --- 4. MATRIX REPRESENTATION DISPLAY ---
    % Leverages MATLAB's native disp() functionality to render matrices 
    % respecting the user's global numeric formatting preferences.
    fprintf('  abtessarine matrix:\n\n');
    
    fprintf('    Component A (Real):\n');
    disp(obj.A);
    
    fprintf('    Component B (i):\n');
    disp(obj.B);
    
    fprintf('    Component C (j):\n');
    disp(obj.C);
    
    fprintf('    Component D (k):\n');
    disp(obj.D);
    
end