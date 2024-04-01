function [img] = preprocessing(img)
    % change to Gray Scale Image
    gray_img = rgb2gray(img);

    % apply Gaussian filtering for noise reduction
    filtered_img = imgaussfilt(gray_img, 3);

    % histogram equalization
    stretched_img = imadjust(filtered_img, [0, 0.95]);

    % sharpen the segmented image using unsharp masking
    sharpened_img = imsharpen(stretched_img, 'Amount', 1.5, 'Radius', 1, 'Threshold', 0);

    img = sharpened_img;

    img_titles = {'Grayscale', 'Gaussian Filtered', 'Contrast Stretching', 'Sharpenning'};
    imgs = {gray_img, filtered_img, stretched_img, sharpened_img};
    fn.auto_plot_images('Preprocessing', img_titles, imgs);
end