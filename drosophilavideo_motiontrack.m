%% Import Video
% This code imports a video object and then reads the frames.
% If you have questions, contact jsalvi@rockefeller.edu
%
%
 
clear all; close all;
set(0,'DefaultFigureWindowStyle','docked') 
 
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
 
% INPUT the filename of your video
vid_in = '/Users/joshsalvi/Downloads/2014 10 21 cell 4 gamma 2  ODOR LIGHT 1_2014-10-21-181633-0000.mp4';
 
% INPUT where you'd like it to be saved.
vid_out = '/Users/joshsalvi/Downloads/vidout.mat';
 
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
end
 
% Construct a time vector (seconds)
tvec = linspace(0,nFrames/vidobj.FrameRate,nFrames);
 
%%
% Find the mean difference between each frame and a previous one
for j = 2:nFrames
    movdiff(j)=mean(mean(mean(vidmov(j).cdata-vidmov(j-1).cdata)));
end
 
%{
% Plot the answer
figure;
plot(tvec,movdiff);
%}
 
%%
% Create playable movie with video AND time series [DO NOT CLICK OUT OF THE FIGURE AS IT IS PROCESSING]
writerObj = VideoWriter(vid_out);   % create writer object (Image Processing toolbox)
writerObj.Quality=100;
%writerObj.Width=1024;writerObj.Height=1024;
open(writerObj)                     % open the object

set(0,'DefaultFigureWindowStyle','default')
h2=figure;                          % set the figure for movie making
spn=subplot(2,1,2); hold on;plot(tvec,movdiff,'k')  % initial plot of time series in black
snp = get(sph, 'pos');
set(spn, 'Position', [0.4*snp(1) 0.15*snp(2) 1.6*snp(3) 0.8*snp(4)]);set(sph,'Yticklabel','')
xlabel('Time (sec)');ylabel('Diff');
axis([0 tvec(end) -0.5 8]);        % set axes [xmin xmax ymin ymax]
for i = 1:nFrames                   % loop through each frame
sph=subplot(2,1,1);
imagesc(vidmov(i).cdata);colormap('gray');    % plot video frame
spp = get(sph, 'pos');
set(sph, 'Position', [1.8*spp(1) 0.9*spp(2) 0.7*spp(3) 1.4*spp(4)]);set(sph,'Xticklabel','');set(sph,'Yticklabel','');
spn=subplot(2,1,2);plot(tvec,movdiff,'k') ;hold on;plot(tvec(1:i),movdiff(1:i),'r');    % plot time series up to this frame in red
snp = get(sph, 'pos');
set(spn, 'Position', [0.4*snp(1) 0.15*snp(2) 1.6*snp(3) 0.8*snp(4)]);set(sph,'Yticklabel','')
xlabel('Time (sec)');ylabel('Diff');
axis([0 tvec(end) -0.5 8]); 
h(i) = getframe(h2);                % create object/snapshot of figure frame
writeVideo(writerObj,h(i));         % write to video object
end
close(writerObj);                   % close video object