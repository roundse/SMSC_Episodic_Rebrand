function jay_episodic()
clear;
close all;
clc;

global hpc_learning_rate;
global pfc_learning_rate;
global INP_STR;

global cycles;
global VALUE;
% 
% global consolidation_length;
% consol_times = [62 2]; % 124 hours and 4

INP_STR = 2;

runs = 1;
cycles = 14;

trial_type = 3;

%values = [5 2; 0.5 2; 0 2]; %[6 1.5; 0 2; -1 2];
% 
% hpc_learning_rate = 0.4;
% pfc_learning_rate = 0.005;

global pos;
global DIR;
global TRIAL_DIR;
DIR = datestr(now);
DIR = strrep(DIR,':',' ');
mkdir(DIR);

pos = 0;
place_responses = zeros(runs, 14);
place_responses124 = zeros(runs, 14);
place_stats = zeros(runs, 2);
filename = horzcat(DIR, '\trial_data', '.mat');

switch trial_type
    case 1
        disp('trial type: Replenish');
        values = [5 2];
    case 2
        disp('trial type: Pilfer');
        values = [1 2];
    case 3
        disp('trial type: Degrade');
        values = [-1.5 2];
end

is_disp_weights = 0;
[num_values temp] = size(values);
% profile on
for e=1:1
    %v = 1;
    %while v <= num_values
    %VALUE = values(v,:); %worm, peanut
    VALUE = values(:);
    
    for i = 1:runs
        TRIAL_DIR = horzcat(DIR, '\', num2str(VALUE(1)),'-',num2str(VALUE(2)),';', num2str(i),'\');
        mkdir(TRIAL_DIR);
        init_val = VALUE;
        
        [place_responses(i,:) side_pref checked_place first_checked ...
         place_responses124(i,:) side_pref124 checked_place124 first_checked124] = ...
            bg_experiment(trial_type, cycles, is_disp_weights);
        
        place_stats(i,:) = mean(side_pref);
        checked_places{i} = checked_place;
        first_checkeds(i) = first_checked;
        
        place_stats124(i,:) = mean(side_pref124);
        checked_places124{i} = checked_place124;
        first_checkeds124(i) = first_checked124;        
        
        is_disp_weights = false;
        message = horzcat('trial ', num2str(i), ' complete');
        disp(message);
    end
    
    avg_first_checks = sum(first_checkeds) / runs;
    avg_side_preference = mean(place_stats(:,1));

    avg_first_checks124 = sum(first_checkeds124) / runs;
    avg_side_preference124 = mean(place_stats124(:,1));
    
    trials = {INP_STR, VALUE, mean(place_stats(:,2)), avg_side_preference, ...
        place_responses, place_stats, checked_places, '124 trials',...
        mean(place_stats124(:,2)), avg_side_preference124, ...
        place_responses124, place_stats124, checked_places124,};
    
    %v = v+1;
    %end
    
    all_trials{e} = trials;
    
    ffc = 'fig_first_check';
    fsp = 'fig_side_prefs';
    
    figure;
    title('First Check 4 %');
    bar(avg_first_checks);
    drawnow;
    % strrep(ffc, '%d', num2str(e))
    saveas(gcf, horzcat(DIR, '\', ffc, '_', num2str(e)), 'fig');

    figure;
    title('First Check 124 %');
    bar(avg_first_checks124);
    drawnow;
    % strrep(ffc, '%d', num2str(e))
    saveas(gcf, horzcat(DIR, '\', ffc, '_', num2str(e)), 'fig');
    
    temp = zeros(6,1);
    
    for k=1:1
        l = 2*k;
        temp(l-1) = avg_side_preference(k);
        temp(l) = 6- avg_side_preference(k);
 
        temp124(l-1) = avg_side_preference124(k);
        temp124(l) = 6- avg_side_preference124(k);
    end
    
    avg_side_preference = temp;
    
    avg_side_preference124 = temp124;

    figure;
    title('Side Preferences 124 %');
    for i = 1:1
        k = i*2;
        bar(k-1, avg_side_preference124(k-1),'b');
        hold on
        bar(k, avg_side_preference124(k),'r');
        hold on
    end
    drawnow;
    
    figure;
    title('Side Preferences %');
    for i = 1:1
        k = i*2;
        bar(k-1, avg_side_preference(k-1),'b');
        hold on
        bar(k, avg_side_preference(k),'r');
        hold on
    end
    drawnow;
    
    saveas(gcf, horzcat(DIR, '\', fsp, '_', num2str(e)), 'fig');
end

save(filename,'trials', 'avg_first_checks', 'avg_side_preference', ...
    'avg_first_checks124', 'avg_side_preference124');
% profile viewer
% profile off
end

