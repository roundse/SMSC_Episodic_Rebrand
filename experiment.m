function [avg_checks side_pref checked_places] = experiment(is_disp_weights)

global cycles;

% NOTE TO SELF
% INPUT STRENGTH SET TO ONE
global INP_STR;
INP_STR = 3;
global GAIN;
GAIN = 5;

%global learning_rate;
%learning_rate = 0.084;

global HPC_SIZE;
HPC_SIZE = 250;                 % 2 x 14 possible combinations multipled
% by 10 for random connectivity of 10%
global FOOD_CELLS;
global PLACE_CELLS;
FOOD_CELLS = 2;
PLACE_CELLS = 14;

EXT_CONNECT = .1;                   % Chance of connection = 10%
INT_CONNECT = .1;

global VALUE;
VALUE = [3 1];                  % Worm and peanut, respectively.

global worm;
global peanut;
worm = 1;
peanut = 2;

global PEANUT;
global WORM;
PEANUT =[ 1, -1];
WORM =  [-1,  1];

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
hpc_responses_to_place = 0;

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

w_food_to_hpc = 0.3 .* (rand(FOOD_CELLS, HPC_SIZE) < EXT_CONNECT);
w_hpc_to_food = w_food_to_hpc';
w_place_to_hpc = 0.3 .* (rand(PLACE_CELLS, HPC_SIZE) < EXT_CONNECT);
w_hpc_to_place =  w_place_to_hpc';


global w_hpc_to_place_init;
global w_place_to_hpc_init;

w_hpc_to_hpc = -3 .* (rand(HPC_SIZE, HPC_SIZE) < INT_CONNECT);
w_hpc_to_place_init = w_hpc_to_place;
w_place_to_hpc_init = w_place_to_hpc;

global hpc;
global place_region;
global food;

hpc = zeros(cycles, HPC_SIZE);
food = zeros(cycles, FOOD_CELLS);
place_region = zeros(cycles, PLACE_CELLS);
hpc_responses_to_place = zeros(PLACE_CELLS, HPC_SIZE);
PLACE_SLOTS = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 1: Pre-store food in place slots
%         Have agent recover foods from places to learn food/place
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PLACE_STR = 0.1;

w_side = 3 * double(randperm(14)>11);
p_side = 3 * double(randperm(14)>11);

% Food is pre-stored.
for i = 1:PLACE_CELLS
    if i <= 7
        place(:,i) = WORM;
        PLACE_SLOTS(i,:) = (rand(1, PLACE_CELLS) < PLACE_STR) + w_side;
    else
        place(:,i) = PEANUT;
        PLACE_SLOTS(i,:) = (rand(1, PLACE_CELLS) < PLACE_STR) + p_side;
    end
end

place = place';

f_to_h = zeros(2,HPC_SIZE);
p_to_h = zeros(2,HPC_SIZE);
% Agent is recovering food.
for k=1:20
    place_order = randperm(PLACE_CELLS);

    for k = 1:PLACE_CELLS % recover from all slots
        i = place_order(k);
  
        if place(i,:) == WORM
            value = VALUE(worm);
        else
            value = VALUE(peanut);
        end
        
        cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
        hpc_responses_to_place(i,:) = mean(hpc);
        
        if place(i,:) == WORM
            f_to_h(1, :) = f_to_h(1, :) + mean(food * w_food_to_hpc);
            p_to_h(1, :) = p_to_h(1, :) + mean(place_region * w_place_to_hpc);
        else
            f_to_h(2, :) = f_to_h(2, :) + mean(food * w_food_to_hpc);
            p_to_h(2, :) = p_to_h(2, :) + mean(place_region * w_place_to_hpc); 
        end
            
    end
end
figure;
plot((p_to_h(1, :)*(1/7)) - (p_to_h(2, :)*(1/7)));
title(horzcat(num2str(i), ' place ouputs to hpc'));
drawnow;

figure;
plot((f_to_h(1, :)*(1/7)) - (f_to_h(2, :)*(1/7)));
title(horzcat(num2str(i), ' food ouputs to hpc'));
drawnow;

% figure;
% plot(p_to_h(2, :)*(1/7));
% title(horzcat(num2str(i), ' place ouputs to hpc'));
% drawnow;
% 
% figure;
% plot(f_to_h(2, :)*(1/7));
% title(horzcat(num2str(i), ' food ouputs to hpc'));
% drawnow;
show_weights('1st training', is_disp_weights);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % AGENT THINKS ABOUT FOOD AND PALCE ASSOCIATIONS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k=1:10
    place_order = randperm(PLACE_CELLS);

    for k = 1:PLACE_CELLS % recover from all slots
        i = place_order(k);
  
        if place(i,:) == WORM
            value = VALUE(worm);
        else
            value = VALUE(peanut);
        end
        
        cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, value);
        hpc_responses_to_place(i,:) = mean(hpc);
    end
end

show_weights('2nd training', is_disp_weights);

% Determine order spots were checked in
is_learning = 0;
PLACE_SIDES = 2 * [sum(PLACE_SLOTS(1:7,:)); sum(PLACE_SLOTS(8:14,:))];
neutral_input = PLACE_SIDES(1,:) + PLACE_SIDES(2,:);

testing_trials = 6;
hpc_place_responses = zeros(testing_trials,HPC_SIZE);
checked_places = zeros(testing_trials,14);
side_pref = zeros(testing_trials,2);
for k = 1:testing_trials
    bland_input = neutral_input/max(neutral_input) + rand(1,14)/2;
    
    for i = 1:PLACE_CELLS
        cycle_net(bland_input, [0 0], cycles, 1);
    end
    
    hpc_place_responses(k,:) = mean(hpc(3:cycles,:));
    checked_places(k,:) = find_place(hpc_place_responses);
    [side_pref(k, 1) side_pref(k, 2)] = side_preference(checked_places(k,:));
end

avg_checks = mean(checked_places);

figure;
title('Place dist');
plot(avg_checks);
drawnow;
end
