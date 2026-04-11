function disp(obj)
% DISP Overloads the display function for the gabtessarine class.
%
%   Displays the gabtessarine object using a high-readability format. 
%   - For scalars: Shows the full 8-dimensional algebraic expansion using 
%     the Greek symbol 'ε' and optimized sign handling (no "+ -").
%   - For matrices: Displays paired real/ε components horizontally.

%   See also SUBSREF, SUBSASGN.

    % --- 1. HANDLING OF OBJECT ARRAYS ---
    if ~isscalar(obj)
        sz = size(obj);
        dimStr = strjoin(arrayfun(@num2str, sz, 'UniformOutput', false), 'x');
        fprintf('  %s gabtessarine array.\n\n', dimStr);
        return;
    end

    % --- 2. HANDLING OF EMPTY OBJECTS ---
    if isempty(obj.A1)
        fprintf('  Empty gabtessarine object.\n\n');
        return;
    end

    % --- 3. SCALAR 1x1 OBJECT DISPLAY (Algebraic format) ---
    if isscalar(obj.A1)
        fprintf('  gabtessarine scalar:\n\n');
        
        % Data vector and its corresponding unit labels
        vals = [obj.A1, obj.A2, obj.B1, obj.B2, obj.C1, obj.C2, obj.D1, obj.D2];
        units = {'', 'ε', 'i', 'εi', 'j', 'εj', 'k', 'εk'};
        
        % Start with the first element
        out = num2str(vals(1));
        
        % Efficient loop for the remaining 7 dimensions with sign control
        for i = 2:8
            v = vals(i);
            if v >= 0
                out = [out, ' + ', num2str(v), units{i}]; %#ok<AGROW>
            else
                out = [out, ' - ', num2str(abs(v)), units{i}]; %#ok<AGROW>
            end
        end
        
        fprintf('    %s\n\n', out);
        return;
    end

    % --- 4. MATRIX OBJECT DISPLAY (Horizontal Paired Components) ---
    fprintf('  gabtessarine matrix:\n\n');
    
    % Group dual components horizontally for visual correlation
    fprintf('    [ Component A1 (Real)   |   Component A2 (ε) ]:\n');
    disp([obj.A1, obj.A2]);
    
    fprintf('    [ Component B1 (i)      |   Component B2 (εi) ]:\n');
    disp([obj.B1, obj.B2]);
    
    fprintf('    [ Component C1 (j)      |   Component C2 (εj) ]:\n');
    disp([obj.C1, obj.C2]);
    
    fprintf('    [ Component D1 (k)      |   Component D2 (εk) ]:\n');
    disp([obj.D1, obj.D2]);
    
end