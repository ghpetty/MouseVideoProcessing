function varargout = VideoAlignment_ThreshSubGUI(varargin)
% VIDEOALIGNMENT_THRESHSUBGUI MATLAB code for VideoAlignment_ThreshSubGUI.fig
%      VIDEOALIGNMENT_THRESHSUBGUI, by itself, creates a new VIDEOALIGNMENT_THRESHSUBGUI or raises the existing
%      singleton*.
%
%      H = VIDEOALIGNMENT_THRESHSUBGUI returns the handle to a new VIDEOALIGNMENT_THRESHSUBGUI or the handle to
%      the existing singleton*.
%
%      VIDEOALIGNMENT_THRESHSUBGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIDEOALIGNMENT_THRESHSUBGUI.M with the given input arguments.
%
%      VIDEOALIGNMENT_THRESHSUBGUI('Property','Value',...) creates a new VIDEOALIGNMENT_THRESHSUBGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VideoAlignment_ThreshSubGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VideoAlignment_ThreshSubGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VideoAlignment_ThreshSubGUI

% Last Modified by GUIDE v2.5 31-Mar-2022 15:10:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VideoAlignment_ThreshSubGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @VideoAlignment_ThreshSubGUI_OutputFcn, ...
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


% --- When called, the first input in "varargin" will be the alignment
% signal. The second will be the default analysis parameters, or the
% parameters previously used. The third is the entire handles array 
% from the main GUI. 
% When closing this GUI, we send information back to the main GUI by
% copying values into that handles array and saving it to the main GUI with
% guidata().
function VideoAlignment_ThreshSubGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VideoAlignment_ThreshSubGUI (see VARARGIN)
set(hObject,'toolbar','figure');

% Choose default command line output for VideoAlignment_ThreshSubGUI
handles.output = hObject;
% Save the alignment signal passed by the main GUI
handles.data = varargin{1};

% Load previously-used alignment parameters (or defaults)
handles.vidSignalParameters = varargin{2};
% Save the main GUI handles, which we use later
handles.mainGUIHandles = varargin{3};



% Sometimes there are NaN values in video data, so fill them in:
handles.data = fillmissing(handles.data,'linear');

% If the data is meant to be inverted, do that here and set the invert
% checkbox value to reflect that
if handles.vidSignalParameters.isInverted == true
    handles.data = -handles.data;
    handles.InvertCheckbox.Value = 1;
end
% Get the framerate from either the default values (stored by this GUI) or
% from previously used parameters

if ~isnan(handles.vidSignalParameters.framerate)
    dropdownInd = find(ismember(handles.FramerateDropdown.String,...
                                string(handles.vidSignalParameters.framerate)));
    if isempty(dropdownInd)
        % This shouldn't ever happen, here for debugging purposes
        error('Mismatched framerate request between main GUI and sub-GUI')
    end
    handles.FramerateDropdown.Value = dropdownInd;
else
    dropdownInd = handles.FramerateDropdown.Value;
end
handles.framerate = str2double(handles.FramerateDropdown.String{dropdownInd});
% Create a time vector to plot using the framerate:
handles.timeVect = (1:length(handles.data)) / handles.framerate;
% Set the initial plotting range from 0 to 10 seconds. 
handles.plotRange = [1,50*handles.framerate];

% Set minimum duration, maximum duration, and maximum gap to those values
% sent from the main GUI
if ~isnan(handles.vidSignalParameters.minDur)
    handles.MinDurEdit.String = string(...
        round(handles.vidSignalParameters.minDur*1000 / handles.framerate));
end
if ~isnan(handles.vidSignalParameters.maxDur)
    handles.MaxDurEdit.String = string(...
        round(handles.vidSignalParameters.maxDur*1000 / handles.framerate));
end
if ~isnan(handles.vidSignalParameters.maxGap)
    handles.MaxGapEdit.String = string(...
        round(handles.vidSignalParameters.maxGap*1000/handles.framerate));
end




%  --------- DISABLED -----------
% Filter the data if we want to see what it looks like with the baseline
% removed.
% handles.data_filt = highpass(handles.data,0.1,handles.framerate);
handles.data_filt = nan(size(handles.timeVect));


% First call of the plotting function to instantiate the plot of the
% signal:

handles = updatePlot(handles);

% Instantiate the line ROI object and draw it.
% Set the initial threshold value as the mean value of the signal
% If the threshold was sent from the main GUI, use that instead:
if isnan(handles.vidSignalParameters.threshold)
    thresh_default = mean(handles.data,"all","omitmissing");
