% This function measures the difference in trial times between a target
% recording and a second recording that we want to match to the target.
% The target is an ntrode file, and the second is a measurement from a
% video file
% 
% Part of the larger alignVid2Ntrode function.
%
% Outputs a 'template', a vector containing the number of frames that must
% be added at each trial to result in an aligned video signal. This is
% later used to align the video data to ntrode data.
%
% Inputs: 
% TargetStartInds: Trial start indices from the target recording (ntrode).
%                  These times will be left unchanged.
%
% Target_SR      : Sampling rate of target signal (Hz)
%
% MatchStartInds : Trial start indices from the unaligned video. 
%                  These will be modified by adding or removing frames.
%
% Match_SR       : Sampling rate of unaligned video data (FPS or Hz)
%
% MinCorrection  : (Optional) Minimum number of frames / data points to 
%                  correct per trial. Errors less than this will be ignored. 
%                  Defaults to 3, which is very conservative. 
% 
% Parameters:
% 
% 'Plot'         : True/false. Whether to generate summary plots detailing
%                  how well adding/subtracting frames did in correcting 
%                  alignment errors 
% 
% Output:
% template: A 1xN array, where N is the number of trial start signals. 
%       The nth value of the template is the number of frames that must
%       be added or removed before trial start n to align the video signal
%       to the ntrode signal. Positive values indicate that frames will be
%       added, negative values indicate that frames will be removed.
%
% tableOut: A table containing more detailed information about how trial
%           starts were adjusted. 
%
% mdl     : The linear model used to calculate the alignment template.
%
% figHandle: Handle to the figure created if 'Plot' parameter is set to true
%            
% GHP  - Version 2
% Now uses fitlm and model residuals to decide where to add or remove
% frames, rather than iterating through each trial in a loop. 


function [template,tableOut,mdl,figHandle] = createVideoAlignmentTemplate(TargetStartInds,Target_SR,...
                        MatchStartInds,Match_SR,varargin)

% Input Parser - Check inputs to make sure they make sense, and sets
% default values for optional inputs.
p = inputParser;
addRequired(p,'TargetStartInds',@(x) isvector(x));
addRequired(p,'Target_SR',@(x) isscalar(x) && x > 0); 
addRequired(p,'MatchStartInds',@(x) isvector(x));
addRequired(p,'Match_SR',@(x) isscalar(x) && x > 0); 
addOptional(p,'MinCorrection',3,@(x) isscalar(x) && x >= 1);
addParameter(p,'Plot',true,@(x) islogical(x));
parse(p,TargetStartInds,Target_SR,MatchStartInds,Match_SR,varargin{:});
% Assign results from the parser to their own variables
target_startInds = p.Results.TargetStartInds;
target_SR = p.Results.Target_SR;
match_startInds = p.Results.MatchStartInds;
match_SR = p.Results.Match_SR;
minCorrection = p.Results.MinCorrection;
doPlot = p.Results.Plot;

% Check that start index vectors are the same length
if length(target_startInds) ~= length(match_startInds)
    error('Target and match recordings have different number of trials')
end

% Normalize starting indices so that, when we calculate starting times, the
% first trial always starts at t = 0;
% target_startInds = target_startInds - target_startInds(1);
% match_startInds = match_startInds - match_startInds(1);
% Create vectors of start times, in seconds.
target_startTimes = (target_startInds-target_startInds(1))/ target_SR;
match_startTimes = (match_startInds-match_startInds(1))/ match_SR;



% Fit a linear model and get the estimated slope
% - Use this to adjust the frame rate ("match_SR"), as the framerate is
%   usually slightly different than what is reported in the file 

mdl = fitlm(target_startTimes, match_startTimes,'Intercept',false);
% match_SR_adj = match_SR * mdl.Coefficients.Estimate ;
% match_startTimes_adj = match_startTimes / mdl.Coefficients.Estimate;

