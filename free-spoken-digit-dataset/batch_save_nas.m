
directory=['./NAS_recordings/more_reduc_vol50/left/'];
files = dir(directory);

for  i=1:size(files)  
    if(~files(i).isdir)
        fixed_NAS([directory,files(i).name],20,50,'left',64); 
    end
end  

directory=['./NAS_recordings/more_reduc_vol50/right/'];
files = dir(directory);

for  i=1:size(files)  
    if(~files(i).isdir)
        fixed_NAS([directory,files(i).name],20,50,'right',64); 
    end
end   
  