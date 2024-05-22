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
states = readNPY(fullfile(TTL_path,"states.npy"));
timestamps = readNPY(fullfile(TTL_path,"timestamps.npy"));
%% Separate out events using the data key:
varNames = dataKey.VariableName;
[startIndCell,endIndCell] = deal(cell(height(dataKey),1));
% Copy data key table and append onsets and offsets to it
for i = 1:length(varNames)
    startInds = timestamps(states == dataKey{i,"Key"});
    if size(startInds,1) > 1
        startInds = startInds';
    end
    startIndCell{i} = startInds;
    % Offset is always key*-1
    endInds = timestamps(states == -dataKey{i,"Key"});
    if size(endInds,1) > 1
        endInds = endInds';
    end
    endIndCell{i} = endInds;

end

BehaviorDataTable= [dataKey,cell2table([startIndCell,endIndCell],'VariableNames',{'StartInds','EndInds'})];
BehaviorDataTable.Properties.RowNames = BehaviorDataTable.VariableName;
BehaviorDataTable.VariableName = [];

save(fullfile(TTL_path,"BehaviorDataTable"),"BehaviorDataTable")

