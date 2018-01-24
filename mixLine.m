function [TG, t]  = mixLine(segments, vmax, timeLimt, q, dt, mixtime, varargin)
%���ɵ�֮��Ĺ켣�����ɽ׶β���5�׶���ʽ��
%�㹹����������
[ns,nj]=size(segments);

qd0 = zeros(1, nj);
qdf = zeros(1, nj);

q_prev = q;
qd_prev = qd0;
clock = 0;    

tg = [];

for seg=1:ns
    
    if length(mixtime) > 1
        tacc = mixtime(seg); %���ڹ켣��ϵļ���ʱ��,����ָ����Σ�Tacc����������
    else
        tacc = mixtime;
    end
    
    tacc = ceil(tacc/dt)*dt;
    tacc2 = ceil(tacc/2/dt)*dt;
    if seg == 1
        taccx = tacc2*2;    %��һ��ֻ��ĩβ���й켣��ϣ�Դֻ��һ��Ļ��ʱ�䣬�޸�*2.
    else
        taccx = tacc;
    end
    
    q_next = segments(seg,:);    
    dq = q_next - q_prev;   
    
%%
    if ~isempty(vmax)                 %���ٶ��޶�ʱ
        %  ָ���������ٶ�ʱ������������
        qb = taccx * vmax / 2;        % distance moved during blend �켣�������ƶ�����
        tb = taccx;                    % �켣��Ϻķ�ʱ�� t_blend
        
        tl = abs(dq) ./ vmax;         % �����ʱ
        tl = ceil(tl/dt) * dt;         % ���ٶκķ�ʱ�� t_liner
        
        tt = tb + tl;
        tseg = max(tt);      % t_total��ʱ��ȡ��ģ���������

        if tseg <= 2*tacc              % ����趨��ʱ��С�������켣���ʱ�䣬���趨ʱ���޸�Ϊȫ�̹켣���
            tseg = 2 * tacc;
        end
    elseif ~isempty(timeLimt) %������趨ÿ�ε�ʱ�䣬��ʹ�÷ֶ�����
        % segment time specified, use that
        tseg = timeLimt(seg);
    end
    
   %% 
    qd = dq / tseg;       %�ֶ��ڲ���ƽ���ٶ�
    % ����5�׶���ʽ��ƻ�����ߣ��������λ����ƽ���ٶȼ��㡣
    if seg==1
        aa1 = q; aa2 = q_prev+tacc2/2*qd; aa3 = qd_prev; aa4 = qd;
        qb = Line5s(q, q_prev+tacc2/2*qd, 0:dt:taccx/2, qd_prev, qd);
        % q��ʼλ�ã�q_prev+tacc2*qd����λ�ã�taccx��Ϲ��ɺ�ʱ��qd_prev��ʼ�ٶȣ�qd�����ٶ�
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
        % q��ʼλ�ã�q_prev+tacc2*qd����λ�ã�taccx��Ϲ��ɺ�ʱ��qd_prev��ʼ�ٶȣ�qd�����ٶ�
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
% ����β����
qb = Line5s(q, q_next, 0:dt:tacc2*2, qd_prev, qdf);
tg = [tg; qb(2:end,:)];

if nargout > 0
    TG = tg;
end
if nargout > 1
    t = (0:numrows(tg)-1)'*dt;
end