% Using these adjusted start times, identify missing frames: 
time_error = diff(target_startTimes) - diff(match_startTimes);
disp(mean(time_error))
frame_error = [0 ,time_error * match_SR] ;
% Check if we have any trials with a lot of missing frames and throw a 
% warning if we do
if any(abs(frame_error) >= 20)
    warn_trials = find(abs(frame_error) >= 20);
    warning(['Trial(s) ',num2str(warn_trials'),' have misalignments exceeding 20 frames']);
end

% Find those trials where the error exceeds the acceptable cutoff
trials_to_fix = find(abs(frame_error) >= minCorrection);
template = zeros(size(target_startInds));
% Use fix() function to round values towards 0, so we always change the
% minimum amount of frames. This helps avoid over-correcting.
template(trials_to_fix) = fix(frame_error(trials_to_fix));

% Adjust the trial start indices by this template;
new_match_startInds = (match_startInds) + cumsum(template);
new_match_startTimes = (new_match_startInds - new_match_startInds(1)) / match_SR;
% figure; plot(new_match_startInds - match_startInds);
% figure; plot(diff(target_startTimes),'-.k');
% hold on; plot(diff(match_startTimes),'-or');
% plot(diff(new_match_startTimes),'.b');
% Fit a new model. Use this to check how we did adding/removing frames.
new_mdl = fitlm(target_startTimes,new_match_startTimes,'Intercept',false);
% new_match_SR_adj = new_mdl.Coefficients.Estimate * match_SR ; 
new_time_error = diff(target_startTimes) - diff(new_match_startTimes);
new_frame_error = [0,new_time_error * match_SR] ;
% if any(abs(new_frame_error) > minCorrection)
%     error('whoops!')
% end
% new_frame_error = [0; diff(new_mdl.Residuals.Raw) * match_SR];
trialIndVect = 1:length(target_startInds);
% Plotting
if doPlot
    figHandle = figure;
    
    subplot(2,1,1); hold on;
    plot(trialIndVect, (match_startTimes/mdl.Coefficients.Estimate...
        - target_startTimes) * 1000, 'k');
    plot(trialIndVect, (new_match_startTimes/new_mdl.Coefficients.Estimate...
        - target_startTimes) * 1000, 'r');
    title('Adjusted Difference in Start Times')
    ylabel('Match - Target (ms)')
    legend({'Original','Insert/Remove Frames'})
    
    subplot(2,1,2); hold on;
    p1 = plot(trialIndVect, -frame_error, 'k');
    p2 = plot(trialIndVect, -new_frame_error, 'r');
    L = line([trialIndVect(1),trialIndVect(end)],...
         [minCorrection,minCorrection],...
         'Color','b','LineStyle','--');
    line([trialIndVect(1),trialIndVect(end)],...
         [-minCorrection,-minCorrection],...
         'Color','b','LineStyle','--');
    title('Frame Error');
    ylabel('Frames (negative = missing)');
    legend([p1 p2 L] , {'Original','Adjusted','Tolerance'})
%        
%     subplot(3,1,3); hold on;
%     plot(trialIndVect, (mdl.Residuals.Raw * 1000), 'k');
%     plot(trialIndVect, (new_mdl.Residuals.Raw * 1000), 'r');
%     title('Model Residuals');
%     ylabel('Residual (ms)');
%     
%     xlabel('Trial Number');
%     
%     drawnow;
end

% Put results in a table:
tableOut = table(trialIndVect',...
            template',...
            (match_startTimes - target_startTimes)' * 1000,...
            -frame_error',...
            (new_match_startTimes - target_startTimes)' * 1000,...
            -new_frame_error',...
            'VariableNames',...
            {'TrialNumber',...
             'Template',...
             'StartTimeError',...
             'FrameError',...
             'StartTimeError_Adj',...
             'FrameError_Adj'});
            
            
 % If we are plotting, also display the indices where we added / removed
 % frames
 if doPlot
     disp(tableOut(tableOut.Template ~=0,:))
 end







