% This function takes an input vector (or amatrix of multiple data vectors) 
% from a video file and returns a vector interpolated into 1msec time bins

% Inputs
% dataMat: A vector or matrix of values from a video. 
% duration: An integer duration in milliseconds. 

% Output
% msecData: A matrix of the same length specified by 'duration', with
%       values interpolated from the dataMat input.


% GHP - June 2019

% !!! TO DO !!!
% Change to iterate over alignment signal trials and interpolate at a
% smaller scale rather than all at once. See if this gives better alignment

function msecData = interpolateVidData2msec(dataMat,duration)
    % First make sure data is aligned in columns
    if size(dataMat,1) < size(dataMat,2)
        dataMat = dataMat' ;
    end
     
    % We often have edge effects, so before interpolating, set the first
    % and last elements of the data vector to be the mean value of the
    % vector. This should help with interpolation / filling missing data
    dataMat([1,end],:) = nanmean(dataMat(:,1));
    
    % Next start interpolation to msec resolution. 
    % Create a time vector corresponding to the original data, spanning the
    % length of the trial and estimating time steps using linspace
    oldT = linspace(0,duration,length(dataMat));
    % Create a time vector of milliseconds
    T = 1:duration;
    % Interpolate over new msec time vector
    try
        msecData = interp1(oldT,dataMat,T,'linear');
    catch
        error('Wrong data type for interp1')
    end
    
    


