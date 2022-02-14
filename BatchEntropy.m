% 清空缓存
clc
clear
close all
t0 = datestr(now,31);
% 添加函数依赖
add_func_path();
% 设置根目录，读取ICA.SET文件路径
rootdir = 'G:\重度刺激后脑电20S\401,434,504,510';
icaset_path_list = find_icaset(rootdir);
% 设置保存文件名，文件若存在则关闭程序
savefile_name = 'icaout-6-8s.xlsx';
savefile_path = [rootdir filesep savefile_name];
if exist(savefile_path,'file')
    disp([savefile_path '已存在，程序关闭！'])
else
    % 显示开始时间、根目录、检索到的ica文件
    disp('______________Start________________')
    disp(['startTime:' t0])
    disp(['rootdir:' rootdir])
    for i = 1 : length(icaset_path_list)
        disp(['[' num2str(i) '/' num2str(length(icaset_path_list)) '] ' ...
            icaset_path_list{i}])
    end
    disp('_______________Run_________________')
    % 循环处理各ICA文件
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
        
        % 提前定义存放临时数据的变量
        channel = single(zeros(nbchan, 2000));
        app = zeros(1,nbchan);
        lzc = zeros(1,nbchan);
        c0 = zeros(1,nbchan);
        SampEn = zeros(1,nbchan);
        PmEn = zeros(1,nbchan);
        % 循环计算各导联数据的多项指标
        for n = 1:1:nbchan
            %设置处理的时间段，单位 ms
            channel(n,:)=data(n,6001:8000);
            x = channel(n,:)';
            %计算近似熵
            app(n) = CalcTimeSeriesApproximateEntropy( x );
            %计算复杂度
            lzc(n) = CalcTimeSeriesLempelZivComplexity( x );
            c0(n) = CalcTimeSeriesC0Complexity( x );
            %计算样本熵
            SampEn(n) = CalcTimeSeriesSampleEntropy( x );
            %计算排列熵
            PmEn(n) = CalcTimeSeriesPermutationEntropy( x );
        end
        
        Data=zeros(5,nbchan);
        %计算‘C0'复杂性);
        Data(1,:)=app;
        Data(2,:)=c0;
        Data(3,:)=lzc;
        Data(4,:)=PmEn;
        Data(5,:)=SampEn;
        
        entropy1= Data;
        
        entropy_average = entropy1;
        
        entropy_average_hang = mean(entropy_average,2);
        
        entropy1 = [entropy_average entropy_average_hang];
        % 表纵坐标变量名
        name_y = {'app','c0','lzc','PmEn','SampEn'};
        % 表横坐标变量名，自动获取，这里为各导联名
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