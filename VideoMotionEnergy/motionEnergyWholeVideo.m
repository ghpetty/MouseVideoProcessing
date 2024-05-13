function dataStructOut = motionEnergyWholeVideo(VR,varargin)
% dataStructOut = motionEnergyWholeVideo(vidreader,motionEnergyROI,alignmentSignalROI)
% Measure "motion energy" - the frame-by-frame absolutey difference in pixel values -
% over the course of an entire video stored in the VideoReader (VR) object. 
% Also measures an alignment signal by taking the mean value of each pixel
% in the video frame. 
% - Assumes all videos are in grayscale
%
% If given an ROI object, then motion energy and alignment signals are
% calculated only in the corresponding areas of the video. 
% 
% Outputs (stored in a struct array):
% Alignment Signal: A vector of length n, where n is the number of frames
% in the video. The i'th element is the mean pixel value (in the alignment
% signal ROI) on the i'th video frame.
% Motion Energy: A vector of length n, where n is the number of frames in
% the video. The i'th element is the mean difference in pixel values (in
% the motion energy ROI) between frames i and i-1.

p = inputParser;
addRequired(p,'VR');
addOptional(p,'motionEnergyROI',[]);
addOptional(p,'alignmentSignalROI',[]);
addParameter(p,'UseProgressBar',false);
parse(p,VR,varargin{:});

if isempty(p.Results.motionEnergyROI)
    motionEnergyMask = [];
else
    motionEnergyMask = createMask(p.Results.motionEnergyROI,VR.Height,VR.Width);
end

if isempty(p.Results.alignmentSignalROI)
    alignmentSignalMask = [];
else
    alignmentSignalMask = createMask(p.Results.alignmentSignalROI,VR.Height,VR.Width);
end

motionEnergy = nan(1,VR.NumFrames);
alignmentSignal = nan(1,VR.NumFrames);


% Create a progress bar, if requested
if p.Results.UseProgressBar == true
    progBar = waitbar(0,'Processing video',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(progBar,'canceling',0);



end


for i = 1:VR.NumFrames
    currFrame = read(VR,i);
    currFrame = squeeze(currFrame(:,:,1));
    
    % Update progress bar, if it exists
    % If we hit cancel, return an empty array
    if p.Results.UseProgressBar
        if getappdata(progBar,'canceling')
            dataStructOut = struct(); % 
            delete(progBar);
            return
        end

        percDone = floor(100*i/VR.NumFrames);
        percDoneLast = floor(100*(i-1)/VR.NumFrames);
        if ~isequal(percDone,percDoneLast)
            waitbar(percDone/100,progBar);
        end
    end


    % Get mean pixel values for alignment signal:
    if isempty(alignmentSignalMask)
        alignmentSignal(i) = mean(currFrame,"all");
    else
        alignmentSignal(i) = mean(currFrame(alignmentSignalMask),"all");
    end

    % Difference between current frame and previous frame:
    if i == 1
        motionEnergy(i) = 0;
    else
        if isempty(motionEnergyMask)
            motionEnergy(i) = mean(abs(currFrame - prevFrame),"all");
        else
            motionEnergy(i) = mean(abs(currFrame(motionEnergyMask) - prevFrame(motionEnergyMask)),"all");
        end

    end
    
    prevFrame = currFrame;

end
if p.Results.UseProgressBar
    delete(progBar);
end
dataStructOut = struct('MotionEnergy',motionEnergy,'AlignmentSignal',alignmentSignal);





