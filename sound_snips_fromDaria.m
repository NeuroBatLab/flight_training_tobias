          rec_dur=15;
input_channels=0:6;
fs=192e3;


if 1 ~= soundmexpro('init','driver',IDsound,'samplerate',fs,...
                'input',input_channels,'output',output_channels,'track',tracksnr);
            error(['error calling ''init''' error_loc(dbstack)]);
        end
        [ret,fs,bufsiz]=soundmexpro('getproperties');
        soundmexpro( 'recbufsize', 'value', rec_dur*fs);
        soundmexpro('recpause','value', ones(1,length(input_channels)),...
            'channel',input_channels);
        
 

 [succ,recbuf,pos]=soundmexpro('recgetdata','channel',input_channels);
 
   wavname=['.\' audiofn '\' audsstr '\LabNavextend_' batname ...
        '_' datestr(timex,30) '_tn' num2str(current_trial)];
    audiowrite([wavname '.wav'],recbuf,fs);