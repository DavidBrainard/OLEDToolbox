function displaySettingsImageInSRGBFormat(settingsImageForRenderingDisplay, titleText, renderingDisplayCal)
    [settingsCalFormat, n,m] = ImageToCalFormat(settingsImageForRenderingDisplay);
    primaryCalFormat = SettingsToPrimary(renderingDisplayCal.cal, settingsCalFormat);
    XYZcalFormat = PrimaryToSensor(renderingDisplayCal.cal, primaryCalFormat);
    sRGBcalFormat = XYZToSRGBPrimary(XYZcalFormat);
    sRGBImage = CalFormatToImage(sRGBcalFormat, n,m);
    sRGBImage = sRGBImage / max(renderingDisplayCal.maxSRGB(:));
    imshow(sRGB.gammaCorrect(sRGBImage));
    title(titleText);
    set(gca, 'CLim', [0 1]);
end
