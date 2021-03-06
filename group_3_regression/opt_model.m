% Nikolaos Giakoumoglou
% AEM 9043
% Fuzzy Systems 2020
%
% Generate Fuzzy Inference System structure from data using 
% subtractive clustering (genfis2).
% This script loads the optimal number of features, their indexes and
% radiuses after application of the grid search algorithm and trains the
% optimal model
%% Clear
clear all; close all; clc; warning off;
dir = [pwd '\report\plots_opt\'];
tic

%% Load dataset
data = importdata('superconductivity.csv');
data = data.data;

%% Load Optimal number of Features and Rules
load('opt_model.mat'); % load number of features, their indexes and rules
disp(['Optimal number of Features ',num2str(optNumFeatures)]);
disp(['Optimal number of Radius ',num2str(optNumRad)]);
disp(['Feature Indexes ',num2str(featureIdx)]);
data = data(:,[featureIdx , end]); % keep the most important features

%% Preprocess
[trnData,valData,chkData]=split_scale(data,1); % 60-20-20

%% FIS 
fis = genfis2(trnData(:,1:end-1), trnData(:,end), optNumRad);
disp(['Optimal number of Rules ',num2str(length(fis.rule))]);

%% Plot some MFs before training
numberOfPlots = 4;
figure;
sgtitle('Optimal Model - Membership Functions before training');
for i=1:numberOfPlots
    [x,mf] = plotmf(fis,'input',i);
    subplot(2,2,i);
    plot(x,mf);
    xlabel(['input' num2str(i)]); ylabel('Degree of membership');
end
saveas(gcf,[dir 'MF_before_training.png'])

%% Train TSK Model
anfis_opt = anfisOptions('InitialFis', fis, 'EpochNumber', 100,...
    'DisplayANFISInformation', 0, 'DisplayErrorValues', 0,...
    'ValidationData', valData);
[trnFIS, trnError, ~, chkFIS, chkError] = anfis(trnData, anfis_opt);

%% Plot some input MF after training
numberOfPlots = 4;
figure;
sgtitle('Optimal Model - Membership Functions before training');
for i=1:numberOfPlots
    [x,mf] = plotmf(chkFIS,'input',i);
    subplot(2,2,i);
    plot(x,mf);
    xlabel(['input' num2str(i)]); ylabel('Degree of membership');
end
saveas(gcf,[dir 'MF_after_training.png'])

%% Learning curve: error VS epochs
figure;
plot(1:length(trnError),trnError,1:length(trnError),chkError);
title('Learning Curve');
legend('Traning Error', 'Check Error');
xlabel('# of Epochs');
ylabel('MSE');
saveas(gcf,[dir 'learning_curve.png'])

%% Prediction error
y_pred = evalfis(chkData(:,1:end-1),chkFIS); % evaluate the trained FIS
y = chkData(:,end); % real values from data (check set)

figure;
plot(1:length(y),y,'*r',1:length(y),y_pred, '.b');
legend('Reference Outputs','ANFIS Outputs');
saveas(gcf,[dir 'ref_vs_anfis_output.png'])

figure;
plot(y - y_pred);
title('Prediction Errors');
saveas(gcf,[dir 'prediction_error.png'])

%% MSE, RMSE, Rsq, NMSE, NDEI
MSE = mean((y - y_pred).^2);
RMSE = sqrt(MSE);

SSres = sum( (y - y_pred).^2 );
SStot = sum( (y - mean(y)).^2 );
Rsq = 1 - SSres / SStot;

NMSE = (sum( (y - y_pred).^2 )/length(y)) / var(y);
NDEI = sqrt(NMSE);

metrics_name = {'MSE';'RMSE';'R2';'NMSE';'NDEI'};
metrics_value = [MSE;RMSE;Rsq;NMSE;NDEI];
metrics_table = table(metrics_name,metrics_value);
%writetable(metrics_table,[dir 'metrics.txt'])
clc;
disp('TSK Model 1');
disp(metrics_table)

%% End
toc
load gong.mat;
sound(y);