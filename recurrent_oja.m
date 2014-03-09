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

% output weights
for i = 1:I
    for j = 1:J
        if wx(j,i) > eps
            wx_cur = wx(j,i);
            delta_wx = eta*y(j) * (x(i) - y*wx(:,i));
            wx(j,i) = wx_cur + delta_wx;
        end
    end
end

% input weights
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