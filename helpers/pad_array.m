function y = pad_array(x, framelen, dir)
    tail_x = x(length(x) - (framelen - 1):length(x));
    head_x = x(1:framelen);
    
    if strcmp(dir, 'vertical') == 1
        y = vertcat(tail_x, x, head_x);
    end
    
    if strcmp(dir, 'horizontal') == 1
        y = horzcat(tail_x, x, head_x);
    end
end
