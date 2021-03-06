% Nikolaos Giakoumoglou
% AEM 9043
% Fuzzy Systems 2020
%
% TSK Model 2
% Number of MFs: 3 Bell Shaped
% Output: Singleton
% Training method: Back Propagation for MFs and Least Squares for output.
%% Clear
clear all; close all; clc; format compact; warning off;
dir = [pwd '\report\plots_2\'];

%% Load dataset
data = importdata('airfoil_self_noise.csv');
data = data.data;

%% Preprocess
[trnData,valData,chkData]=split_scale(data,1); %60-20-20

%% FIS with grid partition
fis=genfis1(trnData,3,'gbellmf',"constant"); % FIS with 3 bell-shaped MF and singleton output
plotMFs(fis);                                % plot initial MFs
saveas(gcf,[dir 'MFs.png'])                  % save figure
epochs = 100;                                % no of epochs
[trnFIS,trnError,~,chkFIS, chkError]=anfis(trnData,fis,[epochs NaN NaN NaN NaN],[],valData,1); % [] for display options, 1 for hyrbrid
plotMFs(chkFIS)                              % plot trained MFs
saveas(gcf,[dir 'MFs_trn.png'])              % save figure

%% Learning curve: error VS epochs
figure;
plot(1:length(trnError),trnError,1:length(trnError),chkError);
title('Learning Curve');
legend('Traning Error', 'Check Error');
xlabel('# of Epochs');
ylabel('MSE');
saveas(gcf,[dir 'learning_curve.png'])

%% Prediction error
y_hat = evalfis(chkData(:,1:end-1),chkFIS);  % estimated from trained FIS
y = chkData(:,end);                          % real values from data (check set)

figure;
plot(1:length(y),y,'*r',1:length(y),y_hat, '.b');
legend('Reference Outputs','ANFIS Outputs');
saveas(gcf,[dir 'ref_vs_anfis_output.png'])

figure;
plot(y - y_hat);
title('Prediction Errors');
saveas(gcf,[dir 'prediction_error.png'])

%% MSE, RMSE, Rsq, NMSE, NDEI
MSE = mean((y - y_hat).^2);
RMSE = sqrt(MSE);

SSres = sum( (y - y_hat).^2 );
SStot = sum( (y - mean(y)).^2 );
Rsq = 1 - SSres / SStot;

NMSE = (sum( (y - y_hat).^2 )/length(y)) / var(y);
NDEI = sqrt(NMSE);

metrics_name = {'MSE';'RMSE';'R2';'NMSE';'NDEI'};
metrics_value = [MSE;RMSE;Rsq;NMSE;NDEI];
metrics_table = table(metrics_name,metrics_value);
writetable(metrics_table,[dir 'metrics.txt'])
disp('TSK Model 2');
disp(metrics_table)