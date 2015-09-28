function res_table=extract()

% NB: there's a fix against bad XP start/stop

tag='validation_PPG';

% subfolder for recording sessions (also tag for res_table)
studiedSet = 'replay'

construct = {'ecg', 'ppg'};

% how many sessions
nbSubjects=3;

% 128Hz (python box sampling rate) to 8hz
downsamplingFactor = 16;

% main path for data
dataPath = '~/bluff_game/data_validation/';

% codes used to tag start/end XP
stimXpStart = 32769; % OVTK_StimulationId_ExperimentStart
stimXpStop = 32770; % OVTK_StimulationId_ExperimentStop

% will spam this folder with data
outputFolder = [dataPath, 'results/'];

% load eeglab
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

% holder for general table
res_table = cell2table(cell(0,7), 'VariableNames',{'set' 'subject' 'construct' 'channel' 'points' 'n' 'time'});

for s=1:nbSubjects
    disp(['Subject: ', num2str(s)])
    inPath = [dataPath, '/', studiedSet, '/', num2str(s), '/'];
    for cons=1:length(construct)
        disp(['Construct: ', construct{cons}])
        % load data
        inFilename = [construct{cons}, '-bpm.gdf'];
        disp(['Loading: ', inPath, inFilename]); 
        DATA = pop_biosig([inPath, inFilename]);
        
        % seek XP start / stop events
        XP_start_idx = find([DATA.event.type] == stimXpStart);
        XP_start = DATA.event(XP_start_idx).latency;
        XP_stop_idx = find([DATA.event.type] == stimXpStop);
        XP_stop = DATA.event(XP_stop_idx).latency;
        disp(['Found start XP point: ', num2str(XP_start)])
        disp(['Found stop XP point: ', num2str(XP_stop)])

        % ok, I do not know how to press keys, I did wrong with on a
        % the recordings. wild guess about true end as compared to
        % other recordings
        if ( XP_stop < XP_start )
            XP_stop = DATA.pnts - 1000;
            disp(['Hotfix for stop XP: ', num2str(XP_stop)])
        end
            
        % retrieve data of each channel, downsample
        for chan=1:DATA.nbchan
            chanName = DATA.chanlocs(chan).labels;
            disp(['Channel: ', chanName])
            points = DATA.data(chan,:);
            
            % select points corresponding to actual XP
            points_select = points(XP_start:XP_stop);
            
            % don't care about aliasing here
            points_down = downsample(points_select, downsamplingFactor);

            nbPoints = length(points_down);
            newSrate = DATA.srate/downsamplingFactor;
            n = 1:nbPoints;
            time = n/newSrate;

            sub_table = table( ...
                    repmat({studiedSet}, nbPoints, 1), ...
                    repmat(s, nbPoints, 1), ...
                    repmat({construct{cons}}, nbPoints, 1), ...
                    repmat({chanName}, nbPoints, 1), ...
                    points_down', ...
                    n', ...
                    time', ...
                    'VariableNames',{'set' 'subject' 'construct' 'channel' 'points' 'n' 'time'});
            res_table = [res_table;sub_table];  
        end
    end
end

% we don't want to overwhite anything if parameters are different, big name
% to hold it all
name_subjects = [num2str(nbSubjects), 'sub'];
name_construct = strjoin(construct,'-');
outputFilename = [outputFolder, tag, '_', studiedSet, '_', name_subjects, '_', name_construct];
% export overall results
disp(['Saving results to: ', outputFilename])
save([outputFilename, '.mat'], 'res_table');
writetable(res_table,[outputFilename, '.csv']);

end




