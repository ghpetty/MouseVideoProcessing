%% Spike Alignment Sandbox
%loading spike times and TTL pulse times
spikedata=loadGoodSpikesFromPhy('/mnt/multiverse/homes/izzy/Recordings/Aneasthesia_recordings');
TTLPath='/mnt/multiverse/homes/izzy/Recordings/Aneasthesia_recordings/2024-05-11_18-37-19/Record Node 101/experiment1/recording3/events/Acquisition_Board-100.Rhythm Data/TTL';
contPath='/mnt/multiverse/homes/izzy/Recordings/Aneasthesia_recordings/2024-05-11_18-37-19/Record Node 101/experiment1/recording3/continuous/Acquisition_Board-100.Rhythm Data';
states=readNPY(fullfile(TTLPath,'states.npy'));
sample_numbers_TTL=readNPY(fullfile(TTLPath,'sample_numbers.npy'));
sample_numbers_cont=readNPY(fullfile(contPath,'sample_numbers.npy'));
full_words=readNPY(fullfile(TTLPath,'full_words.npy'));
sampleNumbersTTL_zeroed=sample_numbers_TTL-sample_numbers_cont(1);
SmoothTTL_on=sampleNumbersTTL_zeroed(states==1);
SmoothTTL_off=sampleNumbersTTL_zeroed(states==-1);
RoughTTL_on=sampleNumbersTTL_zeroed(states==2);
RoughTTL_off=sampleNumbersTTL_zeroed(states==-2);

sampleRate=30000;

%% 
LED_on_times=sort([RoughTTL_on;SmoothTTL_on]);
LED_off_times=sort([RoughTTL_off;SmoothTTL_off]);

my_cell={RoughTTL_on, RoughTTL_off; SmoothTTL_on, SmoothTTL_off; LED_on_times,LED_off_times};
my_table=cell2table(my_cell, "RowNames", ["rough", "smooth", "LED"] , "VariableNames",["StartInds","EndInds"]);
BehaviorDataTable=my_table;
%% Plotting
% spiketimes=spikedata(1).SpikeTimes;
% window=[-2,6]*30000;
% [allTimes,eventTimes,eventInds,nEvents,eventMatrix] = alignEvents(SmoothTTL_on,spiketimes,window);
% %%
% figure;
% spikeMat_raster(eventMatrix,sampleRate);
sandboxpath='/mnt/multiverse/homes/izzy/matlab-scripts/Sandboxes';
output_folder=fullfile(sandboxpath,'clusterRasterPlots');

if ~exist(output_folder,'dir')
    mkdir(output_folder)
end

% for i=1:length(spikedata)
%     spiketimes=spikedata(i).SpikeTimes;
%     window=[-2,6]*30000;
%     myfig=figure;
%     [allTimes,eventTimes,eventInds,nEvents,eventMatrix] = alignEvents(SmoothTTL_on,spiketimes,window);
%     subplot(2,1,1)
%     spikeMat_raster(eventMatrix,sampleRate);
%     title('smooth stimulus aligned')
%     [allTimes,eventTimes,eventInds,nEvents,eventMatrix] = alignEvents(RoughTTL_on,spiketimes,window);
%     subplot(2,1,2)
%     spikeMat_raster(eventMatrix,sampleRate);
%     title('rough stimulus aligned')
%     drawnow
% 
%     currentcluster=num2str(spikedata(i).ClusterID);
%     figFileName=['cluster_', currentcluster, '_raster_plot.fig'];
%     savefig(myfig,fullfile(output_folder,figFileName));
% end

%% Save output data
% firstSample_cont=sample_numbers_cont(1);
% outputfile=fullfile(sandboxpath,'output_data.mat');
% save(outputfile,'spikedata','SmoothTTL_on', 'SmoothTTL_off', 'RoughTTL_on', 'RoughTTL_off', 'firstSample_cont','sample_numbers_TTL',...
%    'states');
outputfile=fullfile(TTLPath,'BehaviorDataTable.mat');
save(outputfile,"BehaviorDataTable");
