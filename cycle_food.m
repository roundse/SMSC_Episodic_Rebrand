function [returnable1 returnable2 returnable3] = cycle_food(food_in, ...
    input_weights1, input_weights2, input_weights3, input, value)


global w_food_to_food;
global VAL;

global hpc_food_in_queue;
global hpc_food_weight_queue;

global pfc_food_in_queue;
global pfc_food_weight_queue;

global place_food_in_queue;
global place_food_weight_queue;



global FOOD_CELLS;

% recurrency stuff
global w_food_to_hpc;
global w_hpc_to_food;

global w_food_to_pfc;
global w_pfc_to_food;

global w_food_to_place;
global w_place_to_food;

food_eye = eye(FOOD_CELLS);

hpc_queue_pos = length(hpc_food_in_queue)+1;
pfc_queue_pos = length(pfc_food_in_queue)+1;
place_queue_pos = length(place_food_in_queue)+1;

if nargin < 3
    total_inputs = 0;
    hpc_in = food_in{2};
    food_in = food_in{1};
    
    for i = 1:(hpc_queue_pos-1)
        total_inputs = total_inputs + hpc_food_in_queue{i} * ...
            hpc_food_weight_queue{i};
    end
    for i = 1:(pfc_queue_pos-1)
        total_inputs = total_inputs + pfc_food_in_queue{i} * ...
            pfc_food_weight_queue{i};
    end
    for i = 1:(place_queue_pos-1)
        total_inputs = total_inputs + place_food_in_queue{i} * ...
            place_food_weight_queue{i};
    end
    
    food_out = activity(food_in, food_eye, total_inputs, ...
        w_food_to_food);
    
    
    returnable1 = food_out;
    returnable2 = food_out;
    returnable3 = food_out;
    
    if input_weights1
        [w_hpc_to_food w_food_to_hpc] = recurrent_oja(food_out, ...
            food_in, hpc_in, w_hpc_to_food, w_food_to_hpc, VAL, 1);
    end
    if input_weights2
        [w_pfc_to_food w_food_to_pfc] = recurrent_oja(food_out, ...
            food_in, pfc_in, w_pfc_to_food, w_food_to_pfc, VAL, 1);
    end
    if input_weights3
        [w_place_to_food, w_food_to_place] = recurrent_oja(food_out, ...
            food_in, place_in, w_place_to_food, w_food_to_place, VAL, 1);
    end
    
    hpc_food_in_queue = {};
    pfc_food_in_queue = {};
    place_food_in_queue = {};
    
else
    % return the weights given if no weight in queue
    if ( hpc_queue_pos > length(hpc_food_weight_queue) )
        returnable1 = input_weights1;
    else
        returnable1 = hpc_food_weight_queue{hpc_queue_pos};
    end
    
    if (pfc_queue_pos > length(pfc_food_weight_queue))
        returnable2 = input_weights2;
    else
        returnable2 = pfc_food_weight_queue{pfc_queue_pos};
    end
    
    if (place_queue_pos > length(place_food_weight_queue))
        returnable3 = input_weights3;
    else
        returnable3 = place_food_weight_queue{place_queue_pos};
    end
    
    if nargin > 7
        VAL = value;
    end
    
    hpc_food_in_queue{hpc_queue_pos} = input;
    pfc_food_in_queue{pfc_queue_pos} = input;
    place_food_in_queue{place_queue_pos} = input;
    
    hpc_food_weight_queue{hpc_queue_pos} = input_weights1;
    pfc_food_weight_queue{pfc_queue_pos} = input_weights2;
    place_food_weight_queue{place_queue_pos} = input_weights3;
end
end