else
    thresh_default = handles.vidSignalParameters.threshold;
end
defaultPosition = [0,thresh_default ; handles.timeVect(end),thresh_default];
handles.signalROI = images.roi.Line(handles.DataAxes,...
    'Deletable',false,'InteractionsAllowed','translate',...
    'Position',defaultPosition);

% Create a listener and add a function to the ROI so that when it
% moves, we replot the events. The actual function is defined at the end of
% this file.
handles.signalLineListener = addlistener(handles.signalROI,'ROIMoved',...
    @(hObject,eventData)dragLineCallback(hObject,eventData));

set(handles.signalROI,'Position',defaultPosition)
% Preallocate variables that are called later
handles.eventHighlights = [];

% Find the events using the default parameters:
handles = plotEvents(handles);



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VideoAlignment_ThreshSubGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VideoAlignment_ThreshSubGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Pass the processed signal back to the main GUI, then close.
function AcceptButton_Callback(hObject, eventdata, handles)
% Assign necessary parameters to the main GUI handle structure:
thresh = handles.signalROI.Position(1,2);

% guidata(mainGUI,handles.mainGUIHandles);
% Tell that GUI to update:
% Process the entire signal to get all start times:
SR = handles.framerate;
minDur = round(str2double(handles.MinDurEdit.String) * SR / 1000);
maxDur = round(str2double(handles.MaxDurEdit.String) * SR / 1000);
maxGap = round(str2double(handles.MaxGapEdit.String) * SR / 1000);


if handles.RmBaselineCheck.Value
    [eventStarts,eventEnds] = continuous2Event(handles.data_filt,...
        thresh,'minDur',minDur,'maxDur',maxDur,'maxGap',maxGap);
else
    [eventStarts,eventEnds] = continuous2Event(handles.data,...
        thresh,'minDur',minDur,'maxDur',maxDur,'maxGap',maxGap);
end
handles.mainGUIHandles.videoStartInds = eventStarts;
handles.mainGUIHandles.videoEndInds = eventEnds;
handles.mainGUIHandles.framerate = SR;
% Store the analysis parameters used so we can restore this figure if we
% want to edit those parameters later:
vidSignalParameters = struct('isInverted',handles.InvertCheckbox.Value, ...
                              'rmvBaseline',handles.RmBaselineCheck.Value, ...
                              'threshold',thresh, ...
                              'minDur',minDur, ...
                              'maxDur',maxDur, ...
                              'maxGap',maxGap, ...
                              'framerate',SR);
handles.mainGUIHandles.vidSignalParameters = vidSignalParameters;
% Call the "update plot" function on the main GUI, then pass the data back
% to the main GUI.
mainGUIHandles = VideoAlignment_OpenEphys(...
                    'updatePlot',handles.mainGUIHandles,'video');
mainGUI = findobj(allchild(groot),'Tag','VideoAlignment_OpenEphys');
guidata(mainGUI,mainGUIHandles);
% Close this figure:
close



% --- Close this figure and return nothing to the main figure. 
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close

% --- Step back by 3 seconds
function BackButton_Callback(hObject, eventdata, handles)
% hObject    handle to BackButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.plotRange = handles.plotRange - handles.framerate * 30;
% Check that this is still a valid range. 
if handles.plotRange(1) < 1
    handles.plotRange = [1,(handles.framerate*50)];
end
handles = updatePlot(handles);
handles = plotEvents(handles);
guidata(hObject,handles);

% --- Increment the plot forward by 3 seconds
function ForwardButton_Callback(hObject, eventdata, handles)
% hObject    handle to ForwardButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.plotRange = handles.plotRange + handles.framerate * 30;
% Check that this is still a valid range. 
if handles.plotRange(2) > length(handles.data)
    handles.plotRange = [length(handles.data) - handles.framerate*30 + 1,...
        length(handles.data)];
end
handles = updatePlot(handles);
handles = plotEvents(handles);
guidata(hObject,handles);

% --- Flip the signal about the X axis:
function InvertCheckbox_Callback(hObject, eventdata, handles)
handles.data = -handles.data;
handles.data_filt = -handles.data_filt;


currPosition = get(handles.signalROI,'Position');
th = currPosition(1,2);
th = -th;
newPosition = [0,th;
                length(handles.data)*handles.framerate,th];
set(handles.signalROI,'Position',newPosition);
handles = updatePlot(handles);
handles = plotEvents(handles);
guidata(hObject,handles);

% --- Puts the threshold line back at the mean value of the current signal
function ResetLineButton_Callback(hObject, eventdata, handles)
if handles.RmBaselineCheck.Value
    defaultThresh = nanmean(handles.data_filt);
