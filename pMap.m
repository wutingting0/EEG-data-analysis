function [ ] = pMap( chanlocs_path, data, maplimits, leftTitle , id )
%PMAP �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
chanlocs = load(chanlocs_path);
chanlocs = chanlocs.chanlocs;
subImgSize = 0.24;
figure('Name',id)
set(gcf,'position',[200,200,700,300]);
subplot(1,3,1)
set(gca,'position',[0.17 0.3 subImgSize subImgSize*1.7])
topoplot(data{1},chanlocs,'electrodes','on','maplimits',maplimits);
title('��Ϣ̬','fontsize',13)

subplot(1,3,2)
set(gca,'position',[0.43 0.3 subImgSize subImgSize*1.7])
topoplot(data{2},chanlocs,'maplimits',maplimits);
title('���ִ̼�̬','fontsize',13)

subplot(1,3,3)
set(gca,'position',[0.69 0.3 subImgSize subImgSize*1.7])
topoplot(data{3},chanlocs,'electrodes','on','maplimits',maplimits);
title('�̼���״̬','fontsize',13)

anno = annotation('textbox',[0.005, 0.4, 0.1, 0.2],...
    'String',leftTitle,'FontSize',12.5,'EdgeColor','none');
% anno.FontSize = 1;

colorbar('position',[0.93 0.32 0.02 0.3*1.3])  

set(gcf,'color','white','paperpositionmode','auto');

if ~exist('out', 'dir')
    mkdir('out')
end
saveas(gcf,['out/' id '.png']);
end

