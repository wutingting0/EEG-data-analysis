% 清空缓存
clc
clear
close all
t0 = datestr(now,31);
% 添加函数依赖
add_func_path();
% 设置根目录，读取ICA.SET文件路径
rootdir = 'G:\正常对照组\rawHLJ-HXL-YZY';
icaset_path_list = find_icaset(rootdir);
% 设置保存文件名，文件若存在则关闭程序
savefile_name = 'powerout10sHLJ-YZY.xlsx';
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
        %load('4.mat')
        %data = ALLEEG.data;  % import data
        fs = 1000;             % frequency
        N = 1000*15;
        n = 0:N-1;
        t = 0:1/fs:N-1/fs;
        f = n*fs/N;
        
        x_dif_value = single(zeros(nbchan,size(data,2)));
        y = complex(single(zeros(nbchan,N)));
        mag = single(zeros(nbchan,N));
        mag_naqust = single(zeros(nbchan,N/2));
        for j=1:nbchan
            x_mean = mean(data(j,:));
            x_dif_value(j,:) = data(j,:)-x_mean;
            y(j,:) = fft(x_dif_value(j,:),N);
            mag(j,:) = abs(y(j,:));
            mag_naqust(j,:) = mag(j,1:N/2);
        end
        %%%%%%%%%%frequncy band%%%%%%%%%%%%%
        hh = mag_naqust .* mag_naqust;
        energy = hh;
        energy = energy';
        energy_total = sum(energy);
        
        
        N_delta1 = 2 * 500 / 80;
        N_delta2 = 4 * 500 / 80;
        N_theta = 8 * 500 / 80;
        N_alpha = 13 * 500 / 80;
        N_beta1 = 20 * 500 / 80;
        N_beta2 = 30 * 500 / 80;
        N_gumma = 50 * 500 / 80;
        
        
        %%%%frequency band energy%%%%%%%%
        energy_delta1 = sum(energy(1:floor(N_delta1),:));
        energy_delta2 = sum(energy(floor(N_delta1+1):floor(N_delta2),:));
        energy_delta = energy_delta1+energy_delta2;
        energy_theta = sum(energy(floor(N_delta2+1):floor(N_theta),:));
        energy_alpha = sum(energy(floor(N_theta+1):floor(N_alpha),:));
        energy_beta1 = sum(energy(floor(N_alpha+1):floor(N_beta1),:));
        energy_beta2 = sum(energy(floor(N_beta1+1):floor(N_beta2),:));
        energy_beta = energy_beta1+energy_beta2;
        energy_gumma = sum(energy(floor(N_beta2+1):floor(N_gumma),:));
        
        
        energy_total = energy_delta1 + energy_delta2 + energy_theta ...
            + energy_alpha + energy_beta1 + energy_beta2 + energy_gumma;
        
        delta1 = energy_delta1 ./ energy_total;
        delta2 = energy_delta2 ./ energy_total;
        beta1 = energy_beta1 ./ energy_total;
        beta2 = energy_beta2 ./ energy_total;
        alpha = energy_alpha ./ energy_total;
        theta = energy_theta ./ energy_total;
        gumma = energy_gumma ./ energy_total;
        
        delta = delta1 + delta2;
        beta = beta1 + beta2;
        
        
        Data = zeros(19,nbchan);
        Data(1,:) = delta1;
        Data(2,:) = delta2;
        Data(3,:) = delta;
        Data(4,:) = theta;
        Data(5,:) = alpha;
        Data(6,:) = beta1;
        Data(7,:) = beta2;
        Data(8,:) = beta;
        Data(9,:) = gumma;
        Data(10,:) = energy_delta1;
        Data(11,:) = energy_delta2;
        Data(12,:) = energy_delta;
        Data(13,:) = energy_theta;
        Data(14,:) = energy_alpha;
        Data(15,:) = energy_beta1;
        Data(16,:) = energy_beta2;
        Data(17,:) = energy_beta;
        Data(18,:) = energy_gumma;
        Data(19,:) = energy_total;
        power = Data;
        
        power_average = power;
        
        power_average_hang = mean(power_average,2);
        
        power = [power_average power_average_hang];
        name_x = {EEG.chanlocs.labels,'average'};
        name_y = {'delta1','delta2','delta','theta','alpha','beta1',...
            'beta2','beta','gumma','energy_delta1','energy_delta2',...
            'energy_delta','energy_theta','energy_alpha',...
            'energy_beta1','energy_beta2','energy_beta',...
            'energy_gumma','energy_total'};
        
        T = table;
        T.id = ['[' num2str(i) '/' num2str(length(icaset_path_list)) ']'];
        T.folderpath = folderpath;
        T.filename = filename;
        write_start = ['A',num2str(1 + (i - 1) * 22)];
        writetable(T,savefile_path,'Sheet',1,'Range',write_start);
        
        T = table;
        for n = 1:1:nbchan + 1
            T.(name_x{n}) = power(:,n);
        end
        T.Properties.RowNames = name_y;
        
        write_start = ['A',num2str(3 + (i - 1) * 22)];
        writetable(T,savefile_path,'Sheet',1,'Range',write_start,...
            'WriteRowNames',true);
        
        
        t2 = datestr(now,31);
        disp(['SUCCESS: ' datestr(datenum(t2) - datenum(t1),'HH:MM:SS')])
    end
    disp('_______________END_________________')
    disp(['totalTime:' datestr(datenum(t2) - datenum(t0),'HH:MM:SS')])
end



