function s = calculate_arc_length(curve)
    % Calculate distance between adjacent points
    curve_diff = diff(curve,1,1);
    
    % Calculate the diff vectors 2-norm
    curve_diff_norm = vecnorm(curve_diff, 2, 2);
    
    % Calculate the accumulated distance at each point
    s = cumsum([0; curve_diff_norm]);
end

