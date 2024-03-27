function skin_mask = skin_detector(img)

sz = size(img);
r = 1; g = 2; b = 3; y = 1; u = 2; v = 3;

% Convert to YUV color space
yuv = zeros(sz);
yuv(:,:,y) = (img(:,:,r) + 2.*img(:,:,g) + img(:,:,b)) / 4;
yuv(:,:,u) = img(:,:,r) - img(:,:,g);
yuv(:,:,v) = img(:,:,b) - img(:,:,g);

% Skin detection
skin_mask = (yuv(:,:,u) > 20 & yuv(:,:,v) < 74) .* 255;

% Binarization and morphological operations
binary_skin = imbinarize(skin_mask);
cleaned_skin = bwareaopen(binary_skin, 100);
final_skin = imfill(imdilate(cleaned_skin, strel('diamond', 4)), 'holes');

imshow(final_skin);
skin_mask = final_skin;
end
