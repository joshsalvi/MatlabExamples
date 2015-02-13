function rgbslider2
%%%%% Generate and plot data
r1=0.5;g1=0.5;r0=linspace(0.1,0.9,1e3);g0=linspace(0.1,0.9,1e3);
subplot(1,2,1);a=scatter(0,1,50000,[r0(1) g0(end) 0],'filled');axis off;
subplot(1,2,2);scatter(0,1,50000,[r1 g1 0],'filled');axis off;

%%%%% Set appropriate axis limits and settings
set(gcf,'doublebuffer','on');

%%%%% Generate constants for use in uicontrol initialization
pos=get(a,'position');
Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];

% This will create a slider which is just underneath the axis
% but still leaves room for the axis labels above the slider
r0m=max(r0);

S=['set(gca,''xlim'',get(gcbo,''value'')+[0 ' num2str(r0(j)/g0(k)) '])'];
% Setting up callback string to modify XLim of axis (gca)
% based on the position of the slider (gcbo)
%%%%% Creating Uicontrol
h=uicontrol('style','slider',...
      'units','normalized','position',Newpos,...
      'callback',S,'min',0,'max',r0m);
