function [OBS,SCS,phasecollection,phaseIDused,phasegroup,timegroup]=fun_create_by_tx_in(filein,phaseIDused)

%--- OBS
% "OBS" is a 1xn structure array to store OBS information, each OBS (source in tx.in file) is a element of "OBS"
% header(structure field) name list
% name: source name, like 'obs33a'; string
% XYZ: UTM coordinates, depth and scale to meters; [1x4]
% LatLon: latitude and longitude in degree; [1x2]
% moffset: OBS location (offset) in the model in km; scalar
% phase: a cell, each element is a picked event, which is stored in n-by- matrix format, the columns are (the first 4 are identical to tx.in sequence)
%        (1-4) receiver model offset, travel time, uncertainty, new difined travel time group (a normal non-zero integer), (5) the original group number in tx.in, 
%        (6) travel direction in the model (-1 for left, 1 for right), (7) model layer number of the phase, 
%        (8) ray code (1 refraction, 2 reflection, 3 head wave), (9) wave type (1 P-wave, 2 PS-wave),
%        (10) shot number of picking, (11) original pick time, (12) time correction to make tx.in
% phaseID: a 2-by-phase number integer matrix; row 1 are between 100-999, generated by order for both OBS and SCS when the unique phase made and stored in phasecollection; 
%          when a correponding phase deleted, the ID also be cleared and will not use again. Row 2 are normally between 1-99, no-repeat for the model to identify time group for the
%          same layer and same ray code
% phasefile: 1-by-phase number strings, record the source file when the phase data were imported
% remarks: 1-by-phase number strings, for simple explanation words
% offsettable: shot number vs. model offset table, a n-by- matrix, columns are (1) shot number, (2) model offset in km
% tablefile: The corresponding source file of offsettable, a string, each OBS has its own table; the source txt file may have information to indicate itself is a OBS,  
%            that is the first line can be -moffset and moffset, then following the shot number and model offset pairs.
% OBS=struct('name',{},'XYZ',{},'LatLon',{},'moffset',{},'phase',{},'phaseID',{},'phasefile',{},'remarks',{},'offsettable',{},'tablefile',{});
OBS=struct('name','','XYZ',NaN(1,4),'LatLon',NaN(1,2),'moffset',NaN,'phase',{},'phaseID',{},'phasefile',{},'remarks',{},'offsettable',{},'tablefile','');


%--- SCS
% "SCS" is also a 1xn structure array, each survey is a element
% name: different than OBS, here is survey name, like 'scsLine4a'; string
% shot_rec: shot receiver offset, refer to tablefile
% phase: a cell, each element is a picked event, which is stored in n-by- matrix format, the columns are (the first 4 are identical to tx.in sequence)
%        (1-4) receiver model offset, travel time, uncertainty, new difined travel time group (a normal non-zero integer), (5) the original group number in tx.in, 
%        (6) travel direction in the model (-1 for left, 1 for right), (7) model layer number of the phase, 
%        (8) ray code (1 refraction, 2 reflection, 3 head wave), (9) wave type (1 P-wave, 2 PS-wave),
%        (10) shot number of picking, (11) original pick time, (12) time correction to make tx.in
% phaseID: a 2-by-phase number integer matrix; row 1 are between 100-999, generated by order for both OBS and SCS when the unique phase made and stored in phasecollection; 
%          when a correponding phase deleted, the ID also be cleared and will not use again. Row 2 are normally between 1-99, no-repeat for the model to identify time group for the
%          same layer and same ray code
% phasefile: 1-by-phase number strings, record the source file when the phase data were imported
% remarks: 1-by-phase number strings, for simple explanation words
% offsettable: shot number vs. model offset table, a n-by- matrix, columns are (1) shot number, (2) model offset in km
% tablefile: The corresponding source file of offsettable, a string, not like OBS, here each survey has a table; the source txt file may have information 
%          to indicate itself is a SCS survey, that is the first line is 2 identical negative value, the offset of receiver behind the shot; or -999 and 0 for
%          ideal vertical incidence
% SCS=struct('name',{},'shot_rec',{},'phase',{},'phaseID',{},'phasefile',{},'remarks',{},'offsettable',{},'tablefile',{});
SCS=struct('name','','shot_rec',NaN,'phase',{},'phaseID',{},'phasefile',{},'remarks',{},'offsettable',{},'tablefile','');


%--- phase group
% "phasegroup" is a 1xn structure array, used to store phases selected to plot travel time and output tx.in file
% name: user defined name for each group
% OBS: a 6-by-phase number matrix, the rows are (1) phase ID, (2) time group, (3) OBS#, (4) OBS#.moffset, (5) phase number in OBS#, (6) direction: left -1, right 1, both 2
% SCS: a 5-by-phase number matrix, the rows are (1) phase ID, (2) time group, (3) SCS#, (4) shot_rec offset, (5) phase number in SCS#
phasegroup=struct('name',{},'OBS',{},'SCS',{});

