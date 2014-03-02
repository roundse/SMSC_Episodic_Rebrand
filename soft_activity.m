function s = soft_activity (prev, I, g)
    PERSIST  = 0.1;
    s = PERSIST.*prev + (1-PERSIST).*(1./(1+exp(-g.*I)));
end