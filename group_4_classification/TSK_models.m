% Nikolaos Giakoumoglou
% AEM 9043
% Fuzzy Systems 2020
%
% Generate Fuzzy Inference System structure from data using 
% subtractive clustering (genfis with SC option and squash factor).
% Classification by selecting radius_arr and squash factor (Class
% Independent)
%% Clear
disp('Clearing workspace...');
clear all; close all; clc; format compact; warning off;
dir = [pwd '\report\plots_TSK\'];
tic

%% Load dataset
data = importdata('haberman.data');

%% Preprocess
[trnData, valData, chkData, frequencyTable] = preproc(data);
disp(frequencyTable);

%% Initializations
error_matrix = cell(1, 5);          % ERROR
overall_accuracy = zeros(5,1);      % OA
producers_accuracy = cell(1, 5);    % PA
users_accuracy = cell(1, 5);        % UA
k_hat = zeros(5,1);                 % K hat
x_ir = cell(1,5);
x_jc = cell(1,5);
     
radius_arr = [0.94 0.9 0.76 0.66 0.5];      % radius parameter - SC Algorithm
squash_factor_arr=[0.7 0.5 0.5 0.5 0.5];    % squash factor - genfis option
rules_arr = zeros(5,1);                     % number of rules produced 
                                            % by SC Algorithm                                      
%% Training
disp('Training of models just started...');
for iter = 1:length(rules_arr)
    %% Set Subtractive Clustering Options and generate FIS
    genfis_opt = genfisOptions('SubtractiveClustering',...
        'ClusterInfluenceRange',radius_arr(iter),...
        'SquashFactor',squash_factor_arr(iter),'Verbose',0);
    fis = genfis(trnData(:,1:end-1), trnData(:,end), genfis_opt);
    rules_arr(iter) = length(fis.Rule);
    
    for i = 1 : length(fis.Output.MF)
        fis.Output.MF(i).Type = 'constant'; % set MFs 
    end
    
    %% Plot and save MFs before training
    plotMFs(fis); % Plot Inital Membership Functions
    suptitle(['TSK model ', num2str(iter), ' - Input MFs before training']);
    saveas(gcf,[dir 'MFs_before_training_' num2str(iter) '.png'])         
    disp(['Current model training ', num2str(iter), ' / ', num2str(length(radius_arr))]);
    
    %% Set Training Options and train the generated FIS
    anfis_opt = anfisOptions('InitialFis', fis, 'EpochNumber', 200,...
        'DisplayANFISInformation', 0, 'DisplayErrorValues', 0,...
        'ValidationData', valData);
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
    error_matrix{iter} = confusionmat(y, y_pred); % calculate confusion matrix

    figure() % plot error matrix
    confusionchart(y, y_pred)
    title(['TSK Model ' num2str(iter) ' - Confusion Matrix']);
    saveas(gcf,[dir 'confusion_matrix_' num2str(iter) '.png'])         

    figure() % confusion chart
    confusionchart(y, y_pred,'Normalization','row-normalized','RowSummary','row-normalized')
    title(['TSK Model ' num2str(iter) ' - Confusion Matrix Frequencies']);
    saveas(gcf,[dir 'confusion_matrix_freq_' num2str(iter) '.png'])        

    overall_accuracy(iter) = sum(diag(error_matrix{iter})) / length(chkData); % overal accuracy

    x_ir{iter} = sum(error_matrix{iter},2); % sum of each row
    x_jc{iter} = sum(error_matrix{iter},1); % sum of each column

    for i = 1 : upper_limit
        producers_accuracy{iter}(i) = error_matrix{iter}(i,i) / x_jc{iter}(i); % producer's accuracy
        users_accuracy{iter}(i) = error_matrix{iter}(i,i) / x_ir{iter}(i); % user's accuracy
    end

    N = length(chkData(:,end));
    k_hat(iter) = (N * trace(error_matrix{iter}) - sum(x_ir{iter} .* x_jc{iter})) / (N^2 - sum(x_ir{iter} .* x_jc{iter}));
   
    %% Plot and save MFs after training
    plotMFs(chkFIS);
    suptitle(['TSK model ', num2str(iter), ' - Input MF after training']);
    saveas(gcf,[dir 'MFs_after_training_' num2str(iter) '.png'])  
    
    %% Learning curve
    figure;
    plot(1:length(trnError), trnError, 1:length(trnError), chkError);
    title(['TSK model ', num2str(iter), ' - Learning Curve']);
    xlabel('# of Epochs');
    ylabel('Error');
    legend('Training Set', 'Check Set');
    saveas(gcf,[dir 'learning_curve_' num2str(iter) '.png'])         
    
end
disp('Training of models ended...');

%% Results of all 5 models
figure;
bar(rules_arr(1:length(rules_arr)), overall_accuracy);
title('Overall accuracy with regards to number of rules');
xlabel('Number of rules');
saveas(gcf,[dir 'OA_vs_NR.png'])  

figure;
bar(rules_arr(1:length(rules_arr)), k_hat);
title('k value with regards to number of rules');
xlabel('Number of rules');
saveas(gcf,[dir 'k_hat_vs_NR.png'])  

%save('metrics', 'error_matrix','overall_accuracy','k_hat','producers_accuracy','users_accuracy');

%% End
toc
load gong.mat;
sound(y);