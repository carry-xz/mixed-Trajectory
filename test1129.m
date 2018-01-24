
%% 2维 carry-xz
clc;clear;
via = [1 1;0 4; 5 2; 2 5];%经过的点的坐标。
res = mixLine(via,[2 2],[], [0. 0.],0.01,0.2);%生成轨迹 [2 1]是限定的速度
figure;plot(res);
figure;plot(diff(res)/0.01);
figure;plot(diff(diff(res)/0.01)/0.01);
%% 3维
via = [1 1 1;0 4 2; 5 2 6; 2 5 -1];%经过的点的坐标。
res = mixLine(via,[2 2 1],[], [0. 0. 0],0.01,0.5);%生成轨迹 [2 1]是限定的速度
figure;plot(res);title('位置');
figure;plot(diff(res)/0.01);title('速度');
figure;plot(diff(diff(res)/0.01)/0.01);title('加速度');