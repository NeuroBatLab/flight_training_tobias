function honey_pot_training_tobias(varargin)

%clear all
%the "honey pot task" requires the bat to learn which of the 4 feeders
%feeds with the highest probability

% User inputs overrides
name = [];
nparams=length(varargin);
for i=1:2:nparams
    switch lower(varargin{i})
        case 'batname'
           name=varargin{i+1};
        end
end


global h_directory h_run h_stop
global h_probfeed1 h_probfeed2 h_probfeed3 h_probfeed4
global lightbar1 lightbar2 lightbar3 lightbar4
global feed1 feed2 feed3 feed4 ard trg
global h_interfeedtime h_rewardur h_rewardspeed
global h_feed1 h_feed2 h_feed3 h_feed4 
global h_correct h_trials h_repeat
global IDsound fs rec_dur input_channels batName

%create behavioral file
% initialize arduino
trg = 'D7';
lightbar1 = 'D3';
lightbar2 = 'D2';
lightbar3 = 'D4';
lightbar4 = 'D5';
MOT1 = 2;
MOT2 = 1; 
MOT3 = 3;
MOT4 = 4;
ard=arduino('com13','uno','Libraries','Adafruit\MotorShieldV2');
shield=addon(ard,'Adafruit\MotorShieldV2');
configurePin(ard,trg,'pullup');
configurePin(ard,lightbar1,'pullup');
configurePin(ard,lightbar2,'pullup');
configurePin(ard,lightbar3,'pullup');
configurePin(ard,lightbar4,'pullup');
configurePin(ard,trg,'DigitalOutput');
writeDigitalPin(ard,trg,0);
feed1=dcmotor(shield,MOT1);
feed2=dcmotor(shield,MOT2);
feed3=dcmotor(shield,MOT3);
feed4=dcmotor(shield,MOT4);

%audio
IDsound = 'ASIO HDSPe FX';
fs = 192000;
rec_dur = 11; %set to 11 so that ttl will be included
input_channels = 0:6;

%set seed
rand('state',sum(100*clock));

%create gui
h_fig = figure('name','Honey Pot Training Tobias','Position',[65 143 300 500],'ToolBar','none','DockControls','on','MenuBar','none');  

%default directory
h_dir = uicontrol(h_fig,'Style','text','String','Directory','units','normalized',...
   'Position',[.01 .84 .3 .05],'fontsize',9,'fontweight','b'); 
h_directory = uicontrol(h_fig,'Style','edit','String','C:\tobias' ,'units','normalized',...
    'Position',[.01 .80 .96 .05],'fontsize',9,'fontweight','b');

%default batName
h_bat = uicontrol(h_fig,'Style','text','String','Bat Name','units','normalized',...
   'Position',[.01 .74 .3 .05],'fontsize',9,'fontweight','b'); 
batName = uicontrol(h_fig,'Style','edit','String',name,'units','normalized',...
    'Position',[.01 .70 .96 .05],'fontsize',9,'fontweight','b');

%hitting run starts the task
h_run = uicontrol(h_fig,'Style','togglebutton','String','Run','units','normalized',...
    'Position',[.01 .9 .3 .1],'Callback',@run_hpt_training_tobias,'fontsize',10,'fontweight','b','tag','run');

%stop task
h_stop = uicontrol(h_fig,'Style','togglebutton','String','Stop','units','normalized',...
    'Position',[.32 .9 .3 .1],'fontsize',10,'fontweight','b','tag','run');

%Prob feed 1
h_pf1 = uicontrol(h_fig,'Style','text','String','Feed1 (%)','units','normalized',...
   'Position',[.32 .54 .3 .05],'fontsize',9,'fontweight','b'); 
h_probfeed1 = uicontrol(h_fig,'Style','edit','String','0','units','normalized',...
    'Position',[.32 .5 .3 .05],'fontsize',9,'fontweight','b');

%Prob feed 2
h_pf2 = uicontrol(h_fig,'Style','text','String','Feed2 (%)','units','normalized',...
   'Position',[.32 .44 .3 .05],'fontsize',9,'fontweight','b'); 
