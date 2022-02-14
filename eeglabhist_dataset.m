% EEGLAB history file generated on the 27-Sep-2020
% ------------------------------------------------

EEG.etc.eeglabvers = '2019.0'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
EEG = pop_select( EEG, 'nochannel',{'Oz' 'O1' 'O2' 'ECG' 'HEOR' 'HEOL' 'VEOU' 'VEOL'});
EEG = pop_loadset('filename','raw56dao.set','filepath','D:\\xiangshu\\9-15-9.18\\9-15-182\\398\\');
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG, 'time',[49 112] );
EEG= pop_basicfilter( EEG,1:56 , 'Boundary', 'boundary', 'Cutoff',50, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',180, 'RemoveDC', 'on' );% Script: 21-Sep-2020 13:36:32
EEG= pop_basicfilter( EEG,1:56 , 'Boundary', 'boundary', 'Cutoff',0.5, 'Design', 'butter', 'Filter', 'highpass', 'Order',2, 'RemoveDC', 'on' );% Script: 21-Sep-2020 13:36:32
EEG= pop_basicfilter( EEG,1:56 , 'Boundary', 'boundary', 'Cutoff',80, 'Design', 'fir', 'Filter', 'lowpass', 'Order',36 );% Script: 21-Sep-2020 13:36:33
EEG = pop_loadset('filename','filter_0.5_80.set','filepath','D:\\xiangshu\\9-15-9.18\\9-15-182\\398\\2\\');
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
EEG = eeg_checkset( EEG );
EEG = eeg_eegrej( EEG, [5 740;62322 63001]);
pop_eegplot( EEG, 1, 1, 1);
EEG = pop_select( EEG, 'time',[25 55] );
EEG = eeg_checkset( EEG );
EEG=pop_chanedit(EEG, 'lookup','E:\\MATLAB\\toolbox\\eeglab2019_0\\plugins\\dipfit\\standard_BESA\\standard-10-5-cap385.elp');
EEG = eeg_checkset( EEG );
EEG = eeg_checkset( EEG );
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
EEG = eeg_checkset( EEG );
pop_selectcomps(EEG, [1:56] );
