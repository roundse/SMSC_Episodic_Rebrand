function [worm_trial pean_trial] = experiment(cycles, is_disp_weights, VALUE)

global TRIAL_DIR;
global GAIN;
GAIN = 5;

global test_learning;

% to do
% - store lesion prefs based on peanut / worm
% - display at end of trial or store
% - find useful way to relate to activity?
% - work on having them be consistent and in right direction.

initialize_weights(cycles, is_disp_weights, VALUE);

if (test_learning)
    run_test_protocol(cycles, is_disp_weights, VALUE);

else

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PRE: Agent stores both foods. Consolidates 124 hours and is allowed to
    % retrieve the foods. Learns worms decay.
    % Then agent stores both foods. Consolidates 4 hours and then is
    % allowed to retrieve the foods. Learns worms are still good.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    run_protocol('pre_training', cycles, is_disp_weights, VALUE);
    %%%%%%%%%%%%%%%%%%%%%%
    % Don't give it training, Emily, no matter how you may want to
    %%%%%%%%%%%%%%%%%%%%%%
    %run_protocol('training', cycles, is_disp_weights, VALUE);
    % filename = horzcat(TRIAL_DIR, 'after training', '_variables');
    % save(filename);

    % run_empty();

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TESTING: Agent stores one food, consolidates either 4 or 124 hours, then
    % stores the second food, and consolidates the leftover time.
    % Then gets to recover its caches.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % show_weights('before testing',1);

    [worm_trial pean_trial] = ...
    run_protocol('testing', cycles, is_disp_weights, VALUE);

    % show_weights('after testing',1);

end

global debug_sides;
global r_pfc_lesion_prefs_avg;
global r_hpc_lesion_prefs_avg;
global d_pfc_lesion_prefs_avg;
global d_hpc_lesion_prefs_avg;

global r_pfc_lesion_prefs;
global r_hpc_lesion_prefs;
global d_pfc_lesion_prefs;
global d_hpc_lesion_prefs;

global r_prefs_avg;
global d_prefs_avg;
global r_prefs;
global d_prefs;

global lesion_pfc;
global lesion_hpc;

if debug_sides
    
    if ~lesion_pfc
        r_pfc_lesion_prefs_avg(end+1,:) = r_pfc_lesion_prefs;
        d_pfc_lesion_prefs_avg(end+1,:) = d_pfc_lesion_prefs;
    end

    if ~lesion_hpc
        r_hpc_lesion_prefs_avg(end+1,:) = r_hpc_lesion_prefs;
        d_hpc_lesion_prefs_avg(end+1,:) = d_hpc_lesion_prefs;
    end
    
    r_prefs_avg(end+1,:) = r_prefs;
    d_prefs_avg(end+1,:) = d_prefs;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SAVING VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 filename = horzcat(TRIAL_DIR, 'after final trial', '_variables');
save(filename);

varlist = {'hpc','place_region','food', 'place_in_queue', ...
    'place_weight_queue', 'hpc_in_queue', 'hpc_weight_queue', ...
    'food_in_queue', 'food_weight_queue'};
clear(varlist{:})
end

function places = spot_shuffler (start, finish)
if (nargin == 1)
    places = randperm(start);
%     places = [1 : start];
else
    range = finish - start+1;
    numsets = (start : finish);
    perm = randperm(range);
    
    for i=1:range
        p = perm(i);
        places(i) = numsets(p);
    end
%     places = [start : finish];
end
end

