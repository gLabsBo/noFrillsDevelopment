NoFrillsDev

This pipeline uses a Macbeth colorchecker to correct the colors of an image.
In order to do that, it uses
DC_RAW or RAWTHERAPEE to read a raw file
ccFind to identify a Macbeth colorchecker target in the image
White balance is performed in window mode in dcRaw. 
TODO in RAWTHERAPEE
Image is then color corrected using different approaches:
1) polyfit - weighted polyfit
2) spline based fitting (based on SLMtools)
3) SHAFT, that is a trial and error approach freely inspired by Adobe Camera Raw script

Credits
ccFind
ccFind is a customization of the code from the paper: Garcia Capel, Luis E. & Hardeberg, Jon Y.. Automatic Color Reference Target Detection. The 22nd Color and Imaging Conference (CIC), IS&T, Pages 119-124, Boston, MA, USA, Nov, 2014. 

matlab-readraw (Fahri Readraw)
A dcraw wrapper for matlab
https://github.com/farhi/matlab-readraw

DCRAW 
by Dave Coffin https://www.cybercom.net/~dcoffin/dcraw/

SLMtools
Shape language Modeling by John D'Errico
https://it.mathworks.com/matlabcentral/fileexchange/24443-slm-shape-language-modeling

