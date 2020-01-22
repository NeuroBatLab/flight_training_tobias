fileFirst = load('C:\tobias\Ebenezer\200117\audio\170936\audio_trial_1');
audioAll = fileFirst.recbuf(:,end);

for file_i = 1:length(dir('C:\tobias\Ebenezer\200117\audio\170936\audio_trial_*'))-1
    
    fileCur = load(['C:\tobias\Ebenezer\200117\audio\170936\audio_trial_' num2str(file_i) '.mat']);
    fileNext = load(['C:\tobias\Ebenezer\200117\audio\170936\audio_trial_' num2str(file_i+1) '.mat']);
    
    event_ttls_cur = fileCur.recbuf(:,end); %trial data
    [R,LTcur,UT,LL,UL] = risetime(event_ttls_cur,fs); %find times of ttl pulses in SECONDS
    
    event_ttls_next = fileNext.recbuf(:,end); %trial data
    [R,LTnext,UT,LL,UL] = risetime(event_ttls_next,fs); %find times of ttl pulses in SECONDS
    
    extra_end = (length(event_ttls_cur)- (LTcur(end)*fs));
    extra_start = LTnext(1)*fs;
    
        cutOut = extra_end+extra_start-(3*fs);
     audioAll = vertcat(audioAll,event_ttls_next(cutOut+1:end));
    
    
    figure();
    subplot(4,1,1);
    plot(event_ttls_cur);
    hold on
    for i = 1:length(LTcur)
        plot(LTcur(i)*fs,0,'o')
    end
    
    subplot(4,1,2);
    plot(event_ttls_next);
    hold on
    for i = 1:length(LTnext)
        plot(LTnext(i)*fs,0,'o');
    end
    
    subplot(4,1,3);
    plot(event_ttls_next(cutOut+1:end))
    
    subplot(4,1,4);
    plot(audioAll);
    
end



