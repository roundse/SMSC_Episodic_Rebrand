function returnable = cycle_place(place_in, input_weights, input, value)
global w_place_to_place;
global PVAL;

global place_in_queue;
global place_weight_queue;

global PLACE_CELLS;
PLACE_CELLS = 14;

% recurrency stuff
global w_place_to_hpc;
global w_hpc_to_place;

place_eye = eye(PLACE_CELLS);
w_place_to_place = zeros(PLACE_CELLS);

queue_pos = length(place_in_queue)+1;

if nargin < 3
    total_inputs = 0;
    hpc_in = place_in{2};
    place_in = place_in{1};
    
    for i = 1:(queue_pos-1)
        total_inputs = total_inputs + place_in_queue{i} * place_weight_queue{i};
    end
    
    place_out = activity(place_in, place_eye, total_inputs, ...
        w_place_to_place);
    
    returnable = place_out;
    
    if input_weights
    [w_hpc_to_place w_place_to_hpc] = recurrent_oja(place_out, place_in, ...
        hpc_in, w_hpc_to_place, w_place_to_hpc, PVAL);
    end
    
    place_in_queue = {};
else
    % return the weights given if no weight in queue
    if ( queue_pos > length(place_weight_queue) )
        returnable = input_weights;
    else
        returnable = place_weight_queue{queue_pos};
    end
    
    PVAL = value;
    
    place_in_queue{queue_pos} = input;
    place_weight_queue{queue_pos} = input_weights;
end
end
