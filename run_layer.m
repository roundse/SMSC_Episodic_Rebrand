function [net_in] = run_layer(net_in, stim_weights, stimulus, ...
    net_to_netweights, is_hard)
    global INP_STR;
    global GAIN;
    
    if nargin < 5
        is_hard = 0;
    end
    
    len = length(net_in);
    noise = 0.001*rand(1,len)-0.0005;
    
    stim_in = INP_STR*(stimulus*stim_weights');
    intranet_in = 1*(net_in*net_to_netweights');

    I = stim_in + intranet_in+noise;
    
    if is_hard == 1
        net_in = hard_activity(net_in, I, GAIN);
    else
        net_in = soft_activity(net_in, I, GAIN);  
    end
end

% only highest neuron is set to one, rest are zero
function s = hard_activity (prev, I, g)

    s = (0.1*prev + 0.9*I);
    s = s>=max(s);
end