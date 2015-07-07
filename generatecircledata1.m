clear all; close all; clc;

datapath = '/Users/joshsalvi/Downloads/circledata/';
file = dir(sprintf('%s%s',datapath,'*circle*.mat'));

% Load data?
loadyn = input('Load previously stored file (1=yes)? ');
if loadyn==1
disp(['Directory: ' datapath]);
disp('Files:');
for j = 1:length(file)
    disp(['(' num2str(j) ')  ' file(j).name]);
end
fileselect = input('Select a file to load (#): ');
disp('Loading...');
load([datapath file(fileselect).name]);
disp('Complete.');disp(' ');

disp('Parameters: ');
disp(' ');
disp(table(lengthX,imageSizeX,lengthY,imageSizeY))
disp(table(velX,velXp,velY,velYp,radius,intens))


else


% Input the size of the screen
imageSizeX = input('Pixels in X: ');    % pixels
imageSizeY = input('Pixels in Y: ');
lengthX = input('Length in X (m): ');   % m
lengthY = input('Length in Y (m): ');

lX = imageSizeX/lengthX;                % px/m
lY = imageSizeY/lengthY;

% Input and calculate the desired velocities
velX = input('Velocity in X (m/s): ');  % velocity (m/s)
velY = input('Velocity in Y (m/s): ');

velXp = velX*lX;                        % velocity (px/s)
velYp = velY*lY;

lengthT = input('Total time (s): ');    % s
lengthTms = lengthT*1000;               % convert to ms

stptX = input('Starting point in X (px, 1:lengthX): ');
stptY = input('Starting point in Y (px, 1:lengthX): ');

radius = input('Radius (px): ');
intens = input('Intensity (0-1): ');

% Create an image at each time point in ms
circlePixels = cell(lengthTms);circlePixels2 = cell(lengthTms);
disp('Generating...');
for j = 1:lengthTms
    [colI{j} rowI{j}] = meshgrid(1:imageSizeX, 1:imageSizeY);
    % Next create the circle in the image.
    centerX(j) = stptX + (j/1000)*velXp;
    centerY(j) = stptY + (j/1000)*velYp;
    circlePixelsa = (rowI{j} - centerY(j)).^2 ...
    + (colI{j} - centerX(j)).^2 <= radius.^2;
    circlePixels{j} = +circlePixelsa; clear circlePixelsa   % convert to double
    circlePixels{j} = circlePixels{j} .* intens;
    if mod(j,50) == 0
        disp(['...' num2str((j/lengthTms)*100) '%...']);
    end
    if sum(sum(circlePixels{j})) > 0
        circon(j) = 1;
    else
        circon(j) = 0;
    end
end
disp('Finished.');

% If possible, assure that the image starts or ends with an empty frame.
circonind = find(circon==1);
if circonind(1) > 1
    circonind = [1 circonind];
end
if circonind(end) < lengthTms
    circonind = [circonind lengthTms];
end

% Repopulate with an image sequence that includes objects and excludes
% excess empty frames.
mm = 1;
for j = circonind
    circlePixels2{mm} = circlePixels{j};
    mm = mm + 1;
end
circlePixels = circlePixels2;
clear circlePixels2

saveyn = input('Save (1=yes)? ');
if saveyn ==1
    disp('Saving...');
    save([datapath 'savedcirc-circle-' num2str(length(file)+1)]);
    disp('Finished.');
end

end
    
plotyn = input('Plot (1=yes)? ');
if plotyn==1
% Plot the image sequence. 
% Sample rate: 1 frame/ms, 1000 Hz
for j = 1:length(circlePixels)
    warning off;
    imshow(circlePixels{j});
    colormap([0 0 0; 1 1 1]);
end
end
%}
