function slide1
h = surf(peaks(20));
CD = get(h,'cdata');
Min = min(CD(:));
Max = max(CD(:));
cb=colorbar;
DeltaC = (Max-Min)/10;
set(cb,'units','normalized','ylim',Min+[0 1]);
Pos=get(cb,'position');
S=['set(findobj(gcf,''tag'',''Colorbar''),''YLim'',get(gcbo,''Value'')+[0 ' num2str(DeltaC) '])'];
uic=uicontrol('style','slider','units','normalized',...
      'position',[Pos(1)+0.11 Pos(2) 0.04 Pos(4)],...
      'min',Min,'max',Max-DeltaC,'value',Min,...
      'callback',S);
