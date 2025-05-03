function varargout = PupilAnalysisGUI(varargin)
% PUPILANALYSISGUI MATLAB code for PupilAnalysisGUI.fig
%      PUPILANALYSISGUI, by itself, creates a new PUPILANALYSISGUI or raises the existing
%      singleton*.
%
%      H = PUPILANALYSISGUI returns the handle to a new PUPILANALYSISGUI or the handle to
%      the existing singleton*.
%
%      PUPILANALYSISGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PUPILANALYSISGUI.M with the given input arguments.
%
%      PUPILANALYSISGUI('Property','Value',...) creates a new PUPILANALYSISGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PupilAnalysisGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PupilAnalysisGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PupilAnalysisGUI

% Last Modified by GUIDE v2.5 26-Apr-2024 11:15:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PupilAnalysisGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PupilAnalysisGUI_OutputFcn, ...
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


% --- Executes just before PupilAnalysisGUI is made visible.
function PupilAnalysisGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PupilAnalysisGUI (see VARARGIN)

% Choose default command line output for PupilAnalysisGUI
handles.output = hObject;

% Turn off tick marks on axes
set([handles.Axes_Original,handles.Axes_Processed,handles.Axes_Mask],...
    'XTick',[],'YTick',[]);
% Disable all UI elements except the load-video button
allgraphics = findall(groot,'Type','UIControl');
set(allgraphics,'Enable','off');
set(handles.FileSelectButton,'Enable','on');
set(handles.ThreshText,'String',get(handles.ThreshSlider,'Value'));
set(handles.CloseText,'String',get(handles.CloseSlider,'Value'));
set(handles.OpenText,'String',get(handles.OpenSlider,'Value'));

% Placeholder variables for the ROIs. These can be set in the ROI sub-gui,
% called from the ROI button.
handles.IRROI = [];
handles.pupilROI = [];
handles.MaskROIs = [];
handles.BlackROIs = [];

% Plotting range - seconds
handles.plotRange = [-5,0];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PupilAnalysisGUI wait for user response (see UIRESUME)
% uiwait(handles.PupilAnalysisGUI);


% --- Outputs from this function are returned to the command line.
function varargout = PupilAnalysisGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ROI_Button.
function ROI_Button_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAsB
% handles    structure with handles and user data (see GUIDATA)
% handles = processFrame(handles);
% Send the current frame information to a new GUI, which the user will use
% to draw ROIs around the pupil for processing. 
im = rgb2gray(read(handles.VR,handles.currFrame));

handles.ROI_gui = PupilAnalysis_ROI_GUI(im,handles.pupilROI,...
    handles.IRROI,handles.MaskROIs,handles.BlackROIs);
drawnow
guidata(hObject,handles);



% --- Executes on button press in FileSelectButton.
function FileSelectButton_Callback(hObject, eventdata, handles)
% hObject    handle to FileSelectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[f,p] = uigetfile({'*.mp4';'*.avi'},'Select video:');
% Cancel if we selected nothing
if isequal(f,0)
    return
end


handles.filepath = fullfile(p,f);
set(handles.VideoPathText,'String',handles.filepath);
handles.currFrame = 1;
handles.VR = VideoReader(handles.filepath);
handles.nframes = floor(handles.VR.Duration * handles.VR.Framerate);

% Placeholder for pupil radius (geometric mean), semimajor axis, and IR
% signal
handles.pupilRadiusVect = nan(1,handles.nframes);
handles.IRSignal = nan(1,handles.nframes);
handles.semimajorAxis = nan(1,handles.nframes);
processPupilFrame_gui(handles);

% Turn everything back on once we have selected a video
allgraphics = findall(groot,'Type','UIControl');
set(allgraphics,'Enable','on');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function ThreshEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThreshEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function ThreshSlider_Callback(hObject, eventdata, handles)
% hObject    handle to ThreshSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

currVal = get(hObject,'Value');
stepSize = get(hObject,'SliderStep');
stepSize = stepSize(1);
stepSize = (hObject.Max - hObject.Min) * stepSize;
roundVal = round(currVal / stepSize) * stepSize;
set(hObject,'Value',roundVal);
processPupilFrame_gui(handles);
set(handles.ThreshText,'String',get(hObject,'Value'));


% --- Executes during object creation, after setting all properties.
function ThreshSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThreshSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function CloseSlider_Callback(hObject, eventdata, handles)
% hObject    handle to CloseSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
currVal = get(hObject,'Value');
stepSize = get(hObject,'SliderStep');
stepSize = stepSize(1);
stepSize = (hObject.Max - hObject.Min) * stepSize;
roundVal = round(currVal / stepSize) * stepSize;
set(hObject,'Value',roundVal);
processPupilFrame_gui(handles);
processPupilFrame_gui(handles);
set(handles.CloseText,'String',get(hObject,'Value'));

