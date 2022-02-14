clc
clear;
% close all;

tic
%%
Path = 'G:\xiangshu\442-451\422-424';
dname = uigetdir(Path);
timelist = dir(dname);
timename = {timelist.name};
timename = timename(3:end);
TimeNum = length(timename);
for time = 1:TimeNum
    subpath = [dname filesep timename{time}];
    sublist = dir(subpath);
    dirlist = [sublist.isdir];
    sublist = sublist(dirlist);
    subname = {sublist.name};
    subname = subname(3:end);
    SubNum = length(subname);
    
    
    for sub = 1:SubNum
        EEG = pop_loadset('filename','raw.set','filepath',[subpath filesep subname{sub}]);
        EEG = eeg_checkset( EEG );
        EEG  = pop_basicfilter( EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff',  50, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',  180, 'RemoveDC', 'on' );
        EEG = eeg_checkset( EEG );
        EEG  = pop_basicfilter( EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff',  0.5, 'Design', 'butter', 'Filter', 'highpass', 'Order',  2, 'RemoveDC', 'on' );
        EEG = eeg_checkset( EEG );
        EEG  = pop_basicfilter( EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff',  80, 'Design', 'fir', 'Filter', 'lowpass', 'Order',  36 );
        EEG = eeg_checkset( EEG );
        
        EEG = pop_saveset( EEG, 'filename','filter_0.5_80.set','filepath',[subpath filesep subname{sub}]);
    end
end

%%
toc
