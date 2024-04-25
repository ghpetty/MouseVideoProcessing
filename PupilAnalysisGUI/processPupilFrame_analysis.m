function [radius,centroid,IR_signal,semimajorAxis] = processPupilFrame_analysis(params)

p = inputParser;
addParameter(p,'VR',[]); % Video reader
addParameter(p,'IRROI',[]); % Coordinates defining rectangle ROI
addParameter(p,'PupilROI',[]); % "
addParameter(p,'Masks',[]); % Cell array containing 1 or more ROI objects
addParameter(p,'Masks_Black',[]); % Same as above, these ROIs are filled in with black
addParameter(p,'Open',0);
addParameter(p,'Close',0);
addParameter(p,'Min_Radius',0);
addParameter(p,'Threshold',0);
parse(p,params);


im = rgb2gray(readFrame(p.Results.VR));
% Get the IR signal (if we have the ROI)
if ~isempty(p.Results.IRROI)
    IR_signal = mean(imcrop(im,p.Results.IRROI),'all');
else
    IR_signal = nan;
end

% Crop the image to the pupil based on the ROI
if ~isempty(p.Results.PupilROI)
    im = imcrop(im,p.Results.PupilROI);
end

if ~isempty(p.Results.Masks)
    fillMask = false(size(im));
    if ~iscell(p.Results.Masks)
        fillMask = roipoly(...
            im,p.Results.Masks(:,1),...
            p.Results.Masks(:,2));
    else
        for i = 1:length(p.Results.Masks)
            currROI = p.Results.Masks{i};
            BW = roipoly(im,currROI(:,1),currROI(:,2));
            % Overlap new ROI ontop of all previous ROIs.
            fillMask = or(fillMask,BW);
        end
        % Changing from regionfill algorithm to filling in with a median
        % value
%         im_fill = regionfill(im,mergeMask);
        im_fill = im;
        im_fill(fillMask) = nanmedian(im,'all');
    end
else
    im_fill = im;
end

% Same as above for black ROIs
if ~isempty(p.Results.Masks_Black)
    fillMask = false(size(im));
    if ~iscell(p.Results.Masks_Black)
        fillMask = roipoly(...
            im,p.Results.Masks_Black(:,1),...
            p.Results.Masks_Black(:,2));
    else
        for i = 1:length(p.Results.Masks_Black)
            currROI = p.Results.Masks_Black{i};
            BW = roipoly(im,currROI(:,1),currROI(:,2));
            % Overlap new ROI ontop of all previous ROIs.
            fillMask = or(fillMask,BW);
        end
        % Changing from regionfill algorithm to filling in with a median
        % value
%         im_fill = regionfill(im,mergeMask);
    end
    im_fill(fillMask) = min(im,[],'all');
end



% Binarize image using specified threshold parameter
im_bin = imbinarize(im_fill,p.Results.Threshold);
% Open and close to smooth out the thresholded regions
if p.Results.Close > 0
    im_bin = imclose(im_bin,strel('square',p.Results.Close));
end
if p.Results.Open > 0
    im_bin = imopen(im_bin,strel('square',p.Results.Open));
end
im_bin = ~im_bin;
% Find objects that might be the pupil. Then remove objects that are too
% small
RP = regionprops(im_bin,'Centroid','MajorAxisLength','MinorAxisLength',...
                        'Circularity');
if ~isempty(RP)

    all_radii = sqrt([RP.MajorAxisLength] .* [RP.MinorAxisLength]);
    % Now remove small objects, then look for the roundest object.
    RP(all_radii < p.Results.Min_Radius) = [];

    if isempty(RP) 
%         warning('Found no regions larger than specified minimum radius cutoff.')
        radius = nan;
        centroid = nan;
    else
        [~,I] = max([RP.Circularity]);
        RP = RP(I);
        semimajorAxis = RP.MajorAxisLength;
        radius = sqrt(RP.MinorAxisLength * RP.MajorAxisLength);
        centroid = RP.Centroid;
    end
else
    radius = nan;
    centroid = nan;
    semimajorAxis = nan;
end

