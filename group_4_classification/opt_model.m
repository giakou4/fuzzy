% Nikolaos Giakoumoglou
% AEM 9043
% Fuzzy Systems 2020
%
% Generate Fuzzy Inference System structure from data using 
% subtractive clustering (genfis2).
% This script loads the optimal number of features, their indexes and
% number of rules after application of the grid search algorithm and trains 
% the optimal model as class independent.
%% Clear
clear all; close all; clc; warning off;
dir = [pwd '\report\plots_opt\'];
tic

%% Load dataset
disp('Loading dataset...');
data = importdata('epileptic_seizure_recognition.csv');
data = data.data;
   
%% Load Optimal number of Features and Rules
load('opt_model.mat'); % load number of features, their indexes and rules
disp(['Optimal number of Features: ',num2str(optNumFeatures)]);
disp(['Optimal number of Radius ',num2str(optNumRad)]);
disp(['Feature Indexes ',num2str(featureIdx)]);
data = data(:,[featureIdx , end]); % keep the most important features

%% Preprocess
[trnData, valData, chkData, frequencyTable] = preproc(data);
disp(frequencyTable);

%% FIS
fis = genfis2(trnData(:,1:end-1), trnData(:,end), optNumRad); % note that we already have the most important features
disp(['Optimal number of Rules ',num2str(length(fis.rule))]);
for i = 1 : length(fis.Output.MF)
    fis.Output.MF(i).Type = 'constant';
end

%% Plot and save MFs before training
plotMFs(fis); % Plot Inital Membership Functions
suptitle(['Optimal Model - Membership Functions before training']);
saveas(gcf,[dir 'MFs_before_training.png'])         

%% Train TSK Model
anfis_opt = anfisOptions('InitialFis', fis, 'EpochNumber', 100,...
    'DisplayANFISInformation', 0, 'DisplayErrorValues', 0,...
    'ValidationData', valData);
[trnFIS, trnError, ~, chkFIS, chkError] = anfis(trnData, anfis_opt);

%% Plot and save MFs after training
plotMFs(chkFIS);
suptitle(['Optimal Model - Membership Functions after training']);
saveas(gcf,[dir 'MFs_after_training.png']) 

%% Evaluate the trained FIS
y_pred = evalfis(chkData(:,1:end-1), chkFIS); % evaluate the trained FIS
y = chkData(:,end);  % real values from data (check set)
y_pred = round(y_pred); % round output to an integer for classifying
    
lower_limit = frequencyTable(1,1);   % in case output is lower than the lowest value
upper_limit = frequencyTable(end,1); % in case output is higher than the highest value
lower_limit = table2array(lower_limit);
upper_limit = table2array(upper_limit);
    
y_pred(y_pred < lower_limit) = lower_limit; % limit output
y_pred(y_pred > upper_limit) = upper_limit; % limit output

%% Calculate Metrics: Error Matrix, OA, PA, UA, K
error_matrix = confusionmat(y, y_pred); % calculate confusion matrix
    
figure() % plot error matrix
confusionchart(y, y_pred)
title(['TSK Model - Confusion Matrix']);
saveas(gcf,[dir 'confusion_matrix.png'])         
    
figure() % confusion chart
confusionchart(y, y_pred,'Normalization','row-normalized','RowSummary','row-normalized')
title(['TSK Model - Confusion Matrix Frequencies']);
saveas(gcf,[dir 'confusion_matrix_freq.png'])         
    
overall_accuracy = sum(diag(error_matrix)) / length(chkData); % overal accuracy
disp(['Overall accuracy is: ',num2str(overall_accuracy)]);
x_ir = sum(error_matrix,2); % sum of each row
x_jc = sum(error_matrix,1); % sum of each column

for i = 1 : upper_limit
    producers_accuracy(i) = error_matrix(i,i) / x_jc(i); % producer's accuracy
    users_accuracy(i) = error_matrix(i,i) / x_ir(i); % user's accuracy
end
    
N = length(chkData(:,end));
k_hat = (N * trace(error_matrix) - sum(x_ir .* x_jc)) / (N^2 - sum(x_ir .* x_jc));

save('metrics_opt', 'error_matrix','overall_accuracy','k_hat','producers_accuracy','users_accuracy');
    
%% Learning curve: error VS epochs
figure;
plot(1:length(trnError), trnError, 1:length(trnError), chkError);
title(['Learning Curve']);
xlabel('# of Epochs');
ylabel('Error');
legend('Training Set', 'Check Set');
saveas(gcf,[dir 'learning_curve.png'])  

%% End
toc
load gong.mat;
sound(y);