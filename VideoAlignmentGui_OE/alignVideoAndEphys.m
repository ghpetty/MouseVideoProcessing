function S = alignVideoAndEphys(varargin)
% S = ALIGNVIDEOANDEPHYS A new version of alignment code, used by the
% VideoAlignment_OpenEphys GUI.
% Returns S, a struct containing three fields:
% - Behavior: The behavior variables recorded by Open Ephys
% - Video: The variables extracted from various videos
% - Spikes: Spike times, organized by Phy clusters.
% Behavior and Video data are continuous vectorsat millisecond resolution.
% Spike times are vectors of timestamps, also in milliseconds. 
% 
% Aligns video and Open Ephys data based on a common signal. 
% Every signal is upsampled / downsampled to 1kHz, and saved in a single
% output structure.
% Data is appended to this structure, so that we can align multiple videos
% to the same Ephys data (and thus align them to each other).
% Input a structure array with the following fields:
% VideoDataPath: Full path to a data struct containing each of the video
%       data variables you want to align.
% BehaviorDataPath: Full path to a data struct containing all of
%       the data from Open Ephys you want to align. This can contain spike
%       times or behavioral start and end times. %
%       - Behavior variables should be stored in a struct called "Behavior"
%           with fields corresponding to behavior variables. Variable
%           values should be binary vectors
% PhyDataPath: Path to the location of Phy output  
% 
% VideoStartInds: Vector of the indices (AKA frames) where alignment signal
%       starts
% VideoTrimInds: Two-element vector with number of indices to remove from
%       the start and end of the recording.
% VideoSR: Sample rate (AKA framerate) of the video.
% EphysStartInds, EphysTrimInds, EphysSR: Same as the above three, but for
%       Open Ephys data.

p = inputParser;

addParameter(p,'VideoDataPath',[],@(x) exist(x,'file'));
addParameter(p,'BehaviorDataPath',[],@(x) exist(x,'file'));
addParameter(p,'PhyDataPath',[],@(x) exist(x,'dir'));
addParameter(p,'VideoStartInds',[]);
addParameter(p,'VideoTrimInds',[]);
addParameter(p,'VideoSR',[]);
addParameter(p,'EphysStartInds',[]);
addParameter(p,'EphysTrimInds',[]);
addParameter(p,'EphysSR',[]);
addParameter(p,'MinCorrection',[]);
parse(p,varargin{:});

% Load in the video data 
disp(['Loading ',p.Results.VideoDataPath]);
vidData = load(p.Results.VideoDataPath);

% Adjust the trial starts for the two alignment signals:
vidStartInds = p.Results.VideoStartInds;
vidTrimInds = p.Results.VideoTrimInds;
vidStartInds(end-vidTrimInds(2)+1:end) = [];
vidStartInds(1:vidTrimInds(1)) = [];

ephysStartInds = p.Results.EphysStartInds;
ephysTrimInds = p.Results.EphysTrimInds;
ephysStartInds(end-ephysTrimInds(2)+1:end) = [];
ephysStartInds(1:ephysTrimInds(1)) = [];

% Make sure that both vectors have the same dimension, otherwise we get
% errors in the next step:
ephysStartInds = reshape(ephysStartInds,1,[]);
vidStartInds   = reshape(vidStartInds,1,[]);
SR = p.Results.EphysSR;
frameRate = p.Results.VideoSR;

% Plug into the alignment template function.
% This tells us how many frames to add to each video variable.

% minCorrection = 3;
template = createVideoAlignmentTemplate(...
        ephysStartInds,SR,...
        vidStartInds,frameRate,...
        'MinCorrection',p.Results.MinCorrection,...
        'Plot',true);

    
drawnow;
% Iterate through the video data and align it. 
% Only aligns VECTORS, ignores matrices.
% Once we have added frames, linearly interpolate to 1kHz.
% First calculate the total time of the recording after trimming - this is
% used for interpolation. (milliseconds);
totalTime_trimmed = (ephysStartInds(end) - ephysStartInds(1)) / SR * 1000 + 1;
videoVars = fieldnames(vidData);
vidDataOut = struct;


for i = 1:length(videoVars)
%     figure; hold on
    currVar = videoVars{i};
%     d = vidData.(currVar);
%     plot(d);
%     scatter(vidStartInds,d(vidStartInds))
    if isvector(vidData.(currVar)) && ~isscalar(vidData.(currVar)) && isnumeric(vidData.(currVar))
        [currData_adj,startInds_adj] = adjustVidFramesByTemplate(...
            vidData.(currVar),vidStartInds,template);
        % Remove values before and after the current start indices
        currData_trim = currData_adj(startInds_adj(1):startInds_adj(end));
        vidDataOut.(currVar) = interpolateVidData2msec(...
            currData_trim,totalTime_trimmed);
    else
        disp(['Skipping ',currVar]);
    end
end

% Next align the behavior start and stop times.
% - Trim binary vectors by removing indices that excede the specified start
% indices
% - Downsample from sampling rate to 1kHz

% First calculate the indices we want to trim:
% Load behavior data and isolate the binary vectors
disp('Processing behavior data...');
load(p.Results.BehaviorDataPath,'BehaviorDataTable');
behaviorDataOut = struct;
downsampleFactor = p.Results.EphysSR / 1000;
for i = 1:height(BehaviorDataTable)
    currData = BehaviorDataTable.EventBinary{i};
    currdata_trimmed = currData(ephysStartInds(1):ephysStartInds(end));
    % Convert to a valid field name for a struct array:
    varName = genvarname(BehaviorDataTable.Properties.RowNames{i});
    behaviorDataOut.(varName) = ...
        downsample(currdata_trimmed,downsampleFactor);

end

% Align spike times:
disp('Processing spike clusters...');
% Load in spikes and find good spikes:
clusterStruct = loadGoodSpikesFromPhy(p.Results.PhyDataPath);
% - Trim spikes that occur before and after our start time range.
% - Convert from samples to milliseconds, rounding to nearest msec
clusterDataOut = struct;
for i = 1:length(clusterStruct)
    spikeInds = double(clusterStruct(i).SpikeTimes);
    spikeInds(spikeInds > ephysStartInds(end)) = [];
    spikeInds(spikeInds < ephysStartInds(1))   = [];
    spikeInds = spikeInds - ephysStartInds(1);
    spikeInds = round(spikeInds / SR * 1000);
    clusterDataOut(i).SpikeTimes = spikeInds;
    clusterDataOut(i).ClusterID = clusterStruct(i).ClusterID;
    
end

S.Behavior = behaviorDataOut;
S.Spikes = clusterDataOut;
S.Video = vidDataOut;