% --- Executes during object creation, after setting all properties.
function CloseSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CloseSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function OpenSlider_Callback(hObject, eventdata, handles)
% hObject    handle to OpenSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This has to be an integer, so we round it first
currVal = get(hObject,'Value');
stepSize = get(hObject,'SliderStep');
stepSize = stepSize(1);
stepSize = (hObject.Max - hObject.Min) * stepSize;
roundVal = round(currVal / stepSize) * stepSize;
set(hObject,'Value',roundVal);
processPupilFrame_gui(handles);
set(handles.OpenText,'String',get(hObject,'Value'));

% --- Executes during object creation, after setting all properties.
function OpenSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OpenSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function MinCutoffSlider_Callback(hObject, eventdata, handles)
% hObject    handle to MinCutoffSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
currVal = get(hObject,'Value');
stepSize = get(hObject,'SliderStep');
stepSize = stepSize(1);
stepSize = (hObject.Max - hObject.Min) * stepSize;
roundVal = round(currVal / stepSize) * stepSize;
set(hObject,'Value',roundVal);
processPupilFrame_gui(handles);
set(handles.MinCutoffText,'String',get(hObject,'Value'));

% --- Executes during object creation, after setting all properties.
function MinCutoffSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinCutoffSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in ProcessButton.
function ProcessButton_Callback(hObject, eventdata, handles)
% hObject    handle to ProcessButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Create a structure array containing the necessary analysis parameters
params = struct('VR',handles.VR,...
                'Threshold',get(handles.ThreshSlider,'Value'),...
                'Close',get(handles.CloseSlider,'Value'),...
                'Open',get(handles.OpenSlider,'Value'),...
                'PupilROI',handles.pupilROI,...
                'IRROI',handles.IRROI,...
                'Masks',{handles.MaskROIs},...
                'Masks_Black',{handles.BlackROIs},...
                'Min_Radius',get(handles.MinCutoffSlider,'Value'));
