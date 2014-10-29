function [CDspkisi spkisivec spkbinned spkisihista spkisihistb] = findspkisi(spkvec,tvec,thresh,plotyn)
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
% thresh = threshold for counting spikes
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
spkbinned=spkvec;
spkbinned(spkbinned<thresh) = 0;
spkbinned(spkbinned>=thresh) = 1;
spkbind=find(spkbinned==1);

% Find all of the inter-spike intervals
for j = 2:length(spkbind)
    spkisivec(j-1) = tvec(spkbind(j))-tvec(spkbind(j-1));
end
% Calculate the coefficient of dispersion and the histogram
[spkisihista spkisihistb] = ksdensity(spkisivec);
%[spkisihista spkisihistb] = hist(spkisivec,fdhists(spkisivec));
%spkisihista=spkisihista./sum(spkisihista);
CDspkisi = var(spkisivec)/mean(spkisivec);  % coefficient of dispersion

if plotyn == 1
    figure;
    subplot(2,1,1);plot(tvec,spkvec,'k');hold on;scatter(tvec(spkbinned==1),spkvec(spkbinned==1),'r.');title('Time Series with Selected Spikes');ylabel('X');xlabel('Time');
    subplot(2,1,2);plot(spkisihistb,spkisihista,'r');title('Interspike Interval Probabiltiy Density');ylabel('Density');xlabel('Time');
end

end

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
