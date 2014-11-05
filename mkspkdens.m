function [spkdens, spkbinned, kernel,pks,trs] = mkspkdens(spkvec,tvec,thresh,sigma,plotyn)
% This function creates a spike density using a Gaussian kernel density
% estimator.
%
% [spkdens spkbinned kernel] = mkspkdens(spkvec,tvec,thresh,sigma,plotyn)
%
% spkdens = spike density
% spkbinned = binned spike times (1=spike, 0=no spike)
% kernel = kernel density that is convolved with binned spike times to
% create the spike density
%
% spkvec = 1D vector of time series data with spikes
% tvec = time vector
% thresh = threshold for counting spikes, if threshold is empty, it will
% use a k-nearest-neighbors clustering algorithm to define a threshold
% sigma = standard deviation of the kernel density estimate in units of
% time defined by tvec. *Try different values of sigma. 
%    - LARGE SIGMA will broaden the spike density plot
%    - SMALL SIGMA will sharpen the spike density plot
% plotyn = plot your data? (1=yes, 0=no)
%
% Example:
% mkspkdens(spikes,t,10,0.015,1)
%   "spikes" contains your time series data
%   "t" is a time vector with units of seconds
%   "0.015" defines a 15-ms kernel density estimator width
%   "1" generates a plot of the spike density estimate
%
% Joshua D. Salvi
% jsalvi@rockefeller.edu

% Step size in time (dt)
dt = tvec(2)-tvec(1);
% Define the edges of the spike density estimate
edges = (-3*sigma:dt:3*sigma);
% Define the kernel
kernel = normpdf(edges,0,sigma)*dt;

% Find the spikes using a defined threshold
if isempty(thresh) == 0
    [pks trs] = PTDetect(spkvec,thresh);
else
    [c1, c2] = twoclass(spkvec,1e-14);
    thresh = max([c1 c2]);
    pks = PTDetect(spkvec,thresh);
end
spkbinned=zeros(1,length(spkvec));
spkbinned(pks)=1;

% Make a spike density by convolving the binned spike data with a kernel
spkdens = conv(spkbinned,kernel);
% Find the index of the kernel center and trim out the middle portion so
% that you exclude edge artifacts
center = ceil(length(edges)/2);
spkdens = spkdens(center:(length(tvec)-1) + center-1);
spkdens2 = spkdens>mean(spkdens)+std(spkdens);

if plotyn == 1
    figure;
    subplot(3,1,1);plot(tvec,spkvec,'k');title('Time Series');ylabel('X');xlabel('Time');
    subplot(3,1,2);plot(tvec,spkvec,'k');hold on;scatter(tvec(spkbinned==1),spkvec(spkbinned==1),'r.');title('Time Series with Selected Spikes');ylabel('X');xlabel('Time');
    subplot(3,1,3);plot(tvec(1:length(spkdens)),spkdens,'r');title('Spike Density');ylabel('Density');xlabel('Time');
    hold on;scatter(tvec(spkdens2==1),spkdens(spkdens2==1),'b.');
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [P,T] = PTDetect(x, E)
% Peak detection in data x for a given threshold E
%
% [P,T] = PTDetect(x, E)
%
% Jacobson, ML. Auto-threshold peak detection in physiological signals,
% 2001.
%
% compiled: jsalvi@rockefeller.edu

P=[];T=[];a=1;b=1;i=0;d=0;
xL=length(x);

while (i ~= xL)
    i = i + 1;
    if (d == 0)
        if ( x(a) >= (x(i)+E) )
            d=2;
        elseif (x(i) >= (x(b)+E))
            d=1;
        end
        if (x(a)<= x(i))
            a = i;
        elseif (x(i) <= x(b))
            b = i;
        end
    elseif d==1
        if (x(a)<=x(i))
            a=i;
        elseif (x(a) >= (x(i)+E))
            P = [P a]; b=i; d=2;
        end
    elseif d==2
        if (x(i) <= x(b))
            b=i;
        elseif (x(i) >= (x(b)+E))
            T = [T b]; a = i; d=1;
        end
    end
end

end

function [c1,c2]=twoclass(x,e)
% Perform unsupervised learning two class separation given data x and a
% termination condition e.
%
% function [c1,c2]=twoclass(x,e)
%
% Jacobson, ML. Auto-threshold peak detection in physiological signals,
% 2001.
%
% compiled: jsalvi@rockefeller.edu

c1=x(1); lastc1=c1;
c2=x(2); lastc2=c2;

while 1
    class1=[]; class2=[];
    for i = 1:length(x)
        if (abs(c1-x(i)) < abs(c2-x(i)))
            class1 = [class1 x(i)];
        else
            class2 = [class2 x(i)];
        end
    end
    c2 = mean(class2); c1=mean(class1);
    if (abs(lastc2-c2) < e) && (abs(lastc1-c1) < e)
        return;
    end
    lastc2=c2; lastc1=c1;
end

end