function [worm_trial pean_trial] = ...
    run_test_protocol (prot_type, cycles, is_disp_weights, VALUE)
    global pfc_learning;
    global hpc_learning;
    global HVAL;
    global PVAL;
    global REPL; global PILF; global DEGR;
    
    global is_replenish;
    is_replenish = 1;
    
    global is_testing;
    is_testing = 0;
    
    value = DEGR;
    tests = 5;
    cycles = 7;
    
    values = [DEGR; REPL; PILF];
    val_length = length(values);
    
    side_prefs = zeros(2,tests);

    for j=1:tests
        for i=1:val_length
            value = values(i,:);

            pfc_learning = 1;
            hpc_learning = 1;
            
            for k=1:1
                reward_stim(value, cycles, 0);
            end
            
            [checked_places, side_pref, avg_checks, first_checked] ...
                = place_slot_check;
            
            show_weights('short testing',1);

            side_prefs(i,j) = side_pref;
            initialize_weights(cycles, 0, DEGR);
        end
    end
    
    disp('---------------------------');
    for j=1:val_length
        prefs = side_prefs(j,:);
        good_prefs = prefs(prefs>0);
        mean_pref = mean(good_prefs');
        percent_fail = length(good_prefs) / length(prefs);
        side_performance = [mean_pref percent_fail]
    end
    
end

function [worm_trial pean_trial] = ...
    run_protocol (prot_type, cycles, is_disp_weights, VALUE)
global PLACE_SLOTS;

global worm;   global WORM;
global peanut; global PEANUT;

global REPL; global PILF; global DEGR;

global learning_reduction;
        
global PVAL;
global HVAL;
global IS_CHECKING;
global VAL_PAIR;
global ACT_VAL;
    
if VALUE == 2
    value = REPL;
    disp('REPLENISH TRIAL~~~~~~~~~~~~~~~~~~~~~~~~');
    
elseif VALUE == 1
    value = DEGR;
    disp('DEGRADE TRIAL~~~~~~~~~~~~~~~~~~~~~~~~~~');

else
    value = PILF;
    disp('PILFER TRIAL~~~~~~~~~~~~~~~~~~~~~~~~~~~');
end

global is_place_stim;
global is_food_stim;

is_place_stim = 0;
is_food_stim = 0;

global place;
global hpc_cumul_activity;
global pfc_cumul_activity;

global is_pfc;

global hpc_learning;
global pfc_learning;

global hpc_cur_decay;
hpc_cur_decay = 0;

global lesion_pfc;
global lesion_hpc;

global current_time;

hpc_learning = 0;
pfc_learning = 0;

is_pfc = 0;

food_types = [peanut worm];
rev_food = [worm peanut];
test_time_lengths = [120, 4];
train_time_lengths = [124, 4];

type_order = randperm(2);
time_order = randperm(2);

global is_testing;
global is_training;

global last_side;

is_testing = strcmp(prot_type, 'testing');
is_training = strcmp(prot_type, 'training');

global is_learning;

global learning_rate;
global pfc_learning_rate;

if is_testing || is_training
    duration = 2;
    
    if lesion_hpc || lesion_pfc
        disp('~~LESION TRIAL!~~');
    end
else
    duration = 4;
end

global IS_STORING;
IS_STORING = 0;

global hpc_average;
global pfc_average;

global hpc;
global pfc;

global is_replenish;

global is_consolidation;
is_consolidation = 0;

hpc_average = hpc(1,:);
pfc_average = pfc(1,:);

PVAL = 1;
HVAL = 1;

for j=1:duration
    for l=1:2
        is_learning = 0;
        IS_CHECKING = 0;       
        
        % if testing time is always 4 then 120
        if is_testing || is_training
            current_time = test_time_lengths(l);
            current_type = food_types(type_order(l));
            
            % otherwise time is randomly one way or the other
        else
            current_time = train_time_lengths(time_order(l));
            current_type = food_types(type_order(l));
            
        end
        
        if current_type == worm
            disp('worm');
        else
            disp('peanut');
        end
        
        if is_testing || is_training
            if l == 1
                current_place = 'First';
            else
                current_place = 'Second';
            end
        else
            current_place = 'First stored food is';
        end
        
        if is_testing || is_training
            is_replenish =  current_type == worm & current_time == 4;
        else
            is_replenish = current_time == 4;
        end
        
        disp([current_place, ' consolidation period is: ', num2str(current_time)]);
        
        if is_testing || is_training
            if current_type == worm
                spots = spot_shuffler(7);
            else
                spots = spot_shuffler(8,14);
            end
        else
            if current_type == worm
                spots = horzcat(spot_shuffler(7), spot_shuffler(8,14));
            else
                spots = horzcat(spot_shuffler(8,14), spot_shuffler(7));
            end
        end

        pfc_learning = 1;
        hpc_learning = 1;
        IS_STORING = 1;
        if is_testing
            pfc_learning = 0;
        end
        for k = 1:1
            for i = spots
                if i < 8
                    v = REPL(worm);
                else
                    v = REPL(peanut);
                end
                while place(i,:) == 0
                    place(i,:) = current_type;
                end

                VAL_PAIR = REPL;
                ACT_VAL = 1 / (1 + REPL(1) + REPL(2));
                
                HVAL = v;
                PVAL = v;
                % CACHING
                cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles*2, v);
            end 
        end
        IS_STORING = 0;
        pfc_learning = 0;
        hpc_learning = 0;

        % DO I CHANGE THESE TOO?
        HVAL = 1;
        PVAL = 1;
        
        if is_testing || is_training
            if current_time == 4
                if current_type == peanut
                    spots = horzcat(spot_shuffler(7), spot_shuffler(8,14));
                else
                    spots = horzcat(spot_shuffler(8,14), spot_shuffler(7));
                end
            end
        end
        
        if is_replenish
            val = REPL;
        else
            val = value;
        end
        
        VAL_PAIR = val;
        ACT_VAL = 1 / (1 + value(1) + value(2));
        
        hpc_cumul_activity = 0;
        pfc_cumul_activity = 0;

        
        % TURN THIS ON/OF FOR LEARNING DURING TESTING/TRAINING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if is_testing
            pfc_learning = 0;
            hpc_learning = 1;
        end

        hpc_learning = 1;
        pfc_learning = 1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        is_consolidation = 1;
        for q = 1:current_time
            
            if is_testing || is_training
                if current_time == 4
                    spots = spot_shuffler(1,14);
                else
                    if current_type == worm
                        spots = spot_shuffler(7);
                    else
                        spots = spot_shuffler(8,14);
                    end
                end
            else
                spots = spot_shuffler(1,14);
            end
            
            loc_inject = 1;
            for i = spots
                if i < 8
                    v = val(worm);
                else
                    v = val(peanut);
                end
                
                % CHANGE THIS IN ORDER TO CHANGE WHAT VALUE IS PASSED BY
                % DEFAULT
                PVAL = 1;
                HVAL = 1;
                %                   if is_testing
                %disp(['Currently in the consolidating phase...value is ', num2str(0)]);
                %                   end
                cycle_net( PLACE_SLOTS(i,:)*loc_inject, place(i,:)*loc_inject, cycles, 0);
            end
            loc_inject = 0;
        end
        hpc_learning = 0;
        pfc_learning = 0;
        is_consolidation = 0;
        
        global w_hpc_to_hpc;

        if is_testing
            show_weights('testing',1);
        end
