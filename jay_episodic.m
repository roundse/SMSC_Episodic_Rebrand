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

runs = 10;
cycles = 14;
values = [5 2; 0.5 2;0.1 2]; %[6 1.5; 0 2; -1 2];

gain_oja = 0.7;
learning_rate = 0.4;


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

is_disp_weights = false;
v = 1;
[num_values temp] = size(values);
% profile on
for e=1:10
    while v <= num_values
        VALUE = values(v,:); %worm, peanut

        for i = 1:runs
            TRIAL_DIR = horzcat(DIR, '\', num2str(VALUE(1)),'-',num2str(VALUE(2)),';', num2str(i),'\');
            mkdir(TRIAL_DIR);
            init_val = VALUE;

            [place_responses(i,:) side_pref checked_place first_checked] = bg_experiment(cycles, ...
                learning_rate, gain_oja, is_disp_weights);

            place_stats(i,:) = mean(side_pref);
            checked_places{i} = checked_place;
            first_checkeds(i) = first_checked;
            is_disp_weights = false;
            message = horzcat('trial ', num2str(i), ' complete');
            disp(message);
        end

        avg_first_checks(v) = sum(first_checkeds) / runs;
        avg_side_preference(v) = mean(place_stats(:,1));

        trials{v} = {INP_STR, VALUE, mean(place_stats(:,2)), avg_side_preference, ...
            place_responses, place_stats, checked_places, ...
            avg_first_checks, avg_side_preference};

        v = v+1;
    end
    
    all_trials{e} = trials;
    
    figure;
    title('First Check %');
    bar(avg_first_checks);
    drawnow;
    
    temp = zeros(6,1);
    
    for k=1:3
        l = 2*k;
        temp(l-1) = avg_side_preference(k);
        temp(l) = 7- avg_side_preference(k);
    end

    figure;
    title('Side Preferences %');
    bar(temp);
    drawnow;
end

save(filename,'trials', 'avg_first_checks', 'avg_side_preference');
% profile viewer
% profile off
end

