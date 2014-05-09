function [checked_places side_pref avg_checks ] = mean_spot_check()
global PLACE_SLOTS;
global PLACE_CELLS;
global hpc;
global HPC_SIZE;
global cycles;

global pfc;
global PFC_SIZE;

% food is retrieved from store
neutral_input = sum(PLACE_SLOTS);

testing_trials = 6;
hpc_place_responses = zeros(testing_trials,HPC_SIZE);
pfc_place_responses = zeros(testing_trials, PFC_SIZE);
total_place_responses = zeros(testing_trials, HPC_SIZE);
checked_places = zeros(testing_trials,14);
side_pref = zeros(testing_trials,2);
for k = 1:testing_trials
    bland_input = neutral_input/max(neutral_input)+ rand(1,14)/2;
    
    for i = 1:PLACE_CELLS
        cycle_net(bland_input, [0.3 0.3], cycles, 0);
    end
    hpc_place_responses(k,:) = mean(hpc(3:cycles,:));
    pfc_place_responses(k,:) = mean(pfc(3:cycles,:));
    
    total_place_responses(k,:) = (hpc_place_responses(k,:) + ...
                                    pfc_place_responses(k,:)) / 2;
    checked_places(k,:) = find_place(total_place_responses(k,:));
    [side_pref(k, 1) side_pref(k, 2)] = side_preference(checked_places(k,:));
end

avg_checks = mean(checked_places);

figure;
title('Place dist');
plot(avg_checks);
drawnow;

end