function all_weights = oja(all_inputs, all_weights, ys, value)
    global learning_rate;
    lr = learning_rate;
    
    [~, num_neurs] = size(all_weights{1});
    num_conns = length(all_weights);

    w_length = 0;
    w_positions = zeros(num_conns,1);
    
    for k = 1:num_conns
        w_positions(k) = length(all_weights{k}(:,1));
        w_length = w_length + w_positions(k);      
    end
    
    w = zeros(1,w_length);
    
    for n = 1:num_neurs
        start = 1;
        stop = 0;
        for j = 1:num_conns
           temp_w = all_weights{j}(:,n);
           stop = stop + w_positions(j);
           w(1,start:stop) = all_weights{j}(:,n);
           start = start + w_positions(j);
        end
        
        x = zeros(w_length,1);
        start = 1;
        stop = 0;
        for j = 1:num_conns
           stop = stop + w_positions(j);
           x(start:stop) = all_inputs{j};
           start = start + w_positions(j);
        end
        
        x = x';    
%         y1 = w*x';
%         y1 = soft_activity(0, y1, 5);
%         y2 = ys(250-n);
        y = ys(n);
        
        heb = value*x.*y;
        
        oja = (y.^2).*w; % * value;
     
        dw = lr*(heb - oja);
        w = w + dw;
        
        % putting pieces back together
        all_weights{1}(:,n) = w(1:w_positions(1));
        start = 0;
        for j = 2:num_conns-1
           start = start + w_positions(j-1);
           stop = start + w_positions(j);
           all_weights{j}(:,n) = w(start+1:stop); 
        end
        if (num_conns == 2)
            all_weights{2}(:,n) = w(w_positions(1)+1: ...
                w_positions(1) + w_positions(2));
        end
    end

end

% wx = oja(output, input, weights, value)
% 
% if nargin < 4
%     value = 1;
% end
% 
% global learning_rate;
% eta = learning_rate;
% 
% x = input;
% y = output;
% wx = weights;
% 
% n = length(x);
% m = length(y);
% 
% [J I] = size(wx);
% 
% for i = 1:I
%     for j = 1:J
%         if wx(j,i) ~= 0
%             wx_cur = wx(j,i);
%             delta_wx = eta*y(j) * (x(i) - y*wx(:,i));
%             wx(j,i) = wx_cur + value*delta_wx;
%         end
%     end
% end

