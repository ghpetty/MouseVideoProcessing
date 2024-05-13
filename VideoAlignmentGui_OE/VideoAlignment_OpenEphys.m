function varargout = VideoAlignment_OpenEphys(varargin)
% VIDEOALIGNMENT_OPENEPHYS MATLAB code for VideoAlignment_OpenEphys.fig
%      VIDEOALIGNMENT_OPENEPHYS, by itself, creates a new VIDEOALIGNMENT_OPENEPHYS or raises the existing
%      singleton*.
%
%      H = VIDEOALIGNMENT_OPENEPHYS returns the handle to a new VIDEOALIGNMENT_OPENEPHYS or the handle to
%      the existing singleton*.
%
%      VIDEOALIGNMENT_OPENEPHYS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIDEOALIGNMENT_OPENEPHYS.M with the given input arguments.
%
%      VIDEOALIGNMENT_OPENEPHYS('Property','Value',...) creates a new VIDEOALIGNMENT_OPENEPHYS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VideoAlignment_OpenEphys_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VideoAlignment_OpenEphys_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VideoAlignment_OpenEphys

% Last Modified by GUIDE v2.5 24-Jan-2023 16:21:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VideoAlignment_OpenEphys_OpeningFcn, ...
                   'gui_OutputFcn',  @VideoAlignment_OpenEphys_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before VideoAlignment_OpenEphys is made visible.
function VideoAlignment_OpenEphys_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VideoAlignment_OpenEphys (see VARARGIN)

% Choose default command line output for VideoAlignment_OpenEphys
handles.output = hObject;

% Prepare axis for plotting multiple lines:
hold(handles.DiffSignalAxes,'on');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VideoAlignment_OpenEphys wait for user response (see UIRESUME)
% uiwait(handles.VideoAlignment_OpenEphys);


% --- Outputs from this function are returned to the command line.
function varargout = VideoAlignment_OpenEphys_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function MinDurEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MinDurEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinDurEdit as text
%        str2double(get(hObject,'String')) returns contents of MinDurEdit as a double


% --- Executes during object creation, after setting all properties.
function MinDurEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinDurEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxDurEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxDurEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxDurEdit as text
%        str2double(get(hObject,'String')) returns contents of MaxDurEdit as a double


% --- Executes during object creation, after setting all properties.
function MaxDurEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxDurEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- This does nothing on its own other than call the main update function
function EphysSignalDropdown_Callback(hObject, eventdata, handles)
handles = updatePlot(handles,'ephys');
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns EphysSignalDropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from EphysSignalDropdown


% --- Executes during object creation, after setting all properties.
function EphysSignalDropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EphysSignalDropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in VideoDataDropdown.
function VideoDataDropdown_Callback(hObject, eventdata, handles)
% hObject    handle to VideoDataDropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns VideoDataDropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from VideoDataDropdown


% --- Executes during object creation, after setting all properties.
function VideoDataDropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VideoDataDropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Select a mat file containing the behavior data ---
function BehaviorDataButton_Callback(hObject, eventdata, handles)
[behaveFile,behavePath] = uigetfile('*.mat','Select behavior data file');
if isequal(behaveFile,0)
    return
end
D = load(fullfile(behavePath,behaveFile));
handles.BehaviorDataTable = D.BehaviorDataTable;
% Populate the behavior signal dropdown menu with the row names of this
% table.
behaveVars = handles.BehaviorDataTable.Properties.RowNames;
set(handles.EphysSignalDropdown,'String',behaveVars);
% Display the full path to the data loaded
set(handles.BehaviorDataText,'String',fullfile(behavePath,behaveFile));
guidata(hObject,handles);

% --- Load in the video data
function VideoDataButton_Callback(hObject, eventdata, handles)
[videoFile,videoPath] = uigetfile('*.mat','Select video data file');
if isequal(videoFile,0)
    return
end
handles.VideoData = load(fullfile(videoPath,videoFile));
% Populate the behavior signal dropdown menu with the row names of this
% table.
videoVars = fieldnames(handles.VideoData);
set(handles.VideoDataDropdown,'String',videoVars);
% Display the full path to the data loaded
set(handles.VideoDataText,'String',fullfile(videoPath,videoFile));
guidata(hObject,handles);



