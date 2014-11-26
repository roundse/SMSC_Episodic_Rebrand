function jay_episodic(hpc_les, pfc_les)
clear;
% close all;
% clc;

global lesion_pfc;
global lesion_hpc;
global switch_lesion;

global debug;
debug = 0;

global show_pfc_w;
global show_hpc_w;

global internal_weights;

internal_weights = 0;

% false -> lesion happens during during testing
% true  -> lesion happens during training
switch_lesion = 1;

lesion_pfc = 0;
lesion_hpc = 0;

% pfc acts like a really good HPC with training turned on (and off)
% will test HPC with training

show_pfc_w = debug & ~lesion_pfc;
show_hpc_w = debug & ~lesion_hpc;

global learning_rate; %hpc
global pfc_learning_rate;

global INP_STR;  
global cycles;

% global weight_reduction;
% weight_reduction = 1;

pfc_learning_rate = 0.08;
learning_rate = 0.37;

global pfc_max;
global hpc_max;
global max_max_weight;
global int_max_weight;
int_max_weight = 2;

global decay;
decay = 0.0009;

pfc_max = 2;
hpc_max = 8;
max_max_weight = 8;

INP_STR = .2;

runs = 35; 
cycles = 12;

global REPL;
global PILF;
global DEGR;

REPL = [ 5.0   1.0];
PILF = [ 0     1.0];
DEGR = [-5.0   1.0];
% TWO THINGS: MAYBE LOWER DECAY, MAYBE LOWER THE DEGRADE VALUE

global pos
global DIR;
global TRIAL_DIR;
DIR = datestr(now);
DIR = strrep(DIR,':',' ');
DIR = horzcat('trials\data-', DIR);
mkdir(DIR);

pos = 0;
w_place_responses = zeros(runs, 14);
w_place_stats = zeros(runs, 1);
p_place_responses = zeros(runs, 14);
p_place_stats = zeros(runs, 1);
filename = horzcat(DIR, '\trial_data', '.mat');
trial_file_name = horzcat(DIR, '\check_orders', '.mat');
pref_file_name = horzcat(DIR, '\side_prefs', '.mat');
worm_trials = {};
pean_trials = {};

value_groups = {};

multi_groups = {};

is_disp_weights = 0;
for e=1:1
    v = 1;
    while v  <= 3
        VALUE = v;
        for i = 1:runs
            TRIAL_DIR = horzcat(DIR, '\', num2str(VALUE), '-', ...
                num2str(VALUE), ';', num2str(i), '\');
            mkdir(TRIAL_DIR);
            init_val = VALUE;
                       
            tic;
            [worm_trial, pean_trial] = ...
                experiment(cycles, is_disp_weights, VALUE);
            toc;

            worm_trials{i} = worm_trial;
            pean_trials{i} = pean_trial;
            
            w_place_stats(i) = mean(worm_trial.('side_pref'));
            w_checked_places{i} = worm_trial.('check_order');
            w_first_checkeds(i) = worm_trial.('first_check');
            w_pref_error(i) = worm_trial.('error_pref');
            
            p_place_stats(i) = mean(pean_trial.('side_pref'));
            p_checked_places{i} = pean_trial.('check_order');
            p_first_checkeds(i) = pean_trial.('first_check');
            p_pref_error(i) = pean_trial.('error_pref');
            
            message = horzcat('trial ', num2str(i), ' complete');
            disp(message);
            
            all_side_pref{v} = [w_place_stats p_place_stats];
            all_checks{v} = [w_place_stats p_place_stats];
            
           save(trial_file_name, 'all_checks');
           save(pref_file_name, 'all_side_pref');
            
        end
        
        if sum(p_first_checkeds) == 0
            p_avg_first_checks(v) = 0;
        else
            p_avg_first_checks(v) = sum(p_first_checkeds) / runs;
        end
        
        if sum(w_first_checkeds) == 0
            w_avg_first_checks(v) = 0;
        else
            w_avg_first_checks(v) = sum(w_first_checkeds) /  runs;
        end
        
        p_place_stats
        mean(p_place_stats)
        p_avg_side_preference(v) = mean(p_place_stats);
        p_avg_pref_error(v) = std(p_place_stats)/ sqrt(length(p_place_stats));
        
        w_place_stats
        mean(w_place_stats)
        w_avg_side_preference(v) = mean(w_place_stats);
        w_avg_pref_error(v) = std(w_place_stats)/ sqrt(length(w_place_stats));
        
        value_groups{v} = [VALUE worm_trials pean_trials];

        v = v+1;
    end
    is_disp_weights = false;

    showTrials(p_avg_pref_error, p_avg_side_preference, p_avg_first_checks, ...
        e, '124 HR Trial');
    showTrials(w_avg_pref_error, w_avg_side_preference, w_avg_first_checks, ...
        e, '4 HR Trial');
    
    multi_groups{e} = value_groups;
end

save(filename, 'multi_groups');
end

function showTrials(error, avg_side_preference, avg_first_checks, epp, type)
ffc = 'fig_first_check';
fsp = 'fig_side_prefs';

global DIR;

figure;
bar(avg_first_checks);
drawnow;
title_message = horzcat(type, ' First Check %');
title(title_message);

saveas(gcf, horzcat(DIR, '\', ffc, '_', num2str(epp), type), 'fig');

temp = zeros(2,2);

for cond=1:3
    temp(cond, 1) = 7 - avg_side_preference(cond);
    temp(cond, 2) = avg_side_preference(cond);
    e(cond, 1) = error(cond);
    e(cond, 2) = error(cond);
end

avg_side_preference = temp;
error = e;

figure;
barwitherr(error, avg_side_preference);
set(gca,'XTickLabel',{'Degrade','Replenish','Pilfer'});
legend('peanut','worm');
ylabel('Avg Number of Checks');
title_message = horzcat(type, ' Side Preference');
title(title_message);

saveas(gcf, horzcat(DIR, '\', fsp, '_', num2str(epp), type), 'fig');

end