% Programmatically create longitudinal MIP and sag-cor-ax nm/ct, nm and ct slides
% Joseph R. Merrill
% Cold Spring Harbor Laboratory
% 2021/06/29
% Update 2026/07/15
%%

cd(userpath);
clear all;

xppt = dir('stefslon-exportToPPTX*');
addpath(genpath(xppt.name));                % add exportToPPTX tool to path

isOpen  = exportToPPTX();
if ~isempty(isOpen)             % if a presentation was already started, close it
    exportToPPTX('close');
end

exportToPPTX('open','long_study_template.pptx');    % open new presentation

studyDir = uigetdir;                 % user selects directory w/ images (produced by VQ script)
[~,studyid] = fileparts(studyDir);
cd(studyDir);

if isfile(['study_refdate.txt'])
    refdate = fileread(['study_refdate.txt']);
   	refdate = datetime(refdate,'InputFormat','uuuuMMdd');
end

D = dir;
D = D(isfolder({D.name}));
D = D(~ismember({D.name},{'.','..'}));
nsubj = numel(D);			% number of subfolders in the study folder, ie the number of subjects
nslides = 0;                % initialize

for j = 1:nsubj         % count through subject folders

	subjD = D(j).name;
	[~,subjid] = fileparts(subjD);	% read subjid from subfolders
	cd(subjD);
	
	if isfile(['refdate.txt'])
		refdate = fileread(['refdate.txt']);
		refdate = datetime(refdate,'InputFormat','uuuuMMdd');
	end
	
	E = dir;
	E = E(isfolder({E.name}));
	E = E(~ismember({E.name},{'.','..'}));
	ndates = numel(E);			% number of subfolders in the study folder, ie the number of imaging dates
	
    if ndates > 4               % choose a ppt template based on number of longitudinal scans
        miptemplate = num2str(ndates);
        miptemplate = strcat(miptemplate,'mips');
    else
        miptemplate = '4mips';
    end
    
    exportToPPTX('addslide','Layout',miptemplate);		% open a slide for the static mips
   	exportToPPTX('addtext',subjid,'Position','subjid');
    exportToPPTX('addslide','Layout',miptemplate);      % open a slide for the dynamic mips
	exportToPPTX('addtext',subjid,'Position','subjid');
	nslides = nslides+2;
	mipslidepos = nslides-1;							% the slide number for this subject's static MIPs
    dynmipslidepos = nslides;                           % the slide number for this subject's dynamic MIPs
	
	itimepoint = 1;					   % index of the current longitudinal timepoint, for arranging MIPs
	
	for k = 1:ndates        % count through date folders
	
		dateD = E(k).name;
		[~,date] = fileparts(dateD);	% read date from subfolders
		cd(dateD);
		
		date = datetime(date,'InputFormat','uuuuMMdd');
		timepoint = caldiff([refdate;date],'days');
		timepoint = split(timepoint,'days');
		if timepoint > 13
			timepointunit = 'Week_';
			timepoint = num2str(timepoint/7,2);	
		else
			timepointunit = 'Day_';
            timepoint = num2str(timepoint);
		end
		timepoint = strcat(timepointunit,timepoint);
		
		F = dir;
		F = F(isfolder({F.name}));
		F = F(~ismember({F.name},{'.','..'}));
		ntimes = numel(F);			% number of subfolders in the study folder, ie the number of imaging timepoints on that day
		
		for l = 1:ntimes        % count through time folders
		
			timeD = F(l).name;
			[~,time] = fileparts(timeD);	% read time from subfolders
			cd(timeD);
		
			exportToPPTX('switchslide',mipslidepos);
		
			G = dir('*.png');
			statmip = imread(G(1).name);
            range = strsplit(G(1).name,{'Range','-MIP'});
            range = range{2};
			%%exportToPPTX('addtext',time,'Position',['time' num2str(itimepoint)]);
            exportToPPTX('addpicture',statmip,'Position',['mip' num2str(itimepoint)]);
            exportToPPTX('addtext',timepoint,'Position',['date' num2str(itimepoint)]);
            if l == 1                                 %only put scale on slide first time
                exportToPPTX('addtext',['SUV ' range],'Position','mipscale');
            end
		
            exportToPPTX('switchslide',dynmipslidepos);

            H = dir('*.gif')';
            dynmip = H(1).name;
            range = strsplit(G(1).name,{'Range','-MIP'});
            range = range{2};
			%%exportToPPTX('addtext',time,'Position',['time' num2str(itimepoint)]);
            exportToPPTX('addpicture',dynmip,'Position',['mip' num2str(itimepoint)]);
            exportToPPTX('addtext',timepoint,'Position',['date' num2str(itimepoint)]);
            if l == 1                                 %only put scale on slide first time
                exportToPPTX('addtext',['SUV ' range],'Position','mipscale');
            end

			nslice = numel(dir('*slices*'))/3;		%number of sets of sag-cor-ax images

			if nslice
			
				for i = 1:nslice

					exportToPPTX('addslide','Layout','sag-cor-ax-text');
					nslides = nslides+1;
					exportToPPTX('addtext',timepoint,'Position','date');
					exportToPPTX('addtext',subjid,'Position','subjid');
					nmctimg = imread([datestr(date,'yyyymmdd') '_' subjid '_slices_nmct_' num2str(i) '.png']);
					exportToPPTX('addpicture',nmctimg,'Position','nmct');
					nmimg = imread([datestr(date,'yyyymmdd') '_' subjid '_slices_nm_' num2str(i) '.png']);
					exportToPPTX('addpicture',nmimg,'Position','nmonly');
					ctimg = imread([datestr(date,'yyyymmdd') '_' subjid '_slices_ct_' num2str(i) '.png']);
					exportToPPTX('addpicture',ctimg,'Position','ctonly');
					if isfile(['notes-' num2str(i) '.txt'])
						notes = fileread(['notes-' num2str(i) '.txt']);
						exportToPPTX('addtext',notes,'Position','notes');
					end

				end
				
			end
		
			itimepoint = itimepoint+1;
			cd('..');
			
        end
		
		cd('..');
		
    end
    
	cd('..');
	
end

newFile = exportToPPTX('save',[studyid '.pptx']);
exportToPPTX('close');
fprintf('dunzo');

cd(userpath);