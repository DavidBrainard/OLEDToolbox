> Uncompress the ToneMappingApp
> In matlab’s command window:
	cd ToneMappingApp
	LaunchToneMappingDemo

> You will see the app's main window showing the SPDs of the two simulated displays.

> Load an image: From the app’s Menu bar, choose File->Load image data (and select Rocket.mat - this is the image you sent me, but in a matfile). If you want to read other exr images directly, you will have to compile the mex files found in external/matlabEXR as described in the README.txt file in that directory.

> The program will go through the default tone mapping (which is linear mapping of input luminance to display luminance), and once completed you will see the the luminance histograms of the input image (right, bottom panel) and of the tone mapped images (right, top panel) for the OLED (red) and the LCD (blue) displays. The bottom panel will also depict the employed tone mapping functions for the two displays (red line: OLED, blue line: LCD). 

> Results will be displayed in two additional windows, named 'Input & Tonemapped images’ and ‘RGBmappings’.

>  'Input & Tonemapped images'. This window shows the input sRGB image on the very top, and below it the SRGB renditions of the luminance tone mapped images for the OLED display (second row) and for the LCD display (third row); Images in the left column have their luminance mapped without forcing the resulting RGB primaries to lie within the display's gamut, whereas images in the right columns are luminance mapped with their RGB primaries forced to be within the display's gamut. Primaries below 0 are forced to zero. Primaries above 1 are processed with an out-of-gamut operator, controlled by a processing option, see (5) Processing options.

> ‘RGBmappings’. This window plots the relationship between sRGB values of the input image and sRGB values of the tone mapped images shown in the previous window. Panel organization corresponds to that of the previous window.

> The app simulates two displays: the Samsung OLED and an NEC LCD that we use in the lab. The calibration data for these displays can be found in the @ToneMapper directory. 

> There are numerous settings you can try to examine their effects on the resulting tone mapped images.  All settings all controlled by the menus on the top of the main window.

(1) OLED Display Properties: Here you can change the OLED's maximum and minimum luminance. Change the max luminance to say 6,000 cd/m2.

(2) LCD Display Properties.: Same as for the OLED display

(3) OLED ToneMapping method & parameters: Here you can choose between three different luminance tonemapping methods.
  - linear scaling to display's gamut
  - clipping to display's gamut following attenuation of the scene luminance by a specified factor
  - Reinhard global operator (compression of the high luminance also controlled by a specified factor)
Try different methods to see the effect.

(4) LCD ToneMapping method & parameters: Same as above but applied to the LCD display

(5) Processing options. Here you can try the effects of some other options.
   (a) 'Image subsampling': You can specify a higher that 1 factor in order to accelerate computations at the expense of more pixelated images.
   (b) 'sRGB <-> XYZ conversions': You can select between the Matlab and the Psychtoolbox implementation of the sRGB to XYZ conversion. Use the PTB version if you do not have the ImageProcessing toolbox.
   (c) 'Above gamut operation': Here you can choose how to deal with pixels whose R, G, or B primary values are above the monitor's gamut.  When 'Clip individual primaries' is selected, the code clips the primary that is out of gamut, while leaving the other primaries untouched.  When 'Scale RGBprimary triplet' is selected, the code scales the RGB vector that contains the out-of-gamut primary uniformly.
   (d) 'Display max luminance limiting factor': Here you can tell the luminance tone mapping algorithm to use less than the available luminance range to avoid having to deal with out of gamut corrections. The total pixels that are out of gamut is displayed in Matlab's command window for each display.

> The main processing algorithm is located in the tonemapInputSRGBImageForAllDisplays.m file the @ToneMapper directory.  The luminance tone mapping algorithms are implemented in the tonemapInputLuminance.m file, also located in the @ToneMapper directory.  Most of the remaining functions contain code to interface with the GUI and plot the results.








