% Nikolaos Giakoumoglou
% AEM 9043
% Fuzzy Systems 2020
%
% Generate Fuzzy Inference System structure from data using 
% subtractive clustering (genfis2).
% This script loads the optimal number of features, their indexes and
% number of rules after application of the grid search algorithm and trains 
% the optimal model as class dependent.
%% Clear
clear all; close all; clc; warning off;
dir = [pwd '\report\plots_opt_dependent\'];
tic

%% Load dataset
disp('Loading dataset...');
data = importdata('epileptic_seizure_recognition.csv');
data = data.data;
   
%% Load Optimal number of Features and Rules
load('opt_model_dependent.mat'); % load number of features, their indexes and rules
disp(['Optimal number of Features: ',num2str(optNumFeatures)]);
disp(['Optimal number of Radius ',num2str(optNumRad)]);
disp(['Feature Indexes ',num2str(featureIdx)]);
data = data(:,[featureIdx(1:end) , end]); % keep the most important features

%% Preprocess
[trnData, valData, chkData, frequencyTable] = preproc(data);
disp(frequencyTable);

%% Set Subtractive Clustering Options and generate FIS
%%Clustering Per Class
radius = optNumRad;
[c1,sig1]=subclust(trnData(trnData(:,end)==1,:),radius);
[c2,sig2]=subclust(trnData(trnData(:,end)==2,:),radius);
[c3,sig3]=subclust(trnData(trnData(:,end)==3,:),radius);
[c4,sig4]=subclust(trnData(trnData(:,end)==4,:),radius);
[c5,sig5]=subclust(trnData(trnData(:,end)==5,:),radius);

num_rules = size(c1,1)+size(c2,1)+size(c3,1)+size(c4,1)+size(c5,1);
    
%Build FIS From Scratch
fis=newfis('FIS_SC','sugeno');

%Add Input-Output Variables
names_in={'in1','in2','in3','in4','in5','in6','in7','in8','in9','in10','in11'...
    ,'in12','in13','in14','in15','in16','in17','in18','in19','in20','in21'};
for i=1:optNumFeatures
    fis=addvar(fis,'input',names_in{i},[0 1]);
end
fis=addvar(fis,'output','out1',[0 1]);

%Add Input Membership Functions
name='in';
for i=1:optNumFeatures
    for j=1:size(c1,1)
        fis=addMF(fis,names_in{i},'gaussmf',[sig1(i) c1(j,i)]);
    end
    for j=1:size(c2,1)
        fis=addMF(fis,names_in{i},'gaussmf',[sig2(i) c2(j,i)]);
    end
    for j=1:size(c3,1)
        fis=addMF(fis,names_in{i},'gaussmf',[sig3(i) c3(j,i)]);
    end
    for j=1:size(c4,1)
        fis=addMF(fis,names_in{i},'gaussmf',[sig4(i) c4(j,i)]);
    end
    for j=1:size(c5,1)
        fis=addMF(fis,names_in{i},'gaussmf',[sig5(i) c5(j,i)]);
    end
end

%Add Output Membership Functions
for l=1:size(c1,1)
    fis=addMF(fis,'out1','constant',1);
end
for l=1:size(c2,1)
    fis=addMF(fis,'out1','constant',2);
end
for l=1:size(c3,1)
    fis=addMF(fis,'out1','constant',3);
end
for l=1:size(c4,1)
    fis=addMF(fis,'out1','constant',4);
end
for l=1:size(c5,1)
    fis=addMF(fis,'out1','constant',5);
end

%Add FIS Rule Base
ruleList=zeros(1,optNumFeatures+1+2);
idx=0;
for l=1:size(c1,1)
    ruleList(1:end-2)=l;
    ruleList(end-1:end)=1;
    fis=addRule(fis,ruleList);
end
idx=l+idx;
for l=1:size(c2,1)
    ruleList(1:end-2)=l+idx;
    ruleList(end-1:end)=1;
    fis=addRule(fis,ruleList);
end
idx=l+idx;
for l=1:size(c3,1)
    ruleList(1:end-2)=l+idx;
    ruleList(end-1:end)=1;
    fis=addRule(fis,ruleList);
end
idx=l+idx;
for l=1:size(c4,1)
    ruleList(1:end-2)=l+idx;
    ruleList(end-1:end)=1;
    fis=addRule(fis,ruleList);
end
idx=l+idx;
for l=1:size(c5,1)
    ruleList(1:end-2)=l+idx;
    ruleList(end-1:end)=1;
    fis=addRule(fis,ruleList);
end
%% Plot and save MFs before training
plotMFs(fis); % Plot Inital Membership Functions
suptitle(['Input MFs before training']);
saveas(gcf,[dir 'MFs_before_training.png'])         
           
%% Set Training Options and train the generated FIS
anfis_opt = anfisOptions('InitialFis', fis, 'EpochNumber', 200,...
    'DisplayANFISInformation', 0, 'DisplayErrorValues', 0,...
    'ValidationData', chkData);
[trnFIS, trnError, ~, chkFIS, chkError] = anfis(trnData, anfis_opt);
showrule(chkFIS)

%% Evaluate the trained FIS
y_pred = evalfis(chkData(:,1:end-1),chkFIS); % evaluate the trained FIS
y = chkData(:,end);
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
title(['Confusion Matrix']);
saveas(gcf,[dir 'confusion_matrix.png'])         

figure() % confusion chart
confusionchart(y, y_pred,'Normalization','row-normalized','RowSummary','row-normalized')
title(['Confusion Matrix Frequencies']);
saveas(gcf,[dir 'confusion_matrix_freq.png'])        

overall_accuracy = sum(diag(error_matrix)) / length(chkData); % overal accuracy

x_ir = sum(error_matrix,2); % sum of each row
x_jc = sum(error_matrix,1); % sum of each column

for i = 1 : upper_limit
    producers_accuracy(i) = error_matrix(i,i) / x_jc(i); % producer's accuracy
    users_accuracy(i) = error_matrix(i,i) / x_ir(i); % user's accuracy
end

N = length(chkData(:,end));
k_hat = (N * trace(error_matrix) - sum(x_ir .* x_jc)) / (N^2 - sum(x_ir .* x_jc));
   
%% Plot and save MFs after training
plotMFs(chkFIS);
suptitle(['Input MF after training']);
saveas(gcf,[dir 'MFs_after_training.png'])  

%% Learning curve
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
