function [OBS,SCS,prepath]=fun_import_offset_table(OBS,SCS,prepath,tag,obspop1,scspop1)

% *******************************
% Variables for whole function
% *******************************
%--- OBS
% "OBS" is a 1xn structure array to store OBS information, each OBS (source in tx.in file) is a element of "OBS"
% header(structure field) name list
% name: source name, like 'obs33a'; string
% XYZ: UTM coordinates, depth and scale to meters; [1x4]
% LatLon: latitude and longitude in degree; [1x2]
% moffset: OBS location (offset) in the model in km; scalar
% phase: a cell, each element is a picked event, which is stored in n-by- matrix format, the columns are (the first 4 are identical to tx.in sequence)
%        (1-4) receiver model offset, travel time, uncertainty, phase number (a normal non-zero integer), (5) source model offset, 
%        (6) travel direction in the model (-1 for left, 1 for right), (7) model layer number of the phase, 
%        (8) ray code (1 refraction, 2 reflection, 3 head wave), (9) wave type (1 P-wave, 2 PS-wave),
%        (10) shot number of picking, (11) original pick time, (12) time correction to make tx.in
% phaseID: a 1-by-phase number integer (between 100-999) matrix, generated by order for both OBS and SCS when the unique phase made and stored in phasecollection; 
%          when a correponding phase deleted, the ID also be cleared and will not use again.
% phasefile: 1-by-phase number strings, record the source file when the phase data were imported
% remarks: 1-by-phase number strings, for simple explanation words
% offsettable: shot number vs. model offset table, a n-by- matrix, columns are (1) shot number, (2) model offset in km
% tablefile: The corresponding source file of offsettable, a string, each OBS has its own table; the source txt file may have information to indicate itself is a OBS,  
%            that is the first line can be -moffset and moffset, then following the shot number and model offset pairs.
% OBS=struct('name',{},'XYZ',{},'LatLon',{},'moffset',{},'phase',{},'phaseID',{},'phasefile',{},'remarks',{},'offsettable',{},'tablefile',{});

%--- SCS
% "SCS" is also a 1xn structure array, each survey is a element
% name: different than OBS, here is survey name, like 'scsLine4a'; string
% shot_rec: shot receiver offset, refer to tablefile
% phase: a cell, each element is a picked event, which is stored in n-by- matrix format, the columns are (the first 4 are identical to tx.in sequence)
%        (1-4) receiver model offset, travel time, uncertainty, phase number (a normal non-zero integer), (5) source model offset, 
%        (6) travel direction in the model (-1 for left, 1 for right), (7) model layer number of the phase, 
%        (8) ray code (1 refraction, 2 reflection, 3 head wave), (9) wave type (1 P-wave, 2 PS-wave),
%        (10) shot number of picking, (11) original pick time, (12) time correction to make tx.in
% phaseID: a 1-by-phase number integer (between 100-999) matrix, generated by order for both OBS and SCS when the unique phase made and stored in phasecollection; 
%          when a correponding phase deleted, the ID also be cleared and will not use again.
% phasefile: 1-by-phase number strings, record the source file when the phase data were imported
% remarks: 1-by-phase number strings, for simple explanation words
% offsettable: shot number vs. model offset table, a n-by- matrix, columns are (1) shot number, (2) model offset in km
% tablefile: The corresponding source file of offsettable, a string, not like OBS, here each survey has a table; the source txt file may have information 
%          to indicate itself is a SCS survey, that is the first line is 2 identical negative value, the offset of receiver behind the shot; or -999 and 0 for
%          ideal vertical incidence
% SCS=struct('name',{},'shot_rec',{},'phase',{},'phaseID',{},'phasefile',{},'remarks',{},'offsettable',{},'tablefile',{});

