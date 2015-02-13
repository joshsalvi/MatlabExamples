function RGBsliderdemo(varargin)
%
% This functions initializes a color on the right that combines red and
% green channels with another spot of color on the left that uses a slider
% to adjust the relative levels of red and green.

    f = figure(1);

    %// Make initial plot
    A = 0.1;
    if isempty(varargin{1}) == 1
        R = 0.6;
    end
    if isempty(varargin{2}) == 1
        G = 0.5;
    end
    p = subplot(1,2,1);scatter(0,1,50000,[A G 0],'filled');axis off;
    title(['R = ' num2str(A) '   G = ' num2str(G)]);
    subplot(1,2,2);scatter(0,1,50000,[R G 0],'filled');axis off;
    title(['R = ' num2str(R) '   G = ' num2str(G)]);

    %// initialize the slider
    h = uicontrol(...
        'parent'  , f,...        
        'units'   , 'normalized',...   
        'style'   , 'slider',...        
        'position', [0.05 0.05 0.9 0.05],...
        'min'     , 0.05,...               
        'max'     , 0.95,...             
        'value'   , A,...               
        'callback', @sliderCallback);   
    h2 = uicontrol(...
        'parent'  , f,...        
        'units'   , 'normalized',...   
        'style'   , 'slider',...        
        'position', [0.05 0.1 0.9 0.05],...
        'min'     , 0.05,...               
        'max'     , 0.95,...             
        'value'   , 0.7,...               
        'callback', @sliderCallback); 


    hLstn = handle.listener(h,'ActionEvent',@sliderCallback); 
    hLstn2 = handle.listener(h2,'ActionEvent',@sliderCallback); 

    % The slider's callback:
    function sliderCallback(~,~)
        delete(p);
        %p = plot(x, y(get(h,'value')));
        p = subplot(1,2,1);scatter(0,1,50000,[get(h,'value') get(h2,'value') 0],'filled');axis off;
        title(['R = ' num2str(get(h,'value')) '   G = ' num2str(get(h2,'value'))]);
        subplot(1,2,2);scatter(0,1,50000,[R G 0],'filled');axis off;
        title(['R = ' num2str(R) '   G = ' num2str(G)]);
    end

end
