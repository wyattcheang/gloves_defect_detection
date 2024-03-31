%% Classify defects - stain / tearing / finger not enough

function [stain_bboxes, tearing_bboxes, fne_bboxes] = classify_defects(defects_img, finger_mask, object_area)

% Get skin mask to identify tearing / finger not enough regions
skin_mask = detect_skin(defects_img);
skin_mask_rgb = repmat(skin_mask, [1, 1, size(defects_img, 3)]);

% Perform connected component analysis
cc = bwconncomp(defects_img);

% Compute the properties of each connected component
stats = regionprops(cc, 'Area', 'BoundingBox', 'Circularity');

% Initialize lists to store defects regions
stain_bboxes = [];
tearing_bboxes = [];
fne_bboxes = [];

% Counter variables for defects regions
stain_count = 0;    % small area with dark color
dirty_count = 0;    % big area with dark color
holes_count = 0;    % small area, high ciularity, not around the finger area, similar color to glove color, or skin color
tearing_count = 0;  % larger area, low ciularity, not around the finger area, similar color to glove color, or skin color
fne_count = 0;  % skin color, around the finger area

% TODO: change to dynamic
min_area_threshold = object_area * 0.01;

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

    object_mask = ismember(labelmatrix(cc), i);
    object_region = defects_img .* uint8(object_mask);
    % Check if the connected component intersects with the skin color mask
    if any(skin_mask_rgb(cc.PixelIdxList{i}))
        
        % Check for overlap
        if is_overlapped(object_region, finger_mask)  % Finger Not Enough
            fne_count = fne_count + 1;
            fne_bboxes(fne_count, :) = [x, y, w, h];
        else
            % Check circularity (YES-> holes, NO -> tearing)
        end
    else
        % TODO: remove
        imshow(object_region);
        stain_count = stain_count + 1;
        stain_bboxes(stain_count, :) = [x, y, w, h]; % Add to stain regions

        % TODO: complete the logic
        % if is_stained
        %     stain_count = stain_count + 1;
        %     stain_bboxes(stain_count, :) = [x, y, w, h]; % Add to stain regions
        % else 
        %     dirty_count = dirty_count + 1;
        %     dirty_bboxes(dirty_count, :) = [x, y, w, j];
        % end
    end
end

fprintf('stain_count = %d, tearing_count = %d, fne_count = %d\n', stain_count, tearing_count, fne_count);
end

function overlap = is_overlapped(object_region, finger_mask)
    % Apply the mask to the object region
    masked_object_region = object_region .* uint8(finger_mask);
   
    % Check for overlap
    overlap = any(masked_object_region(:) ~= 0);
end