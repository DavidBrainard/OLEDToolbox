1. Uncompress the ToneMappingApp
2. In matlab:
	cd ToneMappingApp
	LaunchToneMappingDemo
You will see the app's main window. This is how you control the app.

3. Load an image
   File->Load image data (and select Rocket.mat - this is the image you sent me, but in a matfile). If you want to read other exr images directly, you will have to compile the MatlabEXR mex files as described in the README.txt file in that directory.

The program will go through the default tone mapping (linear mapping of input luminance to display luminance)
You will see 2 new windows. 

(1) The window titled Input & Tonemapped images shows the input sRGB image on the very top.
Below it are SRGB renditions of tonemapped images for the OLED display (second row)
and SRGB renditions of tonemapped images for the LCD display (third row);
Images in the left column have their luminance tonemapped without necessitating that the resulting RGB primaries are within the display's gamut, whereas images in the right columns are luminance tonemapped and also have their RGB primaries within the display's gamut.

(2) The window titled RGBmappings plots the relationship between input sRGB values and the sRGB values of the images shown on the previous window. Panel organization corresponds to that of the previous window.

The app simulates two displays: the Samsung OLED and an NEC LCD that we use in the lab.
The calibration data for these displays can be found in the @ToneMapper directory.


There are numerous things you can try to see their effects on the tonemapped images. These are all controlled by the menus on the top of the main window.

(1) OLED Display Properties
Here you can change the OLED's maximum and minimum luminance. Change the max luminance to say 6,000 cd/m2.

(2) LCD Display Properties. 
Same as for the OLED display

(3) OLED ToneMapping method & parameters
Here you can choose between three different luminance tonemapping methods.
  - linear scaling to display's gamut
  - clipping to display's gamut following attenuation of the scene luminance by a specified factor
  - Reinhard global operator (compression of the high luminance also controlled by a specified factor)
Try different methods to see the effect.

(4) LCD ToneMapping method & parameters
Same as above but applied to the LCD display

(5) Processing options
(a) 'Image subsampling': A higher number will result in faster computations but more pixelated images. While investigating other parameters you can set this to a high value to save time.
(b) 'sRGB <-> XYZ conversions': Here you can select between the Matlab and the Psychtoolbox version of the sRGB to XYZ conversion. The Matlab is linear, the PTB has a nonlinearity built it. I use the Matlab version.
(c) 'Above gamut operation': Here you can choose how to deal with pixels whose R, G, or B primary values are above the monitor's gamut. When 'Clip individual primaries' is selected, the code clips the primary that is out of gamut, while leaving the other primaries untouched. When 'Scale RGBprimary triplet' is selected, the code scales the RGB vector uniformly.
(d) 'Display max luminance limiting factor': Here you can tell the luminance tone mapping algorithm to use less than the available luminance range to avoid having to deal with out of gamut corrections. The total pixels that are out of gamut is displayed in Matlab's command window for each display.

The main processing algorithm is located in the tonemapInputSRGBImageForAllDisplays.m file the @ToneMapper directory. The three luminance tonemapping algorithsm are implemented in the tonemapInputLuminance.m file, also located in the @ToneMapper directory. Most of the other functions contain code to interface with the GUI and plot the results.

Nicolas








