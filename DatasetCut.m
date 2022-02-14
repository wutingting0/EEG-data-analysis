% ��ջ���
clc
clear
close all
t0 = datestr(now,31);
% ��Ӻ�������
add_func_path();
% ��������
root_dir = 'G:\xiangshu\422-424';
event_num = 14;
% Ĭ�ϱ�����ͨ�������޸�
filename = {'data.bdf','evt.bdf'};
savefile_name = 'raw.set';
% ��ȡ����������Ϣ
tags = readtable([root_dir filesep 'tags.xlsx'],'Range','A1:H65');
tags_name = tags.name;
% ��ȡ���ļ����б�
folder_list = dir(root_dir);
folder_list = folder_list([folder_list.isdir]);
folder_list = folder_list(3:end);
% ��ʾ��ʾ
disp('______________Start________________')
disp(['startTime:' t0])
disp(['rootdir:' root_dir])
for i = 1 : length(folder_list)
    disp(['[' num2str(i) '/' num2str(length(folder_list)) '] folder:' ...
        folder_list(i).name])
end
disp('_______________Run_________________')
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
% ѭ���������ļ���
for i = 1 : length(folder_list)
    t1 = datestr(now,31);
    disp(['[' num2str(i) '/' num2str(length(folder_list)) ']'])
    folder_path = [root_dir filesep folder_list(i).name];
    disp(['folderpath:' folder_path])
    % �ж��Ƿ����'data.bdf','evt.bdf'
    if ~exist([folder_path filesep filename{1}],'file') ...
            || ~exist([folder_path filesep filename{2}],'file')
        fprintf(2,'[err] ');
        disp(['<' [folder_path filesep filename{1}] '> or <' ...
            [folder_path filesep filename{2} '> ������']]);
        fprintf(2,' �������ļ��У�\n');
        continue
    end
    % ��ȡ'data.bdf','evt.bdf'
    EEG = readbdfdata(filename, [folder_path filesep]);
    % ���ݵ��������ļ�ȥ����Ӧ������Ϣ
    EEG = eeg_checkset( EEG );
    [ALLEEG, EEG, ~] = pop_newset(ALLEEG, EEG, 0,'gui','off');
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG, 'nochannel',...
        tags_name(tags.(['F' folder_list(i).name]) == 1)');
    % ����ȥ���������set�ļ�
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1,...
        'savenew',[folder_path filesep num2str(EEG.nbchan) '.set'],...
        'gui','off');
    % �жϸ����ݱ�ǩ���Ƿ������ȷֵ
    event_tmp = EEG.event;
    if size(event_tmp,1) < event_num
        fprintf(2,['[err] ��ǩ��Ϊ<' num2str(size(event_tmp,1)) ...
            '>��С����ȷֵ<' num2str(event_num)  '>���������ļ��У� \n']);
        continue
    end
    % ��ǩȥ��
    event = struct;
    for j = 1 : size(event_tmp,1)
        if j < size(event_tmp,1) && ...
                strcmp(event_tmp(j).type,event_tmp(j + 1).type)
            continue
        end
        if isempty(fieldnames(event))
            event(1).type = event_tmp(j).type;
            event(1).latency = event_tmp(j).latency;
            continue
        end
        event(end + 1).type = event_tmp(j).type;
        event(end).latency = event_tmp(j).latency;
    end
    % ���ݱ�ǩ���鲢�����Ӧset�ļ�
    for j = 1:size(event,2) / 2
        EEG = eeg_checkset( EEG );
        EEG1 = pop_select( EEG, 'time',[...
            (event(2 * j - 1).latency + 1000) / 1000 ...
            (event(2 * j).latency - 1000)/1000] );
        savefile_path = [folder_path filesep num2str(j) '_' ...
            event(2 * j - 1).type '_' event(2 * j).type];
        mkdir(savefile_path)
        pop_saveset(EEG1, savefile_name, savefile_path);
    end
    
    t2 = datestr(now,31);
    disp(['SUCCESS: ' datestr(datenum(t2) - datenum(t1),'HH:MM:SS')])
    disp('___________________________________')
end
disp('_______________END_________________')
disp(['totalTime:' datestr(datenum(t2) - datenum(t0),'HH:MM:SS')])
disp('������ 0��0')
