function [ output_args ] = save_state( prefix )

global TRIAL_DIR;

global w_food_to_hpc;
global w_place_to_hpc;
global w_hpc_to_food;
global w_hpc_to_place;
global w_hpc_to_hpc;

global w_food_to_pfc;
global w_place_to_pfc;
global w_pfc_to_food;
global w_pfc_to_place;

global hpc_average;
global pfc_average;

global current_time;

hpc_average = mean(hpc_average) / (current_time*14);
pfc_average = mean(pfc_average) / (current_time*14);

global place_activity;
avg_place_activity = mean(place_activity);

filename = horzcat(TRIAL_DIR, num2str(prefix), '_testing_save');
save(filename);
end