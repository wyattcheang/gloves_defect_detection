%% Detect skin regions based on the YCbCr color space and predefined color thresholds.

function mask = detect_skin(img, object_area)
    % Convert RGB to YCbCr color space
    ycbcr_img = rgb2ycbcr(img);
    
    % Separate Y, Cb, and Cr components
    y = ycbcr_img(:,:,1);
    cb = ycbcr_img(:,:,2);
    cr = ycbcr_img(:,:,3);
    
    % Define the lower and upper bounds of the skin color cluster
    lower = [78, 134];
    upper = [126, 172];
    % 85, 135
    % 135, 180
    
    % Skin Detection
    skin_mask = cb >= lower(1) & cb <= upper(1) & ...
        cr >= lower(2) & cr <= upper(2);
    
    % Morphological operations for image enhancement
    min_object_size = round(object_area * 0.001);
    cleaned_skin = bwareaopen(skin_mask, min_object_size);
    final_skin = imfill(imdilate(cleaned_skin, strel('diamond', 4)), 'holes');
    
    mask = final_skin;
    
    img_titles = {'YCbCr Image', 'Skin Mask', 'Clean Mask', 'Final'};
    imgs = {ycbcr_img, skin_mask, cleaned_skin, final_skin};
    fn.auto_plot_images('Detect Skin', img_titles, imgs);
end