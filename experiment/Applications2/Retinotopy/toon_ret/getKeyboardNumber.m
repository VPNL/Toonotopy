function k = getKeyboardNumber();

% IMPORTANT (tips from Janice)
%
% DO NOT UNPLUG DEVICES AFTER YOU START MATLAB -- because even if you rerun
% getKeyboardNumber, it will NOT reassign the numbers, even if they have
% changed. You must restart MATLAB. 
%
% DO NOT EVER USE A TRACKBALL (ask Janice)
%
% DY 3/6/2007: also checks for an additional laptop-specific keyboard
% property (productID), since at the scanner, other button
% boxes/devices have the usagename "keyboard." Change the number
% on your local copy to suit your computer. 

d=PsychHID('Devices');
k = 0;

for n = 1:length(d)
    if (d(n).productID == 628) & strcmp(d(n).usageName,'Keyboard');
        k=n;
        break
    end
end
if k == 0
    fprintf(['\nKEYBOARD NOT FOUND. Check the productID number.\n']);
end