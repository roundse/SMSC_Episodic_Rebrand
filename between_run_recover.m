function between_run_recover()

    global hpc_in_queue;
    global hpc_weight_queue;
    global food_in_queue;
    global food_weight_queue;
    
    global place_in_queue;
    global place_weight_queue;
    
    place_in_queue = {};
    place_weight_queue = {};

    hpc_in_queue = {};
    hpc_weight_queue = {};

    food_in_queue = {};
    food_weight_queue = {};
    
    global place_region;
    global food;
    global hpc;
    global HPC_SIZE;
    global FOOD_CELLS;
    global PLACE_CELLS;
    global cycles;
    
    place_region = zeros(cycles, PLACE_CELLS);
    food = zeros(cycles, FOOD_CELLS);
    hpc = zeros(cycles, HPC_SIZE);
    
    global place_out;
    global food_out;
    global hpc_out;
    place_out = zeros(cycles, PLACE_CELLS);
    food_out = zeros(cycles, FOOD_CELLS);
    hpc_out = zeros(cycles, HPC_SIZE);
    
    global w_hpc_to_place;
    global w_place_to_hpc;
    global w_hpc_to_place_init;
    global w_place_to_hpc_init;
    
    w_hpc_to_place = w_hpc_to_place_init;
    w_place_to_hpc = w_place_to_hpc_init;
    
%     global w_hpc_to_food;
%     global w_food_to_hpc;
%     global w_hpc_to_food_init;
%     global w_food_to_hpc_init;
%     
%     w_hpc_to_food = w_hpc_to_food_init;
%     w_food_to_hpc = w_food_to_hpc_init;
    

end

