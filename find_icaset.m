function [ icaset_path_list ] = find_icaset( rootpath )
%FIND_ICASET 此处显示有关此函数的摘要
%   此处显示详细说明
icaset_path_list = {};
filelist = dir([rootpath filesep '*ica*.set']);

for file = {filelist.name}
    icaset_path_list{end + 1} = [rootpath filesep file{1}];
end

childfolder_list = dir(rootpath);
childfolder_list = childfolder_list(3:end);
childfolder_list = childfolder_list([childfolder_list.isdir]);
for folder = {childfolder_list.name}
    tmp = find_icaset([rootpath filesep folder{1}]);
    for t = tmp
        icaset_path_list{end + 1} = t{1};
    end
end
end
