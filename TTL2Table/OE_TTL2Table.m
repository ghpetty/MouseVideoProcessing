% OE_TTL2Table
% Convert Open Ephys TTL files (*.npy format) to a MATLAB table for
% alignment with a video.

%% Select Data Files
TTL_path = uigetdir(cd,"Select folder containing Open Ephys TTL (.npy) files");
% Select data key
[filename,filepath] = uigetfile('*.csv; *.xls; *.xlsx','Select data key:');
dataKey = readtable(fullfile(filepath,filename));
dataKey.VariableName = string(dataKey.VariableName);
%% Load the time stamps and states
states = readNPY(fullfile(TTL_path,"states.npy"))