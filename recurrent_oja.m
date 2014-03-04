function [wy wx] = recurrent_oja(output, old_output, input, ...
    output_weights, input_weights, value)

if nargin < 6
    value = 1;
end

global learning_rate;
alpha = 5;
alpha = sqrt(alpha);
eta = learning_rate;

x = input;
y_old = old_output;
y = output;
wx = output_weights';
wy = input_weights';

n = length(x);
m = length(y);

[J I] = size(wx);

for i = 1:I
    for j = 1:J
        if wx(j,i) > eps
            wx_cur = wx(j,i);
            delta_wx = eta*y(j) * (x(i) - y*wx(:,i));
            wx(j,i) = wx_cur + delta_wx;
        end
    end
end

[J I] = size(wy);
for i = 1:I
    for j = 1:J
        if wy(j,i) > eps
            wy_cur = wy(j,i);
            delta_wy = eta*y(i) * (alpha*value*y_old(i) - y*wy(j,:)');
            wy(j,i) = wy_cur + delta_wy;
        end
    end
end

end



% % if sum(old_output) ~= 0
% %     for i = 1:I
% %         for j = 1:J
% %             if wx(j,i) > eps
% %                 wx_cur = wx(j,i);
% %                 hebb = x(i);
% %                 oja = y*wx(:,j);
% %                 delta_wx = eta*y(j) * (x(i) - y*wx(:,j));
% %                 if (delta_wx > 1)
% %                     hebb
% %                     oja
% %                     input('lookie here!');
% %                     wy(:,j)'
% %                     y(j)
% %                     input('weird, huh?');
% %                 end
% %                 wx(j,i) = wx_cur + delta_wx;
% %             end
% %         end
% %     end
% % 
% %     [J I] = size(wy);
% % 
% %     for i = 1:I
% %         for j = 1:J
% %             if wy(j,i) > eps
% %                 wy_cur = wy(j,i);
% %                 hebb = y_old(i);
% %                 oja = y*wy(i,:)';
% %                 delta_wy = eta*y(i) * (alpha*y_old(i) - y*wy(i,:)');                   
% %                 wy(j,i) = wy_cur + delta_wy;
% %             end
% %         end
% %     end
% % end
% % wx = wx';
% % wy = wy'; 

% for i = 1:I
%     for j = 1:J
%         if wx(j,i) > eps
%             wx_cur = wx(j,i);
%             delta_wx = (lr*y(i) * (value*alpha*y(i) - y*wx(i,:)'));
%             wx(j,i) = wx_cur + delta_wx;
%         end
%     end
% end
% 
% [J I] = size(wy);
% 
% for i = 1:I
%     for j = 1:J
%         if wy(j,i) > eps
%             wy_cur = wy(j,i);
%             delta_wy = lr*y(j) * (x(j) - y*wy(:,i));
%             wy(j,i) = wy_cur + delta_wy;
%         end
%     end
% end