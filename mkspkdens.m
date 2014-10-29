function [spkdens spkbinned kernel] = mkspkdens(spkvec,tvec,thresh,sigma,plotyn)
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
% thresh = threshold for counting spikes
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
edges = [-3*sigma:dt:3*sigma];
% Define the kernel
kernel = normpdf(edges,0,sigma)*dt;

% Find the spikes using a defined threshold
spkbinned=spkvec;
spkbinned(spkbinned<thresh) = 0;
spkbinned(spkbinned>=thresh) = 1;

% Make a spike density by convolving the binned spike data with a kernel
spkdens = conv(spkbinned,kernel);
% Find the index of the kernel center and trim out the middle portion so
% that you exclude edge artifacts
center = ceil(length(edges)/2);
spkdens = spkdens(center:(length(tvec)-1) + center-1);

if plotyn == 1
    figure;
    subplot(3,1,1);plot(tvec,spkvec,'k');title('Time Series');ylabel('X');xlabel('Time');
    subplot(3,1,2);plot(tvec,spkvec,'k');hold on;scatter(tvec(spkbinned==1),spkvec(spkbinned==1),'r.');title('Time Series with Selected Spikes');ylabel('X');xlabel('Time');
    subplot(3,1,3);plot(tvec(1:length(spkdens)),spkdens,'r');title('Spike Density');ylabel('Density');xlabel('Time');
end
