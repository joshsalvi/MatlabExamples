function [CDspkisi, spkisivec, spkbinned, spkisihista, spkisihistb] = findspkisi(spkvec,tvec,thresh,plotyn)
% This function creates a spike density using a Gaussian kernel density
% estimator.
%
% [CDspkisi spkieivec spkbinned spkisihista spkisihistb] = findspkisi(spkvec,tvec,thresh,plotyn)
%
% CDspkisi = coefficient of dispersion of interspike intervals
% spkieivec = vector of all inter-spike interval times
% spkbinned = binned spike times (1=spike, 0=no spike)
% spkisihista = probability density of interspike intervals (y-axis)
% spkisihistb = probability density of interspike intervals (x-axis)
%
% * The coefficient of dispersion equals one for a Poisson distribution.
%
% spkvec = 1D vector of time series data with spikes
% tvec = time vector
% thresh = threshold for counting spikes, if thresh is empty, it will
% use a k-nearest-neighbor clustering algorithm to define a threshold
% plotyn = plot your data? (1=yes, 0=no)
%
% Example:
% findspkisi(spkvec,t,10,1)
%   "spikes" contains your time series data
%   "t" is a time vector with units of seconds
%   "10" defines a threshold of 10
%   "1" generates a plot of the spike density estimate
%
% Joshua D. Salvi
% jsalvi@rockefeller.edu

% Find the spikes using a defined threshold
if isempty(thresh) == 0
    pks = PTDetect(spkvec,thresh);
else
    [c1, c2] = twoclass(spkvec,1e-14);
    thresh = max([c1 c2]);
    pks = PTDetect(spkvec,thresh);
end
spkbinned=zeros(1,length(spkvec));
spkbinned(pks)=1;

% Find all of the inter-spike intervals
spkisivec=zeros(1,length(spkbind)-1);
for j = 2:length(spkbind)
    spkisivec(j-1) = tvec(spkbind(j))-tvec(spkbind(j-1));
end
% Calculate the coefficient of dispersion and the histogram
[spkisihista, spkisihistb] = ksdensity(spkisivec);
%[spkisihista spkisihistb] = hist(spkisivec,fdhists(spkisivec));
%spkisihista=spkisihista./sum(spkisihista);
CDspkisi = var(spkisivec)/mean(spkisivec);  % coefficient of dispersion

if plotyn == 1
    figure;
    subplot(2,1,1);plot(tvec,spkvec,'k');hold on;scatter(tvec(spkbinned==1),spkvec(spkbinned==1),'r.');title('Time Series with Selected Spikes');ylabel('X');xlabel('Time');
    subplot(2,1,2);plot(spkisihistb,spkisihista,'r');title('Interspike Interval Probabiltiy Density');ylabel('Density');xlabel('Time');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function nb = fdhists(x)
% Implementation of the Freedman-Diaconis Rule
%
%   nb = freedmandiaconis(x)
%
%   x : 1xN array of data
%   nb : number of bins according to this rule
%
%   jsalvi@rockefeller.edu

bw = 2*iqr(x)/length(x)^(1/3);
nb = ceil((max(x) - min(x))/bw);

if nb < 4
    nb = 4;
elseif isinf(nb) == 1
    nb = 4;
elseif isnan(nb) == 1
    nb = 4;
end
if nb > 1e3
    nb = 1e3;
end

end

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
