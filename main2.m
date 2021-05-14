addpath(genpath('./helpers/'));
addpath(genpath('./helpers/curvature/'));
addpath(genpath('./helpers/linecurvature_version1b/'));

image_files_paths = enumerate_image_files('./images_splitted/3');
[images_count, ~] = size(image_files_paths);

h = figure;
datetime_str = datestr(now,'mmmm_dd_yyyy_HH_MM_SS');
curves_folder = sprintf("./curves_%s", datetime_str);
mkdir(curves_folder);

contour_levels = 1;
sigmas = [4];
min_points_count = 1000;
max_points_count = 4000;
max_extracted_curves = 1;
min_variance = 0.003;
min_mean = 0.008;

% Smoothing
smoothing_frame_length = 99;
smoothing_order = 2;
smoothing_iterations = 6;

% Curvature flow
evolution_iterations = 6;
evolution_dt = 1e-1;

max_abs_curvature = 6;

for sigma_index=1:length(sigmas)
    curves = [];
    current_curve_index = 1;
    sigma = sigmas(sigma_index);
    sigma_curves_folder = sprintf("%s/%d", curves_folder, sigma);
    mkdir(sigma_curves_folder);
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
            curve_object = current_curves(j);
            curve = horzcat(curve_object.xdata, curve_object.ydata);
            smoothed_curve = smooth_curve(curve, smoothing_frame_length, smoothing_order, smoothing_iterations);
            arc_length = calculate_arc_length(smoothed_curve);
            kappa = calculate_curvature(smoothed_curve, smoothing_frame_length);
            evolved_curve = evolve_curve(smoothed_curve, evolution_iterations, log2(sigma) * evolution_dt, smoothing_frame_length, smoothing_order, smoothing_iterations);
            
            kappa_var = var(kappa);
            kappa_mean = mean(kappa);
            kappa_min = min(kappa);
            kappa_max = max(kappa);

            if(abs(kappa_mean) < min_mean)
                continue;
            end

            if(abs(kappa_var) < min_variance)
                continue;
            end

            if(abs(kappa_min) > max_abs_curvature)
                continue;
            end
            
            if(abs(kappa_max) > max_abs_curvature)
                continue;
            end
            
            subplot(3,1,1);
            plot(smoothed_curve(:,1), smoothed_curve(:,2));
            
            subplot(3,1,2);
            indices = transpose((1:length(kappa)));
            plot(indices, kappa);
            
            subplot(3,1,3);
            plot(evolved_curve(:,1), evolved_curve(:,2));

            saveas(h, sprintf('%s/curve_%d.png', sigma_curves_folder, current_curve_index));

            smoothed_curve_struct = struct('curve', smoothed_curve, 'arc_length', arc_length, 'kappa', kappa, 'evolved_curve', evolved_curve);

            current_curve_index = current_curve_index + 1;
            extracted_curves_count = extracted_curves_count + 1;
            extracted_curves = [extracted_curves; smoothed_curve_struct];
        end

        curves = [curves; extracted_curves];    
        [curves_count, ~] = size(curves);
        fprintf("%d extracted at iteration %d; curves count = %d\n", extracted_curves_count, i, curves_count);
    end
    save(sprintf('%s/curves.mat', sigma_curves_folder), 'curves', 'contour_levels', 'sigma', 'min_points_count', 'max_points_count', 'min_variance', 'min_mean', 'images_count', 'smoothing_frame_length', 'smoothing_order', 'smoothing_iterations', 'max_abs_curvature');
end

