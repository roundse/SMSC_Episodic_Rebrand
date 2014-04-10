function [returnable1 returnable2] = cycle_place(place_in, input_weights1, ...
    input_weights2, input, value)


global w_place_to_place;
global VAL;

global hpc_place_in_queue;
global hpc_place_weight_queue;

global pfc_place_in_queue;
global pfc_place_weight_queue;

global PLACE_CELLS;

% recurrency stuff
global w_place_to_hpc;
global w_hpc_to_place;

global w_place_to_pfc;
global w_pfc_to_place;


place_eye = eye(PLACE_CELLS);

hpc_queue_pos = length(hpc_place_in_queue)+1;
pfc_queue_pos = length(pfc_place_in_queue)+1;

if nargin < 4
    total_inputs = 0;
    hpc_in = place_in(2);
    place_in = place_in(1);
    
    for i = 1:(hpc_queue_pos-1)
        total_inputs = total_inputs + hpc_place_in_queue{i} * ...
            hpc_place_weight_queue{i};
    end
    for i = 1:(pfc_queue_pos-1)
        total_inputs = total_inputs + pfc_place_in_queue{i}' * ...
            pfc_place_weight_queue{i};
    end

    place_out = activity(place_in, place_eye, total_inputs, ...
        w_place_to_place);
    
    
    returnable1 = place_out;
    returnable2 = place_out;
    
    if input_weights1
        [w_hpc_to_place w_place_to_hpc] = recurrent_oja(place_out, ...
            place_in, hpc_in, w_hpc_to_place, w_place_to_hpc, VAL, 1);
    end
    if input_weights2
        [w_pfc_to_place w_place_to_pfc] = recurrent_oja(place_out, ...
            place_in, pfc_in, w_pfc_to_place, w_place_to_pfc, VAL, 1);
    end
    
    hpc_place_in_queue = {};
    pfc_place_in_queue = {};
    
else
    % return the weights given if no weight in queue
    if ( hpc_queue_pos > length(hpc_place_weight_queue) )
        returnable1 = input_weights1;
    else
        returnable1 = hpc_place_weight_queue{queue_pos};
    end
    
    if (pfc_queue_pos > length(pfc_place_weight_queue))
        returnable2 = input_weights2;
    else
        returnable2 = pfc_place_weight_queue{queue_pos};
    end
    
    if nargin > 6
        VAL = value;
    end
    
    hpc_place_in_queue{hpc_queue_pos} = input;
    pfc_place_in_queue{pfc_queue_pos} = input;
    
    hpc_place_weight_queue{hpc_queue_pos} = input_weights1;
    pfc_place_weight_queue{pfc_queue_pos} = input_weights2;
end
end
