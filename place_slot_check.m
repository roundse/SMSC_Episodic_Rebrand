function [checked_places, side_pref, avg_checks, first_checked] = place_slot_check()
    global debug_sides;
    global last_side;
    
    global r_pfc_lesion_prefs;
    global r_hpc_lesion_prefs;
    global d_pfc_lesion_prefs;
    global d_hpc_lesion_prefs;
    global r_prefs;
    global d_prefs;
    global worm;
    
    global lesion_pfc;
    global lesion_hpc;
    
    global hpc_learning;
    global pfc_learning;
    
    hpc_learning = 0;
    pfc_learning = 0;
    
    global stored_place_responses;
    stored_place_responses = place_norm_activity();
    
    if debug_sides
        
        if ~lesion_hpc
            [checked_places, side_pref, avg_checks, first_checked] = ...
                run_side_checks('hpc');

            if last_side == worm
                r_hpc_lesion_prefs(end+1) = side_pref;
            else
                d_hpc_lesion_prefs(end+1) = side_pref;
            end        
        end
        
        if ~lesion_pfc
            [checked_places, side_pref, avg_checks, first_checked] = ...
                run_side_checks('pfc');

            if last_side == worm
                r_pfc_lesion_prefs(end+1) = side_pref;
            else
                d_pfc_lesion_prefs(end+1) = side_pref;
            end
        end
            
        [checked_places, side_pref, avg_checks, first_checked] = ...
            run_side_checks('');

        if last_side == worm
            r_prefs(end+1) = side_pref;
        else
            d_prefs(end+1) = side_pref;
        end
    else
        [checked_places, side_pref, avg_checks, first_checked] = ...
            run_side_checks('');
    end

end

function [checked_places, side_pref, avg_checks, first_checked] = run_side_checks(lesion)

    global PLACE_SLOTS;
    global PLACE_CELLS;
    global cycles;
    global debug;
    global lesion_pfc;
    global lesion_hpc;
    
    lesion_pfc_init = lesion_pfc;
    lesion_hpc_init = lesion_hpc;
    
    global IS_CHECKING;
    IS_CHECKING = 1;
    
    global FOODED_SLOTS;
    FOODED_SLOTS = PLACE_SLOTS;
    
    if strcmp(lesion,'hpc')
        lesion_hpc = 1;
        msg = 'only pfc | ';
    elseif strcmp(lesion,'pfc')
        lesion_pfc = 1;
        msg = 'only hpc | ';
    else
        msg = '';
    end
    
    % make variable place input with all inputs
    % inject into net for a cycle
    % collect place response
    % determine chosen palce
    % remove that input from all inputs
    % continue trial until no inputs left
    % the "Battle Royale" of inputs! 14 INPUTS ENTER. ONE ME LEAVES.

    testing_trials = 6; 

    ranked_slots = zeros(PLACE_CELLS, 1);
    min_vars = zeros(PLACE_CELLS, 1);

    % food is retrieved from store
    neutral_input = ones(1,14);

    %injection_current = rand(1,14); % <-- used for forgetting
    for p = 1:PLACE_CELLS
        injection_current = neutral_input/(15-p) +(rand(1,14) - 0.5 ); % <-- used for the eleminating input model

        final_place_activity = cycle_net(injection_current, [0 0], cycles, 0);
        
        save_state(p);

        avg = final_place_activity;
        [slot_signal ranked_slots(p) min_vars(p)] = find_place(avg); % <-- used for the eleminating input model
%         neutral_input = neutral_input - slot_signal; % <-- used for the eleminating input model
        % cycle_net(slot_signal, [0 0], cycles, -1); % <-- used forgetting
        %model
    end

%     disp(ranked_slots);
    checked_places = ranked_slots;
    side_pref = side_pref_calc(ranked_slots, msg);
    avg_checks = ranked_slots';

    if debug
        rank_and_variance = [ranked_slots min_vars]
    end
    
    first_checked = avg_checks(1)<8;

    lesion_pfc = lesion_pfc_init;
    lesion_hpc = lesion_hpc_init;

end

function place_outputs = place_norm_activity ()
    global PLACE_CELLS;
    global cycles;    
    global HVAL;
    global place;
    global IS_CHECKING;
    global PLACE_SLOTS;
    
    IS_CHECKING = 1;
    HVAL = 0;
    
    runs = 4;
    
    place_outputs = zeros(PLACE_CELLS);

    for i = 1:runs
        for p = 1:PLACE_CELLS
            injection_current = PLACE_SLOTS(p,:);

            place_outputs(p,:) = place_outputs(p,:) + ...
                cycle_net(injection_current, place(p,:), cycles, 0);
        end
    end
    
    place_outputs = place_outputs ./ runs;
    
end

function [slot_signal slot min_var] = find_place(place_response)
    global PLACE_CELLS;
    global stored_place_responses;
    
    vars = zeros(PLACE_CELLS,1);

    for i = 1:length(stored_place_responses);
        vars(i) = sum(var([stored_place_responses(i,:); ...
            place_response]));
    end
       
    min_var = min(vars);
    slot = find(vars==min(vars));
    slot = slot(1); % in the unlikely (but still occuring) event there are multiple minimums, just take the first
    slot_signal = stored_place_responses(slot, :);
    a = -2*ones(1,14);
    fs = stored_place_responses(slot,:);
    stored_place_responses(slot,:) = stored_place_responses(slot,:)*0 - 35;
end

function side_pref = side_pref_calc (ranked_slots, msg)
    global PLACE_CELLS;
    
    first_side = zeros(PLACE_CELLS,1);
    first_side(ranked_slots<8) = 1;
 
    side_pref = sum(first_side(1:7));
    disp(horzcat(msg,'Worms in first seven checks: '));
    disp(side_pref);
end