# VivoQuant-NucMed-processing
This repository contains the code needed to preprocess nuclear medicine images (PET/CT or SPECT/CT), save MIP's and representative slices, and create a PowerPoint of these images using Stefan Slonevskiy's exportToPPTX MATLAB toolkit. The workflow is;

  1) Add the NM-CT-preprocessing.vqs and crop-n-save.vqs scripts to VivoQuant.
  2) Process DICOM images in VivoQuant software using NM-CT-preprocessing.vqs. A directory will be created and maximum intensity projection images saved.
  3) For each processed image in VivoQuant, save images of selected slices using crop-n-save.vqs 
  4) Add the exportToPPTX tool and long_study_template.pptx PowerPoint template to MATLAB folder.
  5) Run long_study_ppt.m in MATLAB to create a PowerPoint presentation from the saved images created by the .vqs scripts.
