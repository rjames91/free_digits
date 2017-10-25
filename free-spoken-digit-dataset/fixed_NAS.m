function [rates] = fixed_NAS(file,bin_width,window_width,dir,num_chans)

%load input AEDAT
[ID,times]=loadaerdat(file);%loadaerdat('0a9f9af7_nohash_0.wav.aedat');
squashed=[double(ID)+1,round(double(times).*0.0002)];
%unique_ids = unique(squashed(:,1),'rows');
unique_ids= num_chans;

time = max(squashed(:,2)) - min(squashed(:,2));

%create rates matrix
rates = zeros(unique_ids,ceil(time/bin_width));

%increment through each ID and sort spikes into bins
spikes=zeros(unique_ids,1);
last_time = squashed(1,2);

for t = 1:ceil(time/bin_width)

    block = squashed(squashed(:,2)<last_time+bin_width & squashed(:,2)>=last_time,:);

    for i=1:size(block,1)
       try
        spikes(block(i,1))=spikes(block(i,1))+1;
       catch 
           print ooops
       end
            
    end
    
    last_time = last_time + bin_width;
    rates(:,t) = spikes./(bin_width*0.001);
    spikes=zeros(unique_ids,1);

end

%pad rate matrix with window width zeros
rates = [zeros(size(rates,1),window_width-1),rates,zeros(size(rates,1),window_width-1)];
%loop across overlapping windows to generate final output data
for i = 1:size(rates,2)-window_width
    stripped_file_name = strsplit(file,'/');
    stripped_file_name = cell2mat(stripped_file_name(end));
    out_file_name = ['./NAS_rates/',strcat(stripped_file_name(1:9),sprintf('%d',i)),'_',dir];
    out_var = rates(:,i:i+window_width-1); 
    save(out_file_name,'out_var');
end

end
