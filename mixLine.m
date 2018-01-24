function [TG, t]  = mixLine(segments, vmax, timeLimt, q, dt, mixtime, varargin)
%生成点之间的轨迹，过渡阶段采用5阶多项式。
%点构成列向量。
[ns,nj]=size(segments);

qd0 = zeros(1, nj);
qdf = zeros(1, nj);

q_prev = q;
qd_prev = qd0;
clock = 0;    

tg = [];

for seg=1:ns
    
    if length(mixtime) > 1
        tacc = mixtime(seg); %用于轨迹混合的加速时间,可以指定多段，Tacc可能是向量
    else
        tacc = mixtime;
    end
    
    tacc = ceil(tacc/dt)*dt;
    tacc2 = ceil(tacc/2/dt)*dt;
    if seg == 1
        taccx = tacc2*2;    %第一段只在末尾进行轨迹混合，源只是一半的混合时间，修改*2.
    else
        taccx = tacc;
    end
    
    q_next = segments(seg,:);    
    dq = q_next - q_prev;   
    
%%
    if ~isempty(vmax)                 %有速度限定时
        %  指定轴的最大速度时，计算最慢轴
        qb = taccx * vmax / 2;        % distance moved during blend 轨迹混合最大移动距离
        tb = taccx;                    % 轨迹混合耗费时间 t_blend
        
        tl = abs(dq) ./ vmax;         % 最短用时
        tl = ceil(tl/dt) * dt;         % 匀速段耗费时间 t_liner
        
        tt = tb + tl;
        tseg = max(tt);      % t_total总时间取最长的，即最慢的

        if tseg <= 2*tacc              % 如果设定的时间小于两倍轨迹混合时间，则设定时间修改为全程轨迹混合
            tseg = 2 * tacc;
        end
    elseif ~isempty(timeLimt) %如果有设定每段的时间，则使用分段数据
        % segment time specified, use that
        tseg = timeLimt(seg);
    end
    
   %% 
    qd = dq / tseg;       %分段内部的平均速度
    % 采用5阶多项式设计混合曲线，混合曲线位移由平均速度计算。
    if seg==1
        aa1 = q; aa2 = q_prev+tacc2/2*qd; aa3 = qd_prev; aa4 = qd;
        qb = Line5s(q, q_prev+tacc2/2*qd, 0:dt:taccx/2, qd_prev, qd);
        % q初始位置，q_prev+tacc2*qd最终位置，taccx混合过渡耗时，qd_prev初始速度，qd最终速度
        tg = [tg; qb(2:end,:)];
        clock = clock + taccx/2;   

        for t=tacc2/2+dt:dt:tseg-tacc2
            s = t/tseg;
            q = (1-s) * q_prev + s * q_next;    
            tg = [tg; q];
            clock = clock + dt;
        end
    else
        aa1 = q; aa2 = q_prev+tacc2*qd; aa3 = qd_prev; aa4 = qd;
        qb = Line5s(q, q_prev+tacc2*qd, 0:dt:taccx, qd_prev, qd);
        % q初始位置，q_prev+tacc2*qd最终位置，taccx混合过渡耗时，qd_prev初始速度，qd最终速度
        tg = [tg; qb(2:end,:)];
        clock = clock + taccx;     
        
        for t=tacc2+dt:dt:tseg-tacc2
            s = t/tseg;
            q = (1-s) * q_prev + s * q_next;     
            tg = [tg; q];
            clock = clock + dt;
        end
    end
    q_prev = q_next;   
    qd_prev = qd;
end
% 增加尾部段
qb = Line5s(q, q_next, 0:dt:tacc2*2, qd_prev, qdf);
tg = [tg; qb(2:end,:)];

if nargout > 0
    TG = tg;
end
if nargout > 1
    t = (0:numrows(tg)-1)'*dt;
end

