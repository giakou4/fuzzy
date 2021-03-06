% Nikolaos Giakoumoglou
% AEM 9043
% Fuzzy Systems 2020
clear all; close all; clc;
warning off;

x0 = 9.1;               % initial x coordinate
y0 = 4.3;               % initial y coordinate
xd = 15;                % desired x coordinate
yd = 7.2;               % desired y coordinate
u = 0.05;               % velocity ct
theta_arr = [0 45 90];  % various values of theta

fis_model_initial;      % create FIS model
fis1 = readfis('fis_model_initial');
simulate(fis1,x0,y0,xd,yd,theta_arr,u)

fis_model_improved;     % create FIS model
fis2 = readfis('fis_model_improved');
simulate(fis2,x0,y0,xd,yd,theta_arr,u)