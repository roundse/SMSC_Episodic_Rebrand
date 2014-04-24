function [avg_checks side_pref checked_places first_checked] = ...
    bg_experiment(trial_type, cycles, is_disp_weights)

global INP_STR;
global GAIN;
GAIN = 5;


%%% NEW (4/8/14) %%%%%
global PFC_SIZE;
PFC_SIZE = 250;
%%%%%%%%%%%%%%%%%%%%%%%

global HPC_SIZE;
HPC_SIZE = 250;                 % 2 x 14 possible combinations multipled
% by 10 for random connectivity of 10%
global FOOD_CELLS;
global PLACE_CELLS;
FOOD_CELLS = 2;
PLACE_CELLS = 14;

EXT_CONNECT = .2;                   % Chance of connection = 20%
INT_CONNECT = .2;

global VALUE;

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
global w_hpc_to_hpc;

%%%% NEW WEIGHTS (4/8/14) %%%%
global w_food_to_place;
global w_place_to_food;

global w_pfc_to_hpc;

global w_food_to_pfc;
global w_place_to_pfc;
global w_pfc_to_food;
global w_pfc_to_place;

global pfc_in_queue;
global pfc_weight_queue;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global w_food_to_food;
global w_food_in;

global hpc_in_queue;
global hpc_weight_queue;
global food_in_queue;
global food_weight_queue;

global place_in_queue;
global place_weight_queue;

global hpc_responses_to_place;
global pfc_responses_to_place;

global is_learning;
is_learning = 1;

place_in_queue = {};
place_weight_queue = {};

hpc_in_queue = {};
hpc_weight_queue = {};

pfc_in_queue = {};
pfc_weight_queue = {};

food_in_queue = {};
food_weight_queue = {};

w_food_in = eye(FOOD_CELLS);
w_food_to_food = zeros(FOOD_CELLS);

global base_inh;

base_inh = -.0001;

w_food_to_hpc = .05 .* (rand(FOOD_CELLS, HPC_SIZE) < EXT_CONNECT);
w_hpc_to_food = w_food_to_hpc';
w_place_to_hpc = .05 .* (rand(PLACE_CELLS, HPC_SIZE) < EXT_CONNECT);
w_hpc_to_place = w_place_to_hpc';

%%%% ADDING IN THE NEW WEIGHTS (4/8/14)
w_food_to_place = .05 .* ones(FOOD_CELLS, PLACE_CELLS);
w_place_to_food = w_food_to_place';
w_food_to_pfc = .01 .* (rand(FOOD_CELLS, PFC_SIZE) < EXT_CONNECT);
w_pfc_to_food = w_food_to_pfc';
w_place_to_pfc = .01 .* (rand(PLACE_CELLS, PFC_SIZE) < EXT_CONNECT);
w_pfc_to_place = w_place_to_pfc';
%w_pfc_to_hpc = base_inh .* ones(PFC_SIZE, HPC_SIZE);

global w_pfc_to_place_init;
global w_place_to_pfc_init;
w_pfc_to_place_init = w_pfc_to_place;
w_place_to_pfc_init = w_place_to_pfc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


global w_hpc_to_place_init;
global w_place_to_hpc_init;

w_hpc_to_hpc = 0 .* (rand(HPC_SIZE, HPC_SIZE) < INT_CONNECT);
w_hpc_to_place_init = w_hpc_to_place;
w_place_to_hpc_init = w_place_to_hpc;

global pfc;
global hpc;
global place_region;
global food;

% duration of consolidation
global consolidation_length;

pfc = zeros(cycles, PFC_SIZE);
hpc = zeros(cycles, HPC_SIZE);
food = zeros(cycles, FOOD_CELLS);
place_region = zeros(cycles, PLACE_CELLS);
hpc_responses_to_place = zeros(PLACE_CELLS, HPC_SIZE);
pfc_responses_to_place = zeros(PLACE_CELLS, HPC_SIZE);

global PLACE_SLOTS;

PLACE_SLOTS = zeros(PLACE_CELLS);

PLACE_STR = 0.4;

side1 = 1*(rand(1, PLACE_CELLS) < PLACE_STR/2);

side2 = 1*(rand(1, PLACE_CELLS) < PLACE_STR/2);

% Food is pre-stored.
for i = 1:PLACE_CELLS
    if i <= 7
        place(:,i) = WORM;
        PLACE_SLOTS(i,:) = 1*(rand(1, PLACE_CELLS) < PLACE_STR) + side1 ...
            - side2;
    else
        place(:,i) = PEANUT;
        PLACE_SLOTS(i,:) = 1*(rand(1, PLACE_CELLS) < PLACE_STR) - side1 ...
            + side2;
    end
