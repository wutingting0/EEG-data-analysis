clc
clear all
%% ≤Œ ˝…Ë÷√
dataset_filename = 'filter_0.5_80.set';
dataset_filepath = 'D:\\xiangshu\\9-15-9.18\\9-15-182\\398\\3\\';
rejdataset_filepath = ['E:\\xll' filesep '3983' 'rej.set'];
%%
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename',dataset_filename,'filepath',dataset_filepath);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
% EEG = eeg_eegrej( EEG, [61899 63001] );
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew','','gui','off'); 
while ~exist(rejdataset_filepath,'file')
end
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG, 'time',[15 45] );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
eeglab redraw;
