function y = unpad_array(x, padding)
    y = x((padding + 1):length(x) - padding);
end

