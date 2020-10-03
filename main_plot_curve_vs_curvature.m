addpath(genpath('./helpers/'));
addpath(genpath('./helpers/curvature/'));
addpath(genpath('./helpers/linecurvature_version1b/'));

curves = [];

image_files_paths = enumerate_image_files('./images');
[images_count, ~] = size(image_files_paths);

current_curve_index = 1;
h = figure;
datetime_str = datestr(now,'mmmm_dd_yyyy_HH_MM_SS');
curves_folder = sprintf("./curve_vs_curvature_%s", datetime_str);
mkdir(curves_folder);

contour_levels = 10;
sigmas = [2,4,8,16,24,32,64];
min_points_count = 1500;
max_points_count = 3800;
max_extracted_curves = 1;
min_variance = 0.001;
min_mean = 0.008;
frame_length = 99;
order = 2;
smooth_iterations = 6;

for sigma_index=1:length(sigmas)
    sigma = sigmas(sigma_index);
    for i=1:images_count
        try
            Z = imread(image_files_paths(i).path);
        catch
            continue;
        end
        [~,dims] = size(size(Z));
        if(dims ~= 3)
            continue;
        end
        [~, ~, channels] = size(Z);
        if(channels > 1)
            Z = rgb2gray(Z);
        end
        Z = imgaussfilt(Z, sigma);

        [rows, cols, ~] = size(Z);
        [X,Y] = ndgrid(1:rows,1:cols);

        [M, ~] = contour(X, Y, Z, contour_levels);

        [M_rows, M_cols] = size(M);
        if(M_cols == 0)
            continue;
        end

        current_curves = get_closed_curves(M, min_points_count, max_points_count, max_extracted_curves);
        [current_curves_count, ~] = size(current_curves);

        extracted_curves = [];

        extracted_curves_count = 0;
        for j=1:current_curves_count 
            curve = current_curves(j);

            x = pad_array(curve.xdata, 3*frame_length, 'vertical');
            y = pad_array(curve.ydata, 3*frame_length, 'vertical');

            x_smoothed = smooth_array(x, frame_length, order, smooth_iterations);
            y_smoothed = smooth_array(y, frame_length, order, smooth_iterations);
            kappa = calculate_curvature(x_smoothed, y_smoothed);

            x_smoothed  = unpad_array(x_smoothed, 3*frame_length - 1);
            y_smoothed  = unpad_array(y_smoothed, 3*frame_length - 1);
            kappa  = unpad_array(kappa, 3*frame_length - 1);    

            kappa_var = var(kappa);
            kappa_mean = mean(kappa);

            if(abs(kappa_mean) < min_mean)
                continue;
            end

            if(abs(kappa_var) < min_variance)
                continue;
            end

            subplot(2,1,1);
            plot(x_smoothed, y_smoothed);

            subplot(2,1,2);
            indices = transpose((1:length(kappa)));
            plot(indices, kappa);

            saveas(h, sprintf('%s/curve_%d.png', curves_folder, current_curve_index));

            smoothed_curve = struct('numel', length(x_smoothed), 'xdata', x_smoothed, 'ydata', y_smoothed);

            current_curve_index = current_curve_index + 1;
            extracted_curves_count = extracted_curves_count + 1;
            extracted_curves = [extracted_curves; smoothed_curve];
        end

        curves = [curves; extracted_curves];    
        [curves_count, ~] = size(curves);
        fprintf("%d extracted at iteration %d; curves count = %d\n", extracted_curves_count, i, curves_count);
    end
end

save(sprintf('%s/curves_%s.mat', curves_folder, datetime_str), 'curves', 'contour_levels', 'sigmas', 'min_points_count', 'max_points_count', 'min_variance', 'min_mean', 'images_count', 'frame_length', 'order', 'smooth_iterations');