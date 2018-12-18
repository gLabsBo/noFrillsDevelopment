Code from the paper: Garcia Capel, Luis E. & Hardeberg, Jon Y.. Automatic Color Reference Target Detection. The 22nd Color and Imaging Conference (CIC), IS&T, Pages 119-124, Boston, MA, USA, Nov, 2014. 


- File/folder structure:

MainCCFind: Code to process a batch of images using CCFind
MainTempMatching: Code to process a batch of images using the provided template matching approach
CCFind/: CCFind code. Download the latest version at http://campus.udayton.edu/~ISSL/index.php/research/ccfind/ (last visited on 3/12/2014)
Others/: Other functions used
ROISelection/: Code of the ROI selection preprocessing step. It contains a compiled version of the saliency method proposed by Chen et al., although for its use in different systems (e.g. Linux) a recompilation might be needed. The SW can be found at the author's website: http://mmcheng.net/code-data/ (last visited on 3/12/2014)
TempMatching/: Code of the template matching method


- Instructions:

1) Open MainCCFind or MainTempMatching and adjust the options and parameters: input folder, output folder, saliency cut threshold, use of ROI selection, etc.
2) Run the file
3) Have fun!


Version 1.0
Last updated: December 2014