phasecollection=[]; % a unique integer vector (between 100-999) store all phases' ID, including OBS and SCS
% phaseIDused=99; % increase 1 each time a new phase produced, but will not decrease
timegroup={}; % hold the 1-by-n vetors of phaseID; each phaseID can only be in one vetor; the phases in one time group share the same layer and ray code and wave type

phasecolnumber=12; % column length of the phase matrix defined for OBS and SCS

imdata=importdata(filein);
sourceline=find(imdata(:,4)==0);
% find out obs and single channel part
obssource=[];
scssource=[];
for i=1:length(sourceline);
    if i==length(sourceline);
        if sourceline(i)+2==length(imdata(:,4));
            scssource=[scssource; sourceline(i)];
        else
            obssource=[obssource; sourceline(i)];
        end
    else
        if sourceline(i)+2==sourceline(i+1);
            scssource=[scssource; sourceline(i)];
        else
            obssource=[obssource; sourceline(i)];
        end
    end
end
timegroupcount=0;
timegroup_relation=[];
phasegroupcurrent=length(phasegroup)+1;
phasegroup(phasegroupcurrent).name=num2str(phasegroupcurrent);
        
% handle scs part
sourcedata=imdata(scssource,:);
phasedata=imdata(scssource+1,:);
count=0;
while ~isempty(phasedata);
    count=count+1;
    phase=phasedata(1,4);
    phaseIDused=phaseIDused+1;
    phasecollection=[phasecollection;phaseIDused];
    timegroupcount=timegroupcount+1;
    timegroup{timegroupcount}=phaseIDused;
    timegroup_relation=[timegroup_relation phase];
    index=find(phasedata(:,4)==phase);
    data=NaN(length(index),phasecolnumber);
    data(:,[1:3 5])=phasedata(index,:);
    data(:,4)=timegroupcount;
    data(:,6)=sourcedata(index,2);
    SCS(1).phase{count}=data;
    SCS(1).phaseID(:,count)=[phaseIDused;timegroupcount];
    SCS(1).phasefile{count}=filein; % set phasefile field
    phasegroup(phasegroupcurrent).name=num2str(phasegroupcurrent);
    phasegroup(phasegroupcurrent).SCS=[phasegroup(phasegroupcurrent).SCS [phaseIDused timegroupcount 1 NaN count]']; 
    phasedata(index,:)=[];
    sourcedata(index,:)=[];
end
% handel obs part
% get source list
obssourceoffset=imdata(obssource(1),1);
for i=2:length(obssource);
    if isempty(find(obssourceoffset==imdata(obssource(i),1)));
        obssourceoffset=[obssourceoffset; imdata(obssource(i),1)];
    end
end
% phase part
obsdata=imdata(1:end-1,:);
obsdata([scssource; scssource+1],:)=[];
sourceline=find(obsdata(:,4)==0);
obsdata=[obsdata NaN(length(obsdata(:,1)),phasecolnumber-4)];
for i=1:length(sourceline);
    if i==length(sourceline);
        obsdata(sourceline(i)+1:end,5)=obsdata(sourceline(i),1);
        obsdata(sourceline(i)+1:end,6)=obsdata(sourceline(i),2);
    else
        obsdata(sourceline(i)+1:sourceline(i+1)-1,5)=obsdata(sourceline(i),1);
        obsdata(sourceline(i)+1:sourceline(i+1)-1,6)=obsdata(sourceline(i),2);
    end
end
for i=1:length(obssourceoffset);
    OBS(i).name=num2str(i);
    OBS(i).moffset=obssourceoffset(i);
    phasedata=obsdata(obsdata(:,5)==obssourceoffset(i),:);
    count=0;
    while ~isempty(phasedata);
        fistrun=false;
        count=count+1;
        phase=phasedata(1,4);
        phaseIDused=phaseIDused+1;
        phasecollection=[phasecollection;phaseIDused];
        if timegroupcount==0; % no SCS data
            timegroupcount=timegroupcount+1;
            timegroup{timegroupcount}=phaseIDused;
            timegroup_relation=[timegroup_relation phase];
            timegroupid=timegroupcount;
        else
            index=find(timegroup_relation==phase);
            if isempty(index)
                timegroupcount=timegroupcount+1;
                timegroup{timegroupcount}=phaseIDused;
                timegroup_relation=[timegroup_relation phase];
                timegroupid=timegroupcount;
            else
                timegroup{index}=[timegroup{index} phaseIDused];
                timegroupid=index;
            end
        end
        index=find(phasedata(:,4)==phase);
        OBS(i).phase{count}=phasedata(index,:);
        OBS(i).phase{count}(:,5)=OBS(i).phase{count}(:,4);
        OBS(i).phase{count}(:,4)=timegroupid;
        OBS(i).phaseID(:,count)=[phaseIDused;timegroupid];
        OBS(i).phasefile{count}=filein; % set phasefile field
        phasedata(index,:)=[];
        phasegroup(phasegroupcurrent).OBS=[phasegroup(phasegroupcurrent).OBS [phaseIDused timegroupid i OBS(i).moffset count 2]'];
    end
end


end