options.Interpreter = 'tex';
options.Default = 'Cancel';
switch tag
    case 'SCS';  % import SINGLE file to current SCS survey
        [filename,pathname] = uigetfile([prepath,'*.*']);
        while isscalar(filename);
            qstring = {'\bf\fontsize{12}\color{red}You didn''t pick any file! Try again or cancel?'};
            choice = questdlg(qstring,'','Try again','Cancel',options);
            switch choice,
                case 'Try again'
                case 'Cancel'
                    return
            end
            [filename,pathname] = uigetfile([prepath,'*.*']);
        end
        fullname=fullfile(pathname,filename);
        data=importdata(fullname);
        if size(SCS,2)==0;
            scsnumber=1;
        else
            scsnumber=get(scspop1,'Value');
        end
        if data(1,1)==-999 && data(1,2)==0;
            SCS(scsnumber).shot_rec=0;
            SCS(scsnumber).offsettable=data(2:end,:);
        elseif data(1,1)==data(1,2) && data(1,1)<0 && data(1,2)<0;
            SCS(scsnumber).shot_rec=data(1,1);
            SCS(scsnumber).offsettable=data(2:end,:);
        else
            SCS(scsnumber).offsettable=data;
        end
        SCS(scsnumber).tablefile=fullname;
    case 'OBS'   % import one or more files into OBS
        [filename,pathname] = uigetfile([prepath,'*.*'],'Select multiple files by holding down the Shift or Ctrl key and clicking on file names','MultiSelect','on');
        while isscalar(filename);
            qstring = {'\bf\fontsize{12}\color{red}You didn''t pick any file! Try again or cancel?'};
            choice = questdlg(qstring,'','Try again','Cancel',options);
            switch choice,
                case 'Try again'
                case 'Cancel'
                    return
            end
            [filename,pathname] = uigetfile([prepath,'*.*'],'Select multiple files by holding down the Shift or Ctrl key and clicking on file names','MultiSelect','on');
        end
        if ~iscell(filename);
            filename={filename};
        end
        filenumber=length(filename);
        offsettable=cell(1,filenumber);
        offsetsourcefile=cell(filenumber,1);
        source=NaN(1,filenumber);
        relation=zeros(1,filenumber);
        relationstring=cell(1,filenumber);
        newname=cell(1,filenumber);
        import=cell(1,filenumber);
        obsname=cell(1,filenumber);
        for i=1:size(OBS,2);
            moffset(i)=OBS(i).moffset;
        end
        for i=1:filenumber;
            import{i}=false;
            relationstring{i}='';
            obsname{i}='';
            newname{i}=false;
            fullname=fullfile(pathname,filename{i});
            offsetsourcefile{i}=fullname;
            data=importdata(fullname);
            if abs(data(1,1))==abs(data(1,2)) && data(1,1)<=0 && data(1,2)>=0;
                source(i)=abs(data(1,1));
                offsettable{i}=data(2:end,:);
                position=find(moffset==source(i));
                if ~isempty(position);
                    position=position(1);
                    relation(i)=position;
                    relationstring{i}=num2str(moffset(position));
                    import{i}=true;
                    if isempty(OBS(position).name);
                        newname{i}=true;
                    else
                        obsname{i}=OBS(position).name;
                    end
                end
            else
                offsettable{i}=data;
            end
        end
        t=[filename; num2cell(source); import; relationstring; obsname; filename; newname]';  % cellstr(num2str(moffset'))'
        columnname =   {'Source file', 'Distance', 'Import', 'Exist OBS','Exist name','Create new name','Yes'};
        columnformat = {'char', 'numeric', 'logical',cellstr(num2str(moffset'))','char', 'char','logical'};
        columneditable =  [false false true true false true true];
        h=figure('Visible','off','NumberTitle','off','Name','File Associate','MenuBar','none','Position',[300,300,1000,450]);
        ph=uipanel(h,'Visible','off','Position',[.0 .2 1 0.8]);
        th=uitable(ph,'Units','normalized','Position',[.0 .0 1 1],'Data',t,'ColumnName',columnname,'ColumnFormat',columnformat,...
            'ColumnWidth',{250 100 'auto' 100 100 250 'auto'},'ColumnEditable',columneditable,'FontSize',12);
        pbh1 = uicontrol(h,'Style','pushbutton','String','Confirm','Tag','import','Position',[200 30 160 40],'Callback',@pbh1_callback);
        pbh2 = uicontrol(h,'Style','pushbutton','String','Cancel','Position',[460 30 160 40],'Callback',@pbh2_callback);
        set(h,'CloseRequestFcn',@pbh2_callback)
        % make the window visable
        set(ph,'Visible','on');
        set(h,'Visible','on');
        uiwait(h);  % very important to use this, so you can have chance to interactive with uitable and then continue; otherwise, the function will return before your action
    case 'create'   % initialize the database, MultiSelect mode
        [filename,pathname] = uigetfile([prepath,'*.*'],'Select multiple files by holding down the Shift or Ctrl key and clicking on file names','MultiSelect','on');
        while isscalar(filename);
            qstring = {'\bf\fontsize{12}\color{red}You didn''t pick any file! Try again or cancel?'};
            choice = questdlg(qstring,'','Try again','Cancel',options);
            switch choice,
                case 'Try again'
                case 'Cancel'
                    return
            end
            [filename,pathname] = uigetfile([prepath,'*.*'],'Select multiple files by holding down the Shift or Ctrl key and clicking on file names','MultiSelect','on');
        end
        if ~iscell(filename);
            filename={filename};
        end
        filenumber=length(filename);
        offsettable=cell(1,filenumber);
        offsetsourcefile=cell(filenumber,1);
        source=NaN(1,filenumber);
        type=ones(1,filenumber);  % assume all are OBS
        typestring=cell(1,filenumber);
        newname=cell(1,filenumber);
        import=cell(1,filenumber);
        for i=1:filenumber;
            import{i}=true;
            typestring{i}='OBS';
            newname{i}=true;
            fullname=fullfile(pathname,filename{i});
            offsetsourcefile{i}=fullname;
            data=importdata(fullname);
            if data(1,1)==-999 && data(1,2)==0;
                source(i)=0;
                offsettable{i}=data(2:end,:);
                type(i)=0;
                typestring{i}='SCS';
            elseif data(1,1)==data(1,2) && data(1,1)<0 && data(1,2)<0;
                source(i)=data(1,1);
                offsettable{i}=data(2:end,:);
                typestring{i}='SCS';
                type(i)=0;
            elseif abs(data(1,1))==abs(data(1,2)) && data(1,1)<=0 && data(1,2)>=0;
                source(i)=abs(data(1,1));
                offsettable{i}=data(2:end,:);
            else
                offsettable{i}=data;
            end
        end
        t=[filename; num2cell(source); import; typestring; filename; newname]';  % cellstr(num2str(moffset'))'
        columnname =   {'Source file', 'Distance', 'Import', 'OBS/SCS','Create new name','Yes'};
        columnformat = {'char', 'numeric', 'logical',{'OBS' 'SCS'},'char', 'logical'};
        columneditable =  [false false true true true true];
        h=figure('Visible','off','NumberTitle','off','Name','File Associate','MenuBar','none','Position',[100,200,1000,450]);
        ph=uipanel(h,'Visible','off','Position',[.0 .2 1 0.8]);
        th=uitable(ph,'Units','normalized','Position',[.0 .0 1 1],'Data',t,'ColumnName',columnname,'ColumnFormat',columnformat,...
            'ColumnWidth',{300 100 'auto' 100 300 'auto'},'ColumnEditable',columneditable,'FontSize',12);
        pbh1 = uicontrol(h,'Style','pushbutton','String','Confirm','Tag','create','Position',[200 30 160 40],'Callback',@pbh1_callback);
        pbh2 = uicontrol(h,'Style','pushbutton','String','Cancel','Position',[460 30 160 40],'Callback',@pbh2_callback);
        set(h,'CloseRequestFcn',@pbh2_callback)
        % make the window visable
        set(ph,'Visible','on');
        set(h,'Visible','on');
        uiwait(h);  % very important to use this, so you can have chance to interactive with uitable and then continue; otherwise, the function will return before your action
    