%         learning_rate = learning_rate*weight_reduction;
%         pfc_learning_rate = pfc_learning_rate*weight_reduction;
        
        show_weights([prot_type, ' ', num2str(current_time)], 1);
        
        m1 = mean(hpc_cumul_activity) / (current_time*14);
        global activity1;
        activity1 = mean(m1);
        %disp(['HPC Consolidate: ', num2str(activity1)]);
        
        save_state('during expriment');
        
        m2 = mean(pfc_cumul_activity) / (current_time*14);
        global activity2;
        activity2 = mean(m2);
        %disp(['PFC Consolidate: ', num2str(activity2)]);
        hpc_cur_decay = 0;
        
        last_side = current_type;
        
        if ~is_testing && ~is_training % this means pre-training
            pfc_learning = 1;
            hpc_learning = 1;
            PVAL = v;
            HVAL = v;
            %         end
            %         if ~is_testing && ~is_training
            disp('PRE-TRAINING Place slot check');
            [checked_places, side_pref, avg_checks, first_checked] ...
                = place_slot_check;
            reward_stim(value, cycles, is_replenish);
        end
        if ~is_training && ~is_testing
            run_empty();
        end
    end

    global decay;
    
    pfc_learning_rate = pfc_learning_rate * learning_reduction;
    learning_rate = learning_rate * learning_reduction;
    decay = decay * learning_reduction;

    if is_testing || is_training % i.e everything but pre-training
        food_types = [food_types(2) food_types(1)];
        
        if is_training
            disp('TRAINING Place slot check');
            [checked_places, side_pref, avg_checks, first_checked] ...
            = place_slot_check;
            reward_stim(value, cycles, is_replenish);
        elseif is_testing
            disp('TESTING Place slot check');
            [checked_places, side_pref, avg_checks, first_checked] ...
            = place_slot_check;
