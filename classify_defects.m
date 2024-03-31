%% Classify defects - stain / tearing / finger not enough

function [stain_bboxes, tearing_bboxes, fne_bboxes] = classify_defects(img, defects_img, defect_free_mask)

% Get skin mask to identify tearing / finger not enough regions
skin_mask = detect_skin(defects_img);
skin_mask_rgb = repmat(skin_mask, [1, 1, size(defects_img, 3)]);

% Refine the defect_free_mask;
defect_free_mask = imopen(defect_free_mask, strel('diamond', 10));
defect_free_mask = imfill(defect_free_mask, "holes");

% Get the palm from binary mask.
defect_free_mask = imfill(defect_free_mask, "holes");
area = bwarea(defect_free_mask);
ratio = 5.0; % claculate base of testing
palm_kernel_radius = round(sqrt(area/(ratio * pi)));
palm_mask = imopen(defect_free_mask, strel('disk', palm_kernel_radius));
fprintf('area = %d, kernel = %d', area, palm_kernel_radius);
figure
subplot(141), imshow(defect_free_mask);
subplot(142), imshow(palm_mask);

% Get only the fingers.
finger_mask = defect_free_mask - palm_mask;
subplot(143), imshow(finger_mask);
fingers = imopen(finger_mask, strel('disk', round(palm_kernel_radius/5))); % Get the fingers.
fingers = imbinarize(fingers);
subplot(144), imshow(fingers);

stats = regionprops(fingers, 'Area', 'Centroid');
disp([stats.Area])
largest_finger_area = max([stats.Area]);

sizeThreshold = largest_finger_area * 0.2;
fprintf('\nsizeThreshold = %d', sizeThreshold);
finger = bwpropfilt(fingers, 'Area', [sizeThreshold Inf]);

% Perform connected component analysis
cc = bwconncomp(defects_img);
disp(cc)

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

% TODO: change to dynamic
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