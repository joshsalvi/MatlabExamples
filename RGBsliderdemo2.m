function RGBsliderdemo2
%
% This functions initializes a color on the right that combines red and
% green channels with another spot of color on the left that uses a slider
% to adjust the relative levels of red and green.

    f = figure(1);

    %// Make initial plot
    A = 0.3;
    R = 0.55;
    G = 0.45;
    p = subplot(1,2,1);scatter(0,1,50000,[A 1-A 0],'filled');axis off;
    title(['R = ' num2str(A) '   G = ' num2str(1-A)]);
    subplot(1,2,2);scatter(0,1,50000,[R G 0],'filled');axis off;
    title(['R = ' num2str(R) '   G = ' num2str(G)]);

    %// initialize the slider
    h = uicontrol(...
        'parent'  , f,...        
        'units'   , 'normalized',...   
        'style'   , 'slider',...        
        'position', [0.05 0.05 0.9 0.05],...
        'min'     , 0.2,...               
        'max'     , 0.8,...             
        'value'   , A,...               
        'callback', @sliderCallback);   


    hLstn = handle.listener(h,'ActionEvent',@sliderCallback); 

    % The slider's callback:
    function sliderCallback(~,~)
        delete(p);
        %p = plot(x, y(get(h,'value')));
        p = subplot(1,2,1);scatter(0,1,50000,[get(h,'value') 1-get(h,'value') 0],'filled');axis off;
        title(['R = ' num2str(get(h,'value')) '   G = ' num2str(1-get(h,'value'))]);
        subplot(1,2,2);scatter(0,1,50000,[R G 0],'filled');axis off;
        title(['R = ' num2str(R) '   G = ' num2str(G)]);
    end

end