%             reward_stim(value, cycles, is_replenish);
        end
    end
    
%    
%     initialize_weights(cycles, is_disp_weights, VALUE);
    
    if is_testing
        if is_replenish
            if value == DEGR
                expected = 6;
            elseif value == PILF
                expected = 4;
            else
                expected = 6;
            end
        else
            if value == DEGR
                expected = 1;
            elseif value == PILF
                expected = 4;
            else
                expected = 6;
            end
        end
        
        trial = struct('type_order' , current_type, ...
            'check_order', checked_places, ...
            'first_check', first_checked, ...
            'side_pref'  , side_pref, ...
            'error_pref' , (side_pref-expected), ...
            'avg_checks' , avg_checks);
        
        if value == DEGR & trial.('type_order') ~= worm & side_pref < 3
            disp('bad trial!');
        elseif value == REPL & trial.('type_order') == worm & side_pref < 4
            disp('bad trial!');
        elseif value == REPL & side_pref < 4
            disp('bad trial!');
        end
        
        if (trial.('type_order') ~= worm)
            pean_trial = trial;
        else
            worm_trial = trial;
        end
        % if training then just reverse time order after trial
    else
        time_order = [time_order(2) time_order(1)];
        %type_order = [type_order(2) type_order(1)];
    end
    if is_training || is_testing
        run_empty;
    end
end

end

function run_empty ()
    global PLACE_SLOTS;
    global place;
    global cycles;
    disp('Cycling empty');
    for i = 1:4
        cycle_net(0.*PLACE_SLOTS(1,:), 0.*place(i,:), cycles, 0);
    end


end

function reward_stim(value, cycles, is_replenish)

global REPL;
global is_place_stim;
global is_food_stim;
global pfc_learning;
global hpc_learning;
global HVAL;
global PVAL;
global VAL_PAIR;

global worm;
global peanut;

global PLACE_SLOTS;
global place;

global is_testing;
global ACT_VAL;

% global w_pfc_to_hpc;

% figure;
% imagesc(w_pfc_to_hpc);
% colorbar;
% drawnow;

if ~is_testing
    if is_replenish
        val = REPL;
    else
        val = value;
    end
    is_place_stim = 1;
    is_food_stim = 1;
    VAL_PAIR = val;
    ACT_VAL = 1 / (1 + value(1) + value(2));

    for q = 1:1
        % jay considers input given
        spots = spot_shuffler(14);
        
        for i = spots
            if i < 8
                v = val(worm);
            else
                v = val(peanut);
            end
            HVAL = v;
            PVAL = v;
            
            % disp(['Currently in the recovery phase...value is ', num2str(v)]);
            cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, v);
        end
    end
    
    
    is_place_stim = 0;
    is_food_stim = 0;
    pfc_learning = 0;
    hpc_learning = 0;
    
end

global activity_fig;

