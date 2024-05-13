function varargout = PupilAnalysis_ROI_GUI(varargin)
% PUPILANALYSIS_ROI_GUI MATLAB code for PupilAnalysis_ROI_GUI.fig
%      PUPILANALYSIS_ROI_GUI, by itself, creates a new PUPILANALYSIS_ROI_GUI or raises the existing
%      singleton*.
%
%      H = PUPILANALYSIS_ROI_GUI returns the handle to a new PUPILANALYSIS_ROI_GUI or the handle to
%      the existing singleton*.
%
%      PUPILANALYSIS_ROI_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PUPILANALYSIS_ROI_GUI.M with the given input arguments.
%
%      PUPILANALYSIS_ROI_GUI('Property','Value',...) creates a new PUPILANALYSIS_ROI_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PupilAnalysis_ROI_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PupilAnalysis_ROI_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PupilAnalysis_ROI_GUI

% Last Modified by GUIDE v2.5 25-Apr-2024 16:30:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PupilAnalysis_ROI_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PupilAnalysis_ROI_GUI_OutputFcn, ...
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


% --- Executes just before PupilAnalysis_ROI_GUI is made visible.
function PupilAnalysis_ROI_GUI_OpeningFcn(hObject, eventdata, handles,...
                                             im,pupilROI,IRROI,maskROIs,blackROIs)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PupilAnalysis_ROI_GUI (see VARARGIN)

% Choose default command line output for PupilAnalysis_ROI_GUI
handles.output = hObject;
% Put the input image into our handles object.
handles.im = im;
imshow(handles.im,'Parent',handles.Axes_Crop);
% If we inhereted ROI information from the main GUI, use this to regenerate
% those ROIs
if ~isempty(pupilROI)
    handles.pupilROI = images.roi.Rectangle(handles.Axes_Crop,'Color','b',...
        'Position',pupilROI);
    addlistener(handles.pupilROI,'ROIMoved',...
        @(src,evnt)pupilROICallback(src,evnt,im,handles.Axes_Mask));
    IC = imcrop(im,pupilROI);
    imshow(IC,'Parent',handles.Axes_Mask);
else
    handles.pupilROI = [];
end
if ~isempty(IRROI)
    handles.IRROI = images.roi.Rectangle(handles.Axes_Crop,'Color','r',...
        'Position',IRROI);
else
    handles.IRROI = [];
end

if ~isempty(maskROIs)
    handles.MaskROIs = struct([]);
    for i = 1:length(maskROIs)
        coords = maskROIs{i};
        currROI = images.roi.Polygon(handles.Axes_Mask,...
            'Position',coords);
        handles.MaskROIs = [handles.MaskROIs, struct('ROI',currROI)];
    end
else
    handles.MaskROIs = struct([]); % Multiple ROIs can go here. 
end

% Black masking ROIs for the pupil
if ~isempty(blackROIs)
    handles.BlackROIs = struct([]);
    for i = 1:length(blackROIs)
        coords = blackROIs{i};
        currROI = images.roi.Polygon(handles.Axes_Mask,...
            'Position',coords,'Color','k');
        handles.BlackROIs = [handles.BlackROIs,struct('ROI',currROI)];
    end
else
    handles.BlackROIs = struct([]);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PupilAnalysis_ROI_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PupilAnalysis_ROI_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles;


% --- Executes on button press in PupilROIButton.
function PupilROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to PupilROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.pupilROI)
    delete(handles.pupilROI)
end
im = handles.im;
ax = handles.Axes_Mask;
handles.pupilROI = images.roi.Rectangle(handles.Axes_Crop,'Color','b');
addlistener(handles.pupilROI,'ROIMoved',...
    @(src,evnt)pupilROICallback(src,evnt,im,ax));
draw(handles.pupilROI);
guidata(hObject,handles);


% --- Executes on button press in LEDROIButton.
function LEDROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to LEDROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.IRROI)
    delete(handles.IRROI);
end
handles.IRROI = images.roi.Rectangle(handles.Axes_Crop,'Color','r');
draw(handles.IRROI);
guidata(hObject,handles);

% --- Executes on button press in MaskROIButton.
function MaskROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to MaskROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currROI = images.roi.Polygon(handles.Axes_Mask);
draw(currROI);
% Add this ROI to the structure of all mask ROIs

