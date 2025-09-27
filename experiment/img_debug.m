%%
images = stimulus.images{1,1}; 
for i = 1:length(stimulus.seq)
    index = stimulus.seq(i); 
    F(i) = im2frame(images(:,:,:,index));
end

movie(F)

%% blanks not there
images = stimulus.images{1,1}; 
for i = 1:512
    F(i) = im2frame(images(:,:,:,i));
end

movie(F)