% ��ջ���
clc
clear
close all
t0 = datestr(now,31);
% ��Ӻ�������
add_func_path();
% ���ø�Ŀ¼����ȡICA.SET�ļ�·��
rootdir = 'G:\�ضȴ̼����Ե�20S\401,434,504,510';
icaset_path_list = find_icaset(rootdir);
% ���ñ����ļ������ļ���������رճ���
savefile_name = 'icaout-6-8s.xlsx';
savefile_path = [rootdir filesep savefile_name];
if exist(savefile_path,'file')
    disp([savefile_path '�Ѵ��ڣ�����رգ�'])
else
    % ��ʾ��ʼʱ�䡢��Ŀ¼����������ica�ļ�
    disp('______________Start________________')
    disp(['startTime:' t0])
    disp(['rootdir:' rootdir])
    for i = 1 : length(icaset_path_list)
        disp(['[' num2str(i) '/' num2str(length(icaset_path_list)) '] ' ...
            icaset_path_list{i}])
    end
    disp('_______________Run_________________')
    % ѭ�������ICA�ļ�
    for i = 1 : length(icaset_path_list)
        t1 = datestr(now,31);
        disp(['[' num2str(i) '/' num2str(length(icaset_path_list)) ']'])
        filename = strsplit(icaset_path_list{i},'\');
        folderpath = fullfile(filename{1:end - 1});
        filename = filename{end};
        disp(['folderpath:' folderpath])
        disp(['filename:' filename])
        
        EEG = pop_loadset('filename',filename,'filepath',folderpath);
        EEG = eeg_checkset( EEG );
        data = EEG.data;
        nbchan = EEG.nbchan;
        
        % ��ǰ��������ʱ���ݵı���
        channel = single(zeros(nbchan, 2000));
        app = zeros(1,nbchan);
        lzc = zeros(1,nbchan);
        c0 = zeros(1,nbchan);
        SampEn = zeros(1,nbchan);
        PmEn = zeros(1,nbchan);
        % ѭ��������������ݵĶ���ָ��
        for n = 1:1:nbchan
            %���ô����ʱ��Σ���λ ms
            channel(n,:)=data(n,6001:8000);
            x = channel(n,:)';
            %���������
            app(n) = CalcTimeSeriesApproximateEntropy( x );
            %���㸴�Ӷ�
            lzc(n) = CalcTimeSeriesLempelZivComplexity( x );
            c0(n) = CalcTimeSeriesC0Complexity( x );
            %����������
            SampEn(n) = CalcTimeSeriesSampleEntropy( x );
            %����������
            PmEn(n) = CalcTimeSeriesPermutationEntropy( x );
        end
        
        Data=zeros(5,nbchan);
        %���㡮C0'������);
        Data(1,:)=app;
        Data(2,:)=c0;
        Data(3,:)=lzc;
        Data(4,:)=PmEn;
        Data(5,:)=SampEn;
        
        entropy1= Data;
        
        entropy_average = entropy1;
        
        entropy_average_hang = mean(entropy_average,2);
        
        entropy1 = [entropy_average entropy_average_hang];
        % �������������
        name_y = {'app','c0','lzc','PmEn','SampEn'};
        % ���������������Զ���ȡ������Ϊ��������
        name_x = {EEG.chanlocs.labels,'average'};
        
        T = table;
        T.id = ['[' num2str(i) '/' num2str(length(icaset_path_list)) ']'];
        T.folderpath = folderpath;
        T.filename = filename;
        write_start = ['A',num2str(1 + (i - 1) * 8)];
        writetable(T,savefile_path,'Sheet',1,'Range',write_start);
        
        T = table;
        for n = 1:1:nbchan + 1
            T.(name_x{n}) = entropy1(:,n);
        end
        T.Properties.RowNames = name_y;
        
        write_start = ['A',num2str(3 + (i - 1) * 8)];
        writetable(T,savefile_path,'Sheet',1,'Range',write_start,...
            'WriteRowNames',true);
        
        t2 = datestr(now,31);
        disp(['SUCCESS: ' datestr(datenum(t2) - datenum(t1),'HH:MM:SS')]) 
    end
    disp('_______________END_________________')
    disp(['totalTime:' datestr(datenum(t2) - datenum(t0),'HH:MM:SS')])
end