function fixed_MAP(audio_file)

global CNoutput dtSpikes ANoutput ICoutput


%run MAP model for audio at 60dBSPL
fileName=audio_file;%'./recordings/0_jackson_0.wav';%'./recordings/vowels_a.wav';%
runMAP1_14_DRNL([],fileName,[]);
%Use CN output
model_output=ICoutput(1+(end/2):end,:);

target_num_segs=60;
target_norm=zeros(size(model_output,1),target_num_segs);

PSTHbinwidth=0.05;%0.005;%seconds
dt=dtSpikes;%seconds

%post stimulus time histogram
PSTH=UTIL_PSTHmaker(model_output,dt,PSTHbinwidth);
%rates 
rates=PSTH./PSTHbinwidth;
%average aross neurons
AvRates=mean(PSTH,1)/PSTHbinwidth;

Onset= max(AvRates);
Saturated= mean(AvRates(round(length(AvRates)/2): end));

%figure;
%plot(rates);

norm=rates./max(max(rates));

%figure;
%plot(norm);

num_segs=size(norm,2);
%remove or add segments
%repeat num_segs in target
if target_num_segs > num_segs
    
    index=1;
    
    for i=1:target_num_segs
       
        check=mod(i,ceil(target_num_segs/num_segs));
        target_norm(:,i)=norm(:,index);
        if check==0
            index = index+1;
        end
    end
%drop some of num_segs in target
elseif num_segs > target_num_segs   
    nth=floor(num_segs/target_num_segs);
    for i=1:target_num_segs
              
        target_norm(:,i)=norm(:,i*nth);
    end    
%same size already    
else
    target_norm=norm;
end

%save final target data as .mat
out_file= ['./map_rates/' audio_file(14:end-4)];
%out_file= './map_rates/test';
save(out_file,'target_norm');

end
