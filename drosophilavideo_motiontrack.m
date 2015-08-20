%% Import Video
% This code imports a video object and then reads the frames.
% If you have questions, contact jsalvi@rockefeller.edu
%
%
 
clear all; 
%close all;
set(0,'DefaultFigureWindowStyle','docked') 
 
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
 
% INPUT the filename of your video
vid_in = '/Users/joshsalvi/Documents/Lab/Lab/Videos/Zebrafish/20150709/20150709-1715-Bapta/Composite_(NTSC)_20150709_1718_150ugmlBapta.mov';
 
% INPUT where you'd like it to be saved.
vid_out = '/Users/joshsalvi/Documents/Lab/Lab/Videos/Analysis-Composite_(NTSC)_20150701_1837';
 
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
 
% Be sure that you use one of the formats specified by VideoReader.getFileFormats()
%    .3gp - 3GP File
%    .avi - AVI File
%   .divx - DIVX File
%     .dv - DV File
%    .flc - FLC File
%    .flv - FLV File
%    .m4v - MPEG-4 Video
%    .mj2 - Motion JPEG2000
%    .mkv - MKV File
%    .mov - QuickTime movie
%    .mp4 - MPEG-4
%    .mpg - MPEG-1
% You can convert your videos using a program called HandBrake:
% https://handbrake.fr/downloads.php
 
% Import video using VideoReader (requires Image Processing Toolbox)
vidobj = VideoReader(vid_in);
 
nFrames = vidobj.NumberOfFrames;  % extract number of frames in video
vidHeight = vidobj.Height;        % video height
vidWidth = vidobj.Width;          % video dimensions
 
% Construct a 1 x nFrame struct array with cdata (pre-allocate first)
vidmov(1:nFrames) = ...
    struct('cdata',zeros(vidHeight,vidWidth, 3,'uint8'),...
           'colormap',[]);
       
%%
            
% Loop through each frame and extract the color data, creating a 1xn structure of HxWx3 matrices
for i = 1:nFrames
    vidmov(i).cdata = read(vidobj,i);
    %vidmov2(i).cdata = vidmov(i).cdata(:,:,1);
    if mod(i,20) == 0
        %disp(['frame ' num2str(i) '/' num2str(nFrames)]);
        disp([num2str(round(i/nFrames*100)) '% complete']);
    end
end
disp([num2str(round(i/nFrames*100)) '% complete']);
%vidmov2=vidmov;clear vidmov2

% Construct a time vector (seconds)
tvec = linspace(0,nFrames/vidobj.FrameRate,nFrames);

%% Draw an ROI (optional)
figure(2);
imshow(vidmov(1).cdata(:,:,1));colormap('gray');
nroi = input('How many ROIs? ');
setfiguredefaults(nroi);

% This allows you to draw a polygon 
for j = 1:nroi
    figure(1);
    [ROI{j}, x1{j}, y1{j}] = roipoly(vidmov(1).cdata(:,:,1));
    figure(2);
    %imshow(vidmov(1).cdata(:,:,1));colormap('gray');
    hold all;
    plot(x1{j},y1{j});hold all;
    text(x1{j}(1),y1{j}(1),num2str(j));
    ROI2{j}=abs(ROI{j}-1);
end

%%
% Find the mean difference between each frame and a previous one
for i = 1:nroi
    for j = 2:nFrames
        movdiff(i,j)=mean(mean(mean(vidmov(j).cdata(ROI{i}==1)-vidmov(j-1).cdata(ROI{i}==1))));
    end
end
 
%{
% Plot the answer
figure;
plot(tvec,movdiff);
%}

figure(3);
for j = 1:nroi
    subplot(2,ceil(nroi/2),j);
    plot(tvec,movdiff(j,:));axis([0 tvec(end) -max(abs(movdiff(j,:))) max(abs(movdiff(j,:)))]);
    hold on;
    plot(tvec,movdiff(j,:)-mean(movdiff),'r');
    title(num2str(j));
end


saveyn = input('Save? (1=yes):  ');
if saveyn ==1
disp('Saving...');
save([vid_out '.mat'],'movdiff','ROI','tvec','vidmov','x1','y1','nFrames','ROI2');
disp('Finished.');
end


%%
j = input('Which ROI?  ');
% Create playable movie with video AND time series [DO NOT CLICK OUT OF THE FIGURE AS IT IS PROCESSING]
writerObj = VideoWriter(vid_out);   % create writer object (Image Processing toolbox)
writerObj.Quality=100;
%writerObj.Width=1024;writerObj.Height=1024;
open(writerObj)                     % open the object

set(0,'DefaultFigureWindowStyle','default')
h2=figure;                          % set the figure for movie making
spn=subplot(2,1,2); hold on;plot(tvec,movdiff(j,:),'k')  % initial plot of time series in black
snp = get(spn, 'pos');
set(spn, 'Position', [0.4*snp(1) 0.15*snp(2) 1.6*snp(3) 0.8*snp(4)]);set(spn,'Yticklabel','')
xlabel('Time (sec)');ylabel('Diff');
axis([0 tvec(end) -0.5 12]);        % set axes [xmin xmax ymin ymax]
for i = 1:nFrames                   % loop through each frame
sph=subplot(2,1,1);
%J=roifill(vidmov(i).cdata(:,:,1),ROI2{j});
J=vidmov(i).cdata(:,:,1);
imshow(J);colormap('gray');    % plot video frame
hold on;plot(x1{j},y1{j},'r-');
spp = get(sph, 'pos');
set(sph, 'Position', [1.8*spp(1) 0.9*spp(2) 0.7*spp(3) 1.4*spp(4)]);set(sph,'Xticklabel','');set(sph,'Yticklabel','');
spn=subplot(2,1,2);plot(tvec,movdiff(j,:),'k') ;hold on;plot(tvec(1:i),movdiff(j,1:i),'r');    % plot time series up to this frame in red
snp = get(sph, 'pos');
set(spn, 'Position', [0.4*snp(1) 0.15*snp(2) 1.6*snp(3) 0.8*snp(4)]);set(sph,'Yticklabel','')
xlabel('Time (sec)');ylabel('Diff');
axis([0 tvec(end) 1.1*min(movdiff(j,:)) 1.1*max(movdiff(j,:))]); 
h(i) = getframe(h2);                % create object/snapshot of figure frame
writeVideo(writerObj,h(i));         % write to video object
end
close(writerObj);                   % close video object

%%
for j = 2:nFrames
    movdiff4(j-1).cdata = double(vidmov(j).cdata) - double(vidmov(j-1).cdata);
end

movdiff4n = abs(movdiff4(1).cdata);
for j = 2:nFrames-1
    movdiff4n = double(movdiff4n) + abs(double(movdiff4(j).cdata));
end

titletext='150 µg/ml BAPTA  ';
figure;
subplot_tight(1,2,1,[0.11 0.11]);imagesc(vidmov(1).cdata);title(titletext);colormap gray
subplot_tight(1,2,2,[0.11 0.11]);imagesc(movdiff4n(:,:,1));colormap jet;title([titletext ' Difference Image']);
