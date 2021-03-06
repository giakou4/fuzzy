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
dir = [pwd '\report\plots_grid_search_dependent\'];
tic

%% Load dataset
data = importdata('epileptic_seizure_recognition.csv');
data = data.data;

%% Preprocess
[trnData, valData, chkData, frequencyTable] = preproc(data);
disp(frequencyTable);

%% Features selection with Relief algorithm
disp('Feature selection (Relief algorithm)...');
load('ranks.mat')

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
        
        %% Build FIS from scratch
        radius = radii(f,r);
        optNumFeatures = features_arr(f);
        
        trnDataIns = trnData(:,ranks(1:optNumFeatures));
        trnDataIns = [trnDataIns, trnData(:,end)];
        [c1,sig1]=subclust(trnDataIns(trnDataIns(:,end)==1,:),radius);
        [c2,sig2]=subclust(trnDataIns(trnDataIns(:,end)==2,:),radius);
        [c3,sig3]=subclust(trnDataIns(trnDataIns(:,end)==3,:),radius);
        [c4,sig4]=subclust(trnDataIns(trnDataIns(:,end)==4,:),radius);
        [c5,sig5]=subclust(trnDataIns(trnDataIns(:,end)==5,:),radius);

        if (length(c4) >150 ||length(c5) > 200)
            continue;
        end
        
        num_rules = size(c1,1)+size(c2,1)+size(c3,1)+size(c4,1)+size(c5,1);
                
        fis=newfis('FIS_SC','sugeno');

        %Add Input-Output Variables
        names_in={'in1','in2','in3','in4','in5','in6','in7','in8','in9','in10','in11'...
            ,'in12','in13','in14','in15','in16','in17','in18','in19','in20','in21'};
        for i=1:optNumFeatures
            fis=addvar(fis,'input',names_in{i},[0 1]);
        end
        fis=addvar(fis,'output','out1',[0 1]);

        %Add Input Membership Functions
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
        
       %% Grid Search (continued)
        
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
            
            %for iter = 1 : length(fis.Output.MF)
                %fis.Output.MF(iter).Type = 'constant';
                %fis.Output.MF(iter).Params = (table2array(frequencyTable(1,1))+table2array(frequencyTable(end,1)))/2;
            %end
            
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
%save('error_arr.mat','error_arr');
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
saveas(gcf,[dir 'mean_model_errors_2D.png'])

%% 3D Plot of All Model Errors
figure;
bar3(error_arr); 
ylabel('Number of Features');
yticklabels(string(features_arr));
xlabel('radii');
xticklabels(string(radii(1,:)));
zlabel('MSE');
title('3D Plot of All Model Errors');
saveas(gcf,[dir 'mean_model_errors_3D.png'])

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
save('opt_model_dependent.mat','optNumFeatures','optNumRad','featureIdx') % save optimum model

%% End
toc
load gong.mat;
sound(y);