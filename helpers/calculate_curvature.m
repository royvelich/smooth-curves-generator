function k = calculate_curvature(x, y)
    dx_dt = gradient(x);
    dy_dt = gradient(y);
    d2x_dt2 = gradient(dx_dt);
    d2y_dt2 = gradient(dy_dt);
    k = (d2x_dt2 .* dy_dt - dx_dt .* d2y_dt2) ./ (dx_dt .* dx_dt + dy_dt .* dy_dt) .^ 1.5;
end

