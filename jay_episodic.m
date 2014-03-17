function jay_episodic()
clear;
close all;
clc;

global learning_rate;
global gain_oja;
global INP_STR;
global cycles;
global VALUE;

INP_STR = 2;
gain_step = .04;
gain_max = 0.7;

runs = 20;
cycles = 14; %14;
values = [6 1.5; 0 2; -1 2];

gain_oja = 0.7;
learning_rate = 0.3;


global pos
global DIR;
global TRIAL_DIR;
DIR = datestr(now);
DIR = strrep(DIR,':',' ');
mkdir(DIR);

pos = 0;
place_responses = zeros(runs, 14);
place_stats = zeros(runs, 2);
filename = horzcat(DIR, '\trial_data', '.mat');

is_disp_weights = 0;
v = 1;
% profile on
while v <= length(values)
    VALUE = values(v,:); %worm, peanut

    for i = 1:runs
        TRIAL_DIR = horzcat(DIR, '\', num2str(i),'\');
        mkdir(TRIAL_DIR);
        init_val = VALUE;
        
        [place_responses(i,:) side_pref checked_place] = bg_experiment(cycles, ...
            learning_rate, gain_oja, is_disp_weights);
        
        place_stats(i,:) = mean(side_pref);
        checked_places{i} = checked_place;
        is_disp_weights = false;
        message = horzcat('trial ', num2str(i), ' complete');
        disp(message);
    end

    trials{v} = {INP_STR, VALUE, mean(place_stats(:,2)), mean(place_stats(:,1)), ...
        place_responses, place_stats, checked_places};
    
    v = v+1;
end
save(filename,'trials');
% profile viewer
% profile off
end