% --- Prepare the output signal and analysis parameters, then send that
% info to the alignment function.
function AlignButton_Callback(hObject, eventdata, handles)
 % Get the Open Ephys signal from the behavior data table:
% - Identify which signal to plot from the corresponding dropdown
% box:
S = struct;
signalType = handles.EphysSignalDropdown.String{...
                handles.EphysSignalDropdown.Value};
S.EphysStartInds = cell2mat(handles.BehaviorDataTable{...
                signalType,'StartInds'});
S.EphysSR = str2double(handles.SamplerateDropdown.String{...
                handles.SamplerateDropdown.Value});
startTrim = str2double(get(handles.EphysTrimStartEdit,'String'));
endTrim   = str2double(get(handles.EphysTrimEndEdit,'String'));
S.EphysTrimInds = [startTrim,endTrim];

S.VideoSR = handles.frameRate;
S.VideoStartInds = handles.videoStartInds;
startTrim = str2double(get(handles.VideoTrimStartEdit,'String'));
endTrim   = str2double(get(handles.VideoTrimEndEdit,'String'));
S.VideoTrimInds = [startTrim,endTrim];

% We can read out the full path from the text fields in the GUI
S.VideoDataPath = get(handles.VideoDataText,'String');
% ephysDataPath = fileparts(get(handles.BehaviorDataText,'String'));
% S.EphysDataPath = fullfile(ephysDataPath,'Merged Behavior and Ephys Data.mat');
S.BehaviorDataPath = get(handles.BehaviorDataText,'String');
S.PhyDataPath = get(handles.PhyDataText,'String');
S.MinCorrection = str2double(get(handles.ErrorToleranceEdit,'String'));
% Save alignment parameters for later reference
outPath = fullfile(fileparts(S.BehaviorDataPath),'Alignment parameters.mat');
if ~exist(outPath,'file')
    save(outPath,'-struct','S');
else
    save(outPath,'-struct','S','-append');
end

% Send to alignment function
S_out = alignVideoAndEphys(S);
disp('Alignment complete');
% Save to the same folder as the behavior/ephys data.
outPath = fullfile(fileparts(S.BehaviorDataPath),'Aligned data.mat');
disp(['Saving to ',outPath]);
if exist(outPath,'file')
    % If we already have a file here we want to merge the video data with
    % anything that might already exist. We do this by loading in the
    % existing struct array and merging the "Video" variable
    
    S_in = load(fullfile(...
        fileparts(S.BehaviorDataPath),'Aligned data.mat'),...
        'Video');
    S_out.Video = appendStructs(S_in.Video,S_out.Video);
end

    save(fullfile(...
        fileparts(S.BehaviorDataPath),'Aligned data.mat'),...
        '-struct','S_out');

disp('Done!');

% --- Executes on button press in VideoTrimStartBackButton.
function VideoTrimStartBackButton_Callback(hObject, eventdata, handles)
V = str2double(get(handles.VideoTrimStartEdit,'String'));
V = max(V - 1 , 0);
set(handles.VideoTrimStartEdit,'String',num2str(V));
handles = updatePlot(handles,'video');
guidata(hObject,handles);


% --- Executes on button press in VideoTrimEndBackButton.
function VideoTrimEndBackButton_Callback(hObject, eventdata, handles)
V = str2double(get(handles.VideoTrimEndEdit,'String'));
V = max(V - 1 , 0);
set(handles.VideoTrimEndEdit,'String',num2str(V));
handles = updatePlot(handles,'video');
guidata(hObject,handles);




function VideoTrimStartEdit_Callback(hObject, eventdata, handles)
% hObject    handle to VideoTrimStartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
checkTrimVal(hObject);
handles = updatePlot(handles,'video');
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of VideoTrimStartEdit as text
%        str2double(get(hObject,'String')) returns contents of VideoTrimStartEdit as a double


