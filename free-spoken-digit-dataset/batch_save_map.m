num_digits=10;
num_samples=50;

for i=1:num_digits
    for j=1:num_samples
        file_name=['./recordings/' num2str(i-1) '_jackson_' num2str(j-1) '.wav'];
        fixed_MAP(file_name); 
    end    
end
