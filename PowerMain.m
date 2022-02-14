clc
clear
close all
t0 = datestr(now,31);

rootdir = 'E:\xll\test';
savefile_name = 'power_compare.xlsx';
savefile_path = [rootdir filesep savefile_name];
rule.bt = {'1,2,3','1,2,4'};
rule.lt = {};
rule.range = {'1','2'};

folder_list = dir(rootdir);
folder_list = folder_list([folder_list.isdir]);
folder_list = folder_list(3:end);
folder_list = {folder_list.name};

count = 0;
T = table;
T.id = cell(length(folder_list),1);
T.folderpath = cell(length(folder_list),1);
rowNames = cell(length(folder_list),1);
for r = rule.bt
    col_title = ['R_bt_' strrep(r{1},',','_')];
    T.(col_title) = cell(length(folder_list),1);
end
for r = rule.lt
    col_title = ['R_lt_' strrep(r{1},',','_')];
    T.(col_title) = cell(length(folder_list),1);
end
disp('______________Start________________')
disp(['startTime:' t0])
disp(['rootdir:' rootdir])
disp('_______________Run_________________')
for folder = folder_list
    count = count + 1;
    
    t1 = datestr(now,31);
    disp(['[' num2str(count) '/' num2str(length(folder_list)) ']'])
    folderpath = fullfile(rootdir,folder{1});
    
    clear power_data
    is_skiped = false;
    for tag_name = rule.range
        ica_folderpath = fullfile(folderpath,tag_name);
        filename = dir(fullfile(ica_folderpath{1},'*ica*.set'));
        if length(filename) ~= 1
            is_skiped = true;
            disp('[err] set文件数量不等于1，跳过！')
            break
        end
        filename = filename.name;
        ica_folderpath = ica_folderpath{1};
        power_data.(['T' tag_name{1}]) = get_power(filename,ica_folderpath);
    end
    
    T.id{count} = ['[' num2str(count) '/' num2str(length(folder_list)) ']'];
    T.folderpath{count} = folderpath;
    rowNames{count} = folder{1};
    
    for r = rule.bt
        col_title = ['R_bt_' strrep(r{1},',','_')];
        if is_skiped
            T.(col_title){count}  = 'x';
            continue
        end
        rule_tmp = strsplit(r{1},',');
        
        left = rule_tmp{1};
        right = rule_tmp{2};
        data_index = str2double(rule_tmp{3});
        
        left_data = mean(power_data.(['T' left]),2);
        right_data = mean(power_data.(['T' right]),2);
        
        
        if left_data(data_index) > right_data(data_index)
            T.(col_title){count} = '1';
        else
            T.(col_title){count} = '0';
        end
    end
    
    for r = rule.lt
        col_title = ['R_lt_' strrep(r{1},',','_')];
        if is_skiped
            T.(col_title){count}  = 'x';
            continue
        end
        rule_tmp = strsplit(r{1},',');
        
        left = rule_tmp{1};
        right = rule_tmp{2};
        data_index = str2double(rule_tmp{3});
        
        left_data = mean(power_data.(['T' left]),2);
        right_data = mean(power_data.(['T' right]),2);
        
        if left_data(data_index) < right_data(data_index)
            T.(col_title){count} = '1';
        else
            T.(col_title){count}  = '0';
        end
    end
   
    t2 = datestr(now,31);
    disp(['SUCCESS: ' datestr(datenum(t2) - datenum(t1),'HH:MM:SS')])
end

T.Properties.RowNames = rowNames;
writetable(T,savefile_path,'Sheet',1,'Range','A1'); 
disp('_______________END_________________')
disp(['totalTime:' datestr(datenum(t2) - datenum(t0),'HH:MM:SS')])