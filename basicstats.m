function [meanX stdX medX modX] = basicstats(x,plotyn);
% This function calculates the mean and standard deviation of a signal. It
% includes detailed comments for MATLAB beginners.
%
%   [meanX stdX] = meanandstd(x);
%
%  x : input signal, where x is a 1xn array
%  plotyn : Would you like to plot the data? (1=yes)
%
%  meanX : mean of X
%  stdX : standard deviation of X
%  medX : median of X
%  modX : mode of X
%
%  Contact: josh.salvi@gmail.com
%
%

% Calculate the mean of X
meanX = mean(x);

% Calculate the standard deviation of X
stdX = std(x);

% Calculate the median of x
medX = median(x);

% Calculate the mode of x
modX = mode(x);

if plotyn == 1      % the IF statement will run if and only if plotyn is 1
    figure;         % generate a new figure window
    [a,b]=hist(x,20);     % create a histogram of x with 20 bins
    a=a./sum(a);          % normalize the histogram
    plot(b,a);            % plot the histogram
    xlabel('X');    % create a text label on the x-axis
    title('Histogram of X');    % create a title for the plot
    % Create a text box on the plot that displays all of your statistics.
    % Look up the functions "text" "sprintf" and "num2str" to learn how
    % this works using the matlab HELP command. (e.g. "help text")
    text(modX,max(a),sprintf('%s%s\n%s%s\n%s%s\n%s%s','Mean = ',num2str(meanX),'Std.Dev. = ',num2str(stdX),'Median = ',num2str(medX),'Mode = ',num2str('modX')));
end
end

