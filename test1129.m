
%% 2ά carry-xz
clc;clear;
via = [1 1;0 4; 5 2; 2 5];%�����ĵ�����ꡣ
res = mixLine(via,[2 2],[], [0. 0.],0.01,0.2);%���ɹ켣 [2 1]���޶����ٶ�
figure;plot(res);
figure;plot(diff(res)/0.01);
figure;plot(diff(diff(res)/0.01)/0.01);
%% 3ά
via = [1 1 1;0 4 2; 5 2 6; 2 5 -1];%�����ĵ�����ꡣ
res = mixLine(via,[2 2 1],[], [0. 0. 0],0.01,0.5);%���ɹ켣 [2 1]���޶����ٶ�
figure;plot(res);title('λ��');
figure;plot(diff(res)/0.01);title('�ٶ�');
figure;plot(diff(diff(res)/0.01)/0.01);title('���ٶ�');