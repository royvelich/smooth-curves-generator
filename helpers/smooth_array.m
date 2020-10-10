function y = smooth_array(x, framelen, order, iterations)
    for i = 1:iterations
        x = sgolayfilt(x, order, framelen);
    end 
    y = x;
end
