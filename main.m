addpath(genpath('./helpers/'));

curves = [];

image_files_paths = enumerate_image_files('./images');
[images_count, ~] = size(image_files_paths);

current_curve_index = 0;
h = figure;
curves_folder = sprintf("./curves_%s", date);
mkdir(curves_folder);
save(sprintf('%s/curves_%s.mat', curves_folder, date), 'curves');
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
    Z = imgaussfilt(Z, 32);
    
    [rows, cols, ~] = size(Z);
    [X,Y] = ndgrid(1:rows,1:cols);

    [M, ~] = contour(X, Y, Z, 6);
    
    [M_rows, M_cols] = size(M);
    if(M_cols == 0)
        continue;
    end
    
    current_curves = get_closed_curves(M, 2000, 3000, 3);
    [current_curves_count, ~] = size(current_curves);
    curves = [curves; current_curves];
    
    [curves_count, ~] = size(curves);
    
    for j=1:current_curves_count
        current_curve_index = current_curve_index + 1;
        
        plot(current_curves(j).xdata, current_curves(j).ydata);
        saveas(h, sprintf('%s/curve_%d.png', curves_folder, current_curve_index));

    end
    
    fprintf("%d extracted at iteration %d; curves count = %d\n", current_curves_count, i, curves_count);
end

save(sprintf('%s/curves_%s.mat', curves_folder, date), 'curves');