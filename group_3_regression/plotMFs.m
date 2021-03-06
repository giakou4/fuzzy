function plotMFs(fis)
% function plotMFs(fis)
% PLOTMFS plots the membership functions of the inputs of the FIS. In the
% specific script, the inputs are limited to 6 (for assignment 3)
%
% Inputs:
% fis       : the FIS
% Outputs:
% A figure with all the MFs

figure;
for iter=1:length(fis.Inputs)
    subplot(ceil(sqrt(length(fis.Inputs))),...
        ceil(sqrt(length(fis.Inputs))),iter)
    plotmf(fis,'input',iter);
end

end