end



%----- Callback Functions ------%
    function pbh1_callback(hObject, eventdata)
        aa=get(th,'Data');
        switch get(hObject,'Tag');
            case 'import'
                for ii=1:size(aa,1);  % length(filename)
                    if aa{ii,3};   % import is true
                        if relation(ii)>0;  % merge into exist OBS
                            OBS(relation(ii)).offsettable=offsettable{ii};
                            OBS(relation(ii)).tablefile=offsetsourcefile{ii};
                            if aa{ii,end}; % make new OBS name
                                OBS(relation(ii)).name=aa{ii,end-1};
                            end
                        else   % create new OBS
                            OBS(end+1).moffset=source(ii);
                            OBS(end).offsettable=offsettable{ii};
                            OBS(end).tablefile=offsetsourcefile{ii};
                            if aa{ii,end}; % make new OBS name
                                OBS(end).name=aa{ii,end-1};
                            end
                        end
                    end
                end
            case 'create'
                obscount=0;
                scscount=0;
                for ii=1:size(aa,1);  % length(filename)
                    if aa{ii,3};   % import is true
                        switch aa{ii,4}
                            case 'OBS'
                                obscount=obscount+1;
                                OBS(obscount).moffset=source(ii);
                                OBS(obscount).offsettable=offsettable{ii};
                                OBS(obscount).tablefile=offsetsourcefile{ii};
                                if aa{ii,end}; % make new OBS name
                                    OBS(obscount).name=aa{ii,end-1};
                                end
                            case 'SCS'
                                scscount=scscount+1;
                                SCS(scscount).shot_rec=source(ii);
                                SCS(scscount).offsettable=offsettable{ii};
                                SCS(scscount).tablefile=offsetsourcefile{ii};
                                if aa{ii,end}; % make new SCS name
                                    SCS(scscount).name=aa{ii,end-1};
                                end
                        end
                    end
                end
        end
        prepath=pathname;
        delete(h);
    end

    function pbh2_callback(hObject, eventdata)
        selection = questdlg('Do you want to exit ?',...
            'Close Request Function',...
            'Yes','No','Yes');
        switch selection,
            case 'Yes',
                delete(h)
            case 'No'
        end
    end

end % end the function

        