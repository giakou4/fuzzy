% Nikolaos Giakoumoglou
% AEM 9043
% Fuzzy Systems 2020
%% FIS
fis = newfis('car_control','AndMethod','min',...
    'ImplicationMethod','min','AggregationMethod','max',...
    'DefuzzificationMethod','centroid'); 

%% Variables
fis = addvar(fis, 'input', 'dV', [0 1]);
fis = addvar(fis, 'input', 'dH', [0 1]);
fis = addvar(fis, 'input', 'theta', [-180 180]);
fis = addvar(fis, 'output', 'Dtheta', [-130 130]);

%% Membership Functions (MF)
fis = addmf(fis, 'input', 1, 'S', 'trimf', [0 0 0.5]); % dV
fis = addmf(fis, 'input', 1, 'M', 'trimf', [0 0.5 1]);
fis = addmf(fis, 'input', 1, 'L', 'trimf', [0.5 1 1]);

fis = addmf(fis, 'input', 2, 'S', 'trimf', [0 0 0.5]); % dH
fis = addmf(fis, 'input', 2, 'M', 'trimf', [0 0.5 1]);
fis = addmf(fis, 'input', 2, 'L', 'trimf', [0.5 1 1]);

fis = addmf(fis, 'input', 3, 'N', 'trimf', [-180 -180 0]); % theta 
fis = addmf(fis, 'input', 3, 'ZE', 'trimf', [-180 0 180]);
fis = addmf(fis, 'input', 3, 'P', 'trimf', [0 180 180]);

fis = addmf(fis, 'output', 1, 'N', 'trimf', [-130 -130 0]); % Dtheta
fis = addmf(fis, 'output', 1, 'ZE', 'trimf', [-130 0 130]);
fis = addmf(fis, 'output', 1, 'P', 'trimf', [0 130 130]);

%% Plot MFs
figure; plotmf(fis,'input',1); title('Input 1: dV');
figure; plotmf(fis,'input',2); title('Input 2: dH');
figure; plotmf(fis,'input',3); title('Input 3: \theta');
figure; plotmf(fis,'output',1); title('Output 1: \Delta\theta')

%% Rule Base
rules = [...
"dV==S & dH==S & theta==N => Dtheta=P"; ...
"dV==S & dH==S & theta==ZE => Dtheta=P"; ...
"dV==S & dH==S & theta==P => Dtheta=P"; ...
"dV==M & dH==S & theta==N => Dtheta=P"; ...
"dV==M & dH==S & theta==ZE => Dtheta=P"; ...
"dV==M & dH==S & theta==P => Dtheta=N"; ...
"dV==L & dH==S & theta==N => Dtheta=P"; ...
"dV==L & dH==S & theta==ZE => Dtheta=P"; ...
"dV==L & dH==S & theta==P => Dtheta=N"; ...
...
"dV==S & dH==M & theta==N => Dtheta=P"; ...
"dV==S & dH==M & theta==ZE => Dtheta=P"; ...
"dV==S & dH==M & theta==P => Dtheta=N"; ...
"dV==M & dH==M & theta==N => Dtheta=P"; ...
"dV==M & dH==M & theta==ZE => Dtheta=ZE"; ...
"dV==M & dH==M & theta==P => Dtheta=N"; ...
"dV==L & dH==M & theta==N => Dtheta=P"; ...
"dV==L & dH==M & theta==ZE => Dtheta=ZE"; ...
"dV==L & dH==M & theta==P => Dtheta=N"; ...
...
"dV==S & dH==L & theta==N => Dtheta=P"; ...
"dV==S & dH==L & theta==ZE => Dtheta=P"; ...
"dV==S & dH==L & theta==P => Dtheta=N"; ...
"dV==M & dH==L & theta==N => Dtheta=P"; ...
"dV==M & dH==L & theta==ZE => Dtheta=ZE"; ...
"dV==M & dH==L & theta==P => Dtheta=N"; ...
"dV==L & dH==L & theta==N => Dtheta=P"; ...
"dV==L & dH==L & theta==ZE => Dtheta=ZE"; ...
"dV==L & dH==L & theta==P => Dtheta=N"; ...
];
fis = addRule(fis,rules);

%% Write FIS
writefis(fis,'fis_model_initial.fis');