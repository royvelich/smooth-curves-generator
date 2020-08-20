addpath(genpath('./helpers/'));
addpath(genpath('./helpers/curvature/'));
addpath(genpath('./helpers/linecurvature_version1b/'));

curves = [];

image_files_paths = enumerate_image_files('./images');
[images_count, ~] = size(image_files_paths);

current_curve_index = 1;
h = figure;
datetime_str = datestr(now,'mmmm_dd_yyyy_HH_MM_SS');
curves_folder = sprintf("./curves_%s", datetime_str);
mkdir(curves_folder);

contour_levels = 10;
sigma = 32;
min_points_count = 1500;
min_variance = 0.4;

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
    
    current_curves = get_closed_curves(M, min_points_count, 3000, 6);
    [current_curves_count, ~] = size(current_curves);

    
    extracted_curves = [];
    
    extracted_curves_count = 0;
    for j=1:current_curves_count
        
        curve = current_curves(j);
        curve_matrix = horzcat(curve.xdata, curve.ydata);
        kappa = LineCurvature2D(curve_matrix);
        
        kappa_var = var(kappa);
        kappa_mean = mean(kappa);
        
        if(isnan(kappa_var) || isnan(kappa_mean))
            continue;
        end
        
        if(abs(kappa_var) < min_variance)
            continue;
        end
        
        plot(current_curves(j).xdata, current_curves(j).ydata);
        saveas(h, sprintf('%s/curve_%d.png', curves_folder, current_curve_index));
        
        current_curve_index = current_curve_index + 1;
        extracted_curves_count = extracted_curves_count + 1;
        extracted_curves = [extracted_curves; curve];
    end
    
    curves = [curves; extracted_curves];    
    [curves_count, ~] = size(curves);
    fprintf("%d extracted at iteration %d; curves count = %d\n", extracted_curves_count, i, curves_count);
end

save(sprintf('%s/curves_%s.mat', curves_folder, datetime_str), 'curves', 'contour_levels', 'sigma', 'min_points_count', 'min_variance');