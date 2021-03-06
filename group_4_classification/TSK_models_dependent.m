% Nikolaos Giakoumoglou
% AEM 9043
% Fuzzy Systems 2020
%
% Classification - Class Dependent
%% Clear
disp('Clearing workspace...');
clear all; close all; clc; format compact; warning off;
dir = [pwd '\report\plots_TSK_class_dependent\'];
tic

%% Load dataset
data = importdata('haberman.data');

%% Preprocess
[trnData, valData, chkData, frequencyTable] = preproc(data);
disp(frequencyTable);

%% Initializations
error_matrix = cell(1, 2);          % ERROR
overall_accuracy = zeros(2,1);      % OA
producers_accuracy = cell(1, 2);    % PA
users_accuracy = cell(1, 2);        % UA
k_hat = zeros(2,1);                 % K hat
x_ir = cell(1,2);
x_jc = cell(1,2);
     
radius_arr = [0.94 0.58];           % radius parameter - SC Algorithm
rules_arr = zeros(2,1);             % number of rules produced 
                                    % by SC Algorithm                                      
%% Training
disp('Training of models just started...');
for iter = 1:2
    %% Set Subtractive Clustering Options and generate FIS
    %%Clustering Per Class
    radius = radius_arr(iter);
    [c1,sig1]=subclust(trnData(trnData(:,end)==1,:),radius);
    [c2,sig2]=subclust(trnData(trnData(:,end)==2,:),radius);
    num_rules = size(c1,1)+size(c2,1);
    rules_arr(iter) = num_rules;
    
    %Build FIS From Scratch
    fis=newfis('FIS_SC','sugeno');

    %Add Input-Output Variables
    names_in={'in1','in2','in3','in4','in5'};
    for i=1:size(trnData,2)-1
        fis=addvar(fis,'input',names_in{i},[0 1]);
    end
    fis=addvar(fis,'output','out1',[0 1]);

    %Add Input Membership Functions
    name='in';
    for i=1:size(trnData,2)-1
        for j=1:size(c1,1)
            fis=addMF(fis,[name num2str(i)],'gaussmf',[sig1(j) c1(j,i)]);
        end
        for j=1:size(c2,1)
            fis=addMF(fis,[name num2str(i)],'gaussmf',[sig2(j) c2(j,i)]);
        end
    end

    %Add Output Membership Functions
    params=[zeros(1,size(c1,1)) ones(1,size(c2,1))];
    for i=1:rules_arr(iter)
        fis=addMF(fis,'out1','constant',params(i));
    end

    %Add FIS Rule Base
    ruleList=zeros(num_rules,size(trnData,2));
    for i=1:size(ruleList,1)
        ruleList(i,:)=i;
    end
    ruleList=[ruleList ones(num_rules,2)];
    fis=addrule(fis,ruleList);
    
    %[trnFis,trnError,~,valFis,valError]=anfis(trnData,fis,[200 0 0.01 0.9 1.1],[],chkData);
    
    %% Plot and save MFs before training
    plotMFs(fis); % Plot Inital Membership Functions
    suptitle(['TSK model ', num2str(iter+5), ' - Input MFs before training']);
    saveas(gcf,[dir 'MFs_before_training_' num2str(iter) '.png'])         
    disp(['Current model training ', num2str(iter), ' / ', num2str(length(radius_arr))]);

    %% Set Training Options and train the generated FIS
    anfis_opt = anfisOptions('InitialFis', fis, 'EpochNumber', 200,...
        'DisplayANFISInformation', 0, 'DisplayErrorValues', 0,...
        'ValidationData', chkData);
    [trnFIS, trnError, ~, chkFIS, chkError] = anfis(trnData, anfis_opt);
    showrule(chkFIS);
    
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
    title(['TSK Model ' num2str(iter+5) ' - Confusion Matrix']);
    saveas(gcf,[dir 'confusion_matrix_' num2str(iter) '.png'])         

    figure() % confusion chart
    confusionchart(y, y_pred,'Normalization','row-normalized','RowSummary','row-normalized')
    title(['TSK Model ' num2str(iter+5) ' - Confusion Matrix Frequencies']);
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
    suptitle(['TSK model ', num2str(iter+5), ' - Input MF after training']);
    saveas(gcf,[dir 'MFs_after_training_' num2str(iter) '.png'])  
    
    %% Learning curve
    figure;
    plot(1:length(trnError), trnError, 1:length(trnError), chkError);
    title(['TSK model ', num2str(iter+5), ' - Learning Curve']);
    xlabel('# of Epochs');
    ylabel('Error');
    legend('Training Set', 'Check Set');
    saveas(gcf,[dir 'learning_curve_' num2str(iter) '.png'])         
    
end
disp('Training of models ended...');

%% End
toc
load gong.mat;
sound(y);