handles.MaskROIs = [handles.MaskROIs,struct('ROI',currROI)];
% Clean up the mask ROI struct to remove deleted ROIs and empty rows
toRemove = cellfun(@(x)isempty(x),{handles.MaskROIs.ROI});
handles.MaskROIs(toRemove) = [];
toRemove =  cellfun(@(x) ~isvalid(x),{handles.MaskROIs.ROI});
handles.MaskROIs(toRemove) = [];
% disp(handles.MaskROIs);
guidata(hObject,handles);

% --- Executes on button press in ClearMaskROI.
function ClearMaskROI_Callback(hObject, eventdata, handles)
% hObject    handle to ClearMaskROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Delete the polygons that already exist (if we have any)
if ~isempty(handles.MaskROIs)
    for i = 1:length(handles.MaskROIs)
        delete(handles.MaskROIs(i).ROI)
    end
end

if ~isempty(handles.BlackROIs)
    for i = 1:length(handles.BlackROIs)
        delete(handles.BlackROIs(i).ROI)
    end
end
% Replace the handles to these deleted objects with a blank struct.
handles.MaskROIs = struct([]);
handles.BlackROIs = struct([]);
guidata(hObject,handles);

% --- Executes on button press in OKButton.
function OKButton_Callback(hObject, eventdata, handles)
% hObject    handle to OKButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Access the handles structure of the main pupil analysis gui
mainGUI = findobj(allchild(groot),'Tag','PupilAnalysisGUI');
mainGUIHandles = guidata(mainGUI);
% Add the ROI information to this structure:
% First check that these objects exist / aren't empty
% - Position of the pupil bounding box
if ~isempty(handles.pupilROI)
    mainGUIHandles.pupilROI = handles.pupilROI.Position;
end
if ~isempty(handles.IRROI)
    mainGUIHandles.IRROI = handles.IRROI.Position;
end
% Store the positions of each of the masking ROIs in a cell array. 
if ~isempty(handles.MaskROIs)
    % Clean up the structure befor export: 
    toRemove = cellfun(@(x)isempty(x),{handles.MaskROIs.ROI});
    handles.MaskROIs(toRemove) = [];
    toRemove =  cellfun(@(x) ~isvalid(x),{handles.MaskROIs.ROI});
    handles.MaskROIs(toRemove) = [];
    maskPositions = cell(length(handles.MaskROIs),1);
    for i = 1:length(maskPositions)
        maskPositions{i} = handles.MaskROIs(i).ROI.Position;
    end
    mainGUIHandles.MaskROIs = maskPositions;
else
    mainGUIHandles.MaskROIs = [];
end

% Same for black ROIs

if ~isempty(handles.BlackROIs)
    % Clean up the structure befor export: 
    toRemove = cellfun(@(x)isempty(x),{handles.BlackROIs.ROI});
    handles.BlackROIs(toRemove) = [];
    toRemove =  cellfun(@(x) ~isvalid(x),{handles.BlackROIs.ROI});
    handles.BlackROIs(toRemove) = [];
    maskPositions = cell(length(handles.BlackROIs),1);
    for i = 1:length(maskPositions)
        maskPositions{i} = handles.BlackROIs(i).ROI.Position;
    end
    mainGUIHandles.BlackROIs = maskPositions;
else
    mainGUIHandles.BlackROIs = [];
end


processPupilFrame_gui(mainGUIHandles);
guidata(mainGUI,mainGUIHandles);
delete(hObject);
close;

% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject)
close;

% Callback function for the cropping ROI, used to update the 
function pupilROICallback(src,event,im,ax)
% Get the boundaries of the ROI and crop the image "im". 
% Draw the cropped image on the axes "ax"
pos = src.Position;
IC = imcrop(im,pos);
imshow(IC,'Parent',ax);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in BlackMaskROIButton.
function BlackMaskROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to BlackMaskROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currROI = images.roi.Polygon(handles.Axes_Mask,'Color','black');
draw(currROI);
% Add this ROI to the structure of all black mask ROIs

handles.BlackROIs = [handles.BlackROIs,struct('ROI',currROI)];
% Clean up the mask ROI struct to remove deleted ROIs and empty rows
toRemove = cellfun(@(x)isempty(x),{handles.BlackROIs.ROI});
handles.BlackROIs(toRemove) = [];
toRemove =  cellfun(@(x) ~isvalid(x),{handles.BlackROIs.ROI});
handles.BlackROIs(toRemove) = [];
% disp(handles.MaskROIs);
guidata(hObject,handles);
