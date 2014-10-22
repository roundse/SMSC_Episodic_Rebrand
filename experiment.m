function [worm_trial pean_trial] = experiment(cycles, ...
    learning_rate, gain_oja, is_disp_weights, VALUE)

% To do:
% - separate pfc and hpc learning
% - create different value systems for hpc / pfc
% - make pfc learn from hpc
% - pfc decay


global GAIN;
GAIN = 5;

global HPC_SIZE;
HPC_SIZE = 250;                 % 2 x 14 possible combinations multipled
% by 10 for random connectivity of 10%
global FOOD_CELLS;
global PLACE_CELLS;
FOOD_CELLS = 2;
PLACE_CELLS = 14;

EXT_CONNECT = .2;                   % Chance of connection = 20%
INT_CONNECT = .1;

global worm;
global peanut;
worm = 1;
peanut = 2;

global PEANUT;
global WORM;
WORM =  [-1,  1];
PEANUT =[ 1, -1];

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
global PFC_SIZE;
PFC_SIZE = 250;

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

%%   8.1 WAS 0.2 0.2
w_food_to_pfc = 0.24 .* (rand(FOOD_CELLS, PFC_SIZE) < EXT_CONNECT);
w_pfc_to_food = w_food_to_pfc';
w_place_to_pfc = 0.24 .* (rand(PLACE_CELLS, PFC_SIZE) < EXT_CONNECT);
w_pfc_to_place = w_place_to_pfc';

global w_pfc_to_hpc;
w_pfc_to_hpc = -.15 .* (rand(PFC_SIZE, HPC_SIZE) < EXT_CONNECT);
global w_pfc_to_hpc_init;
w_pfc_to_hpc_init = w_pfc_to_hpc;
global w_pfc_to_hpc_prev
w_pfc_to_hpc_prev = w_pfc_to_hpc;

% global w_pfc_to_pfc;
w_pfc_to_pfc = 0 .* (rand(PFC_SIZE, PFC_SIZE) < INT_CONNECT);
global w_pfc_to_pfc_init;
w_pfc_to_pfc_init = w_pfc_to_pfc;
global w_pfc_to_pfc_prev;
w_pfc_to_pfc_prev = w_pfc_to_pfc;

global w_hpc_to_hpc;
w_hpc_to_hpc = .01 .* (rand(HPC_SIZE, HPC_SIZE) < INT_CONNECT);
global w_hpc_to_hpc_init;
w_hpc_to_hpc_init = w_hpc_to_hpc;
global w_hpc_to_hpc_prev;
w_hpc_to_hpc_prev = w_hpc_to_hpc;


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

global pfc;
pfc = zeros(cycles, PFC_SIZE);

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

w_food_to_hpc = 0.78 .* (rand(FOOD_CELLS, HPC_SIZE) < EXT_CONNECT);
w_hpc_to_food = - w_food_to_hpc';
w_place_to_hpc = 0.78 .* (rand(PLACE_CELLS, HPC_SIZE) < EXT_CONNECT);
w_hpc_to_place =  - w_place_to_hpc';

% w_food_to_hpc = 0 .* (rand(FOOD_CELLS, HPC_SIZE) < EXT_CONNECT);
% w_hpc_to_food = - w_food_to_hpc';
% w_place_to_hpc = 0 .* (rand(PLACE_CELLS, HPC_SIZE) < EXT_CONNECT);
% w_hpc_to_place =  - w_place_to_hpc';

global w_hpc_to_place_init;
global w_place_to_hpc_init;

w_hpc_to_place_init = w_hpc_to_place;
w_place_to_hpc_init = w_place_to_hpc;

global hpc;
global place_region;
global food;

global hpc_average;
global pfc_average;

hpc = zeros(cycles, HPC_SIZE);
food = zeros(cycles, FOOD_CELLS);
place_region = zeros(cycles, PLACE_CELLS);
hpc_responses_to_place = zeros(PLACE_CELLS, HPC_SIZE);

global PLACE_SLOTS;
global TRIAL_DIR;

PLACE_SLOTS = zeros(PLACE_CELLS);

PLACE_STR = 0.4;

side1 = 1*(rand(1, PLACE_CELLS) < PLACE_STR/2);
side2 = 1*(rand(1, PLACE_CELLS) < PLACE_STR/2);

% Food is pre-stored.
for i = 1:PLACE_CELLS
    if i <= 7
        place(:,i) = WORM;
        PLACE_SLOTS(i,:) = 1*(rand(1, PLACE_CELLS) < PLACE_STR) + side1 - side2;
    else
        place(:,i) = PEANUT;
        PLACE_SLOTS(i,:) = 1*(rand(1, PLACE_CELLS) < PLACE_STR) - side1 + side2;
    end
end

place = place';

