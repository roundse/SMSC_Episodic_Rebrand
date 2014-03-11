function cycle_net( place_stim, food_stim, cycles, value)

global hpc;
global place_region;
global food;

global PLACE_CELLS;
global FOOD_CELLS;

global w_hpc_to_place;
global w_hpc_to_food;
global w_place_to_hpc;
global w_food_to_hpc;

global is_learning;

for j = 2:cycles
    hpc_out = hpc(j-1,:);
    place_out = place_region(j-1,:);
    food_out = food(j-1, :);

    cycle_place(place_out, eye(PLACE_CELLS), place_stim, value);
    cycle_place(place_out, w_hpc_to_place, hpc_out, value);

    cycle_food(food_out, eye(FOOD_CELLS), food_stim, value);
    cycle_food(food_out, w_hpc_to_food, hpc_out, value);

    cycle_hpc(hpc_out, w_place_to_hpc, place_out, value);
    cycle_hpc(hpc_out, w_food_to_hpc, food_out, value);

    cycle_hpc(hpc_out, w_food_to_hpc,  food_stim, value);
    
    hpc(j,:) = cycle_hpc(hpc_out, is_learning);
    place_region(j,:) = cycle_place({place_region(j-1,:), hpc(j,:)}, is_learning);
    food(j,:) = cycle_food({food(j-1,:), hpc(j,:)}, is_learning);
end

end

