Screen('Preference','SkipSyncTests', 1);
 
windowPtr    = max(Screen('screens'));
[wP] = Screen('OpenWindow', windowPtr);

for i = 1:8
    if mod(i,2) == 0
        color = [0 255 0];
    else
       color = [255 0 0]; 
    end
    
    Screen('FillRect',wP,color)
    Screen('DrawText',wP,num2str(i), 500, 500)
    VBLTimestamp = Screen('Flip',wP)

    WaitSecs(.125)
end


sca
