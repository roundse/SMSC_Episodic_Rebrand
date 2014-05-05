function returnable = cycle_place(place_in, input_weights, input, value)
global w_place_to_place;
global PVAL;

global place_in_queue;
global place_weight_queue;

global PLACE_CELLS;
PLACE_CELLS = 14;

place_eye = eye(PLACE_CELLS);
w_place_to_place = zeros(PLACE_CELLS);

global w_hpc_to_place w_place_to_hpc;
global w_pfc_to_place w_place_to_pfc;


global w_hpc_to_place_prev w_place_to_hpc_prev;
global w_pfc_to_place_prev w_place_to_pfc_prev;

queue_pos = length(place_in_queue)+1;

%global w_food_to_place;

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
            hpc_in, w_hpc_to_place, w_hpc_to_place_prev, w_place_to_hpc, ...
            w_place_to_hpc_prev, PVAL, 1);
        [w_pfc_to_place w_place_to_pfc] = recurrent_oja(place_out, place_in, ...
            hpc_in, w_pfc_to_place, w_pfc_to_place_prev, w_place_to_pfc, ...
            w_place_to_pfc_prev, PVAL, 0); % !BUG
        
        w_hpc_to_place_prev = w_hpc_to_place;
        w_place_to_hpc_prev = w_place_to_hpc;
        w_pfc_to_place_prev = w_pfc_to_place;
        w_place_to_pfc_prev = w_place_to_pfc;
    end

place_in_queue = {};
else
    % return the weights given if no weight in queue
    if ( queue_pos > length(place_weight_queue) )
        returnable = input_weights;
    else
        returnable = place_weight_queue{queue_pos};
    end
    
    if nargin > 3
        PVAL = value;
    end
    
    place_in_queue{queue_pos} = input;
    place_weight_queue{queue_pos} = input_weights;
end
end
