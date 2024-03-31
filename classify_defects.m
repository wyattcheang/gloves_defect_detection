%% Classify defects - stain / tearing / finger not enough

function [stain_bboxes, tearing_bboxes, fne_bboxes] = classify_defects(defects_img, defect_free_mask)

% Get skin mask to identify tearing / finger not enough regions
skin_mask = detect_skin(defects_img);
skin_mask_rgb = repmat(skin_mask, [1, 1, size(defects_img, 3)]);

% Get the palm from binary mask.
palm_mask = imopen(defect_free_mask, strel('disk',50));

% Get only the fingers.
fingers = imopen(defect_free_mask - palm_mask, strel('disk', 4)); % Get the fingers.
fingers = imbinarize(fingers);
sizeThreshold = 5000; % Accept size of fingers that are greater or equal to 5000 pixels (finger size)
finger = bwpropfilt(fingers, 'Area', [sizeThreshold Inf]);


% Perform connected component analysis
cc = bwconncomp(defects_img);

% Compute the properties of each connected component
stats = regionprops(cc, 'Area', 'BoundingBox');

% Initialize lists to store defects regions
stain_bboxes = [];
tearing_bboxes = [];
fne_bboxes = [];

% Counter variables for defects regions
stain_count = 0;
tearing_count = 0;
fne_count = 0;

min_area_threshold = 250;
tearing_threshold = 5000;

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
        % TODO: Change this to maybe examine whether the fingertips pixels'
        % neighbours are background
        if stats(i).Area > tearing_threshold
            fne_count = fne_count + 1;
            fne_bboxes(fne_count, :) = [x, y, w, h]; % Add to finger not enough regions
        else
            tearing_count = tearing_count + 1;
            tearing_bboxes(tearing_count, :) = [x, y, w, h]; % Add to tearing regions
        end
    else
        stain_count = stain_count + 1;
        stain_bboxes(stain_count, :) = [x, y, w, h]; % Add to stain regions
    end
end

fprintf('stain_count = %d, tearing_count = %d, fne_count = %d\n', stain_count, tearing_count, fne_count);

figure('Name', 'Palm Detection');
subplot(131), imshow(defect_free_mask), title('Defects Free Mask');
subplot(132), imshow(palm_mask), title('Palm Mask');
subplot(133), imshow(finger), title('Finger Image');
end