% allgraphics = findall(groot,'Type','UIControl');
% set(allgraphics,'Enable','off');
% processPupil_wholevid(params,floor(60 * handles.VR.FrameRate),false,true
nFrames=floor(60 * handles.VR.FrameRate);
dosave=false;
doplot=true;
useProgressBar=true;
processPupil_wholevid(params,nFrames,dosave,doplot,useProgressBar)
% set(allgraphics,'Enable','on');


% --- Executes on button press in PlayButton.
function PlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
doPlay = get(hObject,'Value');
allgraphics = findall(groot,'Type','UIControl');
if doPlay
    set(hObject,'String','Pause');
    % Disable all UI elements except this button
    set(allgraphics,'Enable','off');
    set(hObject,'Enable','on');
else
    set(hObject,'String','Play');
    % Turn everything back on.
    set(allgraphics,'Enable','on');
end

while doPlay && hasFrame(handles.VR)
    handles.currFrame = handles.currFrame + 1;
    [pupilRadius,IRSignal,semimajorAxis]= processPupilFrame_gui(handles);
    handles.pupilRadiusVect(handles.currFrame) = pupilRadius;
    handles.IRSignal(handles.currFrame) = IRSignal;
    handles.semimajorAxis(handles.currFrame) = semimajorAxis;
    
    plot(handles.Axes_Area, handles.pupilRadiusVect);
    xlim(handles.Axes_Area,...
        [handles.currFrame , handles.currFrame] + ...
            (handles.plotRange)*handles.VR.FrameRate);
    plot(handles.Axes_IR,handles.IRSignal,'Color','r')
    xlim(handles.Axes_IR,...
        [handles.currFrame , handles.currFrame] + ...
            (handles.plotRange)*handles.VR.FrameRate);

    set([handles.Axes_Area,handles.Axes_IR],'YAxisLocation','right');
    drawnow;
    
    doPlay = get(hObject,'Value');
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of PlayButton


% --- Executes on button press in ForwardButton.
function ForwardButton_Callback(hObject, eventdata, handles)
% hObject    handle to ForwardButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currFrame = min(handles.nframes,handles.currFrame + 1);
PA = processPupilFrame_gui(handles);
handles.pupilRadiusVect(handles.currFrame) = PA;
plot(handles.Axes_Area,handles.pupilRadiusVect);
xlim(handles.Axes_Area,...
    [handles.currFrame , handles.currFrame] + ...
        (handles.plotRange)*handles.VR.FrameRate);
guidata(hObject,handles);

% --- Executes on button press in BackButton.
function BackButton_Callback(hObject, eventdata, handles)
% hObject    handle to BackButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currFrame = max(1,handles.currFrame - 1);
PA = processPupilFrame_gui(handles);
handles.pupilRadiusVect(handles.currFrame) = PA;
plot(handles.Axes_Area,handles.pupilRadiusVect);
xlim(handles.Axes_Area,...
    [handles.currFrame , handles.currFrame] + ...
        (handles.plotRange)*handles.VR.FrameRate);
guidata(hObject,handles);


% --- Executes on button press in BackButtonDouble.
function BackButtonDouble_Callback(hObject, eventdata, handles)
% hObject    handle to BackButtonDouble (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currFrame = max(1,handles.currFrame - round(handles.VR.FrameRate));
PA = processPupilFrame_gui(handles);
handles.pupilRadiusVect(handles.currFrame) = PA;
plot(handles.Axes_Area,handles.pupilRadiusVect);
xlim(handles.Axes_Area,...
    [handles.currFrame , handles.currFrame] + ...
        (handles.plotRange)*handles.VR.FrameRate);
guidata(hObject,handles);


% --- Executes on button press in ForwardButtonDouble.
function ForwardButtonDouble_Callback(hObject, eventdata, handles)
% hObject    handle to ForwardButtonDouble (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currFrame = min(handles.nframes,handles.currFrame + round(handles.VR.FrameRate));
PA = processPupilFrame_gui(handles);
handles.pupilRadiusVect(handles.currFrame) = PA;
plot(handles.Axes_Area,handles.pupilRadiusVect);
xlim(handles.Axes_Area,...
    [handles.currFrame , handles.currFrame] + ...
        (handles.plotRange)*handles.VR.FrameRate);
guidata(hObject,handles);


% --- Executes on button press in ResetButton.
function ResetButton_Callback(hObject, eventdata, handles)
% hObject    handle to ResetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currFrame = 1;
handles.pupilRadiusVect = nan(size(handles.pupilRadiusVect));
processPupilFrame_gui(handles);
plot(handles.Axes_Area,handles.pupilRadiusVect);
guidata(hObject,handles);


% --- Save the current parameters to a .mat file for parallel processing
% later.
function ExportParamsButton_Callback(hObject, eventdata, handles)
params = struct('Threshold',get(handles.ThreshSlider,'Value'),...
                'Close',get(handles.CloseSlider,'Value'),...
                'Open',get(handles.OpenSlider,'Value'),...
                'PupilROI',handles.pupilROI,...
                'IRROI',handles.IRROI,...
                'Masks',{handles.MaskROIs},...
                'Masks_Black',{handles.BlackROIs},...
                'Min_Radius',get(handles.MinCutoffSlider,'Value'));
[~,vidname] = fileparts(handles.filepath);
paramfilename = string(vidname) + "_analysis_parameters.mat";
outpath = fullfile(fileparts(handles.filepath),paramfilename);
save(outpath,'-struct','params');
disp("Analysis parameters saved to: ");
disp(outpath)


% --- Executes on button press in GoToFrameButton.
function GoToFrameButton_Callback(hObject, eventdata, handles)
% hObject    handle to GoToFrameButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currFrame = str2double(get(handles.GoToFrameEdit,'String'));
processPupilFrame_gui(handles);
plot(handles.Axes_Area,handles.pupilRadiusVect);
guidata(hObject,handles);

% --- Check the input and make sure it is a number. 
function GoToFrameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to GoToFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GoToFrameEdit as text
%        str2double(get(hObject,'String')) returns contents of GoToFrameEdit as a double
if isnan(str2double(get(hObject,'String')))
    set(hObject,'String','1');
else
    set(hObject,'String',...
        num2str(round(str2double(get(hObject,'String')))));
end
guidata(hObject,handles);


function GoToFrameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GoToFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in WholeVidButton.
function WholeVidButton_Callback(hObject, eventdata, handles)
% hObject    handle to WholeVidButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
params = struct('VR',handles.VR,...
                'Threshold',get(handles.ThreshSlider,'Value'),...
                'Close',get(handles.CloseSlider,'Value'),...
                'Open',get(handles.OpenSlider,'Value'),...
                'PupilROI',handles.pupilROI,...
                'IRROI',handles.IRROI,...
                'Masks',{handles.MaskROIs},...
                'Masks_Black',{handles.BlackROIs},...
                'Min_Radius',get(handles.MinCutoffSlider,'Value'));
nFrames='all';
dosave=true;
doplot=true;
useProgressBar=true;
processPupil_wholevid(params,nFrames,dosave,doplot,useProgressBar)



% --- Executes during object creation, after setting all properties.
function Axes_Original_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Axes_Original (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate Axes_Original


% --- Executes during object creation, after setting all properties.
function Axes_Area_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Axes_Area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'XTick',[],'XTickLabelMode','manual')
guidata(hObject,handles)
% Hint: place code in OpeningFcn to populate Axes_Area
