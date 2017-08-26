%% gui: 图形用户界面
function gui
	% 窗口尺寸
	gWidth = 750;
	gHeight = 500;

	% 组件尺寸
	itemHeight = 25;
	itemHeightSmall = 20;
	itemHeightLarge = 30;
	itemWidth = 150;

	% 间隙尺寸
	gap = 20;
	gapSmall = 10;
	gapLarge = 30;

	% 特定组件的尺寸
	selectorHeight = 50;
	selectorNum = 7;
	% panel 高度
	panelHeight = gHeight - gap * 2;
	panelHeightLeftUp = panelHeight / 2;
	panelHeightLeftDown = panelHeight / 2 - gap;
	panelHeightRightUp = panelHeight * 0.6;
	panelHeightRightDown = panelHeight * 0.4 - gap;
	% 左侧 panel 宽度
	panelLeftWidth = 450;
	% 右侧 panel 宽度
	panelRightWidth = gWidth - panelLeftWidth - gap * 3;

	addpath('./assistant');
	addpath('./inversion');

	gui = figure();
	screenSize = get(0,'ScreenSize');
	set(gui, ...
		'NumberTitle','off', ...
		'Name','Rayinvr', ...
		'MenuBar','none', ...
		'ToolBar','none', ...
		'Position',[(screenSize(3)-gWidth)/2,(screenSize(4)-gHeight)/2,gWidth,gHeight] ...
	);

	panelLeftUp = uipanel( ...
		'Parent',gui, ...
		'Title','1. 输入', ...
		'Unit','pixels', ...
		'Position',[gap,panelHeightLeftDown+gap*2,panelLeftWidth,panelHeightLeftUp] ...
	);

	panelLeftDown = uipanel( ...
		'Parent',gui, ...
		'Title','2. 预处理', ...
		'Unit','pixels', ...
		'Position',[gap,gap,panelLeftWidth,panelHeightLeftDown] ...
	);

	panelRightUp = uipanel( ...
		'Parent',gui, ...
		'Title','3. 计算', ...
		'Unit','pixels', ...
		'Position',[panelLeftWidth+gap*2,panelHeightRightDown+gap*2,panelRightWidth,panelHeightRightUp] ...
	);

	panelRightDown = uipanel( ...
		'Parent',gui, ...
		'Title','4. 反演', ...
		'Unit','pixels', ...
		'Position',[panelLeftWidth+gap*2,gap,panelRightWidth,panelHeightRightDown] ...
	);

	panelSelectFolder = uipanel( ...
		'Parent',panelLeftUp, ...
		'Title','选择输入文件所在目录', ...
		'BorderType','none', ...
		'Unit','pixels', ...
		'Position',[gapSmall,panelHeightLeftUp-gapLarge-selectorHeight,panelLeftWidth-gapSmall*2,selectorHeight] ...
	);

	editSelectFolder = uicontrol(...
		'Parent',panelSelectFolder, ...
		'Style','edit', ...
		'HorizontalAlignment', 'left', ...
		'Unit', 'normalized', ...
		'Position',[0.01,0.1,0.85,0.8] ...
	);

	btnSelectFolder = uicontrol(...
		'Parent',panelSelectFolder, ...
		'Style','pushbutton', ...
		'String','选择', ...
		'Callback',@btnSelectFolderCallback, ...
		'Unit', 'normalized', ...
		'Position',[0.87,0.1,0.12,0.8] ...
	);

	btnAssistant = uicontrol(...
		'Parent', panelLeftDown, ...
		'Style', 'pushbutton', ...
		'String', '预处理工具箱', ...
		'TooltipString', '编辑v.in等输入文件', ...
		'Callback', @btnAssistantCallback, ...
		'Unit', 'pixels', ...
		'Position', [gap,panelHeightLeftDown-gapLarge-itemHeightLarge,itemWidth,itemHeightLarge] ...
	);

	checkboxOde = uicontrol(...
		'Parent', panelRightUp, ...
		'Style', 'checkbox', ...
		'String', '调用 Matlab ODE 工具箱', ...
		'Unit', 'pixels', ...
		'Position', [gap,panelHeightRightUp-itemHeight-gapLarge,500,itemHeight] ...
	);

	checkboxTimer = uicontrol(...
		'Parent', panelRightUp, ...
		'Style', 'checkbox', ...
		'String', '开启耗时统计', ...
		'Unit', 'pixels', ...
		'Position', [gap,panelHeightRightUp-itemHeight*2-gapLarge-gapSmall,500,itemHeight] ...
	);

	btnCalc = uicontrol(...
		'Parent', panelRightUp, ...
		'Style', 'pushbutton', ...
		'String', '仅计算', ...
		'Callback', @btnCalcCallback, ...
		'Unit', 'pixels', ...
		'Position', [gap,panelHeightRightUp-itemHeight*2-gapLarge-gapSmall*2-itemHeightLarge,itemWidth,itemHeightLarge] ...
	);

	btnPlot = uicontrol(...
		'Parent', panelRightUp, ...
		'Style', 'pushbutton', ...
		'String', '仅绘图', ...
		'Callback', @btnPlotCallback, ...
		'Unit', 'pixels', ...
		'Position', [gap,panelHeightRightUp-itemHeight*2-gapLarge-gapSmall*3-itemHeightLarge*2,itemWidth,itemHeightLarge] ...
	);

	btnRun = uicontrol(...
		'Parent',panelRightUp, ...
		'Style','pushbutton', ...
		'String','计算并绘图', ...
		'Callback',@btnRunCallback, ...
		'Unit','pixels', ...
		'Position',[gap,panelHeightRightUp-itemHeight*2-gapLarge-gapSmall*4-itemHeightLarge*3,itemWidth,itemHeightLarge] ...
	);

	textWidth = 70;
	textIter = uicontrol(...
		'Parent',panelRightDown, ...
		'Style','text', ...
		'HorizontalAlignment','left', ...
		'String','迭代次数：', ...
		'Unit','pixels', ...
		'Position',[gap,panelHeightRightDown-itemHeight-gapLarge-6,textWidth,itemHeight] ...
	);

	popupIter = uicontrol(...
		'Parent',panelRightDown, ...
		'Style','popupmenu', ...
		'String',sprintf('1\n2\n3\n4\n5\n6\n7\n8\n9\n10'), ...
		'Value', 4, ...
		'Unit','pixels', ...
		'Position',[gap+textWidth,panelHeightRightDown-itemHeight-gapLarge,50,itemHeight] ...
	);

	btnInverse = uicontrol(...
		'Parent',panelRightDown, ...
		'Style','pushbutton', ...
		'String','反演', ...
		'Callback',@btnInverseCallback, ...
		'Unit','pixels', ...
		'Position',[gap,panelHeightRightDown-itemHeight-itemHeightLarge-gapLarge-gapSmall,itemWidth,itemHeightLarge] ...
	);


	setFontSize({panelSelectFolder,editSelectFolder,btnSelectFolder,checkboxOde,checkboxTimer,textIter,popupIter},9);
	setFontSize({panelLeftUp,panelLeftDown,panelRightUp,panelRightDown,btnAssistant,btnCalc,btnPlot,btnRun,btnInverse},10);

	function setFontSize(handles, fontSize)
		for ii = 1:length(handles)
			set(handles{ii},'FontName','Microsoft YaHei','FontSize',fontSize);
		end
	end


	pathIn = '';
	if exist('history_gui.mat','file')
	    load('history_gui.mat',pathIn);
	end
	set(editSelectFolder,'String',pathIn);

	%% callbacks
	% 选择输入文件所在目录按钮
	function btnSelectFolderCallback(hObject, eventdata, handles)
	% hObject    handle to btnSelectFolder (see GCBO)
	% eventdata  reserved - to be defined in a future version of MATLAB
	% handles    structure with handles and user data (see GUIDATA)
		startPath = './';
		if pathIn, startPath = pathIn; end
		pathIn = uigetdir(startPath,'选择输入文件所在目录');

		% 如果用户未选择目录而直接取消对话框
		if ~pathIn
			pathIn = get(editSelectFolder,'String');
			if ~pathIn
				errordlg('请选择输入文件目录','输入错误');
				return;
			end
		else
			set(editSelectFolder,'String',pathIn);
			if exist('history_gui.mat','file')
				save('history_gui.mat','pathIn','-append');
			else
				save('history_gui.mat','pathIn');
			end
		end
	end

	% 启动预处理工具箱
	function btnAssistantCallback(hObject,eventdata,handles)
		assistant_gui();
	end

	% 运行按钮
	function btnRunCallback(hObject,eventdata,handles)
		params.pathIn = '';
		params.isUseOde = false;

		pathIn = get(editSelectFolder,'String');
		if isempty(pathIn)
			errordlg('请选择输入文件目录','输入错误');
			return;
		end
		params.pathIn = pathIn;

		isUseOde = get(checkboxOde,'Value');
		params.isUseOde = isUseOde;

		isTimeCounting = get(checkboxTimer,'Value');

		fprintf('开始计算……\n');
		fprintf('· 输入文件所在目录：%s\n',params.pathIn);
		fprintf('· 使用 Matlab ODE 工具箱：');
		if params.isUseOde, fprintf('是\n'); else fprintf('否\n'); end
		fprintf('· 开启耗时统计：');
		if isTimeCounting, fprintf('是\n'); else fprintf('否\n'); end
		fprintf('\n');

		if isTimeCounting
		    profile on; main(params); profile off; profile viewer;
		else
			main(params);
		end
	end

	% 反演按钮
	function btnInverseCallback(hObject,eventdata,handles)
		iteration = get(popupIter,'Value');
		fun_inverse(pathIn,iteration);
	end

end
