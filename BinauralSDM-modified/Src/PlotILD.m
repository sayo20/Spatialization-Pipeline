% Load the MAT file containing spectrogram
spk1_90 = load("/Users/u618151/Desktop/Work/Datasets/Sppatializatio_Data/Re-createdCorrectly/Spatialization Pipeline/CenterExample/Sounds/spk1_90_ild.mat");
spk2_270 = load("/Users/u618151/Desktop/Work/Datasets/Sppatializatio_Data/Re-createdCorrectly/Spatialization Pipeline/CenterExample/Sounds/spk2_-90_ild.mat");




% Plot spectrogram of file 1
subplot(1, 3, 1);
imagesc(spk1_90.ILD_inDB_mn_);
colormap(redwhiteblue(-5,5));
caxis([-5, 5]);  % Set color axis limits
colorbar;
title('Speaker 1 at 90');
set(gca,'YDir', 'normal');

% Plot spectrogram of file 2
subplot(1, 3, 2);
imagesc(spk2_270.ILD_inDB_mn_);
colormap(redwhiteblue(-5,5));
caxis([-5, 5]);  % Set color axis limits
colorbar;
title('Speaker 1 at -90');
set(gca,'YDir', 'normal');

% Sum the two signals and plot the spectrogram
sum_data = spk1_90.ILD_inDB_mn_ + spk2_270.ILD_inDB_mn_;
subplot(1, 3, 3);
imagesc(sum_data);
caxis([-5, 5]);  % Set color axis limits
title('Speaker 1 + speaker 2');
set(gca,'YDir', 'normal');
colormap(redwhiteblue(-5,5)); % Set colormap to redwhiteblue
colorbar;
