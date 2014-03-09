function returnable = cycle_hpc(hpc_in, input_weights, input, value)
global w_hpc_to_hpc;
global hpc_eye;
global INTERNAL_LEARNING;

global hpc_in_queue;
global hpc_weight_queue;

global HVAL;

global HPC_SIZE;

hpc_eye = eye(HPC_SIZE);

queue_pos = length(hpc_in_queue)+1;

if nargin < 3
    total_inputs = 0;
    for i = 1:(queue_pos-1)
        total_inputs = total_inputs + hpc_in_queue{i} * hpc_weight_queue{i};
    end
    
    food_hpc_out = activity(hpc_in, hpc_eye, total_inputs, ...
        w_hpc_to_hpc);
    
    returnable = food_hpc_out;
    
    if input_weights
        % delete internal self weights
        for l = 1:length(w_hpc_to_hpc)
            w_hpc_to_hpc(l,l) = 0;
        end
        
        hpc_weight_queue{queue_pos} = w_hpc_to_hpc;
        hpc_in_queue{queue_pos} = food_hpc_out;

        %w_hpc_to_hpc = oja(hpc_in, total_inputs, w_hpc_to_hpc, HVAL);
        hpc_weight_queue = oja(hpc_in_queue, hpc_weight_queue, food_hpc_out, HVAL);
        
        % remove them from the weight lists so they don't mess up the
        temp_w = hpc_weight_queue{queue_pos};
        hpc_weight_queue{queue_pos} = [];
        hpc_in_queue{queue_pos} = [];
        
        if INTERNAL_LEARNING
            w_hpc_to_hpc = temp_w;
        end
    end
    
    hpc_in_queue = {};
else
    % return the weights given if no weight in queue
    if ( queue_pos > length(hpc_weight_queue) )
        returnable = input_weights;
    else
        returnable = hpc_weight_queue{queue_pos};
    end

    HVAL = value;

    
    hpc_in_queue{queue_pos} = input;
    hpc_weight_queue{queue_pos} = input_weights;
end
end