figure(activity_fig); %sets current figure to prevent overwriting or ludicrous output
global hpc_collected_activity;
subplot(4,1,1);
imagesc(hpc_collected_activity');
colorbar;
drawnow;
global pfc_collected_activity;
subplot(4,1,2);
imagesc(pfc_collected_activity');
colorbar;
drawnow;
global place_collected_activity;
subplot(4,1,3);
imagesc(place_collected_activity');
colorbar;
drawnow;
global food_collected_activity;
subplot(4,1,4);
imagesc(food_collected_activity');
colorbar;
activity_fig = gcf;
drawnow;

% if is_testing
%     pause;
% end

end

function initialize_weights(cycles, is_disp_weights, VALUE)

    global HPC_SIZE;
    HPC_SIZE = 200;                 % 2 x 14 possible combinations multipled
    global PFC_SIZE;
    PFC_SIZE = 200;

    % by 10 for random connectivity of 10%
    global FOOD_CELLS;
    global PLACE_CELLS;
    FOOD_CELLS = 2;
    PLACE_CELLS = 14;

    EXT_CONNECT = 0.02;                   % Chance of connection = 20%
    INT_CONNECT = 0.1;

    global worm;
    global peanut;
    worm = 1;
    peanut = 2;

    global PEANUT;
    global WORM;
    WORM =  [ 1, -1];
    PEANUT =[-1,  1];

    global r_pfc_lesion_prefs;
    global r_hpc_lesion_prefs;
    global d_pfc_lesion_prefs;
    global d_hpc_lesion_prefs;
    
    global r_prefs;
    global d_prefs;

    r_pfc_lesion_prefs = [];
    r_hpc_lesion_prefs = [];

    d_pfc_lesion_prefs = [];
    d_hpc_lesion_prefs = [];
    
    d_prefs = [];
    r_prefs = [];
    
    global place;
    place = zeros(length(PEANUT), PLACE_CELLS);

    % Weight initialization
    global w_food_to_hpc;
    global w_place_to_hpc;
    global w_hpc_to_food;
    global w_hpc_to_place;

    global w_food_to_food;
    global w_food_in;

    global hpc_in_queue;
    global hpc_weight_queue;
    global food_in_queue;
    global food_weight_queue;

    global place_in_queue;
    global place_weight_queue;

    global hpc_responses_to_place;

    global hpc_cumul_activity;
    hpc_cumul_activity = 0;

    global pfc_cumul_activity;
    pfc_cumul_activity = 0;

    global is_learning;
    is_learning = 1;

    % PFC AREA

    global w_food_to_pfc;
    global w_place_to_pfc;
    global w_pfc_to_food;
    global w_pfc_to_place;

    global w_food_to_pfc_prev;
    global w_place_to_pfc_prev;
    global w_pfc_to_food_prev;
    global w_pfc_to_place_prev;

    global pfc_in_queue;
    global pfc_weight_queue;
    global pfc_responses_to_place;

    pfc_in_queue = {};
    pfc_weight_queue = {};

    global pfc_eye;
    global w_pfc_to_pfc;

    pfc_eye = eye(PFC_SIZE);
    %w_pfc_to_pfc = zeros(PFC_SIZE);
    
    
    %%   was 0.55
    w_food_to_pfc = 1 .* (rand(FOOD_CELLS, PFC_SIZE) < EXT_CONNECT);
    w_pfc_to_food = w_food_to_pfc';
    w_place_to_pfc = 1 .* (rand(PLACE_CELLS, PFC_SIZE) < EXT_CONNECT);
    w_pfc_to_place = w_place_to_pfc';

    global w_pfc_to_hpc;
    w_pfc_to_hpc = 0 .* (rand(PFC_SIZE, HPC_SIZE) < EXT_CONNECT);
    global w_pfc_to_hpc_init;
    w_pfc_to_hpc_init = w_pfc_to_hpc;
    global w_pfc_to_hpc_prev
    w_pfc_to_hpc_prev = w_pfc_to_hpc;

    % global w_pfc_to_pfc;
    w_pfc_to_pfc = 0.00 .* (rand(PFC_SIZE, PFC_SIZE) < INT_CONNECT);
    global w_pfc_to_pfc_init;
    w_pfc_to_pfc_init = w_pfc_to_pfc;
    global w_pfc_to_pfc_prev;
    w_pfc_to_pfc_prev = w_pfc_to_pfc;

    % w_food_to_pfc = 0 .* (rand(FOOD_CELLS, PFC_SIZE) < EXT_CONNECT);
    % w_pfc_to_food = w_food_to_pfc';
    % w_place_to_pfc = 0 .* (rand(PLACE_CELLS, PFC_SIZE) < EXT_CONNECT);
    % w_pfc_to_place = w_place_to_pfc';

    global w_pfc_to_place_init;
    global w_place_to_pfc_init;
    w_pfc_to_place_init = w_pfc_to_place;
    w_place_to_pfc_init = w_place_to_pfc;

    w_food_to_pfc_prev = w_food_to_pfc;
    w_place_to_pfc_prev = w_place_to_pfc;
    w_pfc_to_food_prev = w_pfc_to_food;
    w_pfc_to_place_prev = w_pfc_to_place;

    pfc_responses_to_place = zeros(PLACE_CELLS, HPC_SIZE);
    % end PFC!

    place_in_queue = {};
    place_weight_queue = {};

    hpc_in_queue = {};
    hpc_weight_queue = {};

    food_in_queue = {};
    food_weight_queue = {};

    w_food_in = eye(FOOD_CELLS);
    w_food_to_food = zeros(FOOD_CELLS);

    % HPC WEIGHTS
    global w_hpc_to_hpc;
    w_hpc_to_hpc = 0.0 .* (rand(HPC_SIZE, HPC_SIZE) < INT_CONNECT);

    w_food_to_hpc = 2 .* (rand(FOOD_CELLS, HPC_SIZE) < EXT_CONNECT);
    w_hpc_to_food = w_food_to_hpc';
    w_place_to_hpc = 2 .* (rand(PLACE_CELLS, HPC_SIZE) < EXT_CONNECT);
    w_hpc_to_place = w_place_to_hpc';

    global w_hpc_to_place_init;
    global w_place_to_hpc_init;

    w_hpc_to_place_init = w_hpc_to_place;
    w_place_to_hpc_init = w_place_to_hpc;

    global hpc;
    global place_region;
    global food;

    global w_hpc_to_hpc_init;
    w_hpc_to_hpc_init = w_hpc_to_hpc;
    global w_hpc_to_hpc_prev;
    w_hpc_to_hpc_prev = w_hpc_to_hpc;

    global pfc;

    pfc = zeros(cycles, PFC_SIZE);
    hpc = zeros(cycles, HPC_SIZE);
    food = zeros(cycles, FOOD_CELLS);
    place_region = zeros(cycles, PLACE_CELLS);
    hpc_responses_to_place = zeros(PLACE_CELLS, HPC_SIZE);

    global hpc_collected_activity;
    hpc_collected_activity = zeros(1, HPC_SIZE);

    global pfc_collected_activity;
    pfc_collected_activity = zeros(1, PFC_SIZE);

    global place_collected_activity;
    place_collected_activity = zeros(1, PLACE_CELLS);

    global food_collected_activity;
    food_collected_activity = zeros(1, FOOD_CELLS);

    global PLACE_SLOTS;

    PLACE_SLOTS = zeros(PLACE_CELLS);

    %%%%%%%%%%%%%%%%%%%PLACE STRENGTH
    PLACE_STR = 2;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    side1 = 1*(rand(1, PLACE_CELLS) < PLACE_STR/2);
    side2 = 1*(rand(1, PLACE_CELLS) < PLACE_STR/2);

    PLACE_SLOTS = PLACE_STR*eye(14);

    % Food is pre-stored.
    for i = 1:PLACE_CELLS
        if i <= 7
            place(:,i) = WORM;
            PLACE_SLOTS(i,:) = PLACE_SLOTS(i,:) + [ones(1,7), zeros(1,7)];
        else
            place(:,i) = PEANUT;
            PLACE_SLOTS(i,:) = PLACE_SLOTS(i,:) + [zeros(1,7), ones(1,7)];
        end
    end
    
    PLACE_SLOTS(1:7, :) = PLACE_SLOTS(1:7, :) - 2*PLACE_SLOTS(8:14,:);
    PLACE_SLOTS(8:14,:) = PLACE_SLOTS(8:14,:) - 2*PLACE_SLOTS(1:7 ,:);

%     PLACE_SLOTS = eye(PLACE_CELLS) .* 3;
    
    place = place';

    % filename = horzcat(TRIAL_DIR, 'before training', '_variables');
    % save(filename);

end