function outlierBool = processPupil_findOutliers(centroid,radius,outlierWindow,thresholdFactor)
% outlierBool = processPupil_rmvOutliers(centroids,radii,outlierWindow)
%
% Identify outliers frames in a pupil video by finding frames where the
% pupil may have been mislabelled. This algorithm looks for outliers by
% finding frames where the pupil center (centroid) or the pupil size
% (radius) changes dramatically between consecutive frames. The algorithm
% looks locally in time to reduce the effect of saccades or blinks
% effecting the entire video. This is implemented with MATLAB's built-in
% isoutlier function using movmedian and a threshold factor of 4. 
%
% Inputs:
% centroid: A nx2 matrix of the X and Y coordinates of the pupil centroid
%   on each of the n frames in the video.
% radius: A vector of length n of the radius of the pupil on each of the n
%   frames in the video.
% outlierWindow: The window of time over which to look for outliers, in
%   terms of frames. Outliers are identified with a moving boxcar approach.
%   I recommend a window of at least 1 second.
%
% Output:
% outlierBool: A boolean vector of length n, with 1's indicating outlier frames.
%
% GHP April 2024

% Combine data into a single matrix
outlier_test_mat = [centroid',radius'];
outlierBoolMat = isoutlier(outlier_test_mat,'movmedian',outlierWindow,...
    'ThresholdFactor',4);
outlierBool = any(outlierBoolMat,2);
