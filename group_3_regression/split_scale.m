function [trnData,valData,chkData] = split_scale(data,preproc)
% function [trnData,valData,chkData] = split_scale(data,preproc)
% SPLIT_SCALE shuffles and splits data to training, validation and check
% set with proportion 60-20-20 percent respectively.
%
% Inputs:
% data           : the data to be preprocessed
% preproc        : 1 for normalization of input to unit hypercube or
%                  2 for standardization of input to zero mean - unit 
%                  variance
% Outputs:
% trnData        : training set, 60 percent
% valData        : validation set, 20 percent
% chkData        : check set, 20 percent
        
idx=randperm(length(data));                % array of random positions, no repeating
trnIdx=idx(1:round(length(idx)*0.6));      % indexes of first 60%
chkIdx=idx(round(length(idx)*0.6)+...
    1:round(length(idx)*0.8));             % indexes of next 20%
tstIdx=idx(round(length(idx)*0.8)+1:end);  % indexes of last 20%
trnX=data(trnIdx,1:end-1);                 % shuffled training set
valX=data(chkIdx,1:end-1);                 % shuffled validation set
chkX=data(tstIdx,1:end-1);                 % shuffled check set

switch preproc
case 1 % normalization of input to unit hypercube
    xmin=min(trnX,[],1);
    xmax=max(trnX,[],1);
    trnX=(trnX-repmat(xmin,[length(trnX) 1]))./(repmat(xmax,[length(trnX) 1])-repmat(xmin,[length(trnX) 1]));
    valX=(valX-repmat(xmin,[length(valX) 1]))./(repmat(xmax,[length(valX) 1])-repmat(xmin,[length(valX) 1]));
    chkX=(chkX-repmat(xmin,[length(chkX) 1]))./(repmat(xmax,[length(chkX) 1])-repmat(xmin,[length(chkX) 1]));
case 2 % standardization of input to zero mean - unit variance
    mu=mean(data,1);
    sig=std(data,1);
    trnX=(trnX-repmat(mu,[length(trnX) 1]))./repmat(sig,[length(trnX) 1]);
    valX=(trnX-repmat(mu,[length(valX) 1]))./repmat(sig,[length(valX) 1]);
    chkX=(trnX-repmat(mu,[length(chkX) 1]))./repmat(sig,[length(chkX) 1]);
otherwise
    disp('Not appropriate choice.')
end

trnData=[trnX data(trnIdx,end)]; % add output
valData=[valX data(chkIdx,end)]; % add output
chkData=[chkX data(tstIdx,end)]; % add output

end