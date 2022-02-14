# EEG-data-analysis
对原始脑电信号截断，用到代码datacut.m，从而得到raw.bdf，对raw.bdf做滤波处理，用到代码m1-filter
在MATLAB平台中的eeglab脑电处理工具包中，将第一步滤波完成的信号做去伪迹，截断处理，选出最平稳有效的脑电信号
对上一步的脑电信号做独立成分分析（ICA），同样用到eeglab脑电处理工具包，以去除脑电中的眼电，肌电，从而完成预处理全部步骤，命名为ica.set
对所有ica.set计算各种非线性熵值，用到代码find-icaset.m，Batchentropy.m,(.p文件为五种熵值复杂度的算法文件，需要结合Batchentropy.m共同计算）
对所有ica.set计算各频段能量占比，用到代码find-icaset.m，Batchpower.m,(power.main,get-power.m为比较文件，选取满足条件的值）
用SPSS统计软件对5,6步所得结果做统计学分析，两组样本之间的差异用到独立样本T检验，同一组人不同时间状态下的比较用配对T检验，同一组人同一时刻下不同脑区的差异用单因素方差分析，p<0.05为差异显著
