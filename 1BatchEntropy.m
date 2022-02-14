% 清空缓存
clc
clear
close all
t0 = datestr(now,31);
% 添加函数依赖
add_func_path();
% 设置根目录，读取ICA.SET文件路径
rootdir = 'E:\matlab\1software\pretreatment\chen5_210\after';
icaset_path_list = find_icaset(rootdir);
%设置采样率、选取时间
rate = 250;
starttime = [1
11
21
31
41
51
61
71
81
91
101
111
121
131
141
151
161
171
181
191
201
211
221
231
241
251
261
271
281
291
301
311
321
331
341
351
361
371
381
391
401
411
421
431
441
451
461
471
481
491
501
511
521
531
541
551
561
571
581
591
];
endtime =   [7
17
27
37
47
57
67
77
87
97
107
117
127
137
147
157
167
177
187
197
207
217
227
237
247
257
267
277
287
297
307
317
327
337
347
357
367
377
387
397
407
417
427
437
447
457
467
477
487
497
507
517
527
537
547
557
567
577
587
597
];
tlength = length(starttime);
% 设置保存文件名，文件若存在则关闭程序
savefile_name = 'chen5_210_after_entropy.xlsx';
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
        channel = single(zeros(nbchan, (endtime(1)-starttime(1))*rate));
        app = zeros(1,nbchan);
        lzc = zeros(1,nbchan);
        c0 = zeros(1,nbchan);
        SampEn = zeros(1,nbchan);
        PmEn = zeros(1,nbchan);
        app_sum = zeros(1,nbchan);
        lzc_sum = zeros(1,nbchan);
        c0_sum = zeros(1,nbchan);
        SampEn_sum = zeros(1,nbchan);
        PmEn_sum = zeros(1,nbchan);
        % 循环计算各导联数据的多项指标
        for j = 1:1:tlength %循环处理各时间段
            for n = 1:1:nbchan
                start_ = rate*starttime(j)+1;
                end_ = rate*endtime(j);
                channel(n,:)=data(n,start_:end_);
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
                disp(['starttime = ',num2str(starttime(j)),', ','endtime = ',num2str(endtime(j)),', ','channel[',num2str(n),'] done']);
            end
            app_sum = app_sum + app;
            lzc_sum = lzc_sum + lzc;
            c0_sum = c0_sum + c0;
            SampEn_sum = SampEn_sum + SampEn;
            PmEn_sum = PmEn_sum + PmEn;
        end
        
        Data=zeros(5,nbchan);
        %计算‘C0'复杂性);
        Data(1,:)=app_sum/tlength;
        Data(2,:)=c0_sum/tlength;
        Data(3,:)=lzc_sum/tlength;
        Data(4,:)=PmEn_sum/tlength;
        Data(5,:)=SampEn_sum/tlength;
        
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