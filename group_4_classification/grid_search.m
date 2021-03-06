% Nikolaos Giakoumoglou
% AEM 9043
% Fuzzy Systems 2020
%
% Generate Fuzzy Inference System structure from data using 
% subtractive clustering (genfis2).
% This script finds the optimal number of features, their indexes and the
% radius of the cluster for the dataset epileptic seizure recognition.
%% Clear
clear all; close all; clc; warning off;
dir = [pwd '\report\plots_grid_search\'];
tic

%% Load dataset
data = importdata('epileptic_seizure_recognition.csv');
data = data.data;

%% Preprocess
[trnData, valData, chkData, frequencyTable] = preproc(data);
disp(frequencyTable);

%% Features selection with Relief algorithm
disp('Feature selection (Relief algorithm)...');
[ranks, ~] = relieff(data(:, 1:end - 1), data(:, end), 100,'method', 'classification'); % 100 nearest neighbours
   
%% Values 2 check for features and rules
features_arr = [3 9 15 21]; % number of features
radii = [0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85 0.95; % f = 3
        0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85 0.95; % f = 9
        0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85 0.95; % f = 15
        0.15 0.25 0.35 0.45 0.55 0.65 0.75 0.85 0.95]; % f = 21
rules_arr = NaN*ones(length(features_arr),length(radii)); % holds number of rules for each model  
error_arr = inf*ones(length(features_arr), length(rules_arr)); % holds mean model error for each model
count = 1; % iterates for every model 

%% Grid Search Algorithm
disp('Grid Search...')
for f = 1 : length(features_arr)
    for r = 1 : length(radii)
        
        c = cvpartition(trnData(:, end), 'KFold', 5); % 5-Folds Cross Validation
        MSE = zeros(c.NumTestSets, 1); % error
        fis = genfis2(trnData(:, ranks(1:features_arr(f))), trnData(:, end), radii(f, r));
        
        for i = 1 : length(fis.Output.MF)
            fis.Output.MF(i).Type = 'constant'; % manually set output to constant
        end
        
        rules_arr(f, r) = length(fis.rule); % no of rules
        
        if (rules_arr(f, r) == 1 || rules_arr(f,r) > 100) % if there is only one rule we cannot create a fis, so continue to next values
            continue; % or more than 100, continue, for speed reason
        end
        
        disp(' ');
        disp(['TSK Model ', num2str(count), ' / ', num2str(length(features_arr)*length(rules_arr))]);
        disp(['Number of features: ',num2str(features_arr(f))]);
        disp(['Radius: ',num2str(radii(f,r))]) ;
        disp(['Number of rules : ',num2str(rules_arr(f,r))]) ;
        fprintf('Fold: ');
        
        for i = 1 : c.NumTestSets % 5 Folds
            fprintf(' %1.0f ',i);
            trnIdx = c.training(i); % find training idx
            chkIdx = c.test(i); %find check idx
            trnDataCV = trnData(trnIdx,[ranks(1:features_arr(f)), end]); % 80% of the trnData as training data by default, take just features_arr(f) features
            chkDataCV = trnData(chkIdx,[ranks(1:features_arr(f)), end]); % 20% of the trnData as check data by default, take just features_arr(f) features              
            %tabulate(trnDataCV(:,end)) 
            %tabulate(chkDataCV(:,end))
            
            for iter = 1 : length(fis.Output.MF)
                fis.Output.MF(iter).Type = 'constant';
                fis.Output.MF(iter).Params = (table2array(frequencyTable(1,1))+table2array(frequencyTable(end,1)))/2;
            end
            
            anfis_opt = anfisOptions('InitialFis',fis,'EpochNumber',100,'DisplayANFISInformation',0,'DisplayErrorValues',0,'DisplayStepSize',0,'DisplayFinalResults',0,'ValidationData',[chkDataCV(:,1:end-1) chkDataCV(:,end)]); % use validation data to avoid overfitting            
            [trnFIS, trnError, ~, chkFIS, chkError] = anfis([trnDataCV(:,1:end-1) trnDataCV(:,end)], anfis_opt); % tune FIS
            y_pred = evalfis(valData(:, ranks(1:features_arr(f))), chkFIS); % calculate output
            y_pred = round(y_pred); % output must be an integer (classification)
            y = valData(:, end); % real output 
            lower_limit = table2array(frequencyTable(1,1)); % special cases if the output is out of the classification range
            upper_limit = table2array(frequencyTable(end,1)); % special cases if the output is out of the classification range
            y_pred(y_pred < lower_limit) = lower_limit;
            y_pred(y_pred > upper_limit) = upper_limit;
            MSE(i) = (norm(y-y_pred))^2/length(y); % MSE
        end
        disp(' ');
        disp(['MSE = ',num2str(mean(MSE))]);
        error_arr(f, r) = mean(MSE);
        count = count + 1;
    end
end
save('error_arr.mat','error_arr');
disp('Grid Search finished.');

%% 2D Plot of All Model Errors
figure;
sgtitle('2D Plot of All Model Errors');
for i=1:length(features_arr)
    subplot(2,2,i);
    bar(error_arr(i,:))
    xlabel('radii');
    xticklabels(string(radii(1,:)));
    legend([num2str(features_arr(i)),' features'])
end
%saveas(gcf,[dir 'mean_model_errors_2D.png'])

%% 3D Plot of All Model Errors
figure;
bar3(error_arr); 
ylabel('Number of Features');
yticklabels(string(features_arr));
xlabel('radii');
xticklabels(string(radii(1,:)));
zlabel('MSE');
title('3D Plot of All Model Errors');
%saveas(gcf,[dir 'mean_model_errors_3D.png'])

%% Optimal Model Selection
disp('Optimal model...')
idx = min(error_arr(:)); % set minimum after we observe matrix mean_model_MSE
[row,col] = find(error_arr==idx); 
optNumFeatures = features_arr(row);        % number of features of optimal model
optNumRad = radii(row,col);           % number of rules of optimal model
featureIdx = sort(ranks(1:optNumFeatures));
disp('Optimum Model Found:');
disp(['Number of Features : ',num2str(optNumFeatures)]);
disp(['Radius : ',num2str(optNumRad)]) ; 
save('opt_model.mat','optNumFeatures','optNumRad','featureIdx') % save optimum model

%% End
toc
load gong.mat;
sound(y);