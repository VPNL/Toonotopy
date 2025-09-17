function score = scoreRet(stim,resp)

%stim = stimulus.fixSeq;
%resp =response.keyCode;


maxNum = 0;
loop = 1;
for i=1:length(stim)
    if i < length(stim)
        if stim(i) == 1 & stim(i+1) == 2
            g2r(loop) = i;
            maxNum = maxNum+1;
            loop=loop+1;
        end
    end
end
% loop = 1;
% for i=1:length(stim)
%     if i < length(stim)
%         if stim(i) == 2 & stim(i+1) == 1
%             r2g(loop) = i; 
%             loop=loop+1;
%         end
%     end
% end
            

ansCount=0;
for i=1:length(g2r)
    if i < length(g2r)
        pushSum = sum(resp(g2r(i):g2r(i+1)));
        if pushSum >0;
            ansCount=ansCount+1;
        end
    elseif i == length(g2r)
        pushSum = sum(resp(g2r(i):end));
        if pushSum >0;
            ansCount=ansCount + 1;
        end

    end
end

score=100*(ansCount/maxNum);
