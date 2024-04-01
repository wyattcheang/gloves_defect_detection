%% Classify defects - stain / tearing / finger not enough

function [defect_names, defect_bboxes] = classify_defects(defects_img, palm_mask, finger_mask, object_area)
    
    % Get skin mask to identify tearing / finger not enough regions
    skin_mask = detect_skin(defects_img);
    skin_mask_rgb = repmat(skin_mask, [1, 1, size(defects_img, 3)]);

    % Perform connected component analysis
    gray_img = rgb2gray(defects_img);
    binary_img = gray_img ~= 0;
    cc = bwconncomp(binary_img);
    
    % Compute the properties of each connected component
    stats = regionprops(cc, 'Area', 'Circularity', 'Perimeter', 'BoundingBox');
    disp([stats.Area])
    
    % Counter variables for defects regions
    palm_tearing_count = 0;     % skin color, at the palm or back of the hand area
    fne_count = 0;              % skin color, around the finger area
    wrist_tearing_count = 0;    % TODO: skin color, around the wrist area
    stain_count = 0;            % TODO: small area with dark color
    dirty_count = 0;            % TODO: big area with dark color
    holes_count = 0;            % TODO: small area, high ciularity, not around the finger area, similar color to glove color, or skin color
    
    max = 100;
    palm_bboxes = zeros(max, 4);
    fne_bboxes = zeros(max, 4);
    wrist_tearing_bboxes = zeros(max, 4);
    stain_bboxes = zeros(max, 4);
    dirty_bboxes = zeros(max, 4);
    holes_bboxes = zeros(max, 4);
    
    % remove the small error based on 0.005
    min_area_threshold = object_area * 0.005;
    
    % Iterate through connected components
    for i = 1:cc.NumObjects
        
        % Remove small objects based on the area threshold
        if stats(i).Area < min_area_threshold
            defects_img(cc.PixelIdxList{i}) = 0; % Set pixels of small object to background
            continue; % Skip classification for this region
        end
    
        % Bouding Box position
        bbox = stats(i).BoundingBox;
    
        % Extract the binary mask of the defect object
        object_mask = ismember(labelmatrix(cc), i);
    
        % Extract the colored defect area of the image 
        object_region = defects_img .* uint8(object_mask);
    
        % Check if the connected component intersects with the skin color mask
        if any(skin_mask_rgb(cc.PixelIdxList{i}))
            [palm_overlap, ~, p_count, p_bboxes] = is_overlapped(object_mask, palm_mask);
            if palm_overlap
                palm_tearing_count = palm_tearing_count + p_count;
                palm_bboxes = [palm_bboxes; p_bboxes];
            end
            [finger_overlap, ~, f_count, f_bboxes] = is_overlapped(object_mask, finger_mask);
            if finger_overlap
                fne_count = fne_count + f_count;
                % Append p_bboxes to palm_tearing_bboxes
                fne_bboxes = [fne_bboxes; f_bboxes];
            end
        else
            % TODO: remove
            stain_count = stain_count + 1;
            stain_bboxes(stain_count, :) = bbox; % Add to stain regions
    
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
    
    % Remove all-zeros bounding boxes
    palm_bboxes = palm_bboxes(any(palm_bboxes, 2), :);
    fne_bboxes = fne_bboxes(any(fne_bboxes, 2), :);
    wrist_tearing_bboxes = wrist_tearing_bboxes(any(wrist_tearing_bboxes, 2), :);
    stain_bboxes = stain_bboxes(any(stain_bboxes, 2), :);
    dirty_bboxes = dirty_bboxes(any(dirty_bboxes, 2), :);
    holes_bboxes = holes_bboxes(any(holes_bboxes, 2), :);
    
    defect_names = {'Palm Tearing', 'Finger Not Enough', 'Wrist Tearing', 'Stain', 'Dirty', 'Hole'};
    defect_bboxes = {palm_bboxes, fne_bboxes, wrist_tearing_bboxes, stain_bboxes, dirty_bboxes, holes_bboxes};
    fprintf('stain_count = %d, fne_count = %d\n', stain_count, fne_count);
end

function [overlap, area, count, bboxes] = is_overlapped(region1, region2)
    % find intersection mask
    intersection_mask = region1 & region2;
    
    % Check if the masks overlap or not
    overlap = sum(intersection_mask(:)) > 0;

    area = bwarea(intersection_mask);

    % Find connected components (objects) in the intersection mask
    cc = bwconncomp(intersection_mask);
    count = cc.NumObjects;
    
    % Get bounding boxes for each object
    status = regionprops(cc, 'BoundingBox');
    bboxes = zeros(count, 4); % Preallocate bboxes matrix
    
    for i = 1:count
        bboxes(i, :) = status(i).BoundingBox;
    end
end
