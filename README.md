
# Wide field Toonotopy

Wide field Toonotopy is an experiment designed in 2018. It is used to map pRFs across the entire visual system.

During the experiments participants view while fixating a traveling bar sweepingthe visual field in 4 directions in the following sequence:
left-> right
bottom right -> top left
top-> bottom
bottom left -> top right

Each direction has 12 steps (each for a 2 seconds duration) and the whole sequence is repeated twice throughout the experiment. In the bar are displayed colored cartoons randomly at a rate of 8 Hz. The stimuli span 20 degrees from the fovea.

Task: fixate and response with a button press when the fixation color changes

To visualize the stimuli sequence: toon_showStim.m

## Work flow for analyzing 
See toon_workflow.m for details
1. Initialize the data for mrvista: toon_init.m
2. Manually align inplane anatomy to volume anatomy using rxAlign.m
3. Motion correction, within and between scans: toon_motionCorrect.m
4. Install segmentation. Transform time series from inplane to volume anatomy, and average the time series: toon_2gray.m
5. run pRF CSS model (Dumoulin 2008; Kay 2013) for each voxel in the gray: toon_prfRun.m



