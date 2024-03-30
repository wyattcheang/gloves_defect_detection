%% Detects stains and tearing defects by:
% i) color difference (delta E)
% ii) thresholding
% iii) morphological
% iv) connected component analysis.
function [stain_bboxes, tearing_bboxes] = detect_stain_tearing(img, ...
    glove_mean_rgb, deltaE_threshold, min_area_threshold)

% Compute color difference (Delta E) between image and reference color
de = deltaE(img, glove_mean_rgb);

% Apply threshold to Delta E values to segment the image
defect_free_mask = de < deltaE_threshold;

% Apply the mask to original mask to get defects
defects_img = img .* uint8(~defect_free_mask);

% Morphology operations to enhance the defects_img
defects_img = imopen(defects_img, strel('disk', 3));

% Get skin mask to identify tearing regions
skin_mask = detect_skin(defects_img);
skin_mask_rgb = repmat(skin_mask, [1, 1, size(defects_img, 3)]);

% Perform connected component analysis
cc = bwconncomp(defects_img);

% Compute the properties of each connected component
stats = regionprops(cc, 'Area', 'BoundingBox');

% Initialize lists to store tearing and stain regions
tearing_bboxes = [];
stain_bboxes = [];

% Counter variables for tearing and stain regions
tearing_count = 0;
stain_count = 0;

% Iterate through connected components
for i = 1:cc.NumObjects
    % Remove small objects based on the area threshold
    if stats(i).Area < min_area_threshold
        defects_img(cc.PixelIdxList{i}) = 0; % Set pixels of small object to background
        continue; % Skip classification for this region
    end

    bbox = stats(i).BoundingBox;
    x = bbox(1);
    y = bbox(2);
    w = bbox(4);
    h = bbox(5);

    % Check if the connected component intersects with the skin color mask
    if any(skin_mask_rgb(cc.PixelIdxList{i}))
        tearing_count = tearing_count + 1;
        tearing_bboxes(tearing_count, :) = [x, y, w, h]; % Add to tearing regions
    else
        stain_count = stain_count + 1;
        stain_bboxes(stain_count, :) = [x, y, w, h]; % Add to stain regions
    end
end

fprintf('tearing_count %d, stain_count = %d\n', tearing_count, stain_count);

figure;
subplot(231), imshow(img), title('Original Image');
subplot(232), imshow(de, []), title('Delta E');
subplot(233), imshow(defect_free_mask), title('Defects free mask');
subplot(234), imshow(defects_img), title('Defects image');
subplot(235), imshow(skin_mask), title('skin_mask');
end