end

place = place';

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Task 1: Pre-store food in place slots
% %         Have agent recover foods from places to learn food/place
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% % given food without value
% stored_val = VALUE;
% VALUE = [1 1];
% value = 1;
%
%
% activity1 = 0;
% activity2 = 0;
% for k=1:1
%     place_order = randperm(PLACE_CELLS);
%
%     for j = 1:PLACE_CELLS % recover from all slots
%         i = place_order(j);
%
%         [fpa hpc_sum(j) pfc_sum(j)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), ...
% cycles, value);
%     end
%     m1(k) = mean(hpc_sum);
%     m2(k) = mean(pfc_sum);
% end
% activity1 = mean(m1);
% activity2 = mean(m2);
% disp(['HPC - Task 1a: ', num2str(activity1)]);
% disp(['PFC - Task 1a: ', num2str(activity2)]);
%
% for k=1:10
%     place_order = randperm(PLACE_CELLS);
%
%     for j = 1:PLACE_CELLS % recover from all slots
%         i = place_order(j);
%
%         [fpa hpc_sum(j) pfc_sum(j)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), ...
% cycles, value);
%     end
%     m1(k) = mean(hpc_sum);
%     m2(k) = mean(pfc_sum);
% end
% activity1 = mean(m1);
% activity2 = mean(m2);
% disp(['HPC - Task 1b: ', num2str(activity1)]);
% disp(['PFC - Task 1b: ', num2str(activity2)]);
%
% show_weights('No value', is_disp_weights);
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Task 2: Agent stores food in place slots
% %         Have agent recover foods from places, but this time with
% %         value
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% % given food with value
% VALUE = stored_val;
% activity1 = 0;
% activity2 = 0;
% for k=1:1
%     place_order = randperm(PLACE_CELLS);
%
%     for j = 1:PLACE_CELLS
%         i = place_order(j);
%
%         if place(i,:) == WORM
%             value = VALUE(worm);
%         else
%             value = VALUE(peanut);
%         end
%
%         [fpa hpc_sum(j) pfc_sum(j)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
%     end
%     m1(k) = mean(hpc_sum);
%     m2(k) = mean(pfc_sum);
% end
% activity1 = mean(m1);
% activity2 = mean(m2);
% disp(['HPC - Task 2a: ', num2str(activity1)]);
% disp(['PFC - Task 2a: ', num2str(activity2)]);
%
% % given food with value
% for k=1:30
%     place_order = randperm(PLACE_CELLS);
%
%     for j = 1:PLACE_CELLS
%         i = place_order(j);
%
%         if place(i,:) == WORM
%             value = VALUE(worm);
%         else
%             value = VALUE(peanut);
%         end
%         [fpa hpc_sum(j) pfc_sum(j)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
%     end
%     m1(k) = mean(hpc_sum);
%     m2(k) = mean(pfc_sum);
% end
% activity1 = mean(m1);
% activity2 = mean(m2);
% disp(['HPC Task 2b: ', num2str(activity1)]);
% disp(['PFC Task 2b: ', num2str(activity2)]);
%
% show_weights('Cached with value ', is_disp_weights);
%
% global TRIAL_DIR;
% filename = horzcat(TRIAL_DIR, 'post learning', '_variables');
% save(filename);
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Task 3: Agent stores food in place slots
% %         Have agent recover foods from places, see if it chooses
% %         highest-value places.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% is_learning = false;
% place_order = randperm(PLACE_CELLS);
% activity1 = 0;
% activity2 = 0;
% for k=1:1
%     place_order = randperm(PLACE_CELLS);
%
%     for j = 1:PLACE_CELLS
%         i = place_order(j);
%
%         if place(i,:) == WORM
%             value = VALUE(worm);
%         else
%             value = VALUE(peanut);
%         end
%
%         [fpa hpc_sum(j) pfc_sum(j)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
%
%         hpc_responses_to_place(i,:) = mean(hpc(3:cycles,:));
%         pfc_responses_to_place(i,:) = mean(pfc(3:cycles, :));
%     end
%     m1(k) = mean(hpc_sum);
%     m2(k) = mean(pfc_sum);
% end
% activity1 = mean(m1);
% activity2 = mean(m2);
% disp(['HPC Task 3a: ', num2str(activity1)]);
% disp(['PFC Task 3a: ', num2str(activity2)]);
% for k=1:10
%     place_order = randperm(PLACE_CELLS);
%
%     for j = 1:PLACE_CELLS
%         i = place_order(j);
%
%         if place(i,:) == WORM
%             value = VALUE(worm);
%         else
%             value = VALUE(peanut);
%         end
%
%         [fpa hpc_sum(j) pfc_sum(j)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
%
%         hpc_responses_to_place(i,:) = mean(hpc(3:cycles,:));
%         pfc_responses_to_place(i,:) = mean(pfc(3:cycles, :));
%     end
%     m1(k) = mean(hpc_sum);
%     m2(k) = mean(pfc_sum);
% end
% activity1 = mean(m1);
% activity2 = mean(m2);
% disp(['HPC Task 3b: ', num2str(activity1)]);
% disp(['PFC Task 3b: ', num2str(activity2)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRE: Agent stores both foods. Consolidates 124 hours and is allowed to
%           retrieve the foods. Learns worms decay.
%         Then agent stores both foods. Consolidates 4 hours and then is
%         allowed to retrieve the foods. Learns worms are still good.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% given food with value
% given food with value
% VALUE = stored_val;
%
%
% 4 pairs of pre trials
%
% TO DO:
% - output what pair of trials it is on
% - output which trial it is on
% - output which food is first and which consolidation period it is
% - change VALUES to reflect what it learns based on consolidation duration
% - output values along with food and consoliation period to make sure that
%   the correct value is being taught
%
%
% - output activity and weights to see what is happening.
%
% WRITE THE TESTING PROTOCOL:
% - This is exactly the same except that consolidation period happens right
%   after caching.

switch trial_type
    case 1
        values = [5 2];
    case 2
        values = [1 2];
    case 3
        values = [-1.5 2];
end

default_val = [5 2];

% food_types = [peanut worm];
% time_lengths = [4, 120];
%
% type_order = randperm(2);
% time_order = randperm(2);
%
% for j=1:4
%     disp(['Training pair ', num2str(j)]);
%     for l=1:2
%         current_type = food_types(type_order(l));
%         current_time = time_lengths(time_order(l));
%
%         if current_time == 4
%             value1 = default_val;
%             %             value2 = values;
%         else
%             value1 = values;
%             %             value2 = default_val;
%         end
%
%         if current_type == peanut
%             disp('First food to be stored is peanut');
%         else
%             disp('First food to be stored is worm');
%         end
%
%
%         disp(['First consolidation period is: ', num2str(current_time)]);
%
%         if current_type == worm
%             spots = spot_shuffler(7);
%         else
%             spots = spot_shuffler(8,14);
%         end
%
%         for i = spots
%             while place(i,:) == 0
%                 place(i,:) = current_type;
%             end
%             val = default_val(current_type);
%             cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, val);
%         end
%
%         % consolidate
%         spots = spot_shuffler(14);
%         for i = spots
%
%             if place(i,:) == WORM
%                 value = value1(1);
%
%             elseif place(i,:) == PEANUT
%                 value = value1(2);
%
%             end
%
%             [fpa hpc_sum(i) pfc_sum(i)] = cycle_net(PLACE_SLOTS(i,:), ...
%                 place(i,:), cycles*current_time, value); %, m1, m2);
%         end
%         m1 = mean(hpc_sum);
%         m2 = mean(pfc_sum);
%
%         activity1 = mean(m1);
%         activity2 = mean(m2);
%
%         disp(['HPC Consolidate: ', num2str(activity1)]);
%         disp(['PFC Consolidate: ', num2str(activity2)]);
%     end
%
%     time_order = [time_order(2) time_order(1)];
% end



worm_4_1 = false;
peanut_4_1 = false;
worm_120_1 = false;
peanut_120_1 = false;

for j = 1:4
    m1 = 0;
    m2 = 0;
    base_inh = -.0001;
    w_pfc_to_hpc = base_inh .* ones(PFC_SIZE, HPC_SIZE);
    
    disp(['Training pair ', num2str(j)]);
    
    not_found = false;
    while ( ~not_found )
        f = rand;
        if f < 0.5
            food1 = worm;
            food2 = peanut;
        else
            food1 = peanut;
            food2 = worm;
        end
        t = rand;
        if t < 0.5
            time1 = 4;
            time2 = 120;
        else
            time1 = 120;
            time2 = 4;
        end
        
        if food1 == worm && time1 == 4 && ~worm_4_1
            worm_4_1 = true;
            not_found = true;
        elseif food1 == worm && time1 == 120 && ~worm_120_1
            worm_120_1 = true;
            not_found = true;
        elseif food1 == peanut && time1 == 4 && ~peanut_4_1
            peanut_4_1 = true;
            not_found = true;
        elseif food1 == peanut && time1 == 120 && ~peanut_120_1
            peanut_120_1 = true;
            not_found = true;
        end    
    end
    
    if time1 == 4
        value1 = default_val;
        value2 = values;
    elseif time1 == 120
        value1 = values;
        value2 = default_val;
    end
    
    for k = 1:2
        if k == 1
            if food1 == 1
                disp('First food to be stored is worm');
            else
                disp('First food to be stored is peanut');
            end
            disp(['First consolidation period is: ', num2str(time1)]);
        else
            if food2 == 1
                disp('Second food to be stored is worm');
            else
                disp('Second food to be stored is peanut');
            end
            disp(['Second consolidation period is: ', num2str(time2)]);
        end
        
        if food1 == worm
            %value = VALUE(worm);
            spots = spot_shuffler(7);
            for q = 1:7
                i = spots(q);
                while place(i,:) == 0
                    place(i,:) = WORM;
                end
                %[fpa hpc_suma(i) pfc_suma(i)] =
                cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, ...
                    default_val(1)); % !BUG
            end
            %value = VALUE(peanut);
            spots = spot_shuffler(8, 14);
            for i = spots
                while place(i,:) == 0
                    place(i,:) = PEANUT;
                end
                %[fpa hpc_sumb(i) pfc_sumb(i)] =
                cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, ...
                    default_val(2));
            end
            %             hpc_sum(:) = hpc_suma(:) + hpc_sumb(:);
            %             pfc_sum(:) = pfc_suma(:) + pfc_sumb(:);
            %             m1 = mean(hpc_sum);
            %             m2 = mean(pfc_sum);
        else
            %value = VALUE(peanut);
            spots = spot_shuffler(8, 14);
            for i = spots
                while place(i,:) == 0
                    place(i,:) = PEANUT;
                end
                %[fpa hpc_suma(j) pfc_suma(j)] =
                cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, ...
                    default_val(2));
            end
            %value = VALUE(worm);
            spots = spot_shuffler(7);
            for i = spots
                while place(i,:) == 0
                    place(i,:) = WORM;
                end
                %[fpa hpc_sumb(j) pfc_sumb(j)] =
                cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, ...
                    default_val(1));
            end
            %             hpc_sum(:) = hpc_suma(:) + hpc_sumb(:);
            %             pfc_sum(:) = pfc_suma(:) + pfc_sumb(:);
            %             m1 = mean(hpc_sum);
            %             m2 = mean(pfc_sum);
        end
        %         activity1 = mean(m1);
        %         activity2 = mean(m2);
        %         disp(['HPC Storage: ', num2str(activity1)]);
        %         disp(['PFC Storage: ', num2str(activity2)]);
        
        if k == 1
            spots = spot_shuffler(14);
            for i = spots
                
                if place(i,:) == WORM
                    value = value1(1);
                    
                elseif place(i,:) == PEANUT
                    value = value1(2);
                    
                end
                
                [fpa hpc_sum(i) pfc_sum(i)] = cycle_net(PLACE_SLOTS(i,:), ...
                    place(i,:), cycles*time1, value, m1, m2);
            end
            %             disp(base_inh);
            %             pause;
            %             disp(w_pfc_to_hpc);
            %             pause;
            m1 = mean(hpc_sum);
            m2 = mean(pfc_sum);
        else
            spots = spot_shuffler(14);
            for i = spots
                
                if place(i,:) == WORM
                    value = value2(1);
                elseif place(i,:) == PEANUT
                    value = value2(2);
                end
                
                [fpa hpc_sum(i) pfc_sum(i)] = cycle_net(PLACE_SLOTS(i,:), ...
                    place(i,:), cycles*time2, value, m1, m2);
            end
            m1 = mean(hpc_sum);
            m2 = mean(pfc_sum);
        end
        activity1 = mean(m1);
        activity2 = mean(m2);
        
        disp(['HPC Consolidate: ', num2str(activity1)]);
        disp(['PFC Consolidate: ', num2str(activity2)]);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TESTING: Agent stores one food, consolidates either 4 or 124 hours, then
