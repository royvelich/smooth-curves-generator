function smoothed_curve = smooth_curve(curve, frame_length, order, iterations)
    padding = 3*frame_length;
    x = curve(:, 1);
    y = curve(:, 2);
    x_padded = pad_array(x, padding, 'vertical');
    y_padded = pad_array(y, padding, 'vertical');
    x_smoothed = smooth_array(x_padded, frame_length, order, iterations);
    y_smoothed = smooth_array(y_padded, frame_length, order, iterations);
    x_smoothed_unpadded = unpad_array(x_smoothed, padding);
    y_smoothed_unpadded = unpad_array(y_smoothed, padding);
    smoothed_curve = zeros(size(curve));
    smoothed_curve(:, 1) = x_smoothed_unpadded;
    smoothed_curve(:, 2) = y_smoothed_unpadded;
end
