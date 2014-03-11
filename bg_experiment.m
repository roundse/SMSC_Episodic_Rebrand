function [avg_checks side_pref checked_places] = bg_experiment(cycles, ... 
    learning_rate, gain_oja, is_disp_weights)

global INP_STR;
INP_STR = 2;
global GAIN;
GAIN = 5;


global HPC_SIZE;
HPC_SIZE = 250;                 % 2 x 14 possible combinations multipled
                                % by 10 for random connectivity of 10%
global FOOD_CELLS;
global PLACE_CELLS;
FOOD_CELLS = 2;
PLACE_CELLS = 14;

EXT_CONNECT = .2;                   % Chance of connection = 10%
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

global w_food_to_food;
global w_food_in;

global hpc_in_queue;
global hpc_weight_queue;
global food_in_queue;
global food_weight_queue;

global place_in_queue;
global place_weight_queue;

global hpc_responses_to_place;

global is_learning;
is_learning = 1;

place_in_queue = {};
place_weight_queue = {};

hpc_in_queue = {};
hpc_weight_queue = {};

food_in_queue = {};
food_weight_queue = {};

w_food_in = eye(FOOD_CELLS);
w_food_to_food = zeros(FOOD_CELLS);

w_food_to_hpc = 0.5 .* (rand(FOOD_CELLS, HPC_SIZE) < EXT_CONNECT);
w_hpc_to_food = - w_food_to_hpc';
w_place_to_hpc = 0.5 .* (rand(PLACE_CELLS, HPC_SIZE) < EXT_CONNECT);
w_hpc_to_place =  - w_place_to_hpc';


global w_hpc_to_place_init;
global w_place_to_hpc_init;

w_hpc_to_hpc = -1 .* (rand(HPC_SIZE, HPC_SIZE) < INT_CONNECT);
w_hpc_to_place_init = w_hpc_to_place;
w_place_to_hpc_init = w_place_to_hpc;

global hpc;
global place_region;
global food;

hpc = zeros(cycles, HPC_SIZE);
food = zeros(cycles, FOOD_CELLS);
place_region = zeros(cycles, PLACE_CELLS);
hpc_responses_to_place = zeros(PLACE_CELLS, HPC_SIZE);

global PLACE_SLOTS;

PLACE_SLOTS = zeros(PLACE_CELLS);

PLACE_STR = 0.4;

% Food is pre-stored.
for i = 1:PLACE_CELLS
    if i <= 7
        place(:,i) = WORM;
        PLACE_SLOTS(i,:) = 1*(rand(1, PLACE_CELLS) < PLACE_STR);
    else
        place(:,i) = PEANUT;
        PLACE_SLOTS(i,:) = 1*(rand(1, PLACE_CELLS) < PLACE_STR);
    end
end

place = place';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 1: Pre-store food in place slots
%         Have agent recover foods from places to learn food/place
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% given food without value
stored_val = VALUE;
VALUE = [1 1];
value = 1;

for k=1:1
    place_order = randperm(PLACE_CELLS);

    for j = 1:PLACE_CELLS % recover from all slots
        i = place_order(j);

        cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
    end
end


for k=1:10
    place_order = randperm(PLACE_CELLS);

    for j = 1:PLACE_CELLS % recover from all slots
        i = place_order(j);

        cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
    end
end

show_weights('No value', is_disp_weights);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 2: Agent stores food in place slots
%         Have agent recover foods from places, but this time with
%         value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% given food with value
VALUE = stored_val;

for k=1:1
    place_order = randperm(PLACE_CELLS);

    for j = 1:PLACE_CELLS
        i = place_order(j);
  
        if place(i,:) == WORM
            value = VALUE(worm);
        else
            value = VALUE(peanut);
        end
        
        cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
    end
end

% given food with value
for k=1:30
    place_order = randperm(PLACE_CELLS);

    for j = 1:PLACE_CELLS
        i = place_order(j);
  
        if place(i,:) == WORM
            value = VALUE(worm);
        else
            value = VALUE(peanut);
        end
        
        cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
    end