% --- Executes during object creation, after setting all properties.
function VideoTrimStartEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VideoTrimStartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VideoTrimEndEdit_Callback(hObject, eventdata, handles)
checkTrimVal(hObject)
% hObject    handle to VideoTrimEndEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VideoTrimEndEdit as text
%        str2double(get(hObject,'String')) returns contents of VideoTrimEndEdit as a double


% --- Executes during object creation, after setting all properties.
function VideoTrimEndEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VideoTrimEndEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in VideoTrimStartForwardButton.
function VideoTrimStartForwardButton_Callback(hObject, eventdata, handles)
V = str2double(get(handles.VideoTrimStartEdit,'String'));
V = V+1;
set(handles.VideoTrimStartEdit,'String',num2str(V));
handles = updatePlot(handles,'video');
guidata(hObject,handles);

% --- Executes on button press in VideoTrimEndForwardButton.
function VideoTrimEndForwardButton_Callback(hObject, eventdata, handles)
V = str2double(get(handles.VideoTrimEndEdit,'String'));
V = V+1;
set(handles.VideoTrimEndEdit,'String',num2str(V));
handles = updatePlot(handles,'video');
guidata(hObject,handles);


% -- Decrease the trim value by 1
function EphysTrimStartBackbutton_Callback(hObject, eventdata, handles)
V = str2double(get(handles.EphysTrimStartEdit,'String'));
V = max(V - 1 , 0);
set(handles.EphysTrimStartEdit,'String',num2str(V));
handles = updatePlot(handles,'ephys');
guidata(hObject,handles);


% --- Executes on button press in EphysTrimEndBackButton.
function EphysTrimEndBackButton_Callback(hObject, eventdata, handles)
V = str2double(get(handles.EphysTrimEndEdit,'String'));
V = max(V - 1 , 0);
set(handles.EphysTrimEndEdit,'String',num2str(V));
handles = updatePlot(handles,'ephys');
guidata(hObject,handles);



function EphysTrimStartEdit_Callback(hObject, eventdata, handles)
checkTrimVal(hObject);
handles = updatePlot(handles,'ephys');
guidata(hObject,handles);

% hObject    handle to EphysTrimStartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EphysTrimStartEdit as text
%        str2double(get(hObject,'String')) returns contents of EphysTrimStartEdit as a double


% --- Executes during object creation, after setting all properties.
function EphysTrimStartEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EphysTrimStartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EphysTrimEndEdit_Callback(hObject, eventdata, handles)
checkTrimVal(hObject)



% --- Executes during object creation, after setting all properties.
function EphysTrimEndEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EphysTrimEndEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EphysTrimStartForwardButton.
function EphysTrimStartForwardButton_Callback(hObject, eventdata, handles)
V = str2double(get(handles.EphysTrimStartEdit,'String'));
V = V+1;
set(handles.EphysTrimStartEdit,'String',num2str(V));
handles = updatePlot(handles,'ephys');
guidata(hObject,handles);


% --- Executes on button press in EphysTrimEndForwardButton.
function EphysTrimEndForwardButton_Callback(hObject, eventdata, handles)
V = str2double(get(handles.EphysTrimEndEdit,'String'));
V = V+1;
set(handles.EphysTrimEndEdit,'String',num2str(V));
handles = updatePlot(handles,'ephys');
guidata(hObject,handles);


% --- This calls the sub GUI which is used to threshold the video alignment
% signal. 
function ThreshSubGUIButton_Callback(hObject, eventdata, handles)
% First identify the signal we want to analyze by checking the value
% currently in the dropdown menu:
% Hints: contents = cellstr(get(hObject,'String')) returns VideoDataDropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from VideoDataDropdown
% Isolate that vector from the video data structure and pass it to the sub
% GUI, along with the handles structure:
behaviorSignalContents = cellstr(...
    get(handles.VideoDataDropdown,'String'));
alignmentSignalName = behaviorSignalContents{...
    get(handles.VideoDataDropdown,'Value')};


VideoAlignment_ThreshSubGUI(handles.VideoData.(alignmentSignalName),handles);
guidata(hObject,handles);


