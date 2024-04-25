function processPupil_postprocessPlot(sampleFrame,frameVect,dataIn)
% processPupil_postprocessPlot(dataIn)
%
% Generates a summary plot of pupil measurements to evaluate the
% effectiveness of the pupil analysis algorithm.
% Plots to the current figure. If none exists, generates a new figure. 
%
% GHP April 2024

gcf
ax1 = subplot(3,4,[1,6]); hold on
plot(ax1,frameVect(~dataIn.isOutlier),dataIn.radius(~dataIn.isOutlier),'Color',[0.5 0.5 0.5]);
plot(ax1,frameVect(~dataIn.isOutlier),dataIn.semimajorAxis(~dataIn.isOutlier),'Color',[0.5 0.5 0.5]);
outlierScatter = scatter(ax1,frameVect(dataIn.isOutlier),dataIn.radius(dataIn.isOutlier),'xk');
scatter(ax1,frameVect(dataIn.isOutlier),dataIn.semimajorAxis(dataIn.isOutlier),'xk');

line1 = plot(ax1,frameVect,dataIn.radius_smoothed,'Color','b');
line2 = plot(ax1,frameVect,dataIn.semimajorAxis_smoothed,'Color','g');

title('Pupil Size')
ylabel('Pixels')
xlabel('Frame')
legend([line1 , line2, outlierScatter],...
    {'Radius (geometric mean)','Semimajor Axis','Outliers'},...
    'Location','northwest');

ax2 = subplot(3,4,[9,10]);
plot(ax2,frameVect,dataIn.alignmentSignal,'Color','r');
title('Alignment Signal');
ylabel('Pixel Value');
xlabel('Frame');

linkaxes([ax1,ax2],'x');

ax3 = subplot(3,4,[3,12]);
imshow(sampleFrame,'Parent',ax3);
hold(ax3,'on')
centerScatter = scatter(ax3,dataIn.centroid(1,~dataIn.isOutlier),...
    dataIn.centroid(2,~dataIn.isOutlier),'.g');
outlierScatter = scatter(ax3,dataIn.centroid(1,dataIn.isOutlier),...
    dataIn.centroid(2,dataIn.isOutlier),'xr');
legend([centerScatter , outlierScatter],{'Pupil Centers','Outliers'})