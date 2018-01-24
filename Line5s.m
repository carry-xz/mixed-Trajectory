function [res,dres,ddres] = Line5md(y0,y1,time,dy0,dy1)
% 根据两个点及该点处一阶导、二阶导构造五阶曲线，连接两个点。
% 默认ddy=0，y0、y1分别是起止点，dy是导数。x是时间。
% 可以并行处理多组y。
if isscalar(time)
    time = 0:1/time:1;
    delt = 1/time;
else
    delt = time(2)-time(1);
end
x0 = time(1);x1=time(end);
res = [];
for ii = 1:length(y0)
    M = [x0^5  x0^4   x0^3   x0^2  x0  1;
        x1^5  x1^4   x1^3   x1^2  x1  1;
        5*x0^4 4*x0^3 3*x0^2 2*x0  1   0;
        5*x1^4 4*x1^3 3*x1^2 2*x1  1   0;
        20*x0^3 12*x0^2 6*x0  1   0   0;
        20*x1^3 12*x1^2 6*x1  1   0   0;
        ];
    
    A = M\[y0(ii),y1(ii),dy0(ii),dy1(ii),0,0]';
    res0 = A'*[time.^5;time.^4;time.^3;time.^2;time;ones(size(time))];
    res = [res,res0'];
end
dres = diff(res)/delt;
ddres = diff(diff(res)/delt)/delt;

    