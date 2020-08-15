% https://www.mathworks.com/matlabcentral/answers/397385-how-to-sort-a-structure-array-based-on-a-specific-field
% https://blogs.mathworks.com/pick/2010/09/17/sorting-structure-arrays-based-on-fields/

function [curves] = get_closed_curves(M, min_points, max_points, max_extracted_curves) 
    curves = [];
    contours = contour_data(M);
    closed_contours = [];
    for i=1:length(contours)
        contour = contours(i);
        if(contour.isopen == 0)
            contour = rmfield(contour,'isopen');
            contour = rmfield(contour,'level');
            closed_contours = [closed_contours; contour];
        end
    end
    
    [closed_contours_count, ~] = size(closed_contours);
    if(closed_contours_count == 0)
        return;
    end
    
    contours = closed_contours;
    
    contours_fields = fieldnames(contours);
    contours_cell = struct2cell(contours);
    sz = size(contours_cell);
    
    % Convert to a matrix
    contours_cell = reshape(contours_cell, sz(1), []);

    % Make each field a column
    contours_cell = contours_cell';

    % Sort by first field "name"
    contours_cell = sortrows(contours_cell, 1, 'descend');
    
    % Convert to Struct
    contours_cell = reshape(contours_cell', sz);
    contours_sorted = cell2struct(contours_cell, contours_fields, 1);
    
    [contours_count, ~] = size(contours_sorted);
    for i=1:contours_count
        % if(contours_sorted(i).numel >= min_points && contours_sorted(i).numel <= max_points && i <= max_extracted_curves)
        if(contours_sorted(i).numel >= min_points)
            curves = [curves; contours_sorted(i)];
        end
    end

end

