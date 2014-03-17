function [checked_places side_pref avg_checks ] = place_slot_check()
    global PLACE_SLOTS;
    global PLACE_CELLS;
    global cycles;

    % make variable place input with all inputs
    % inject into net for a cycle
    % collect place response
    % determine chosen palce
    % remove that input from all inputs
    % continue trial until no inputs left
    % the "Battle Royale" of inputs! 14 INPUTS ENTER. ONE ME LEAVES.

    testing_trials = 6;

    global place_region
    ranked_slots = zeros(PLACE_CELLS, 1);


    % food is retrieved from store
    neutral_input = sum(PLACE_SLOTS);
    for p = 1:PLACE_CELLS
        injection_current = neutral_input/max(neutral_input) + rand(1,14)/2;

        cycle_net(injection_current, [0 0], cycles, 0);

        avg = mean(place_region(3:cycles,:));
        [slot_signal ranked_slots(p)] = find_place(avg);
        neutral_input = neutral_input - slot_signal;
    end

    checked_places = ranked_slots;
    side_pref = side_pref_calc(ranked_slots);
    avg_checks = ranked_slots';


    figure;
    title('Place dist');
    plot(avg_checks);
    drawnow;
end

function [slot_signal slot] = find_place(place_response)
    global PLACE_SLOTS;
    global PLACE_CELLS;
    
    vars = zeros(PLACE_CELLS,1);

    for i = 1:length(PLACE_SLOTS);
        vars(i) = sum(var([PLACE_SLOTS(i,:); ...
            place_response]));
    end
    
    slot = find(vars==min(vars));
    slot_signal = PLACE_SLOTS(slot, :);

end

function side_pref = side_pref_calc (ranked_slots)
    global PLACE_CELLS;
    
    first_side = zeros(PLACE_CELLS,1);
    first_side(ranked_slots<7) = 1;

    side_pref = sum(first_side(1:7))/7;

end