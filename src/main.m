function varargout = main(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @main_OpeningFcn, ...
                       'gui_OutputFcn',  @main_OutputFcn, ...
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

function main_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;

    %% ���������
    global fs;
    global allNotes;

    fs = 44100;             % ������
    dt = 1/fs;              % �������

    T8 = 0.125;             % 1/8 ��
    T4 = 2 * T8;            % 1/4 ��
    T2 = 2 * T4;            % 1/2 ��
    
    t8 = 0:dt:T8;           % 1/8 ���ڵĲ����� ����
    t4 = 0:dt:T4;
    t2 = 0:dt:T2;

    [~, lengthT8] = size(t8);    % 1/8 ���ڲ�������� ����
    [~, lengthT4] = size(t4);
    [~, lengthT2] = size(t2);

    %% ���õ������纯��
    mod2 = (t2 .^ 4) .* exp(-30 * (t2 .^ 0.5));     % 1/2 ���õİ��纯��, ����
    mod2 = mod2 * (1 / max(mod2));
    mod4 = (t4 .^ 4) .* exp(-50 * (t4 .^ 0.5));
    mod4 = mod4 * (1 / max(mod4));
    mod8 = (t8 .^ 4) .* exp(-90 * (t8 .^ 0.5));
    mod8 = mod8 * (1 / max(mod8));

    %% Ƶ�ʱ�
  %  1   2    3    4    5     6    7    8   
    FreqTable = [
    62, 123, 247, 494, 988, 1976, 3951, 0;   % B ��
    58, 117, 233, 466, 932, 1865, 3729, 0;   % Ab��
    55, 110, 220, 440, 880, 1760, 3520, 0;   % A ��
    52, 104, 208, 415, 831, 1661, 3322, 0;   % Ga��
    49, 98,  196, 392, 784, 1568, 3136, 0;   % G ��
    46, 92,  185, 370, 740, 1480, 2960, 0;   % Fg��
    44, 87,  175, 349, 698, 1397, 2794, 0;   % F ��
    41, 82,  165, 330, 659, 1319, 2637, 0;   % E ��
    39, 78,  156, 311, 622, 1245, 2489, 4978;% De��
    37, 73,  147, 294, 587, 1175, 2349, 4698;% D ��
    35, 69,  139, 277, 554, 1109, 2217, 4434;% Cd��
    33, 65,  131, 262, 523, 1047, 2093, 4186 % C ��
    ];

    %% 1/2 ������
    half = zeros(12, 8, lengthT2);
    for i = 1:12
        for j = 1:8
            tone = mod2 .* cos(2 * pi * FreqTable(i,j) * t2);
            half(i,j,:) = tone;
        end
    end

    %% 1/4 ������
    quater = zeros(12, 8, lengthT4);
    for i = 1:12
        for j = 1:8
            tone = mod4 .* cos(2 * pi * FreqTable(i,j) * t4);
            quater(i,j,:) = tone;
        end
    end

    %% 1/8 ������
    eighth = zeros(12, 8, lengthT8);
    for i = 1:12
        for j = 1:8
            tone = mod8 .* cos(2 * pi * FreqTable(i,j) * t8);
            eighth(i,j,:) = tone;
        end
    end

    allNotes = {half quater eighth};        % ������������

    kbimage = importdata('pianoBoard.bmp');   % �򿪱���ͼƬ
    axes(handles.keyboard);                 % ѡ��������
    image(kbimage);                         % ��ͼƬ
    axis off                                % �ر�xy�����ʾ
    
    % ����ͼƬ�ĵ��������
    set(get(handles.keyboard, 'Child'), 'ButtonDownFcn', @ClickKeyBoard);

    % Update handles structure
    guidata(hObject, handles);


function varargout = main_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;
    guidata(hObject, handles);


function noteText_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function Play_Callback(hObject, eventdata, handles)
    % ���Ű�ť����¼�������
    global allNotes;
    global fs;
    
    string = char(get(handles.noteText, 'String')); % ��ȡ�ı�
    S = regexp(string, ',', 'split');               % �ö��ŷָ���
    playNotes(allNotes, S, fs);                     % ����
    
    guidata(hObject, handles);


function ClickKeyBoard(hObject, eventdata)
    % ���ټ��̵���¼�������
    global allNotes;
    global fs;
    handles = guidata(gcf);
    % ���ټ���Ӧ����������һ��Ϊ�ڼ����ڶ���Ϊ�׼�
    TABLE = {'','FG3','GA3','AB3','','CD4','DE4','','FG4','GA4','AB4','','CD5','DE5','','FG5','GA5','AB5','','CD6','DE6','';...
             'F3','G3','A3','B3','C4','D4','E4','F4','G4','A4','B4','C5','D5','E5','F5','G5','A5','B5','C6','D6','E6','F6'};
    
    pos = get(handles.keyboard, 'CurrentPoint');            % ��ȡ�����λ��
    x = pos(1,1);
    y = pos(1,2);
    
    [raw, col] = getPositionInTable(x, y);                  % ͨ�����λ���жϵ��е��ټ�������ʵ�ּ��������롣
    
    originText = get(handles.noteText, 'String');           % ��ȡ��¼�����ԭʼ�ı�
    NoteText = TABLE(raw, col);                             % ��������Ӧ�ı�  
    noteLength = floor(get(handles.noteLength, 'Value'));   % ����ʽ�˵���ֵΪ��������
    NoteText = strcat(NoteText, num2str(noteLength));       % ƴ������
    if get(handles.isRecord, 'Value') == 1                  % �����¼��ť������
        if strcmp(originText, '') == 1                      % �����¼����û������
            set(handles.noteText, 'String', NoteText);      % ֱ�ӷŽ�ȥ
        else                                                % ��������֣��ͼ�һ�����ź�������
            set(handles.noteText, 'String', strcat(originText, ',', NoteText));
        end
    end
    playNotes(allNotes, NoteText, fs);                      % �����������


function noteLength_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function addEmptyNote_Callback(hObject, eventdata, handles)
    originText = get(handles.noteText, 'String');           % ��ȡ��¼�����ԭʼ�ı�
    noteLength = floor(get(handles.noteLength, 'Value'));   % ��ȡ��������
    newToneText = strcat('0', num2str(noteLength));         % ƴ�ӳ������������ı�
    % �Ž���¼��
    if strcmp(originText, '') == 1
        set(handles.noteText, 'String', newToneText);
    else
        set(handles.noteText, 'String', strcat(originText, ',', newToneText));
    end


function save_Callback(hObject, eventdata, handles)
    global allNotes;
    global fs;
    
    % ѡ���ļ�
    [filename, filepath] = uiputfile({'*.txt', '�ı��ĵ�'; '*.wav', '��Ƶ�ļ�'}, '�����ļ�');
    file = [filepath, filename];
    if filename ~= 0    % ����ɹ�ѡ�����ļ�
        if strcmp(filename(end-2:end), 'txt')       % ��׺��Ϊtxt
            fid = fopen(file, 'w');                 % ���ļ�
            text = get(handles.noteText, 'String'); % ��ȡ�ı�
            fprintf(fid, '%s', text);               % ����
            fclose(fid);                            % �ر��ļ�
        else                                                    
            assert(strcmp(filename(end-2:end), 'wav') == 1);    % ��׺������Ϊ wav
            string = char(get(handles.noteText, 'String'));     % ��ȡ�ı�
            S = regexp(string, ',', 'split');                   % �ָ��ı�
            music = noteText2Music(allNotes, S);                % ת��Ϊ��Ƶ�ź�
            audiowrite(file, music, fs);                        % ����
        end
        msgbox('����ɹ�','��ʾ��');                             % ��ʾ
    end

function load_Callback(hObject, eventdata, handles)
    [filename, filepath] = uigetfile('*.txt', '�����ļ�');      % ѡ���ļ�
    file = [filepath, filename];
    if filename ~= 0                                            % ����ɹ�ѡ�����ļ�
        fid = fopen(file, 'rt');                                % ���ļ�
        text = fread(fid, '*char');                             % ��ȡ�����ı�
        set(handles.noteText, 'String', text');                 % �Ž���¼��
        fclose(fid);                                            % �ر��ļ�
    end


function clear_Callback(hObject, eventdata, handles)
    set(handles.noteText, 'String', '');    % ����ı���
    set(handles.keyPlay, 'String', '');

function keyPlay_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function keyPlay_KeyPressFcn(hObject, eventdata, handles)
    global allNotes;
    global fs;
    % ���̺������Ķ�ӦMap
    map = containers.Map({ ...
        'v', 'b', 'n', 'm',...
        'a', 's', 'd', 'f', 'g', 'h', 'j', ...
        'q', 'w', 'e', 'r', 't', 'y', 'u',...
        '1', '2', '3',...
        'space'}, ...
        {'F3', 'G3', 'A3', 'B3',...
        'C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4', ...
         'C5', 'D5', 'E5', 'F5', 'G5', 'A5', 'B5', ...
         'C6', 'D6', 'E6', ...
         '0'});
    key = eventdata.Key;
    if isKey(map, key) % ������µ���������ļ�
        noteLength = floor(get(handles.noteLength, 'Value'));
        noteText = strcat(map(key), num2str(noteLength));   % ƴ�ӳ������ı�
        playNotes(allNotes, {noteText}, fs);                % ����
        % �����¼��ť�����¾ͼ�¼һ��
        if get(handles.isRecord, 'Value') == 1
            originText = get(handles.noteText, 'String');
            if strcmp(originText, '') == 1
                set(handles.noteText, 'String', noteText);
            else
                set(handles.noteText, 'String', strcat(originText, ',', noteText));
            end
        end
    end
