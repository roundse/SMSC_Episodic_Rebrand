
if j == 1
    f = rand;
    t = rand;
    
    if f < 0.5
        fd_order = [worm peanut worm peanut];
    else
        fd_order = [peanut worm peanut worm];
    end
    
    if t < 0.5
        t_order1 = [4   4   120  120];
        t_order2 = [120 120  4   4];
    else
        t_order1 = [120 120  4   4];
        t_order2 = [4   4    120 120];
    end
end

if t_order1(j) == 4
    value1 = default_val;
    value2 = values;
elseif t_order1(j) == 120
    value1 = values;
    value2 = default_val;
end

for k = 1:2
    m1 = 0;
    m2 = 0;
    base_inh = -.0001;
    w_pfc_to_hpc = base_inh .* ones(PFC_SIZE, HPC_SIZE);
    
    if k == 1
        if fd_order(j) == worm
            disp('First food to be stored is worm');
            disp(['First value is: ', num2str(value1(1))]);
            disp(['Second value is: ', num2str(value2(1))]);
            disp('Second food to be stored is peanut');
            disp(['First value is: ', num2str(value1(2))]);
            disp(['Second value is: ', num2str(value2(2))]);
        else
            disp('First food to be stored is peanut');
            disp(['First value is: ', num2str(value1(2))]);
            disp(['Second value is: ', num2str(value2(2))]);
            disp('Second food to be stored is worm');
            disp(['First value is: ', num2str(value1(1))]);
            disp(['Second value is: ', num2str(value2(1))]);
        end
        
        disp(['First consolidation period is: ', num2str(t_order1(j))]);
        disp(['Second consolidation period is: ', num2str(t_order2(j))]);
        %         else
        %             if fd_order(j) == peanut
        %                 disp('Second food to be stored is worm');
        %             else
        %                 disp('Second food to be stored is peanut');
        %             end
        %             disp(['Second consolidation period is: ', num2str(t_order2(j))]);
        %             disp(['First value is: ', num2str(value1(2))]);
    end
    
    if fd_order(j) == worm
        %value = VALUE(worm);
        spots = spot_shuffler(7);
        for q = 1:7
            i = spots(q);
            while place(i,:) == 0
                place(i,:) = WORM;
            end
            %[fpa hpc_suma(i) pfc_suma(i)] =
            [fpa hpc_sum(i) pfc_sum(i)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, ...
                default_val(1), m1, m2); % !BUG
        end
        %value = VALUE(peanut);
        spots = spot_shuffler(8, 14);
        for i = spots
            while place(i,:) == 0
                place(i,:) = PEANUT;
            end
            %[fpa hpc_sumb(i) pfc_sumb(i)] =
            [fpa hpc_sum(i) pfc_sum(i)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, ...
                default_val(2), m1, m2);
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
            [fpa hpc_sum(i) pfc_sum(i)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, ...
                default_val(2), m1, m2);
        end
        %value = VALUE(worm);
        spots = spot_shuffler(7);
        for i = spots
            while place(i,:) == 0
                place(i,:) = WORM;
            end
            %[fpa hpc_sumb(j) pfc_sumb(j)] =
            [fpa hpc_sum(i) pfc_sum(i)] = cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, ...
                default_val(1), m1, m2);
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
                place(i,:), cycles*t_order1(j), value, m1, m2);
            %disp(base_inh);
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
                place(i,:), cycles*t_order2(j), value, m1, m2);
            %disp(base_inh);
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