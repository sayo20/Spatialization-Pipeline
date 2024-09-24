% Define the source positions and microphone position
% source_positions = [5.6,4.5,1.25; 2.6,4.5,1.25; 4,5.9,1.25; 4.0,3.1,1.25];  % Four source positions (x, y)
% source_positions = [4,5.9,1.25; 4,3.1,1.25; 2.6,4.5,1.25; 5.4, 4.5,1.25]; %rolled

% source_positions = [5.6,4.5,1.25; 2.6,4.5,1.25; 4,5.9,1.25; 4.0,3.1,1.25];  % Four source positions (x, y)
source_positions = [1.4, 4.8,1.25; 0.0, 3.4,1.25; 1.4,2.0,1.25; 2.8,3.4,1.25]; %rolled5.352296156804695 4.137653336856471

% source_270 =[4,3.1,1.25]#180
% source_90 =[4,5.9,1.25]#360
% source_180 =[2.6,4.5,1.25] #90
% source_0 =[5.4, 4.5,1.25]
% mic_position = [4.       , 4.5      , 1.25 ];                    % Microphone position (x, y)
mic_position=[1.4      , 3.4      , 1.25  ]
% source_label ={'0', '345','180', '90', '270'};
source_label ={'0', '90','180', '270'};
% Define colors for each source
source_colors = ['r', 'g', 'y','b', 'm'];  % Red, green, blue, magenta

% Create a scatter plot
figure;
for i = 1:size(source_positions, 1)
    scatter(source_positions(i, 1), source_positions(i, 2), 'o', 'filled', 'MarkerFaceColor', source_colors(i));
    hold on;
end

scatter(mic_position(1), mic_position(2), 's', 'filled', 'MarkerFaceColor', 'k');  % Black square for the microphone

% Set axis labels and title
xlabel('X-axis');
ylabel('Y-axis');
title('Source and Microphone Positions');

% Add a legend
% legend(['0', '180', '90', '270', 'center mic'], 'Location', 'Best');
% Create a legend with appropriate color labels
% Create a legend with source labels and appropriate colors
legend_str = cell(size(source_positions, 1) + 1, 1);  % Initialize cell array for legend entries
for i = 1:size(source_positions, 1)
    legend_str{i} = sprintf('Source %s (%s)', num2str(i), source_label{i});  % Include source number and label
end
legend_str{end} = 'Microphone';
legend(legend_str, 'Location', 'Best');
% Optionally, save the plot as an image
% saveas(gcf, 'source_mic_plot.png');

% Hold off to end plotting
hold off;



