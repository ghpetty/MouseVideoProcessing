function dataOut = processPupil_wholevid(params,nFrames,dosave,doplot,useProgressBar)
% PROCESSPUPIL_WHOLEVID analyze the pupil of a video using the parameters
% in PupilAnalysisGUI
% Input is a struct containing a video reader object, ROIs, and image
% manipulation parameters. Performs some smoothing and removes outliers of
% the data, and saves the results to a Mat file in the same directory as
% the original video.
%
% GHP April 2024


if isequal(nFrames,'all') || (nargin < 2)
    nFrames = floor(params.VR.Duration * params.VR.FrameRate);
    params.VR.CurrentTime = 0;
end

if nargin<4
    doplot = true;
    useProgressBar = true;
end
outpath = params.VR.Path;

centroids = nan(2,nFrames);
radii = nan(1,nFrames);
IRsig = nan(1,nFrames);
semimajorAxis = nan(1,nFrames);
% If the video reader is at a time other than 0, we use that time to
% estimate our current frame and add that to the start of our frame vector.

startFrame = floor(params.VR.CurrentTime * params.VR.FrameRate);

% Create a progress bar, if requested.
% Set up a cancel button, so we can terminate video processing.
if useProgressBar
    progBar = waitbar(0,'Processing video',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(progBar,'canceling',0);
end
i = 1;
while i < nFrames && hasFrame(params.VR)
    [radii(i),centroids(:,i),IRsig(i),semimajorAxis(i)] = ...
        processPupilFrame_analysis(params);

    if useProgressBar
        if getappdata(progBar,'canceling')
            break
        end

        percDone = floor(100*i/nFrames);
        percDoneLast = floor(100*(i-1)/nFrames);


        if ~isequal(percDone,percDoneLast)
            waitbar(percDone/100,progBar);
        end

    end
    i = i+1;

end

if getappdata(progBar,'canceling')
    delete(progBar);
    return

end
% If we ended early because we ran out of frames, throw a warning
if i < nFrames
    warndlg('Ran out of video frames while processing 1 minute sample.')
end



% Postprocessing: Removing outliers, interpolating, and smoothing
% Find outliers based on pupil location and size:
% - Parameters for post-processing:
postprocessParams = struct;
postprocessParams.outlierWindow = max(round(params.VR.FrameRate),60);
postprocessParams.thresholdFactor = 4;
postprocessParams.smoothWindow = 5;
% - Data for post-processing:
dataStruct = struct;
dataStruct.centroid = centroids;
dataStruct.radius = radii;
dataStruct.alignmentSignal = IRsig;
dataStruct.semimajorAxis = semimajorAxis;
% - Process the data with this function:
dataOut = processPupil_postprocessing(dataStruct,postprocessParams);

delete(progBar);
% Generate a summary plot, if requested:
if doplot
    % Rewind the video, since we might be at the end
    params.VR.currentTime = 0;
    figure;
    sampleFrame = imcrop(readFrame(params.VR),params.PupilROI);
    frameVect = (1:nFrames) + startFrame - 1;
    processPupil_postprocessPlot(sampleFrame,frameVect,dataOut)
end

% Save results:
if dosave
    [~,vidFile] = fileparts(params.VR.Name);
    resultsFileName = fullfile(outpath,[vidFile '.mat']);
    % These are the old way variables were saved
    % outputStruct = struct(...
    %     'pupilRadius',radii,...
    %     'smoothedRadius',sm_radius,...
    %     'semimajorAxis',semimajorAxis,...
    %     'smoothedSemimajor',sm_semimajor,...
    %     'pupilCenter',centroids,...
    %     'IRledSignal',IRsig,...
    %     'OutlierInds',outlierInds);
    save(resultsFileName,'-struct','dataOut');
    disp(['Saved results to ', resultsFileName]);
end

