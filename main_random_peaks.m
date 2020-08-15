% Based on https://www.mathworks.com/matlabcentral/answers/218806-random-gaussian-surface-generation

% Size in pixels of image
N = [1000 1000]; 

% Frequency-filter width
F = 6;

[X,Y] = ndgrid(1:N(1),1:N(2));
i = min(X-1,N(1)-X+1);
j = min(Y-1,N(2)-Y+1);
H = exp(-.5*(i.^2+j.^2)/F^2);
Z = real(ifft2(H.*fft2(randn(N))));

% Uncomment to render 3D surface
% surf(X,Y,Z,'edgecolor','none');
% light;

% Plot heat map
pcolor(X, Y, Z); % Plot the data
hold on;
shading flat;

% Calculate contour data
[M, ~] = contour(X, Y, Z, [0 0]); % Overlay contour line
data = contour_data(M);

% Take the first contour
contour = data(1);

% Plot the contour
h = plot(contour.xdata, contour.ydata, 'w.');