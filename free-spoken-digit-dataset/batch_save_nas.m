
directory=['./NAS_recordings/more_reduc_vol50/left/'];
files = dir(directory);

bin_width = 20;
window_width = 50;
num_channels = 64;

A = [];
B = [];

for  i=1:size(files)
    if(~files(i).isdir)
        processed_audio_file = fixed_NAS([directory,files(i).name],bin_width,window_width,'left',num_channels);
        
        A = [A, processed_audio_file];
    end
end

left_labels = zeros(2, size(A, 2)); 
left_labels(1,:) = 1;


directory=['./NAS_recordings/more_reduc_vol50/right/'];
files = dir(directory);

for  i=1:size(files)
    if(~files(i).isdir)
        processed_audio_file = fixed_NAS([directory,files(i).name],bin_width,window_width,'right',num_channels);
        
        B = [B, processed_audio_file];
    end
end

right_labels = zeros(2, size(B, 2)); 
right_labels(2,:) = 1;



processed_samples = [A, B];
labels = [left_labels, right_labels];


learning_ratio = 85/100;

k = randperm(size(processed_samples,2));
train_x = processed_samples(:, k(1, 1:ceil(size(processed_samples, 2) * learning_ratio)));
train_y = labels(:, k(1, 1:ceil(size(processed_samples, 2) * learning_ratio)));
test_x = processed_samples(:, k(1, ceil(size(processed_samples, 2) * learning_ratio)+1: size(processed_samples,2)));
test_y = labels(:, k(1, ceil(size(processed_samples, 2) * learning_ratio)+1: size(processed_samples,2)));

%N=ceil(size(processed_samples, 2) * learning_ratio); % no. of rows needed
%c=randperm(length(processed_samples),N);
%train_x = processed_samples(:,c);  % output matrix
%train_y = labels(:, c);