%           stores the second food, and consolidates the leftover time.
%           Then gets to recover its caches.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%for j = 1:4
%disp([' pair ', num2str(j)]);

time1 = 120;
time2 = 4;

%for k = 1:2
%if k == 1

for i = 1:10
    base_inh = -.0001;
    w_pfc_to_hpc = base_inh .* ones(PFC_SIZE, HPC_SIZE);
    
    f = rand;
    if f < 0.5
        food1 = worm;
        food2 = peanut;
    else
        food1 = peanut;
        food2 = worm;
    end
    
    disp('TESTING');
    if food1 == worm
        disp('Trial type: Degrade --- 124 hr');
        disp('First food to be stored is worm');
        disp('Second food to be stored is peanut');
    else
        disp('Trial type: Degrade --- 4 hr');
        disp('First food to be stored is peanut');
        disp('Second food to be stored is worm');
    end
    
    if food1 == worm
        v = values;
        %value = VALUE(worm);
        
        spots = spot_shuffler(7);
        for i = spots
            
            while place(i,:) == 0
                place(i,:) = WORM;
            end
            
            cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, ...
                default_val(1));
        end
        %     value = VALUE(peanut);
        %     for i = 8:14
        %         while place(i,:) == 0
        %             place(i,:) = PEANUT;
        %         end
        %         cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
        %     end
    else
        %value = VALUE(peanut);
        v = default_val;
        
        spots = spot_shuffler(8, 14);
        for i = spots
            while place(i,:) == 0
                place(i,:) = PEANUT;
            end
            cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, ...
                default_val(2));
        end
        %     value = VALUE(worm);
        %     for i = 1:7
        %         while place(i,:) == 0
        %             place(i,:) = WORM;
        %         end
        %         cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
        %     end
    end
    
    spots = spot_shuffler(PLACE_CELLS);
    for i = spots
        
        if place(i,:) == WORM
            value = v(1);
        elseif place(i,:) == PEANUT
            value = v(2);
        end
        
        [fpa hpc_sum(i) pfc_sum(i)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), ...
            cycles*time1, value);
    end
    
    m1 = mean(hpc_sum);
    m2 = mean(pfc_sum);
    disp(['HPC Consolidation after 120 hours: ', num2str(m1)]);
    disp(['PFC Consolidation after 120 hours: ', num2str(m2)]);
    
    if food1 == worm
        v = default_val;
        spots = spot_shuffler(7);
        for i = spots
            while place(i,:) == 0
                place(i,:) = PEANUT;
            end
            cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
        end
        %     value = VALUE(peanut);
        %     for i = 8:14
        %         while place(i,:) == 0
        %             place(i,:) = PEANUT;
        %         end
        %         cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
        %     end
    else
        v = values;
        spots = spot_shuffler(8,14);
        for i = spots
            while place(i,:) == 0
                place(i,:) = WORM;
            end
            cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
        end
        %     value = VALUE(worm);
        %     for i = 1:7
        %         while place(i,:) == 0
        %             place(i,:) = WORM;
        %         end
        %         cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
        %     end
    end
    
    spots = spot_shuffler(PLACE_CELLS);
    for i = spots
        
        if place(i,:) == WORM
            value = v(1);
        elseif place(i,:) == PEANUT
            value = v(2);
        end
        
        [fpa hpc_sum(i) pfc_sum(i)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), ...
            cycles*time2, value, m1, m2);
    end
    m1 = mean(hpc_sum);
    m2 = mean(pfc_sum);
    
    disp(['HPC Consolidation after ', num2str(time2), ' hours: ', num2str(m1)]);
    disp(['PFC Consolidation after ', num2str(time2), ' hours: ', num2str(m2)]);
    
    
    % if k == 1
    %     for i = 1:14
    %         cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles*time1, value);
    %     end
    % else
    %     for i = 1:14
    %         cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles*time2, value);
    %     end
    % end
    %end
    %end
    
    global TRIAL_DIR;
    filename = horzcat(TRIAL_DIR, 'post learning', '_variables');
    save(filename);
    
    [checked_places side_pref avg_checks first_checked] = place_slot_check; % mean_spot_check();
    
    
    filename = horzcat(TRIAL_DIR, 'after final trial ', '_variables');
    save(filename);
    
    varlist = {'hpc','place_region','food', 'pfc', 'place_in_queue', ...
        'place_weight_queue', 'hpc_in_queue', 'hpc_weight_queue', ...
        'food_in_queue', 'food_weight_queue', 'pfc_in_queue', ...
        'pfc_weight_queue'};
    clear(varlist{:})
end

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

% % given food with value
% VALUE = stored_val;
%
% for k=1:1
%     place_order = randperm(PLACE_CELLS);
%
%     for j = 1:PLACE_CELLS
%         i = place_order(j);
%
%         if place(i,:) == WORM
%             value = VALUE(worm);
%         else
%             value = VALUE(peanut);
%         end
%
%         cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
%     end
% end

function out = varname(var)
out = inputname(1);
end