end
show_weights('Cached with value ', is_disp_weights);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 3: Agent stores food in place slots
%         Have agent recover foods from places, see if it chooses
%         highest-value places.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
is_learning = false;
place_order = randperm(PLACE_CELLS);

for l=1:PLACE_CELLS
    i = place_order(l);

    food_stim = place(i,:);
    place_stim = PLACE_SLOTS(i,:);

    for j = 3:cycles
        hpc_out = hpc(j-1,:);
        place_out = place_region(j-1,:);
        food_out = food(j-1, :);

        % sets value
        if place(i,:) == WORM
            value = VALUE(worm);
        else
            value = VALUE(peanut);
        end

        cycle_place(place_out, eye(PLACE_CELLS), place_stim, value);
        cycle_place(place_out, w_hpc_to_place, hpc_out, value);

        cycle_food(food_out, eye(FOOD_CELLS), food_stim, value);
        cycle_food(food_out, w_hpc_to_food, hpc_out, value);

        cycle_hpc(hpc_out, w_place_to_hpc, place_out, value);
        cycle_hpc(hpc_out, w_food_to_hpc, food_out, value);

        cycle_hpc(hpc_out, w_food_to_hpc,  food_stim, value);

        hpc(j,:) = cycle_hpc(hpc_out, is_learning);
        place_region(j,:) = cycle_place({place_region(j-1,:), ...
            hpc(j,:)}, is_learning);
        food(j,:) = cycle_food({food(j-1,:), hpc(j,:)}, is_learning);
    end
    hpc_responses_to_place(i,:) = mean(hpc(3:cycles,:));
end

% agent thinks about stored food
collect_size = 10;
for k=1:collect_size
    place_order = randperm(PLACE_CELLS);
    
    for j=1:PLACE_CELLS
        i = place_order(j);
        
        food_stim = place(i,:);
        place_stim = PLACE_SLOTS(i,:);

        for j = 3:cycles
            hpc_out = hpc(j-1,:);
            place_out = place_region(j-1,:);
            food_out = food(j-1, :);

            % sets value
            if place(i,:) == WORM
                value = VALUE(worm);
            else
                value = VALUE(peanut);
            end

            cycle_place(place_out, eye(PLACE_CELLS), place_stim, value);
            cycle_place(place_out, w_hpc_to_place, hpc_out, value);

            cycle_food(food_out, eye(FOOD_CELLS), food_stim, value);
            cycle_food(food_out, w_hpc_to_food, hpc_out, value);

            cycle_hpc(hpc_out, w_place_to_hpc, place_out, value);
            cycle_hpc(hpc_out, w_food_to_hpc, food_out, value);

            cycle_hpc(hpc_out, w_food_to_hpc, food_stim, value);

            hpc(j,:) = cycle_hpc(hpc_out, is_learning);
            place_region(j,:) = cycle_place({place_region(j-1,:), ...
                hpc(j,:)}, is_learning);
            food(j,:) = cycle_food({food(j-1,:), hpc(j,:)}, is_learning);
        end
        hpc_responses_to_place(i,:) = mean(hpc(3:cycles,:));
    end
end

% food is retrieved from store
is_learning = 0;
neutral_input = sum(PLACE_SLOTS);

testing_trials = 6;
hpc_place_responses = zeros(testing_trials,HPC_SIZE);
checked_places = zeros(testing_trials,14);
side_pref = zeros(testing_trials,2);
for k = 1:testing_trials
    bland_input = neutral_input/max(neutral_input) + rand(1,14)/2;
    
    for i = 1:PLACE_CELLS
        cycle_net(PLACE_SLOTS(2,:), [0.3 0.3], cycles, 0);
    end
    hpc_place_responses(k,:) = mean(hpc(3:cycles,:));
    checked_places(k,:) = find_place(hpc_place_responses(k,:));
    [side_pref(k, 1) side_pref(k, 2)] = side_preference(checked_places(k,:));
end

avg_checks = mean(checked_places);

figure;
title('Place dist');
plot(avg_checks);
drawnow;

varlist = {'hpc','place_region','food', 'place_in_queue', ...
    'place_weight_queue', 'hpc_in_queue', 'hpc_weight_queue', ...
    'food_in_queue', 'food_weight_queue'};
clear(varlist{:})
end