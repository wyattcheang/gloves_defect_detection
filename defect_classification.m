%% Classify defects
function [defect_names, defect_bboxes] = defect_classification(org_img, defects_img, palm_mask, finger_mask, object_area)

% Get skin mask to identify tearing, finger not enough, holes regions
skin_mask = detect_skin(defects_img, object_area);
skin_mask_rgb = repmat(skin_mask, [1, 1, size(defects_img, 3)]);

% Convert Image to Binary
gray_img = rgb2gray(defects_img);
binary_img = gray_img ~= 0;

% Remove small defects pixel
se = strel('disk', 2);
morph_mask = imopen(binary_img, se);

% Compute the properties of each connected component
max_iterations = 50;  % Maximum number of iterations
iteration = 0;          % Counter variable

while iteration < max_iterations
    cc = bwconncomp(morph_mask);
    stats = regionprops(cc, 'Area', 'Circularity', 'Perimeter', 'BoundingBox');

    % Check the number of elements in the mask
    num_elements = numel(morph_mask);

    if num_elements > 10
        % Perform morphological operations here
        se = strel('disk', 10); % Define structuring element (adjust size as needed)
        morph_mask = imclose(morph_mask, se);
    else
        break; % Exit the loop if the condition is not met
    end

    iteration = iteration + 1; % Increment the counter
end

img_titles = {'skin_mask', 'defects_img', 'Binarize Image', 'Morph Mask'};
imgs = {skin_mask, defects_img, binary_img, morph_mask};
fn.auto_plot_images('Testing', img_titles, imgs);

% Counter variables for defects regions
palm_tearing_count = 0;
fne_count = 0;

stain_count = 0;
finger_stain_count = 0;

dirty_count = 0;
finger_dirty_count = 0;

holes_count = 0;
finger_holes_count = 0;

palm_bboxes = zeros(cc.NumObjects, 4);
fne_bboxes = zeros(cc.NumObjects, 4);

stain_bboxes = zeros(cc.NumObjects, 4);
finger_stain_bboxes = zeros(cc.NumObjects, 4);

dirty_bboxes = zeros(cc.NumObjects, 4);
finger_dirty_bboxes = zeros(cc.NumObjects, 4);

holes_bboxes = zeros(cc.NumObjects, 4);
finger_holes_bboxes = zeros(cc.NumObjects, 4);

disp(cc.NumObjects)
if cc.NumObjects > 30
    min_area_threshold = object_area * 0.0008;
elseif cc.NumObjects > 20
    min_area_threshold = object_area * 0.001;
else
    min_area_threshold = object_area * 0.006;
end
fn.print_title_value_pairs({'object_area', 'min area threshold'}, {object_area, min_area_threshold});

