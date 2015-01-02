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

    %% 定义采样点
    global fs;
    global allNotes;

    fs = 44100;             % 采样率
    dt = 1/fs;              % 基础间隔

    T8 = 0.125;             % 1/8 秒
    T4 = 2 * T8;            % 1/4 秒
    T2 = 2 * T4;            % 1/2 秒
    
    t8 = 0:dt:T8;           % 1/8 秒内的采样点 下略
    t4 = 0:dt:T4;
    t2 = 0:dt:T2;

    [~, lengthT8] = size(t8);    % 1/8 秒内采样点个数 下略
    [~, lengthT4] = size(t4);
    [~, lengthT2] = size(t2);

    %% 设置调幅包络函数
    mod2 = (t2 .^ 4) .* exp(-30 * (t2 .^ 0.5));     % 1/2 秒用的包络函数, 下略
    mod2 = mod2 * (1 / max(mod2));
    mod4 = (t4 .^ 4) .* exp(-50 * (t4 .^ 0.5));
    mod4 = mod4 * (1 / max(mod4));
    mod8 = (t8 .^ 4) .* exp(-90 * (t8 .^ 0.5));
    mod8 = mod8 * (1 / max(mod8));

    %% 频率表
  %  1   2    3    4    5     6    7    8   
    FreqTable = [
    62, 123, 247, 494, 988, 1976, 3951, 0;   % B 调
    58, 117, 233, 466, 932, 1865, 3729, 0;   % Ab调
    55, 110, 220, 440, 880, 1760, 3520, 0;   % A 调
    52, 104, 208, 415, 831, 1661, 3322, 0;   % Ga调
    49, 98,  196, 392, 784, 1568, 3136, 0;   % G 调
    46, 92,  185, 370, 740, 1480, 2960, 0;   % Fg调
    44, 87,  175, 349, 698, 1397, 2794, 0;   % F 调
    41, 82,  165, 330, 659, 1319, 2637, 0;   % E 调
    39, 78,  156, 311, 622, 1245, 2489, 4978;% De调
    37, 73,  147, 294, 587, 1175, 2349, 4698;% D 调
    35, 69,  139, 277, 554, 1109, 2217, 4434;% Cd调
    33, 65,  131, 262, 523, 1047, 2093, 4186 % C 调
    ];

    %% 1/2 秒音符
    half = zeros(12, 8, lengthT2);
    for i = 1:12
        for j = 1:8
            tone = mod2 .* cos(2 * pi * FreqTable(i,j) * t2);
            half(i,j,:) = tone;
        end
    end

    %% 1/4 秒音符
    quater = zeros(12, 8, lengthT4);
    for i = 1:12
        for j = 1:8
            tone = mod4 .* cos(2 * pi * FreqTable(i,j) * t4);
            quater(i,j,:) = tone;
        end
    end

    %% 1/8 秒音符
    eighth = zeros(12, 8, lengthT8);
    for i = 1:12
        for j = 1:8
            tone = mod8 .* cos(2 * pi * FreqTable(i,j) * t8);
            eighth(i,j,:) = tone;
        end
    end

    allNotes = {half quater eighth};        % 所有音符集合

    kbimage = importdata('pianoBoard.bmp');   % 打开背景图片
    axes(handles.keyboard);                 % 选中坐标轴
    image(kbimage);                         % 画图片
    axis off                                % 关闭xy轴的显示
    
    % 设置图片的点击处理函数
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
    % 播放按钮点击事件处理函数
    global allNotes;
    global fs;
    
    string = char(get(handles.noteText, 'String')); % 获取文本
    S = regexp(string, ',', 'split');               % 用逗号分隔开
    playNotes(allNotes, S, fs);                     % 播放
    
    guidata(hObject, handles);


