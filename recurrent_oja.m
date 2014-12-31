function [wy wx] = recurrent_oja(output, old_output, input, ...
                                 output_weights, input_weights, value)

global is_pfc;
                             
if nargin < 6
    value = 0;
end

global learning_rate;
global pfc_learning_rate;

global pfc_max;
global hpc_max;
global max_max_weight;

alpha = 1.3;
alpha = sqrt(alpha);
max = max_max_weight;

wx = output_weights';
wy = input_weights';

wx_bin = wx~=0;
wy_bin = wy~=0;

if is_pfc
    eta = pfc_learning_rate;
    max = pfc_max;
else
    eta = learning_rate;
    max = hpc_max;
    wx = decay_weights(wx);
    wy = decay_weights(wy);
end

x = input;
y_old = old_output;
y = output;

[J, I, ~] = find(wx);
K = size(J);
y_wx =  y*wx;

% output weights
for k = 1:K
    j = J(k);
    i = I(k);

    delta_wx = eta*y(j) * (x(i) - y_wx(i));
    wx(j,i) = (wx(j,i) + delta_wx);
end

% input weights
[J, I, ~] = find(wy);
K = size(J);
y_wy =  y*wy';

for k = 1:K
    j = J(k);
    i = I(k);

    delta_wy = eta*y(i) * (alpha*value*y_old(i) - y_wy(j));
    wy(j,i) = (wy(j,i) + delta_wy);
end

wx = wx .* wx_bin;
wy = wy .* wy_bin;

wx(wx>max) = max;
wy(wy>max) = max;

wx(wx<-max) = -max;
wy(wy<-max) = -max;

end

function w = decay_weights(w)
    global decay;

    half_d = decay/2;
    wd = half_d*rand(size(w)) - half_d;
    w = w + wd;

end