% defect_region -> based on the binary_mask
% Cropped_defect_mask -> based on the morph_mask
% Iterate through connected components
for i = 1:cc.NumObjects

    % Bouding Box position
    bbox = stats(i).BoundingBox;
    circularity = stats(i).Circularity;
    defect_area = stats(i).Area;

    % Extract defects' info
    morph_defect_mask = ismember(labelmatrix(cc), i);   % defect area based on morphological mask (larger coverage)
    defect_mask = morph_defect_mask & binary_img;       % defect area based on original binary mask (smaller covera

    cropped_defect_mask = imcrop(defect_mask, bbox);
    cropped_morph_defect_mask = imcrop(morph_defect_mask, bbox);

    cropped_colored_defect = imcrop(org_img, bbox);
    num_colors = count_unique_colors(cropped_colored_defect);
    color_per_area = num_colors/prod(bbox(3:4));

    % Remove small objects based on the area threshold
    if defect_area < min_area_threshold
        defects_img(cc.PixelIdxList{i}) = 0; % Set pixels of small object to background
        continue; % Skip classification for this region
    end

    % Check if the connected component intersects with the skin color mask
    if any(skin_mask_rgb(cc.PixelIdxList{i}))

        [palm_overlap, intersection_mask] = fn.is_overlapped(morph_defect_mask, palm_mask);
        if palm_overlap
            [p_count, p_bboxes, h_count, h_bboxes] = skin_area_defect_count(intersection_mask, object_area, 0.2);
            defect_figure_title = "Skin - Palm Area";

            palm_tearing_count = palm_tearing_count + p_count;
            palm_bboxes = [palm_bboxes; p_bboxes];

            holes_count = holes_count + h_count;
            holes_bboxes = [holes_bboxes; h_bboxes];

            fn.auto_plot_images(defect_figure_title, {'Defect Area', 'Morph Defect Area', 'cropped_colored_defect'}, {intersection_mask, cropped_morph_defect_mask, cropped_colored_defect});
        end
        [finger_overlap, intersection_mask] = fn.is_overlapped(morph_defect_mask, finger_mask);
        if finger_overlap
            [f_count, f_bboxes, h_count, h_bboxes] = skin_area_defect_count(intersection_mask, object_area, 0.01);
            defect_figure_title = "Skin - Finger Area";

            fne_count = fne_count + f_count;
            fne_bboxes = [fne_bboxes; f_bboxes];

            finger_holes_count = finger_holes_count + h_count;
            finger_holes_bboxes = [finger_holes_bboxes; h_bboxes];

            fn.auto_plot_images(defect_figure_title, {'Defect Area', 'Morph Defect Area', 'cropped_colored_defect'}, {intersection_mask, cropped_morph_defect_mask, cropped_colored_defect});
        end
    else
        if defect_area >= object_area * 0.0005
            [palm_overlap, ~] = fn.is_overlapped(defect_mask, palm_mask);
            [finger_overlap, ~] = fn.is_overlapped(defect_mask, finger_mask);
            overlap = finger_overlap || ~palm_overlap;
            if circularity >= 0.5 && color_per_area > 0.6 || circularity >= 0.4 && color_per_area > 0.7
                if overlap
                    defect_figure_title = 'Non-Skin Hole';
                    finger_holes_count = finger_holes_count + 1;
                    finger_holes_bboxes(finger_holes_count, :) = bbox;
                else
                    defect_figure_title = 'Non-Skin Hole';
                    holes_count = holes_count + 1;
                    holes_bboxes(holes_count, :) = bbox;
                end
            elseif color_per_area > 0.4
                if overlap
                    defect_figure_title = 'Stain (Finger)';
                    finger_stain_count = finger_stain_count + 1;
                    finger_stain_bboxes(finger_stain_count, :) = bbox;
                else
                    defect_figure_title = 'Stain';
                    stain_count = stain_count + 1;
                    stain_bboxes(stain_count, :) = bbox;
                end
            else
                if overlap
                    defect_figure_title = 'Dirty (Finger)';
                    finger_dirty_count = finger_dirty_count + 1;
                    finger_dirty_bboxes(finger_dirty_count, :) = bbox;
                else
                    defect_figure_title = 'Dirty';
                    dirty_count = dirty_count + 1;
                    dirty_bboxes(dirty_count, :) = bbox;
                end
            end
        end
        fn.print_title_value_pairs({'Circularity', 'Area', 'Color Per Area'},{circularity, defect_area, color_per_area});
        fn.auto_plot_images(defect_figure_title, {'Defect Area', 'Morph Defect Area', 'cropped_colored_defect'}, {cropped_defect_mask, cropped_morph_defect_mask, cropped_colored_defect});
    end
end

% Remove empty bboxes in the list
palm_bboxes = palm_bboxes(any(palm_bboxes, 2), :);
fne_bboxes = fne_bboxes(any(fne_bboxes, 2), :);
stain_bboxes = stain_bboxes(any(stain_bboxes, 2), :);
dirty_bboxes = dirty_bboxes(any(dirty_bboxes, 2), :);
holes_bboxes = holes_bboxes(any(holes_bboxes, 2), :);
finger_stain_bboxes = finger_stain_bboxes(any(finger_stain_bboxes, 2), :);
finger_dirty_bboxes = finger_dirty_bboxes(any(finger_dirty_bboxes, 2), :);
finger_holes_bboxes = finger_holes_bboxes(any(finger_holes_bboxes, 2), :);


defect_names = {'Palm Tearing', 'Finger Not Enough', 'Stain', 'Dirty', 'Hole', 'Stain (Finger)', 'Dirty (Finger)', 'Hole (Finger)'};
defect_bboxes = {palm_bboxes, fne_bboxes, stain_bboxes, dirty_bboxes, holes_bboxes, finger_stain_bboxes, finger_dirty_bboxes, finger_holes_bboxes};
defect_counts = {palm_tearing_count, fne_count, stain_count, dirty_count, holes_count, finger_stain_count, finger_dirty_count, finger_holes_count};
fn.print_title_value_pairs(defect_names, defect_counts);
end

function [tearing_count, tearing_bboxes, hole_count, hole_bboxes] = skin_area_defect_count(mask, object_area, ratio)
% Find connected components (objects) in the intersection mask
cc = bwconncomp(mask);
status = regionprops(cc, 'BoundingBox', 'Area', 'Circularity');

% Initialize count and bounding boxes
tearing_count = 0;
hole_count = 0;

tearing_bboxes = [];
hole_bboxes = [];

% Iterate over connected components
for i = 1:cc.NumObjects
    circularity = status(i).Circularity;
    defect_area = status(i).Area;
    bbox = status(i).BoundingBox;
    fn.print_title_value_pairs({'Circularity', 'Area'},{circularity, defect_area});

    if defect_area >= ratio * object_area
        % Increment count
        tearing_count = tearing_count + 1;
        % Get bounding box for current connected component
        tearing_bboxes(tearing_count, :) = bbox;
    elseif defect_area > object_area * 0.0005 && circularity >= 0.5
        hole_count = hole_count + 1;
        hole_bboxes(hole_count, :) = bbox;
    end
end
end

function num_colors = count_unique_colors(img)
% Convert the image to a 3D matrix where each row represents a pixel
% and each column represents a color channel (RGB)
pixels = reshape(img, [], 3);
% Find the unique rows in the matrix (unique colors)
unique_colors = unique(pixels, 'rows');

% Count the number of unique colors
num_colors = size(unique_colors, 1);
end


