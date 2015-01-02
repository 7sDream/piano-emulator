# PianoEmulator 帮助文档

标签（空格分隔）： 开发 帮助文档

---

### 第一部分 文件列表
```
PianoEmulator
|   ReadMe.html
|   
+---bin
|   |   pianoBoard.bmp
|   |   PianoEmulator.exe
|   |   keyboardMap.png
|   |
|   \---music
|           
\---src
        getPositionInTable.m
        keyboardMap.png
        keyboardMap.psd
        main.fig
        main.m
        noteText2Music.m
        pianoBoard.bmp
        pianoBoard.psd
        playNotes.m
        

```

其中`bin`为编译为exe后的文件夹，因为没有打包MCRInsraller，所以可能无法运行，其中：

- `PianoEmulator.exe` 主程序，双击运行。
- `pianoBoard.bmp` 钢琴键盘图片，不能删
- `keyboardMap.png` 键盘音符对应图
- `music文件夹` 一些简单的简谱图片和软件可以直接用的乐谱。
<br />

`src`文件夹是源代码文件夹，其中：

- `main.m`和`main.fig`为GUI的主要实现代码
- 其他三个`.m`文件是支持函数，作用分别为：
 - `playNotes.m` 播放文本形式的音频信号，函数内部使用了`noteText2Music`来进行转化。
 - `noteText2Music.m` 将文本形式的音符转换为音频信号
 - `getPositionInTable.m` 由鼠标点击窗口里键盘的位置算出按的是哪个键
- `pianoBoard.bmp`、`keyboardMap.png` 见上
- `pianoBoard.psd`、`keyboardMap.psd` 图片的psd格式，方便修改

---

### 第二部分 软件使用介绍

打开软件后看到的界面如下

![fistScreen][firstscreen]

各个地方的功能如下

1. 简易钢琴键盘。鼠标点击琴键可以发出相应的声音。白键上注明了音阶和音度，两个白键之间的黑键为两白键之间的音。如第一个黑键在`F3`和`G3`之间，则它的音是`FG3`。
2. 音符长度控制菜单。控制点一下钢琴发出的音符的长度。可选1/2秒，1/4秒，1/8秒。
3. 插入空音符按钮。在下方的记录区插入一个空音符，空音符长度由音符长度控制菜单决定。
4. 录制开关。当按下时会自动在下方的记录框里记下播放出的音符。
5. 记录框。记录播放出的音符。
6. 载入按钮。从文本文件中载入音符序列到记录框中。
7. 保存按钮。根据文件扩展名不同，可以选择保存为文本文件以供下次加载或者导出为WAV音频文件。
8. 键盘弹奏区。在这个文本框里按下键盘会弹出相应音调，键盘和音调的对应图标在下方给出。
9. 清空按钮。清空记录区和键盘弹奏区。
10. 播放按钮。可以播放记录区里的音符序列。

<br />
键盘音符对应图
![keyboardMap][keyboardMap]

键盘到音符的映射可以很方便的通过修改代码来完成，关键代码在`main.m`文件中的`keyPlay_KeyPressFcn`函数。通过修改
```matlab
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
```
这里的映射关系，就可以决定按哪个键出哪个音符了。

### 第三部分 参考资料

关于音符函数的编写参考了[《MATLAB版最炫民族风》][matlab_minzufeng]的部分代码。

GUI方面，Axes轴载入图片后点击回调函数无效的处理方法参考了 [这个博客][axes_solve_bolg]

---

END

Author: 7sDream
FinishTime: 2015.1.1

  [firstscreen]: http://ww4.sinaimg.cn/large/88e401f0tw1enuaqs6colj20b009jdgv.jpg
  [keyboardMap]: http://ww4.sinaimg.cn/large/88e401f0tw1enuc4zmmvcj20ks06bmys.jpg
  [matlab_minzufeng]: http://www.douban.com/group/topic/29707088/
  [axes_solve_bolg]: http://blog.sina.com.cn/s/blog_598e352501017uic.html