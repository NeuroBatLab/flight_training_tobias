function run_hpt_training_tobias(varargin)

global h_directory h_run h_stop
global h_probfeed1 h_probfeed2 h_probfeed3 h_probfeed4
global lightbar1 lightbar2 lightbar3 lightbar4
global feed1 feed2 feed3 feed4 ard trg
global h_interfeedtime h_rewardur h_rewardspeed
global h_feed1 h_feed2 h_feed3 h_feed4
global h_correct h_trials h_repeat batName

%create a new behavioral file in the designated directory
bhv_data.fields = {'prob_feed1','prob_feed2','prob_feed3','prob_feed4','inter_feed_time','reward_duration','reward_speed','correct_feeder','chosen_feeder','trial_outcome','trigger_time'};
dateString = datetime('now','Format','yyMMdd');
dateString = char(dateString);
bhv_data.directory = [h_directory.String filesep batName.String filesep dateString];
bhv_data.trials = [];
%make directory if it doesn't already exist
if ~isdir(bhv_data.directory)
    mkdir(bhv_data.directory)
end

c = clock;
bhvfile = [bhv_data.directory filesep 'bhv_' batName.String '_' date '_' num2str(c(4)) '-' num2str(c(5))];
save(bhvfile,'bhv_data');

tcounter = 0;
ncorrect = 0;
lastfeed = 0;
while h_stop.Value < 1
    
    feedwait = tic;
    
    %set feeder parameters
    feed_speed = str2double(h_rewardspeed.String);
    rew_dur = str2double(h_rewardur.String);
    interfeed_time = str2double(h_interfeedtime.String);
    
    feed1.Speed = feed_speed; feed2.Speed = feed_speed; feed3.Speed = feed_speed; feed4.Speed = feed_speed;
    
    %determine which feeder will feed, based on probability data

    pf(1) = str2double(h_probfeed1.String); %see if > rand, and make a 0 or 1
    pf(2) = str2double(h_probfeed2.String);
    pf(3) = str2double(h_probfeed3.String);
    pf(4) = str2double(h_probfeed4.String);
        
    lb1 = 1; lb2 = 1; lb3 = 1; lb4 = 1;
    
    %wait for bat to activate feeder by interrupting light barrier, or for the stop or feed buttons to be pressed
    while lb1 == 1 && lb2 == 1 && lb3 == 1 && lb4 && h_stop.Value < 1 && h_stop.Value < 1 && h_feed1.Value < 1 && h_feed2.Value < 1 && h_feed3.Value < 1 && h_feed4.Value < 1
        lb1 = readDigitalPin(ard,lightbar1); lb2 = readDigitalPin(ard,lightbar2); lb3 = readDigitalPin(ard,lightbar3); lb4 = readDigitalPin(ard,lightbar4);
        drawnow
    end
    
    %determine if a light bar is broken, if stop was hit, or if the a feed button was pressed
    %quit if stop button pressed
    if h_stop.Value < 1
        %determine if feeder was activated by light bar
        if ~isempty(find([lb1 lb2 lb3 lb4] < 1))
            tcounter = tcounter + 1;
            h_trials.String = num2str(tcounter); drawnow %update gui
            
            %trigger motion tracking and save time
            writeDigitalPin(ard,trg,1);
            c = clock;
            trigger_time = ((c(4)*60+c(5))*60) + c(6); %converted to seconds
            pause(.05)
            writeDigitalPin(ard,trg,0);
            
            %feed if correct
            active_feeder = find([lb1 lb2 lb3 lb4] < 1);
            correct = 0;
             if h_repeat.Value || (active_feeder ~= lastfeed)
                if pf(active_feeder) >= (rand*100)
                    feeder_name = ['feed' num2str(active_feeder)];
                    start(eval(feeder_name));
                    pause(rew_dur);
                    stop(eval(feeder_name));
                    ncorrect = ncorrect + 1;
                    correct = 1;
                    lastfeed = active_feeder;
                    h_correct.String = num2str(ncorrect); drawnow %update gui
                end
             end
            
            tt = tic; %start clock to keep track of animal at feeder
            %bhv_data.fields = {'prob_feed1','prob_feed2','prob_feed3','prob_feed4','inter_feed_time','reward_duration','reward_speed','correct_feeder','chosen_feeder','trial_outcome'};
            bhv_data.trials(tcounter,:) = [pf(1) pf(2) pf(3) pf(4) interfeed_time rew_dur feed_speed active_feeder correct trigger_time];
                    save(bhvfile,'bhv_data');
            
            %make sure the animal has left the feeder for the designated amount of time
            while toc(tt) < interfeed_time
                if readDigitalPin(ard,lightbar1) ~= 1 || readDigitalPin(ard,lightbar2) ~= 1 || readDigitalPin(ard,lightbar3) ~= 1 || readDigitalPin(ard,lightbar4) ~= 1
                    tt = tic; %restart the clock
                end
            end
        else
            %if feeder not activated by light bar then it must be feed button
            feed
        end
    end
end

%reset the values of the run and stop toggle buttons to zero
h_run.Value = 0;
h_stop.Value = 0;


