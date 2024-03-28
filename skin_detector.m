function skin_mask = skin_detector(img)
%% RGB -> YCbCr
ycbcr_img = rgb2ycbcr(img);

% Separate Y, Cb, and Cr components
y = ycbcr_img(:,:,1);
cb = ycbcr_img(:,:,2);
cr = ycbcr_img(:,:,3);

%% Skin Detection
% Define the lower and upper bounds of the skin color cluster
lower = [78, 134];
upper = [126, 172];
% 85, 135
% 135, 180

% Threshold YCbCr -> BW
skin_mask = cb >= lower(1) & cb <= upper(1) & ...
    cr >= lower(2) & cr <= upper(2);

%% Morphological operations
cleaned_skin = bwareaopen(skin_mask, 100);
final_skin = imfill(imdilate(cleaned_skin, strel('diamond', 4)), 'holes');

skin_mask = final_skin;
end
