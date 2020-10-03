function y = unpad_array(x, framelen)
    y = x((framelen + 1):length(x) - framelen);
end