% --- Executes on selection change in SamplerateDropdown.
function SamplerateDropdown_Callback(hObject, eventdata, handles)
handles = updatePlot(handles,'ephys');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function SamplerateDropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SamplerateDropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Function to plot the difference in start times.
% This is called almost every time something is changed in the GUI
function handles = updatePlot(handles,dataType)

switch dataType
    case 'ephys'
        % Get the signal from the behavior data table. 
        % - Identify which signal to plot from the corresponding dropdown
        % box:
        signalType = handles.EphysSignalDropdown.String{...
                        handles.EphysSignalDropdown.Value};
        % Index start times from the behavior table:
        startInds = cell2mat(handles.BehaviorDataTable{...
                        signalType,'StartInds'});
        % Convert to seconds, then dake the differential of the signal
        SR = str2double(handles.SamplerateDropdown.String{...
                        handles.SamplerateDropdown.Value});
        startTimes = startInds / SR;
        startDiff = diff(startTimes);
        % Get the trim values, then set the X values based on this
        % trimming.
        startTrim = str2double(get(handles.EphysTrimStartEdit,'String'));
        endTrim   = str2double(get(handles.EphysTrimEndEdit,'String'));
        XVect = (1:length(startDiff))' - startTrim;
        isTrimmed = false(size(XVect));
        isTrimmed(1:startTrim) = true;
        isTrimmed(end-endTrim+1:end) = true;
        if ~isfield(handles,'ephysPlot')
            handles.ephysPlot = plot(handles.DiffSignalAxes,...
                XVect(~isTrimmed),startDiff(~isTrimmed),...
                'Color','k','Marker','.');
        else
            handles.ephysPlot.YData = startDiff(~isTrimmed);
            handles.ephysPlot.XData = XVect(~isTrimmed);
            
        end
    % --- Does the same processing on the video data.
    % However, this needs to inherit the data from a sub GUI, as the start
    % signal is not processed before this stage of the data processing
    % pipeline. 
    case 'video'
        if ~isfield(handles,'videoStartInds') || ...
                ~isfield(handles,'frameRate')
            error('Attempted to plot video data without preprocessing first');
        end
        
        % Convert to seconds, then dake the differential of the signal
        SR = handles.frameRate;
        startTimes = handles.videoStartInds / SR;
        startDiff = diff(startTimes);
        
                % Get the trim values, then set the X values based on this
        % trimming.
        startTrim = str2double(get(handles.VideoTrimStartEdit,'String'));
        endTrim   = str2double(get(handles.VideoTrimEndEdit,'String'));
        XVect = (1:length(startDiff))' - startTrim;
        isTrimmed = false(size(XVect));
        isTrimmed(1:startTrim) = true;
        isTrimmed(end-endTrim+1:end) = true;
        
        if ~isfield(handles,'videoPlot')
            handles.videoPlot = plot(handles.DiffSignalAxes,...
                XVect(~isTrimmed),startDiff(~isTrimmed),...
                'Color','r','Marker','o');
        else
            handles.videoPlot.YData = startDiff(~isTrimmed);
            handles.videoPlot.XData =  XVect(~isTrimmed);
            
        end

end

% Function to force the trim values to be a positive integer, called
% whenever the trim values are edited.
function Y = checkTrimVal(hObject)
X = str2double(get(hObject,'String'));
if X < 0 || isnan(X)
    Y = 0;
else
    Y = round(X);
end
set(hObject,'String',Y);


% --- Look for the clusters from Phy
function LoadClustersButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadClustersButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
phyDataPath = uigetdir(cd,'Select Phy output directory');
set(handles.PhyDataText,'String',phyDataPath);
guidata(hObject,handles);



function ErrorToleranceEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ErrorToleranceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
checkTrimVal(hObject);
guidata(hObject,handles);

% Hints: get(hObject,'String') returns contents of ErrorToleranceEdit as text
%        str2double(get(hObject,'String')) returns contents of ErrorToleranceEdit as a double


% --- Executes during object creation, after setting all properties.
function ErrorToleranceEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ErrorToleranceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
