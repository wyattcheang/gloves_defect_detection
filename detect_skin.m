%% Detect skin regions based on the YCbCr color space and predefined color thresholds.

function skin_mask = detect_skin(img)

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
cleaned_skin = bwareaopen(skin_mask, 100);
final_skin = imfill(imdilate(cleaned_skin, strel('diamond', 4)), 'holes');

skin_mask = final_skin;
end
