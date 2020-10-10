function kappa = calculate_curvature(curve, frame_length)
    padding = 3*frame_length;
    
    % Extract x and y coordinates
    x = curve(:, 1);
    y = curve(:, 2);

    x_padded = pad_array(x, padding, 'vertical');
    y_padded = pad_array(y, padding, 'vertical');
    
    % Calculate first partial derivatives
    dx_dt = gradient(x_padded);
    dy_dt = gradient(y_padded);
    
    % Calculate second partrial derivatives
    d2x_dt2 = gradient(dx_dt);
    d2y_dt2 = gradient(dy_dt);
    
    % Calculate curvature
    kappa = (d2x_dt2 .* dy_dt - dx_dt .* d2y_dt2) ./ (dx_dt .* dx_dt + dy_dt .* dy_dt) .^ 1.5;
    kappa  = unpad_array(kappa, padding);
end

