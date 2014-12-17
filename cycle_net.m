function final_place_activity = cycle_net(place_stim, food_stim, cycles, value)

global pfc;
global hpc;
global place_region;
global food;

global PLACE_CELLS;
global FOOD_CELLS;
global HPC_SIZE;

global w_hpc_to_place;
global w_hpc_to_food;
global w_place_to_hpc;
global w_food_to_hpc;

global is_learning;

global w_pfc_to_food;
global w_food_to_pfc;
global w_pfc_to_place;
global w_place_to_pfc;

global hpc_cumul_activity;
global pfc_cumul_activity;


% TEMPORARY/EXPERIMENTAL WEIGHTS
global w_pfc_to_hpc;
global w_pfc_to_pfc;
global w_hpc_to_hpc;
% ------------------------------

global lesion_pfc;
global lesion_hpc;
global is_testing;

global run_hpc;
global run_pfc;
global switch_lesion;

global place_activity;

if lesion_pfc | lesion_hpc
    if ~switch_lesion
        run_hpc = ~(lesion_hpc & is_testing);
        run_pfc = ~(lesion_pfc & is_testing);
    else
        run_hpc = ~(lesion_hpc); %& is_testing);
        run_pfc = ~(lesion_pfc); %& is_testing); 
    end
else
    run_hpc = 1;
    run_pfc = 1;
end

global is_consolidation;

global pfc_out;

global place_side_inhibit;
place_side_inhibit = food_stim;

p_eye = eye(PLACE_CELLS);
f_eye = eye(FOOD_CELLS);


for j = 2:cycles
    if ~run_hpc
        hpc = hpc .* 0;
    end
    
    if ~run_pfc
        pfc = pfc .* 0;
    end

    hpc_out = hpc(j-1, :);
    place_out = place_region(j-1, :);
    food_out = food(j-1, :);
    pfc_out = pfc(j-1, :);

    cycle_place(place_out, p_eye, place_stim);

    cycle_place(place_out, w_hpc_to_place, hpc_out);
    cycle_place(place_out, w_pfc_to_place, pfc_out);

    cycle_food(food_out, f_eye, food_stim);
    
    cycle_food(food_out, w_hpc_to_food, hpc_out);
    cycle_food(food_out, w_pfc_to_food, pfc_out);

    if run_hpc
        cycle_hpc(hpc_out, w_place_to_hpc, place_out, value);
        cycle_hpc(hpc_out, w_food_to_hpc, food_out, value);
    
        if is_consolidation
            cycle_hpc(hpc_out, w_place_to_hpc, place_stim, value);
            cycle_hpc(hpc_out, w_food_to_hpc, food_stim, value);
        end

%         decay_hpc();
    end

    if run_pfc & run_hpc
        cycle_hpc(hpc_out, w_pfc_to_hpc, pfc_out, value);
    end
    
    if run_pfc
        cycle_pfc(pfc_out, w_place_to_pfc, place_out, value);
        cycle_pfc(pfc_out, w_food_to_pfc, food_out, value);

        if is_consolidation
            cycle_pfc(pfc_out, w_place_to_pfc, place_stim, value);
            cycle_pfc(pfc_out, w_food_to_pfc, food_stim, value);
        end
    end
  
    if run_pfc
        pfc(j,:) = cycle_pfc(pfc_out, is_learning);
    end
    if run_hpc
        hpc(j,:) = cycle_hpc(hpc_out, is_learning);
    end
    place_region(j,:) = cycle_place({place_region(j-1,:), hpc(j,:), ...
                        pfc(j,:)}, is_learning);
    food(j,:) = cycle_food({food(j-1,:), hpc(j,:), ...
                pfc(j,:)}, is_learning);
end

pfc(1,:) = pfc(end,:);
hpc(1,:) = hpc(end,:);
food(1,:) = food(end,:);
place_region(1,:) = place_region(end,:);

final_place_activity = mean(place_region(6:cycles,:));
hpc_cumul_activity = hpc_cumul_activity + mean(mean(hpc));
pfc_cumul_activity = pfc_cumul_activity + mean(mean(pfc));

global hpc_average;
global pfc_average;

global hpc_collected_activity;
hpc_collected_activity = [hpc_collected_activity; mean(hpc)];

global pfc_collected_activity;
pfc_collected_activity = [pfc_collected_activity; mean(pfc)];

global place_collected_activity;
place_collected_activity = [place_collected_activity; mean(place_region)];

global food_collected_activity;
food_collected_activity = [food_collected_activity; mean(food)];

hpc_average = hpc_average + mean(hpc);
pfc_average = pfc_average + mean(pfc);

place_activity = final_place_activity;
end

function decay_hpc()

    global w_hpc_to_place;
    global w_hpc_to_food;
    global w_place_to_hpc;
    global w_food_to_hpc;

    decay_weights(w_hpc_to_place);
    decay_weights(w_hpc_to_food);
    decay_weights(w_place_to_hpc);
    decay_weights(w_food_to_hpc);

end

function w = decay_weights(w)

    global decay;
    half_d = decay/2;
    wd = half_d*rand(size(w)) - half_d;
    w = w + wd;

end