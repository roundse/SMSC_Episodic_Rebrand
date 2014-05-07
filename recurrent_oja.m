function [wy wx] = recurrent_oja(output, old_output, input, output_weights, ...
    output_weights_old, input_weights, input_weights_old, value, b_hpc)

if nargin < 8
    value = 1;
end


% global hpc_learning_rate;
% global pfc_learning_rate;


alpha = 5;

if b_hpc == true
        eta = .4;
        decay = .925;
        
else
        eta = .0000001;
        decay = 0.0000000001;

end
thresh = -2;
alpha = sqrt(alpha);

x = input;
y_old = old_output;
y = output;
wx = output_weights';
wx_prev = output_weights_old';
wy = input_weights';
wy_prev = input_weights_old';

n = length(x);
m = length(y);

[J I] = size(wx);

% output weights
for i = 1:I
    for j = 1:J
        if wx(j,i) ~= 0
            wx_cur = wx(j,i);
            delta_wx = (eta*y(j) * (x(i) - y*wx(:,i)));
            temp_x = wx_cur + delta_wx ;
%             d = 1 - (decay * wx_prev(j,i));
            d = decay * (temp_x - wx_prev(j,i));
            wx(j,i) = temp_x - d;
            if wx(j,i) < thresh
                wx(j,i) = thresh;
            end
        end
    end
end

% input weights
[J I] = size(wy);

if size(wy) ~= size(wy_prev)
    wy_prev = wy_prev';
end

for i = 1:I
    for j = 1:J
        if wy(j,i) ~= 0
            wy_cur = wy(j,i);
            delta_wy = (eta*y(i) * (alpha*value*y_old(i) - y*wy(j,:)'));
            temp_y = wy_cur + delta_wy ;
%             d = 1 - (decay * wx_prev(j,i));
            d = decay * (temp_y - wy_prev(j,i));
            wy(j,i) = temp_y - d;
            if wy(j,i) < thresh
                wy(j,i) = thresh;
            end
        end
    end
end

%! wy (as w_place_to_food) here turns into an array (0.5)

end



% function [wy wx] = recurrent_oja(output, old_output, input, ...
%     output_weights, input_weights, value)
% 
% if nargin < 6
%     value = 1;
% end
% 
% global learning_rate;
% alpha = 5;
% alpha = sqrt(alpha);
% eta = learning_rate;
% 
% x = input;
% y_old = old_output;
% y = output;
% wx = output_weights';
% wy = input_weights';
% 
% n = length(x);
% m = length(y);
% 
% [J I] = size(wx);
% 
% % output weights
% for i = 1:I
%     for j = 1:J
%         wx_cur = wx(j,i);
%         if wx_cur ~= 0
%             xi = x(i);
%             yj = y(j);
% 
%             heb = yj*xi;
%             oja = wx_cur*yj*yj;
%             delta_wx = eta*(heb-oja);
%             wx(j,i) = wx_cur + delta_wx;
%         end
%     end
% end
% 
% % input weights
% [J I] = size(wy);
% for i = 1:I
%     for j = 1:J
%         wy_cur = wy(j,i);
%         if wy_cur ~= 0
%             xj = x(j);
%             yi = y(i);
% 
%             heb = alpha * value * yi * xj;
%             oja = wx_cur * yj * y_old(i);
%             delta_wx = eta*(heb-oja);
%             wy(j,i) = wy_cur + delta_wx;
%         end
%     end
% end
% 
% end