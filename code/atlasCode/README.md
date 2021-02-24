# Instructions for implementing Noah & Jon's atlas (KGS 2019):

## 1) Install FreeSurfer and Docker
1. FreeSurfer (https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall; https://surfer.nmr.mgh.harvard.edu/fswiki/MacOsInstall). If you have a mac you will also need to install Xquartz (see Freesurfer instructions above). You will need to add FREESURFER_HOME to your path; To do so edit your ~/.bashrc file to contain the lines:
```
export FREESURFER_HOME=/Applications/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
```

2. Docker (https://docs.docker.com/docker-for-mac/install/). Installation should not be difficult. If you want more information, see the Freesurfer and Docker pages on the winawerlab wiki page: https://wikis.nyu.edu/display/winawerlab/Software. To run the Benson Atlas you need to set the docker to use ample compute resources.
In Docker->Resources, set: (i) CPUs = 8,(ii) Memory = 12 GB, and (iii) Swap = 4GB

## 2) Download the latest version of Noah Benson's Neuropythy docker
See GitHub for more: https://github.com/noahbenson/neuropythy/wiki
```docker pull nben/neuropythy:latest```

## 3) Preparing the data:
Put the FreeSurfer segmentation of your testSubject under their 3DAnatomy directory:
TestSubject_190725/3DAnatomy/FreeSurferSegmentation_TestSubject
 
In your xterm,change directory to a folder that contains the FreeSurfer Segmentation: 
```cd ~/Courses/psych224/TestSubject_190725/```

## 4) Run matlab from an xterm
You will be running system commands using FreeSurfer functions from matlab.Therefore,matlab needs to be opened within the environment that has the paths to FreeSufer. In Linux machines this is the default. If you are using your mac you need to invoke matlab from your xterm rather than the graphic icon in your Applications folder otherwise matlab will not inherit the system's environment (e.g.,the FREESURFER_HOME path)

To do so, on your mac, open an xterm, cd to your Matlab directory & then run Matlab
```
cd /Applications/MATLAB_R2019a.app/bin
./matlab &
```

## 5) Running the atlas using matlab code 
You will run 3 matlab functions from the subject's session directory:
1. ```atlases_anatomical```: uses Noah Benson's code to transform the anatomical atlases Wang/Benson ROIs as well as the Benson Polar Angle and Eccentricity maps to your individual subject's brain and renders them.
2. ```atlases_bayesian```: uses Noah Benson's code and your subject's pRF model to generate a Bayesian prediction of the V1-V3 retinotopic maps as well as the Benson Polar Angle and Eccentricity maps for your individual subject's brain and renders them.  
3. ```atlases_compare2handdrawn```: Compares your definition of V1-V3 ROIs to the Wang and Benson ROIs as well as plots them on top of your subject's measured polar angle and eccentricity maps estimated from the pRF model.

Please run these functions in the above order,and section by section so you can learn which commands invoke specific functions. These functions will save the figures in your sessions's Images folder.

Before running these functions change the contents of the variable subDir in these functions to point to the subject's session folder (the folder that contains the mrSESSION.mat file for your subject).

You may also need to change the path to your FreeSurfer segmentation by editing the atlas.path in anatomical_atlases.m to indicate the correct path 

You will need to edit variable myROIs in the functionatlases_compare2handdrawn.m to include your ROI names

To make pretty figures,before running them,in mrVista set the mesh in the view that you would like to render the ROIs and then save the view settings under 
Gray->Mesh View Settings ->Store Current View Settings.
You need to set the view separately for the right hemisphere and left hemisphere meshes. In the code the example has 'lh_medial' and 'rh_medial', but you can save any view and name you wish.



