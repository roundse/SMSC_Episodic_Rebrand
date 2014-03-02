function [wy wx] = recurrent_oja(output, old_output, input, ...
    output_weights, input_weights, value)

global gain_oja;
if nargin < 6
    value = 1;
end

global learning_rate;
%alpha = .9;
alpha = sqrt(gain_oja);
eta = learning_rate;

x = input;
y_old = old_output;
y = output;
wx = input_weights;
wy = output_weights; 

[J I] = size(wx);

% can probably be refactored to matrix multiplication for speed
for i = 1:I
    for j = 1:J
        wx_cur = wx(j,i);
        if wx_cur ~= 0
            wx_cur = wx(j,i);
            delta_wx = eta*y(j) * (x(i) - y*wx(:,i));
            wx(j,i) = wx_cur + delta_wx;
        end
    end
end

[L K] = size(wy);

for k = 1:K
    for l = 1:L
        wy_cur = wy(l,k);
        if wy_cur ~= 0
            delta_wy = eta*y(k) * (alpha*value*y_old(k) - y*wy(l,:)');
            wy(l,k) = wy_cur + delta_wy;
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