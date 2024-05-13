% Insert or remove frame data from a vector or matrix according to an
% alignment template. The template is a vector created by the function
% createVideoAlignmentTemplate.
%
% Inputs
% data_in : A vector or matrix of data. 
%
% trialStartInds : a vector of the indices in the data_in corresponding 
%                  to the trial starts 
%
% template : The template vector created by the createVideoAlignmentTemplate
%            function, indicating how many frames to insert or remove from
%            each trial
% 
% Outputs:
% dataOut : A vector or matrix of the adjusted data with values
%           removed/added
% 
% newStartInds: A vector indicating the adjusted trial start indices.
%
%               
% Frames are added or removed at indices evenly spaced throughout the
% trial. When adding frames, values are linearly interpolated between
% previous and following values (i.e. it is the mean of those values).

% GHP Feb 2021

% This is a new version of alignArray2VidTemplate. 
% It is designed to work with the new version of
% createVideoAlignmentTemplate, which uses linear regressions between trial
% start time to more accurately decide where to insert/remove frames.

% GHP October 2022 
% Reworking this function in an attempt to improve accuracy

function [dataOut, newStartInds] = adjustVidFramesByTemplate(dataIn, trialStartInds, template)
% Ensure that matrix is aligned in rows - Time points are in columns
if size(dataIn,1) > size(dataIn,2)
    dataIn = dataIn';
end

dataOut = dataIn;
if ~isequal(size(trialStartInds),size(template))
    trialStartInds = trialStartInds';
end
newStartInds = trialStartInds + cumsum(template);
nTrials = length(trialStartInds);

for i = 2:nTrials
    if template(i) ~= 0
        % Adding frames
        if template(i) > 0
            trialsToAdd = template(i);
            trialStartPrev = newStartInds(i-1);
            trialStartNext = newStartInds(i);
            indsToAdd = round(linspace(trialStartPrev,trialStartNext,(trialsToAdd + 2)));
            indsToAdd = indsToAdd(2:end-1);
            insertVals = nan(size(dataIn,1),1);
%             figure; plot(dataOut); hold on; 
            for j = 1:length(indsToAdd)
                try
                    dataOut = [dataOut(:,1:indsToAdd(j)),insertVals,dataOut(:,indsToAdd(j)+1:end)];
                catch
                    error('Error adding extra frames')
                end
            end
%             plot(dataOut);
        % Removing Frames    
        else
            trialsToRemove = abs(template(i));
            trialStartPrev = newStartInds(i-1);
            trialStartNext = newStartInds(i);
            indsToRemove = round(linspace(trialStartPrev,trialStartNext,(trialsToRemove + 2)));
            indsToRemove = indsToRemove(2:end-1);
            for j = 1:length(indsToRemove)
                dataOut(:,indsToRemove(j)) = [];
            end
        end 
    end    
end