function ClickKeyBoard(hObject, eventdata)
    % 钢琴键盘点击事件处理函数
    global allNotes;
    global fs;
    handles = guidata(gcf);
    % 钢琴键对应的音符表，第一行为黑键，第二行为白键
    TABLE = {'','FG3','GA3','AB3','','CD4','DE4','','FG4','GA4','AB4','','CD5','DE5','','FG5','GA5','AB5','','CD6','DE6','';...
             'F3','G3','A3','B3','C4','D4','E4','F4','G4','A4','B4','C5','D5','E5','F5','G5','A5','B5','C6','D6','E6','F6'};
    
    pos = get(handles.keyboard, 'CurrentPoint');            % 获取鼠标点击位置
    x = pos(1,1);
    y = pos(1,2);
    
    [raw, col] = getPositionInTable(x, y);                  % 通过鼠标位置判断点中的琴键，具体实现见函数代码。
    
    originText = get(handles.noteText, 'String');           % 获取记录框里的原始文本
    NoteText = TABLE(raw, col);                             % 新音符对应文本  
    noteLength = floor(get(handles.noteLength, 'Value'));   % 下拉式菜单的值为音符长度
    NoteText = strcat(NoteText, num2str(noteLength));       % 拼接起来
    if get(handles.isRecord, 'Value') == 1                  % 如果记录按钮被按下
        if strcmp(originText, '') == 1                      % 如果记录框里没有文字
            set(handles.noteText, 'String', NoteText);      % 直接放进去
        else                                                % 如果有文字，就加一个逗号和新音符
            set(handles.noteText, 'String', strcat(originText, ',', NoteText));
        end
    end
    playNotes(allNotes, NoteText, fs);                      % 播放这个音符


function noteLength_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function addEmptyNote_Callback(hObject, eventdata, handles)
    originText = get(handles.noteText, 'String');           % 获取记录框里的原始文本
    noteLength = floor(get(handles.noteLength, 'Value'));   % 获取音符长度
    newToneText = strcat('0', num2str(noteLength));         % 拼接城完整的音符文本
    % 放进记录框
    if strcmp(originText, '') == 1
        set(handles.noteText, 'String', newToneText);
    else
        set(handles.noteText, 'String', strcat(originText, ',', newToneText));
    end


function save_Callback(hObject, eventdata, handles)
    global allNotes;
    global fs;
    
    % 选择文件
    [filename, filepath] = uiputfile({'*.txt', '文本文档'; '*.wav', '音频文件'}, '保存文件');
    file = [filepath, filename];
    if filename ~= 0    % 如果成功选择了文件
        if strcmp(filename(end-2:end), 'txt')       % 后缀名为txt
            fid = fopen(file, 'w');                 % 打开文件
            text = get(handles.noteText, 'String'); % 获取文本
            fprintf(fid, '%s', text);               % 保存
            fclose(fid);                            % 关闭文件
        else                                                    
            assert(strcmp(filename(end-2:end), 'wav') == 1);    % 后缀名必须为 wav
            string = char(get(handles.noteText, 'String'));     % 获取文本
            S = regexp(string, ',', 'split');                   % 分割文本
            music = noteText2Music(allNotes, S);                % 转化为音频信号
            audiowrite(file, music, fs);                        % 保存
        end
        msgbox('保存成功','提示：');                             % 提示
    end

function load_Callback(hObject, eventdata, handles)
    [filename, filepath] = uigetfile('*.txt', '载入文件');      % 选择文件
    file = [filepath, filename];
    if filename ~= 0                                            % 如果成功选择了文件
        fid = fopen(file, 'rt');                                % 打开文件
        text = fread(fid, '*char');                             % 读取所有文本
        set(handles.noteText, 'String', text');                 % 放进记录框
        fclose(fid);                                            % 关闭文件
    end


function clear_Callback(hObject, eventdata, handles)
    set(handles.noteText, 'String', '');    % 清空文本框
    set(handles.keyPlay, 'String', '');

function keyPlay_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function keyPlay_KeyPressFcn(hObject, eventdata, handles)
    global allNotes;
    global fs;
    % 键盘和音符的对应Map
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
    if isKey(map, key) % 如果按下的是设置里的键
        noteLength = floor(get(handles.noteLength, 'Value'));
        noteText = strcat(map(key), num2str(noteLength));   % 拼接成音符文本
        playNotes(allNotes, {noteText}, fs);                % 播放
        % 如果记录按钮被按下就记录一下
        if get(handles.isRecord, 'Value') == 1
            originText = get(handles.noteText, 'String');
            if strcmp(originText, '') == 1
                set(handles.noteText, 'String', noteText);
            else
                set(handles.noteText, 'String', strcat(originText, ',', noteText));
            end
        end
    end
