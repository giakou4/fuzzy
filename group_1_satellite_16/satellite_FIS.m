% Nikolaos Giakoumoglou
% AEM 9043
% Fuzzy Systems 2020
%% Clear
clear all; close all; clc;
warning off;

%% Satellite FIS
fis = newfis('satellite','AndMethod','min','AggregationMethod','max',...
    'DefuzzificationMethod','customdefuzz','ImplicationMethod','prod'); 

fis = addvar(fis, 'input', 'E', [-1 1]);
fis = addvar(fis, 'input', 'CE', [-1 1]);
fis = addvar(fis, 'output', 'CU', [-1 1]);

%% MF of Error - E
fis = addmf(fis, 'input', 1, 'NL', 'trimf', [-1 -1 -0.67]);
fis = addmf(fis, 'input', 1, 'NM', 'trimf', [-1 -0.67 -0.33]);
fis = addmf(fis, 'input', 1, 'NS', 'trimf', [-0.67 -0.33 0]);
fis = addmf(fis, 'input', 1, 'ZR', 'trimf', [-0.33 0 0.33]);
fis = addmf(fis, 'input', 1, 'PS', 'trimf', [0 0.33 0.67]);
fis = addmf(fis, 'input', 1, 'PM', 'trimf', [0.33 0.67 1]);
fis = addmf(fis, 'input', 1, 'PL', 'trimf', [0.67 1 1]);

%% MF of Change of Error - CE
fis = addmf(fis, 'input', 2, 'NL', 'trimf', [-1 -1 -0.67]);
fis = addmf(fis, 'input', 2, 'NM', 'trimf', [-1 -0.67 -0.33]);
fis = addmf(fis, 'input', 2, 'NS', 'trimf', [-0.67 -0.33 0]);
fis = addmf(fis, 'input', 2, 'ZR', 'trimf', [-0.33 0 0.33]);
fis = addmf(fis, 'input', 2, 'PS', 'trimf', [0 0.33 0.67]);
fis = addmf(fis, 'input', 2, 'PM', 'trimf', [0.33 0.67 1]);
fis = addmf(fis, 'input', 2, 'PL', 'trimf', [0.67 1 1]);

%% MF of Change of U - CU
fis = addmf(fis, 'output', 1, 'NV', 'trimf', [-1 -1 -0.75]);
fis = addmf(fis, 'output', 1, 'NL', 'trimf', [-1 -0.75 -0.5]);
fis = addmf(fis, 'output', 1, 'NM', 'trimf', [-0.75 -0.5 -0.25]);
fis = addmf(fis, 'output', 1, 'NS', 'trimf', [-0.5 -0.25 0]);
fis = addmf(fis, 'output', 1, 'ZR', 'trimf', [-0.25 0 0.25]);
fis = addmf(fis, 'output', 1, 'PS', 'trimf', [0 0.25 0.5]);
fis = addmf(fis, 'output', 1, 'PM', 'trimf', [0.25 0.5 0.75]);
fis = addmf(fis, 'output', 1, 'PL', 'trimf', [0.5 0.75 1]);
fis = addmf(fis, 'output', 1, 'PV', 'trimf', [0.75 1 1]);

%% Add rules
rules = [...
"E==NL & CE==PL => CU=ZR"; ...
"E==NL & CE==PM => CU=NS"; ...
"E==NL & CE==PS => CU=NM"; ...
"E==NL & CE==ZR => CU=NL"; ...
"E==NL & CE==NS => CU=NV"; ...
"E==NL & CE==NM => CU=NV"; ...
"E==NL & CE==NL => CU=NV"; ...
"E==NM & CE==PL => CU=PS"; ...
"E==NM & CE==PM => CU=ZR"; ...
"E==NM & CE==PS => CU=NS"; ...
"E==NM & CE==ZR => CU=NM"; ...
"E==NM & CE==NS => CU=NL"; ...
"E==NM & CE==NM => CU=NV"; ...
"E==NM & CE==NL => CU=NV"; ...
"E==NS & CE==PL => CU=PM"; ...
"E==NS & CE==PM => CU=PS"; ...
"E==NS & CE==PS => CU=ZR"; ...
"E==NS & CE==ZR => CU=NS"; ...
"E==NS & CE==NS => CU=NM"; ...
"E==NS & CE==NM => CU=NL"; ...
"E==NS & CE==NL => CU=NV"; ...
"E==ZR & CE==PL => CU=PL"; ...
"E==ZR & CE==PM => CU=PM"; ...
"E==ZR & CE==PS => CU=PS"; ...
"E==ZR & CE==ZR => CU=ZR"; ...
"E==ZR & CE==NS => CU=NS"; ...
"E==ZR & CE==NM => CU=NM"; ...
"E==ZR & CE==NL => CU=NL"; ...
"E==PS & CE==PL => CU=PV"; ...
"E==PS & CE==PM => CU=PL"; ...
"E==PS & CE==PS => CU=PM"; ...
"E==PS & CE==ZR => CU=PS"; ...
"E==PS & CE==NS => CU=ZR"; ...
"E==PS & CE==NM => CU=NS"; ...
"E==PS & CE==NL => CU=NM"; ...
"E==PM & CE==PL => CU=PV"; ...
"E==PM & CE==PM => CU=PV"; ...
"E==PM & CE==PS => CU=PL"; ...
"E==PM & CE==ZR => CU=PM"; ...
"E==PM & CE==NS => CU=PS"; ...
"E==PM & CE==NM => CU=ZR"; ...
"E==PM & CE==NL => CU=NS"; ...
"E==PL & CE==PL => CU=PV"; ...
"E==PL & CE==PM => CU=PV"; ...
"E==PL & CE==PS => CU=PV"; ...
"E==PL & CE==ZR => CU=PL"; ...
"E==PL & CE==NS => CU=PM"; ...
"E==PL & CE==NM => CU=PS"; ...
"E==PL & CE==NL => CU=ZR"; ...
];
fis = addRule(fis,rules);
writefis(fis,'satellite.fis')

%% Plot MF
figure; plotfis(fis)
figure; plotmf(fis,'input',1)
figure; plotmf(fis,'input',2)
figure; plotmf(fis,'output',1)
figure; gensurf(fis)

%% More
ruleview(fis)
%ruleedit(fis)
%mfedit(fis)
%surfview(fis)