h_probfeed2 = uicontrol(h_fig,'Style','edit','String','0','units','normalized',...
    'Position',[.32 .4 .3 .05],'fontsize',9,'fontweight','b');

%Prob feed 3
h_pf3 = uicontrol(h_fig,'Style','text','String','Feed3 (%)','units','normalized',...
   'Position',[.32 .34 .3 .05],'fontsize',9,'fontweight','b'); 
h_probfeed3 = uicontrol(h_fig,'Style','edit','String','100','units','normalized',...
    'Position',[.32 .3 .3 .05],'fontsize',9,'fontweight','b');

%Prob feed 4
h_pf4 = uicontrol(h_fig,'Style','text','String','Feed4 (%)','units','normalized',...
   'Position',[.32 .24 .3 .05],'fontsize',9,'fontweight','b'); 
h_probfeed4 = uicontrol(h_fig,'Style','edit','String','100','units','normalized',...
    'Position',[.32 .2 .3 .05],'fontsize',9,'fontweight','b');

%repeat
h_repeat = uicontrol(h_fig,'Style','togglebutton','String','Repeat','units','normalized',...
    'Position',[.01 .6 .3 .05],'fontsize',10,'fontweight','b','tag','run');
h_repeat.Value = true;

%feed1
h_feed1 = uicontrol(h_fig,'Style','pushbutton','String','Feed1','units','normalized',...
    'Position',[.01 .5 .3 .05],'Callback',@feed,'fontsize',10,'fontweight','b','tag','run');

%feed2
h_feed2 = uicontrol(h_fig,'Style','pushbutton','String','Feed2','units','normalized',...
    'Position',[.01 .4 .3 .05],'Callback',@feed,'fontsize',10,'fontweight','b','tag','run');

%feed3
h_feed3 = uicontrol(h_fig,'Style','pushbutton','String','Feed3','units','normalized',...
    'Position',[.01 .3 .3 .05],'Callback',@feed,'fontsize',10,'fontweight','b','tag','run');

%feed4
h_feed4 = uicontrol(h_fig,'Style','pushbutton','String','Feed4','units','normalized',...
    'Position',[.01 .2 .3 .05],'Callback',@feed,'fontsize',10,'fontweight','b','tag','run');

%Inter feed time
h_ift = uicontrol(h_fig,'Style','text','String','IFT (s)','units','normalized',...
   'Position',[.01 .1 .3 .05],'fontsize',9,'fontweight','b'); 
h_interfeedtime = uicontrol(h_fig,'Style','edit','String','0.2','units','normalized',...
    'Position',[.01 .06 .3 .05],'fontsize',9,'fontweight','b');

%Reward duration
h_rd = uicontrol(h_fig,'Style','text','String','RD (s)','units','normalized',...
   'Position',[.32 .1 .3 .05],'fontsize',9,'fontweight','b'); 
h_rewardur = uicontrol(h_fig,'Style','edit','String','0.2','units','normalized',...
    'Position',[.32 .06 .3 .05],'fontsize',9,'fontweight','b');

%Reward speed
h_rs = uicontrol(h_fig,'Style','text','String','RS','units','normalized',...
   'Position',[.63 .1 .3 .05],'fontsize',9,'fontweight','b'); 
h_rewardspeed = uicontrol(h_fig,'Style','edit','String','1','units','normalized',...
    'Position',[.63 .06 .3 .05],'fontsize',9,'fontweight','b');

%number of correct trials
h_corr = uicontrol(h_fig,'Style','text','String','#Correct','units','normalized',...
   'Position',[.63 .54 .3 .05],'fontsize',9,'fontweight','b'); 
h_correct = uicontrol(h_fig,'Style','text','String','0','units','normalized',...
    'Position',[.63 .5 .3 .05],'fontsize',9,'fontweight','b');

%number of trials
h_tr = uicontrol(h_fig,'Style','text','String','#Trials','units','normalized',...
   'Position',[.63 .44 .3 .05],'fontsize',9,'fontweight','b'); 
h_trials = uicontrol(h_fig,'Style','text','String','0','units','normalized',...
    'Position',[.63 .4 .3 .05],'fontsize',9,'fontweight','b');
