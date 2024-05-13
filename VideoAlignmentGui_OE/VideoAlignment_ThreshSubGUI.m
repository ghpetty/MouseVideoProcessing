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
% signal. The second will be the entire handles array from the main GUI. 
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

% Save the main GUI handles, which we use later
handles.mainGUIHandles = varargin{2};
% Sometimes there are NaN values in video data, so fill them in:
handles.data = fillmissing(handles.data,'linear');

% Create a time vector to plot using the default framerate. This will
% change later if we change the frame rate:
FRVals = get(handles.FramerateDropdown,'String');
handles.frameRate = str2double(FRVals{get(handles.FramerateDropdown,'Value')});
handles.timeVect = (1:length(handles.data)) / handles.frameRate;
% Set the initial plotting range from 0 to 10 seconds. 
handles.plotRange = [1,50*handles.frameRate];
% First call of the plotting function to instantiate the plot of the
% signal:
% Filter the data if we want to see what it looks like with the baseline
% removed.
handles.data_filt = highpass(handles.data,0.1,handles.frameRate);

% figure; sp1 = subplot(1,2,1); plot(handles.data);
% sp2 = subplot(1,2,2); plot(handles.data_filt)
% linkaxes([sp1 sp2],'x')

handles = updatePlot(handles);

% Instantiate the line ROI object and draw it.
% Set the initial threshold value as the mean value of the signal
th = nanmean(handles.data);
defaultPosition = [0,th ; handles.timeVect(end),th];
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
% handles.mainGUIHandles.videoThresh = handles.signalROI.Position(1,2);
% handles.mainGUIHandles.videoMinDur = round(...
%     str2double(get(handles.MinDurEdit,'String')) * handles.frameRate / 1000);
% handles.mainGUIHandles.videoMaxDur = round(...
%     str2double(get(handles.MaxDurEdit,'String')) * handles.frameRate / 1000);
% handles.mainGUIHandles.videoInvert = get(handles.InvertCheckbox,'Value');
% handles.mainGUIHandles.videoFramerate = handles.frameRate;
% % Identify the main GUI object, then pass this information to it:

% guidata(mainGUI,handles.mainGUIHandles);
% Tell that GUI to update:
% Process the entire signal to get all start times:
SR = handles.frameRate;
mindur = round(str2double(handles.MinDurEdit.String) * SR / 1000);
maxdur = round(str2double(handles.MaxDurEdit.String) * SR / 1000);
if handles.RmBaselineCheck.Value
    eventStarts = continuous2Event(handles.data_filt,...
        thresh,'minDur',mindur,'maxDur',maxdur);
else
    eventStarts = continuous2Event(handles.data,...
        thresh,'minDur',mindur,'maxDur',maxdur);
end
handles.mainGUIHandles.videoStartInds = eventStarts;
handles.mainGUIHandles.frameRate = SR;
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
handles.plotRange = handles.plotRange - handles.frameRate * 30;
% Check that this is still a valid range. 
if handles.plotRange(1) < 1
    handles.plotRange = [1,(handles.frameRate*50)];
end
handles = updatePlot(handles);
handles = plotEvents(handles);
guidata(hObject,handles);

% --- Increment the plot forward by 3 seconds
function ForwardButton_Callback(hObject, eventdata, handles)
% hObject    handle to ForwardButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.plotRange = handles.plotRange + handles.frameRate * 30;
% Check that this is still a valid range. 
if handles.plotRange(2) > length(handles.data)
    handles.plotRange = [length(handles.data) - handles.frameRate*30 + 1,...
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
                length(handles.data)*handles.frameRate,th];
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
    length(handles.data)*handles.frameRate,defaultThresh];
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
handles.frameRate = newFR;
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
SR = handles.frameRate;
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
