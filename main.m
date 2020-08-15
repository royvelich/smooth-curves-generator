addpath(genpath('./helpers/'));

image_files_paths = enumerate_image_files('./images');
Z = imread(image_files_paths(1).path);
Z = rgb2gray(Z);
Z = imgaussfilt(Z,24);

image_size = size(Z);
[X,Y] = ndgrid(1:image_size(1),1:image_size(2));

pcolor(X, Y, Z);
hold on;
shading flat;
[M, ~] = contour(X, Y, Z, 10);

curves = get_closed_curves(M);
curve = curves(2);
hold on;
h = plot(curve.xdata, curve.ydata, 'w.');