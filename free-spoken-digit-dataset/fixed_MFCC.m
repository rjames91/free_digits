function fixed_MFCC(audio_file)
%open audio file & read Fs
%[input_sound,fs]=audioread('./recordings/0_jackson_0.wav');
[input_sound,fs]=audioread(audio_file);

%args: segment size, overlap size, target number of segments
segment_size=512;
overlap_size=segment_size/2;
target_num_segs=20;%1200; %(150ms @ 8kHz)

%fft_size=round((segment_size-overlap_size + 1)/2);
fft_size=segment_size;

target_segs=zeros(target_num_segs,fft_size);

%measure total time length
input_time_length=length(input_sound)/fs;

%calculate if integer number of segments will fit into input sound
modulus=mod(length(input_sound),segment_size-overlap_size);

%pad zeros if necessary
if modulus   
    input_sound=[input_sound',zeros(1,segment_size-overlap_size-modulus)];    
else
    input_sound=input_sound';
end

num_segs=length(input_sound)/(segment_size-overlap_size)-1;

segs=zeros(num_segs,fft_size);

%perform hamming window then FFT on each segment
for i=1:num_segs
    
    index =(i-1) * (segment_size-overlap_size);
    index(index<=0)=1;
    %chunk = input_sound(1,index:index+(segment_size-overlap_size)-1);

    chunk = input_sound(1,index:index+segment_size-1);

    chunkh=chunk.*hamming(size(chunk,2))';
    %[f,Y]= FFT(chunkh,fs);
    %segs(i,:,:)=[f;Y];
    %segs(i,:)=Y;
    segs(i,:)=abs(fft(chunkh));
end   

%assemble target file (x dim: seg, y dim: freq/mag, z dim: value

index=1;
%repeat num_segs in target
if target_num_segs > num_segs
    for i=1:target_num_segs
       
        check=mod(i,ceil(target_num_segs/num_segs));
        target_segs(i,:)=segs(index,:);
        if check==0
            index = index+1;
        end
    end
%drop some of num_segs in target
elseif num_segs > target_num_segs   
    nth=floor(num_segs/target_num_segs);
    for i=1:target_num_segs
              
        target_segs(i,:)=segs(i*nth,:);
    end    
%same size already    
else
    target_segs=segs;
end
    
%Mel-scale & Log magnitude map
%Filter bank parameters
lowestFrequency = 133.3333;
linearFilters = 13;
linearSpacing = 66.66666666;
logFilters = 27;
logSpacing = 1.0711703;
cepstralCoefficients = 13;

% Keep this around for later....
totalFilters = linearFilters + logFilters;

% Figure out Discrete Cosine Transform.  We want a matrix
% dct(i,j) which is totalFilters x cepstralCoefficients in size.
% The i,j component is given by 
%                cos( i * (j+0.5)/totalFilters pi )
% where we have assumed that i and j start at 0.
mfccDCTMatrix = 1/sqrt(totalFilters/2)*cos((0:(cepstralCoefficients-1))' * ...
				(2*(0:(totalFilters-1))+1) * pi/2/totalFilters);
mfccDCTMatrix(1,:) = mfccDCTMatrix(1,:) * sqrt(2)/2;


% Now figure the band edges.  Interesting frequencies are spaced
% by linearSpacing for a while, then go logarithmic.  First figure
% all the interesting frequencies.  Lower, center, and upper band
% edges are all consequtive interesting frequencies. 

freqs = lowestFrequency + (0:linearFilters-1)*linearSpacing;
freqs(linearFilters+1:totalFilters+2) = ...
		      freqs(linearFilters) * logSpacing.^(1:logFilters+2);

lower = freqs(1:totalFilters);
center = freqs(2:totalFilters+1);
upper = freqs(3:totalFilters+2);

% We now want to combine FFT bins so that each filter has unit
% weight, assuming a triangular weighting function.  First figure
% out the height of the triangle, then we can figure out each 
% frequencies contribution
mfccFilterWeights = zeros(totalFilters,fft_size);
triangleHeight = 2./(upper-lower);
fftFreqs = (0:fft_size-1)/fft_size*fs;

for chan=1:totalFilters
	mfccFilterWeights(chan,:) = ...
  (fftFreqs > lower(chan) & fftFreqs <= center(chan)).* ...
   triangleHeight(chan).*(fftFreqs-lower(chan))/(center(chan)-lower(chan)) + ...
  (fftFreqs > center(chan) & fftFreqs < upper(chan)).* ...
   triangleHeight(chan).*(upper(chan)-fftFreqs)/(upper(chan)-center(chan));
end

%DCT to obtain cepstrum coefficients
ceps=zeros(cepstralCoefficients,target_num_segs);
for i=1:target_num_segs
    earMag = log10(mfccFilterWeights * target_segs(i,:)');
    ceps(:,i)= mfccDCTMatrix * earMag;    
end
%save final target data as .mat
out_file= ['./mfcc/' audio_file(14:end-4)];
save(out_file,'ceps');
