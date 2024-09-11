
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   biofeedback_isometric
%
%   ~
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reset setting
clear

% Connect to QTM
ip = '127.0.0.1';
% Connects to QTM and keeps the connection alive.
QCM('connect', ip, 'frameinfo', 'force');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a figure window
figureHandle = figure('Position', [300, 300, 1200, 600], 'Name', 'ML Force Feedback', 'NumberTitle','off', 'Color', [0.8, 0.8, 0.8]);
hold on

% set the figure size
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
% remove ticks from axes
set(gca,'YTick',[])

xlim=[-600, 600];
ylim=[0, 500];

% set limits for axes
set(gca, 'xlim', xlim, 'ylim',ylim)

% center coordinate for figure size
centerpoint = [(xlim(1) + xlim(2)) / 2, (ylim(1) + ylim(2)) / 2];

% each bar width
width = 100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% draw outlines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
title(sprintf('Difference Vertical GRF\n  Left              Right'), 'FontSize', 30);

% center line
plot([centerpoint(1), centerpoint(1)], get(gca, 'ylim'), 'LineWidth', 3,'Color','black');

% make handles for each bar to update Medial Lateral Force
diff_bar = barh(centerpoint(2), 0, 'FaceColor','black', 'BarWidth', width);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRF data list for measuring maximal medial/lateral force
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% max iteration is 100,000 for preallocation, because of speed
grf_array = zeros(1, 100000);
i = 1;

while ishandle(figureHandle)
    try
        event = QCM('event');
        [frameinfo, force] = QCM;
        
        % get GRF Z from plate 1,2 unit: kgf
        try
            GRF1 = (force{2,2}(1,3)); % right
            GRF2 = (force{2,1}(1,3)); % left
        catch exception
            continue;
        end

        diff_grf = GRF2 - GRF1;
        
        % Update each bar
        diff_bar.YData = diff_grf;

        grf_array(i) = diff_grf;
        i = i+1;

        drawnow;
    
    catch exception
        disp(exception.message);
        break;
    end       
end

delete(figureHandle);