else
    defaultThresh = nanmean(handles.data);
end
position = [0,defaultThresh;...
    length(handles.data)*handles.framerate,defaultThresh];
set(handles.signalROI,'Position',position);
handles = plotEvents(handles);
guidata(hObject,handles);


function MinDurEdit_Callback(hObject, eventdata, handles)
handles = plotEvents(handles);
guidata(hObject,handles);


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
handles = plotEvents(handles);
guidata(hObject,handles);

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


% --- Set the framerate of the video, then rescale the signal plot to
% account for this change.
function FramerateDropdown_Callback(hObject, eventdata, handles)
% Get the newly selected value:
FR_options = get(hObject,'String');
newFR = str2double(FR_options{get(hObject,'Value')});
% Compute the new time vector
handles.timeVect = (1:length(handles.data)) / newFR;
% Reset the plot range from 0 to 10 seconds
handles.plotRange = [1,newFR * 50];
handles.framerate = newFR;
handles = updatePlot(handles);
handles = plotEvents(handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function FramerateDropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FramerateDropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Run a high-pass filter over the data to flatten out the baseline
function RmBaselineCheck_Callback(hObject, eventdata, handles)
% hObject    handle to RmBaselineCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RmBaselineCheck
handles = updatePlot(handles);
handles = plotEvents(handles);
guidata(hObject,handles);

% --- Update the signal plot
function handles = updatePlot(handles)
XVals = handles.timeVect(handles.plotRange(1):handles.plotRange(2));
if handles.RmBaselineCheck.Value
    YVals = handles.data_filt(handles.plotRange(1):handles.plotRange(2));
else
    YVals = handles.data(handles.plotRange(1):handles.plotRange(2));
end
% Instantiate the plot object if we haven't already.
% Otherwise, replace the plot values with new values.
% Either way, change the axes limits to match the new values
if ~isfield(handles,'dataPlot')
    handles.dataPlot = plot(handles.DataAxes,XVals,YVals);
else
    set(handles.dataPlot,'XData',XVals);
    set(handles.dataPlot,'YData',YVals);
end

set(handles.DataAxes,'XLim',[XVals(1) , XVals(end)]);

% --- Highlight events that cross the signal threshold:
% Find events and highlight them on the signal axes
function handles = plotEvents(handles)
% Signal snippet as defined by the current plotting indices
% Switch based on whether we are subtracting baseline or not
if handles.RmBaselineCheck.Value
    signalsnippet = handles.data_filt(handles.plotRange(1):handles.plotRange(2));
else
    signalsnippet = handles.data(handles.plotRange(1):handles.plotRange(2));
end
% Threshold from current ROI line position
thresh = handles.signalROI.Position(1,2);
% Sampling rate from the data header.
SR = handles.framerate;
% Event duration parameters from the values of the edit boxes
% -- Converting from milliseconds to sample count
mindur = round(str2double(handles.MinDurEdit.String) * SR / 1000);
maxdur = round(str2double(handles.MaxDurEdit.String) * SR / 1000);
maxgap = round(str2double(handles.MaxGapEdit.String) * SR / 1000);
[eventStarts,eventEnds] = continuous2Event(signalsnippet,thresh,...
    'minDur',mindur,'maxDur',maxdur,'maxGap',maxgap);
% Convert start / end indices to seconds with the proper offset
eventStarts = (eventStarts + handles.plotRange(1)) / SR;
eventEnds   = (eventEnds   + handles.plotRange(1)) / SR;
ymin = min(signalsnippet);
ymax = max(signalsnippet);
% If we have already created patches, first we clear them from the plot:
if ~isempty(handles.eventHighlights)
    for i = 1:length(handles.eventHighlights)
        if isfield(handles.eventHighlights,'P')
            delete(handles.eventHighlights(i).P)
        end
    end
end
handles.eventHighlights = makeShadedRect(eventStarts,eventEnds,ymin,ymax,'b',0.3,handles.DataAxes);

% --- Called whenever the line ROI is repositioned
function dragLineCallback(hObject,eventData,dataType)
% Get the handles from the object:
handles = guidata(hObject);
% Use this to replot the thresholded events:
handles = plotEvents(handles);
% Update handles:
guidata(hObject,handles);



function MaxGapEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxGapEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = plotEvents(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of MaxGapEdit as text
%        str2double(get(hObject,'String')) returns contents of MaxGapEdit as a double


% --- Executes during object creation, after setting all properties.
function MaxGapEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxGapEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
