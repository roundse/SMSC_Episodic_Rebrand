function returnable = cycle_food(food_in, input_weights, input, value)
global w_food_to_food;
global VAL;

global food_in_queue;
global food_weight_queue;

global FOOD_CELLS;

global w_hpc_to_food w_food_to_hpc;
global w_pfc_to_food w_food_to_pfc;
global w_place_to_food w_food_to_place;

global w_hpc_to_food_prev w_food_to_hpc_prev;
global w_pfc_to_food_prev w_food_to_pfc_prev;
global w_place_to_food_prev w_food_to_place_prev;

food_eye = eye(FOOD_CELLS);

queue_pos = length(food_in_queue)+1;

if nargin < 3
    total_inputs = 0;
    hpc_in = food_in{2};
    food_in = food_in{1};
    
    for i = 1:(queue_pos-1)
        total_inputs = total_inputs + food_in_queue{i} * ...
            food_weight_queue{i};
    end
    
    food_out = activity(food_in, food_eye, total_inputs, ...
        w_food_to_food);
    
    
    returnable = food_out;
    if input_weights

        [w_hpc_to_food w_food_to_hpc] = recurrent_oja(food_out, food_in, ...
            hpc_in, w_hpc_to_food, w_hpc_to_food_prev, w_food_to_hpc, ...
            w_hpc_to_food_prev, VAL, 1);
        
        [w_pfc_to_food w_food_to_pfc] = recurrent_oja(food_out, food_in, ...
            hpc_in, w_pfc_to_food, w_pfc_to_food_prev, w_food_to_pfc, ...
            w_food_to_pfc_prev, VAL, 0);

        [w_place_to_food w_food_to_place] = recurrent_oja(food_out, ...
            food_in, hpc_in, w_place_to_food, w_place_to_food_prev, ...
            w_food_to_place, w_food_to_place_prev, VAL, 0);
        
        w_hpc_to_food_prev = w_hpc_to_food;
        w_food_to_hpc_prev = w_food_to_hpc;
        w_pfc_to_food_prev = w_pfc_to_food;
        w_food_to_pfc_prev = w_food_to_pfc;
        w_place_to_food_prev = w_place_to_food;
        w_food_to_place_prev = w_food_to_place;
    end
    
    food_in_queue = {};
else
    % return the weights given if no weight in queue
    if ( queue_pos > length(food_weight_queue) )
        returnable = input_weights;
    else
        returnable = food_weight_queue{queue_pos};
    end
    
    if nargin > 3
        VAL = value;
    end
    
    food_in_queue{queue_pos} = input;
    food_weight_queue{queue_pos} = input_weights;
end
end
