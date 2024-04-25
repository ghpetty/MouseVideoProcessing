function dataOut = processPupil_postprocessing(dataIn,postprocessParams)
% dataOut = processPupil_postprocessing(dataIn,postprocessParams)
%
% Perform post-processing on pupil analysis vectors:
% - Remove outlier frames based on pupil object locations and size
% - Interpolate over missing values (linear interpolation)
% - Smooth resulting vectors (boxcar moving mean)
% - Return a struct with output variables

% Find outliers:
outlierBool = processPupil_findOutliers(dataIn.centroid,dataIn.radius,postprocessParams.outlierWindow);

dataOut = dataIn;
% Remove outliers from video parameters, interpolate, and smooth.
% Only operates on 1-dimensional vectors. 
% Skips "alignment signal"
varNames = fieldnames(dataIn);
for i = 1:length(varNames)
    currVarName = varNames{i};
    if isequal(lower(currVarName),'alignmentsignal')
        continue
    end
    currVar = dataIn.(currVarName);
    if ~isvector(currVar)
        continue
    end

    currVar(outlierBool) = nan;
    currVar = fillmissing(currVar,"linear");
    currVar = movmean(currVar,postprocessParams.smoothWindow);
    newVarName = string(currVarName)+"_smoothed";
    dataOut.(newVarName) = currVar;
end
dataOut.isOutlier = outlierBool;