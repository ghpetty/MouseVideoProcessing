% Function called by PupilAnalysis_gui_V2 to process a video frame and
% display it on the gui axes.
% This is a separate file because we also call it from the sub gui.
function [pupil_radius,IR_signal,semimajorAxis] = processPupilFrame_gui(handles)
im = rgb2gray(read(handles.VR,handles.currFrame));
% Get the IR signal (if we have the ROI)
if ~isempty(handles.IRROI)
    IR_signal = mean(imcrop(im,handles.IRROI),'all');
else
    IR_signal = nan;
end

% Crop the image to the pupil based on the ROI
if ~isempty(handles.pupilROI)
    im = imcrop(im,handles.pupilROI);
end
imshow(im,'Parent',handles.Axes_Original);
hold(handles.Axes_Original, 'on');
% Set the masking ROI values to be gray. 
if ~isempty(handles.MaskROIs)
    mergeMask = false(size(im));
    for i = 1:length(handles.MaskROIs)
        currROI = handles.MaskROIs{i};
        BW = roipoly(im,currROI(:,1),currROI(:,2));
        % Overlap new ROI ontop of all previous ROIs.
        mergeMask = or(mergeMask,BW);
    end
    % Apply a region filling algorithm -- Very Slow! --
    % Switching to just the median gray value of the frame:
%     im_fill = regionfill(im,mergeMask);
    im_fill = im;
    im_fill(mergeMask) = nanmedian(im,'all');
%     % Display the filled image

    % hold(handles.Axes_Original,'on');
else
    im_fill = im;
end

% Same thing, but for black filled ROIs
if ~isempty(handles.BlackROIs)
    mergeMask = false(size(im));
    for i = 1:length(handles.BlackROIs)
        currROI = handles.BlackROIs{i};
        BW = roipoly(im,currROI(:,1),currROI(:,2));
        % Overlap new ROI ontop of all previous ROIs.
        mergeMask = or(mergeMask,BW);
    end
    % Fill with minimum value of the current frame
    im_fill(mergeMask) = min(im,[],'all');
end




%     im(mergeMask) = median(im,'all');
imshow(im_fill,'Parent',handles.Axes_Mask);
% Threshold to create a binary image
im_bin = imbinarize(im_fill,handles.ThreshSlider.Value);
im_bin = ~im_bin;
% T = adaptthresh(im_fill,handles.ThreshSlider.Value,'NeighborhoodSize',31);
% im_bin = imbinarize(im_fill,T);
% Open and close to smooth out the thresholded regions
if handles.CloseSlider.Value >0
    im_bin = imclose(im_bin,strel('square',handles.CloseSlider.Value));
end
if handles.OpenSlider.Value > 0
    im_bin = imopen(im_bin,strel('square',handles.OpenSlider.Value));
end

% Measure properties of the binarized image
RP = regionprops(im_bin,'Centroid','MajorAxisLength','MinorAxisLength',...
    'Orientation','Circularity');
if ~ isempty(RP)
    % Remove small objects, then looks for the roundest object.
    all_radii = sqrt([RP.MajorAxisLength] .* [RP.MinorAxisLength]);
    RP(all_radii < handles.MinCutoffSlider.Value) = [];
    [~,I] = max([RP.Circularity]);
    RP = RP(I);
    if isempty(RP) 
        % warning('Found no regions larger than specified minimum cutoff')
        pupil_radius = nan;
        IR_signal = nan;
        return
    end
    pupil_radius = sqrt(RP.MinorAxisLength * RP.MajorAxisLength);
    semimajorAxis = RP.MajorAxisLength;
else
    pupil_radius = nan;
    semimajorAxis = nan;
end
plotEllipse(RP,'Parent',handles.Axes_Original);
hold(handles.Axes_Original,'off');
imshow(im_bin,'Parent',handles.Axes_Processed);
set(handles.CurrFrameText,'String',handles.currFrame);