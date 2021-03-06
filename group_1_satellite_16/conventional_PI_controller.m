% Nikolaos Giakoumoglou
% AEM 9043
% Fuzzy Systems 2020
%% Clear
clear all; close all; clc;

%% Initialize Gc(s) = (s+c)/s 
c = 2; % arbitrarily
num_c = [1 c];
den_c = [1 0];
G_c = tf(num_c, den_c);

%% Initialize Gp(s) = 10/((s+1)*(s+9)) = 10/(s^2+10*s+9)
num_p = [10];
den_p = [1 10 9];
G_p = tf(num_p, den_p);

%% Open loop system
sys_open_loop = series(G_c, G_p);

%% Create the root locus plot
figure;
rlocus(sys_open_loop)
zeta = 0.5911;
wn = 1.8/1.2;
sgrid(zeta,wn)
[k,poles] = rlocfind(sys_open_loop)

%% Closed loop system
K_p = 0.8; % from rlocus
sys_open_loop = K_p * sys_open_loop;
sys_closed_loop = feedback(sys_open_loop, 1, -1);

%% Step response
figure;
step(sys_closed_loop);
info = stepinfo(sys_closed_loop);
text(1,0.25,['Rise Time:',num2str(info.RiseTime)]);
text(1,0.2,['Overshoot: ',num2str(info.Overshoot)]);
disp(['Rise Time of step response is (must be less than 1.2): ',num2str(info.RiseTime)]);
disp(['Overshoot of step response is (must be less than 10): ',num2str(info.Overshoot)]);
disp([' ']);

%% Display integral and proportional gains
disp('Integral and proportional gains of the conventional PI controolers are:');
disp(['K_p = ',num2str(K_p)]);
disp(['K_i = ',num2str(c*K_p)]);