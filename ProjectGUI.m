function varargout = ProjectGUI(varargin)
% PROJECTGUI MATLAB code for ProjectGUI.fig
%      PROJECTGUI, by itself, creates a new PROJECTGUI or raises the existing
%      singleton*.
%
%      H = PROJECTGUI returns the handle to a new PROJECTGUI or the handle to
%      the existing singleton*.
%
%      PROJECTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECTGUI.M with the given input arguments.
%
%      PROJECTGUI('Property','Value',...) creates a new PROJECTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProjectGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ProjectGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProjectGUI

% Last Modified by GUIDE v2.5 06-Dec-2016 13:09:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProjectGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ProjectGUI_OutputFcn, ...
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


% --- Executes just before ProjectGUI is made visible.
function ProjectGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ProjectGUI (see VARARGIN)

% Choose default command line output for ProjectGUI
handles.output = hObject;

% Version 
handles.version = '0.1';

% Set recorded and manipulated signal plots
set(handles.axes1,'XTickLabel',{});
set(handles.axes1,'YTickLabel',{});
set(handles.axes2,'XTick',[]);
set(handles.axes2,'YTick',[]);
set(handles.axes2,'XTickLabel',{});
set(handles.axes2,'YTickLabel',{});

% Set default values
handles = set_default(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ProjectGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ProjectGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Set defaults
function handles = set_default(handles)

% Initialize objects for record and playback
handles.record_obj = [];
handles.play_obj = [];
handles.my_rec = [];
handles.mani_rec = [];

% Initialize structure for saving/manipulating sound data
handles.sound.reclen = [];
handles.fs = [];
handles.mani_fs = [];   


% Initialize status reporting
handles.status.isrecording = false;
handles.status.isplaying = false;
handles.status.isreset = false;
handles.status.issave = false;
handles.status.Xlim = [];
handles.status.Ylim = [];
handles.status.filename = '';


handles.status.isreset = true;
handles = update_GUI(handles);

% Updates GUI buttons
function handles = update_GUI(handles)

if handles.status.isrecording
    set(handles.play_button,'enable','off');
    set(handles.record_button,'enable','off');
elseif handles.status.isplaying
    set(handles.play_button,'enable','off');
    set(handles.record_button,'enable','off');
else
    set(handles.play_button,'enable','on'); 
    set(handles.record_button,'enable','on');
end

% Update the plot for axes1
function handles = update_plot(handles)

axes(handles.axes1);

% --- Executes on button press in record_button.
function record_button_Callback(hObject, eventdata, handles)

try
    handles.status.isrecording = true;
    handles = update_GUI(handles);
    
    handles.fs = 8000;
    handles.mani_fs = 8000;
    handles.sound.reclen = 1.5;
    recLen = handles.sound.reclen;
    
    handles.record_obj = audiorecorder;
    disp('Start speaking.')
    recordblocking(handles.record_obj, recLen);
    disp('End of Recording.');
    
    % Store data in double-precision array.
    myRecording = getaudiodata(handles.record_obj);
    handles.my_rec = myRecording;
    
    axes(handles.axes1);
    cla;
    plot(myRecording);
    title('Original');
    hold on;
    
    handles.status.isrecording = false;
    
    handles = update_GUI(handles);
    guidata(hObject, handles);
catch
    h = errordlg('Error starting audio input device!  Check sound card and microphone!','ERROR');
    waitfor(h);
    return
end


% --- Executes on button press in play_button.
function play_button_Callback(hObject, eventdata, handles)

handles.status.isplaying = true;

handles = update_GUI(handles);
handles = update_plot(handles);

% Store data in double-precision array.
myRecording = handles.my_rec;

% Play the recording
soundsc(myRecording);
pause(1);

% Done
handles.status.isplaying = false;
handles = update_GUI(handles);

guidata(hObject, handles);

% --- Executes on button press in playmani_button.
function playmani_button_Callback(hObject, eventdata, handles)

handles.status.isplaying = true;

handles = update_GUI(handles);
handles = update_plot(handles);

myRecording = handles.mani_rec;

% Play the recording
soundsc(myRecording);
pause(1);

% Done
handles.status.isplaying = false;
handles = update_GUI(handles);

guidata(hObject, handles);
        

% --- Executes on button press in three_button.
function three_button_Callback(hObject, eventdata, handles)

myRecording = handles.my_rec;

%three point averager filter on recording
f = [1/3 1/3 1/3]';
averagedRec = conv(myRecording, f);

handles.mani_rec = averagedRec;

%figure(3)
%plot(abs(fft(handles.mani_rec)), 256);
%fftoSig = fft(handles.my_rec, 256);
%fftSig = fft(handles.mani_rec, 256);
%plot(fftoSig);

%hold on;
%plot(fftSig);
%hold off;

%absfftSig = abs(fftSig);

axes(handles.axes2);

% Clear plot
cla;

plot(handles.mani_rec, 'r');
title('Modified - Three point averager');
hold on;
%handles.status.ismanipulated = true;
%handles.status.threepoint = true;

handles = update_GUI(handles);
guidata(hObject, handles);


% --- Executes on button press in fraction_button.
function fraction_button_Callback(hObject, eventdata, handles)

myRecording = handles.my_rec;

fraction = 50;
halvedRec = myRecording./fraction;

handles.mani_rec = halvedRec;
axes(handles.axes2);

% Clear plot
cla;

plot(myRecording, 'g');
title('Modified - Fraction values');
hold on;
%handles.status.ismanipulated = true;
%handles.status.fraction = true;

handles = update_GUI(handles);
guidata(hObject, handles);


% --- Executes on button press in doubling_button.
function doubling_button_Callback(hObject, eventdata, handles)

myRecording = handles.my_rec;

doubleRec = repelem(myRecording, 2);

handles.mani_rec = doubleRec;
axes(handles.axes2);

% Clear plot
cla;

plot(myRecording, 'o');
title('Modified - Double the length');
hold on;
%handles.status.ismanipulated = true;
%handles.status.doubling = true;

handles = update_GUI(handles);
guidata(hObject, handles);


% --- Executes on button press in reset_button.
function reset_button_Callback(hObject, eventdata, handles)

close(gcbf);
ProjectGUI;

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in speed_button.
function speed_button_Callback(hObject, eventdata, handles)
% hObject    handle to speed_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fs = handles.fs;
handles.mani_rec = resample(handles.my_rec, fs, 12/10*fs);
handles.mani_fs = fs;

axes(handles.axes2);

% Clear plot
cla;

plot(handles.mani_rec, 'b');
title('Speed Up');
hold on;

handles = update_GUI(handles);
guidata(hObject, handles); 

% --- Executes on button press in slow_button.
function slow_button_Callback(hObject, eventdata, handles)
% hObject    handle to slow_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fs = handles.fs;
handles.mani_rec = resample(handles.my_rec, fs, 8/10*fs);
handles.mani_fs = fs;

axes(handles.axes2);

% Clear plot
cla;

plot(handles.mani_rec, 'b');
title('Slow Down');
hold on;

handles = update_GUI(handles);
guidata(hObject, handles); 


% --- Executes on button press in copy_button.
function copy_button_Callback(hObject, eventdata, handles)
% hObject    handle to copy_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.my_rec = handles.mani_rec;
handles.fs = handles.mani_fs;

axes(handles.axes1);
cla;
plot(handles.my_rec);
title('Original');
hold on;

handles = update_GUI(handles);
guidata(hObject, handles);


% --- Executes on button press in lower_button.
function lower_button_Callback(hObject, eventdata, handles)
% hObject    handle to lower_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%add a large value to mess with the recording
maxV = max(handles.my_rec);                       %this line
handles.mani_rec = [2*maxV ; handles.my_rec(2:end)];  %and this line -- this will be the manipulated signal

axes(handles.axes2);

% Clear plot
cla;

plot(handles.mani_rec, 'b');
title('Lower Volume');
hold on;

handles = update_GUI(handles);
guidata(hObject, handles); 


% --- Executes on button press in echo_button.
function echo_button_Callback(hObject, eventdata, handles)
% hObject    handle to echo_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
myRecording = handles.my_rec;

% Recording in row format
%rowRecording = myRecording';

%getting the echo's sound
td = 0.2;
vecb = [1; zeros(round(td*handles.fs), 1); 1/3];
td = 0.3;
vecc = [1/2; zeros(round(td*handles.fs), 1); 1/4];

res = conv(vecb, myRecording);
res = conv(vecc, res);

handles.mani_rec = res;


axes(handles.axes2);

% Clear plot
cla;

%find xaxis
nc = size(res);
nc = 1:1:nc(1);
figxaxis = nc./handles.fs;

plot(figxaxis, handles.mani_rec, 'b');
title('Modified - Echoing the recording');
hold on;

handles = update_GUI(handles);
guidata(hObject, handles); 

% --- Executes on button press in high_pass.
function high_pass_Callback(hObject, eventdata, handles)
% hObject    handle to high_pass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a = [1];
b = [1 -2/3];
handles.mani_rec = filter(b, -a, handles.my_rec);
axes(handles.axes2);
% Clear plot
cla;
%
plot(handles.mani_rec, 'r');
title('Modified - High Pass');
hold on;
%
handles = update_GUI(handles);
guidata(hObject, handles);

