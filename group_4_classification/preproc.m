function [trnData, valData, chkData, frequencyTable] = preproc(data)
% [trnData, valData, chkData, frequencyTable] = preproc(data)
% PREPROC makes a preprocess for the given data.
% First the data are normalized.Then we split the dataset so as each set 
% (training, validation and check) has equal proportion of each output
% which can be shown in the frequencyTable. The sets are split 60-20-20. 
% The data are lastly shuffled and returned.
%
% Inputs:
% data           : the data to be preprocessed
%
% Outputs:
% trnData        : training set, 60 percent
% valData        : validation set, 20 percent
% chkData        : check set, 20 percent
% frequencyTable : a table with the frequencys of outputs for the
%                  initial set and the training, validation and check set
%% Init table
tbl = tabulate(data(:,end));

%% Normalize Data
dataIn = data(:,1:end-1);
dataOut = data(:,end);
xmin=min(dataIn,[],1);
xmax=max(dataIn,[],1);
dataIn=(dataIn-repmat(xmin,[length(dataIn) 1]))./(repmat(xmax,[length(dataIn) 1])-repmat(xmin,[length(dataIn) 1]));
data=[dataIn dataOut];

%% Split dataset with equal proportion of outputs
numOutputs = unique(data(:,end));
trnData = [];
valData = [];
chkData = [];
for iter = 1:length(numOutputs)
    temp_data = data(data(:,end)==numOutputs(iter),:);
    split_temp_data_60 = round(0.6*length(temp_data)); % index of the 60%-th element for data where output is specified
    split_temp_data_80 = round(0.8*length(temp_data)); % index of the 80%-th element for data where output is specified
    trnData = [trnData; temp_data(1:split_temp_data_60,:)];
    valData = [valData; temp_data(split_temp_data_60+1:split_temp_data_80,:)];
    chkData = [chkData; temp_data(split_temp_data_80+1:end,:)];
end
%% Check if dataset is split correctly
tbl_1 = tabulate(trnData(:,end));
tbl_2 = tabulate(valData(:,end));
tbl_3 = tabulate(chkData(:,end));
frequencyTable = table(tbl(:,1),strcat(num2str(tbl(:,3)),'%'),strcat(num2str(tbl_1(:,3)),'%'),...
    strcat(num2str(tbl_2(:,3)),'%'),strcat(num2str(tbl_3(:,3)),'%'));
frequencyTable.Properties.VariableNames = {'classes_values' 'initial_set' 'training_set' 'validation_set' 'check_set'};

%% Shuffle Data
shuffled_data = zeros(size(trnData));
idx = randperm(length(trnData));
for iter = 1 : length(trnData)
    shuffled_data(iter, :) = trnData(idx(iter), :);
end
trnData = shuffled_data;

shuffled_data = zeros(size(valData));
idx = randperm(length(valData));
for iter = 1 : length(valData)
    shuffled_data(iter, :) = valData(idx(iter), :);
end
valData = shuffled_data;

shuffled_data = zeros(size(chkData));
idx = randperm(length(chkData));
for iter = 1 : length(chkData)
    shuffled_data(iter, :) = chkData(idx(iter), :);
end
chkData = shuffled_data;

end
