function [timediff,pk,movdiff_lightthresh] = histgeneratefly(movdiff,tvec,lightthresh,movethresh)
% This function generates histograms of the time between each light pulse and 
% and associated movement.
%
% [timediff,pk,movdiffLT] = histgeneratefly(lightthresh,movethresh)
%
% timediff    : structure of time differences (use timediff{j} to access each array, where
%               j is the index of each light peak)
% pk          : locations of all the light peaks
% movdiffLT   : time series from movdiff but with the light peaks excluded (±10 pts)
% movdiff     : time trace of video differences (1xN)
% tvec        : time vector (seconds)
% lightthresh : threshold for the light pulse (e.g. 50)
% movethresh  : threshold for fly movement (e.g. 0.8)
%
% To use the function, input the time trace and set the two parameters
% you'd like to use. The function will not save any variables but will
% generate histograms of the time after each light pulse that a
% movement occurs. For example, there will be multiple peaks above a 
% threshold at which movement occurs. Each of this is one example, and
% all of the examples are added to a probability density function.
%
%
% Example:
%  [times] = histgeneratefly(movdiff,tvec,50,1)
%
% jsalvi@rockefeller.edu

[pk tr] = PTDetect(movdiff,lightthresh);

movdiff_lightthresh = movdiff;
for j = 1:length(pk)
   movdiff_lightthresh(pk(j)-10:pk(j)+10) = 0; % remove light peaks
end

% Find all of the appropriate events
for j = 1:length(pk)-1
   clear movdiff_lightthresh2
   movdiff_lightthresh2 = movdiff_lightthresh>movethresh;
   movdiffLTind = find(movdiff_lightthresh2==1);movdiffLTind2=find(movdiffLTind>=pk(j) & movdiffLTind<=pk(j+1));
   timediff{j} = tvec(movdiffLTind(movdiffLTind2))-tvec(pk(j));
end
   
   
% Plot the time series data
figure;
plot(tvec,movdiff,'k'); xlabel('Time (sec)');ylabel('Diff');
axis([tvec(1) tvec(end) -0.1 movethresh*5]); hold on;
plot(tvec,movdiff_lightthresh,'r');
scatter(tvec(pk),3*ones(1,length(pk)),6*movdiff(pk),'b.');
scatter(tvec(movdiff_lightthresh>movethresh),movdiff_lightthresh(movdiff_lightthresh>movethresh),'g');
legend('Raw Movement','Light Pulses Subtracted','Light Pulses','Movements');
title(sprintf('%s%s %s%s','Light Pulse Threshold = ',num2str(lightthresh),'Movement Threshold = ',num2str(movethresh)));

% Plot raw histograms with fits to normal distributions
figure;
for j = 1:length(timediff)
    if isempty(timediff{j}) == 0
        subplot(1,length(timediff),j); histfit(timediff{j},freedmandiaconis(timediff{j}));[tda{j} tdb{j}]=hist(timediff{j},freedmandiaconis(timediff{j}));
        xlabel('Time until Movement (sec)');ylabel('Counts');legend('Histogram','Hist Normal Fit');
    else
        subplot(1,length(timediff),j); tda{j}=0;tdb{j}=0;
        xlabel('NO MOVEMENT');
    end
end

% Create overlay of probability density functions
figure;
set(0,'DefaultAxesColorOrder',cool(length(timediff)));
for j = 1:length(timediff)
     if isempty(timediff{j}) == 0
         ksdensity(timediff{j});hold all;
         R(j) = std(timediff{j})/mean(timediff{j});
     else
         plot(tdb{j},tda{j});hold all;
         R(j) = Inf;
     end
    M{j} = sprintf('%s %2g\n%s %0.2f\n%s %0.2f','Delay after Peak',j,'Coefficient of Variation = ',R(j),'1/sqrt(mean) = ',1/sqrt(mean(timediff{j})));
    legend(M);
end
xlabel('Seconds');ylabel('Probability');
end
%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%

function nb = freedmandiaconis(x)
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

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
