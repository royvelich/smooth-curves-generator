function evolved_curve = evolve_curve(curve, evolution_iterations, evolution_dt, smoothing_frame_length, smoothing_order, smoothing_iterations)
%     h = figure;
    padding = 3;
    evolved_curve = curve;
    for i=1:evolution_iterations
        
%         plot(evolved_curve(:,1), evolved_curve(:,2));

%         hold on
        
        kappa = calculate_curvature(evolved_curve, padding);

        x = evolved_curve(:, 1);
        y = evolved_curve(:, 2);

        x_padded = pad_array(x, padding, 'vertical');
        y_padded = pad_array(y, padding, 'vertical');

        % Calculate first partial derivatives
        dx_dt = gradient(x_padded);
        dy_dt = gradient(y_padded);

        dx_dt  = unpad_array(dx_dt, padding);
        dy_dt  = unpad_array(dy_dt, padding);

        normal = zeros(size(evolved_curve));
        
        normal(:, 1) = dy_dt;
        normal(:, 2) = -dx_dt;
        normal = normr(normal);

%         quiver(evolved_curve(:,1), evolved_curve(:,2), normal_big(:,1), normal_big(:,2), 0);
        
        delta = kappa .* normal;
        evolved_curve = evolved_curve + evolution_dt * delta;
        evolved_curve = smooth_curve(evolved_curve, smoothing_frame_length, smoothing_order, smoothing_iterations);
        
%         hold off
    end
end

