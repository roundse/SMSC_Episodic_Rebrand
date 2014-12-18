function [net_in] = activity(net_in, stim_weights, stimulus, ...
    net_to_netweights)
    global INP_STR;
    global GAIN;

    global HVAL;
    global ACT_VAL;
    global IS_CHECKING;
    global VAL_PAIR;
    global ACT_NOISE;
    
    if IS_CHECKING
        val = sum(VAL_PAIR) * ACT_VAL;
    else
        val = HVAL * ACT_VAL;
    end
    
    GAIN = 5;
    persist = 0.2;

    len = length(net_in);
    noise = ACT_NOISE*rand(1,len)-(ACT_NOISE/2);
    
    stim_in = INP_STR*(stimulus*stim_weights');
    intranet_in = 1*(net_in*net_to_netweights');

    I = stim_in + intranet_in;
    I = I + noise;
    
    net_in = persist.*net_in + (1-persist).*(1./(1+exp(-GAIN.*I))); 
end