% filename = horzcat(TRIAL_DIR, 'before training', '_variables');
% save(filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRE: Agent stores both foods. Consolidates 124 hours and is allowed to
% retrieve the foods. Learns worms decay.
% Then agent stores both foods. Consolidates 4 hours and then is
% allowed to retrieve the foods. Learns worms are still good.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run_protocol('training', cycles, is_disp_weights, VALUE);

%
% filename = horzcat(TRIAL_DIR, 'after training', '_variables');
% save(filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TESTING: Agent stores one food, consolidates either 4 or 124 hours, then
% stores the second food, and consolidates the leftover time.
% Then gets to recover its caches.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[worm_trial pean_trial] = ...
    run_protocol('testing', cycles, is_disp_weights, VALUE);


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
else
    range = finish - start+1;
    numsets = (start : finish);
    perm = randperm(range);
    
    for i=1:range
        p = perm(i);
        places(i) = numsets(p);
    end
end
end

function [worm_trial pean_trial] = ...
    run_protocol (prot_type, cycles, is_disp_weights, VALUE)
global PLACE_SLOTS;

global worm;   global WORM;
global peanut; global PEANUT;

global REPL; global PILF; global DEGR;

global PVAL;
global HVAL;

if VALUE == 1
    value = DEGR;
    disp('DEGRADE TRIAL~~~~~~~~~~~~~~~~~~~~~~~~~~');
    
elseif VALUE == 3
    value = REPL;
    disp('REPLENISH TRIAL~~~~~~~~~~~~~~~~~~~~~~~~');
    
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
time_lengths = [120, 4];
%     time_lengths = [1, 1];

type_order = randperm(2);
time_order = randperm(2);

global is_testing;
is_testing = strcmp(prot_type, 'testing');

global is_learning;

if is_testing
    duration = 2;
    
    if lesion_hpc || lesion_pfc
        disp('~~LESION TRIAL!~~');
    end
else
    duration = 4;
end

global hpc_average;
global pfc_average;

global hpc;
global pfc;

hpc_average = hpc(1,:);
pfc_average = pfc(1,:);

PVAL = 1;
HVAL = 1;

for j=1:duration
    for l=1:2
        is_learning = 0;
        
        % if testing time is always 4 then 120
        if is_testing
            current_time = time_lengths(l);
            current_type = food_types(type_order(l));
            
            % otherwise time is randomly one way or the other
        else
            current_time = time_lengths(time_order(l));
            current_type = food_types(type_order(l));
            
        end
        
        if current_type == worm
            disp('worm');
        else
            disp('peanut');
        end
        
        if is_testing
            if l == 1
                current_place = 'First';
            else
                current_place = 'Second';
            end
        else
            current_place = 'First stored food is';
        end
        
        if is_testing
            is_replenish =  current_type == worm & current_time == 4;
        else
            is_replenish = current_time == 4;
        end
        
        disp([current_place, ' consolidation period is: ', num2str(current_time)]);
        
        if is_testing
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
        
        is_place_stim = 1;
        is_food_stim = 1;
        for i = spots
            if i < 8
                v = abs(value(worm));
            else
                v = abs(value(peanut));
            end
            while place(i,:) == 0
                place(i,:) = current_type;
            end
            %             if is_testing
            %disp(['Currently in the caching phase...value is ', num2str(v)]);
            %             end
            cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, v);
        end
        is_place_stim = 0;
        is_food_stim = 0;
        % consolidate
        
        if is_testing
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
        
        hpc_cumul_activity = 0;
        pfc_cumul_activity = 0;
        
        
        
        
        
        % TURN THIS ON/OF FOR LEARNING DURING TESTING/TRAINING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        hpc_learning = 1;
        pfc_learning = 1;
        if ~is_testing
            pfc_learning = 1;
            hpc_learning = 1;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        for q = 1:current_time
            
            if is_testing
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
            
            for i = spots
                if i < 8
                    v = val(worm);
                else
                    v = val(peanut);
                end
                
                PVAL = 0;
                HVAL = 0;
                %                   if is_testing
                %disp(['Currently in the consolidating phase...value is ', num2str(0)]);
                %                   end
                cycle_net( PLACE_SLOTS(i,:), place(i,:), cycles, 0);
                
            end
        end
        hpc_learning = 0;
        pfc_learning = 0;
        
        show_weights([prot_type, ' ', num2str(current_time)], is_disp_weights);
        
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
        
        if ~is_testing
            pfc_learning = 1;
            hpc_learning = 1;
            PVAL = v;
            HVAL = v;
            
            reward_stim(value, cycles, is_replenish);
        end
    end
    
    if is_testing
        [checked_places, side_pref, avg_checks, first_checked] ...
            = place_slot_check;
        
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
        
        food_types = [food_types(2) food_types(1)];
        
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
    
    %     if is_testing
    %         hpc_learning = 1;
    %         reward_stim(value, cycles, is_replenish);
    %     end
end

% 	if ~is_testing
%         rein_dur = 2;
%
%         for t  = 1:rein_dur
%             for q = 1:2
%                 pfc_learning = 1;
%                 hpc_learning = 1;
%
%                 spots = spot_shuffler(14);
%
%                 for i = spots
%                     HVAL = 0;
%                     PVAL = 0;
%
%                     cycle_net( PLACE_SLOTS(i,:), place(i,:), cycles, v);
%                 end
%             end
%
%         end
%
%         pfc_learning = 0;
%         hpc_learning = 0;
%     end
end

function reward_stim(value, cycles, is_replenish)

global REPL;
global is_place_stim;
global is_food_stim;
global pfc_learning;
global hpc_learning;
global HVAL;
global PVAL;

global worm;
global peanut;

global PLACE_SLOTS;
global place;

if is_replenish
    val = REPL;
else
    val = value;
end
is_place_stim = 1;
is_food_stim = 1;

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
