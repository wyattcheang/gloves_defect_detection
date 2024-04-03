function [palm_mask, finger_mask] = part_extraction(mask)

% Refine the defect_free_mask;
refined_mask = imopen(mask, strel('diamond', 10));
refined_mask = imfill(refined_mask, "holes");
refined_mask = imfill(refined_mask, "holes");

% Get the palm from binary mask.
area = bwarea(refined_mask);
ratio = 5.0; % claculate base of testing
palm_kernel_radius = round(sqrt(area/(ratio * pi)));
palm_mask = imopen(refined_mask, strel('disk', palm_kernel_radius));
fprintf('area = %d, kernel = %d', area, palm_kernel_radius);

% Get only the fingers.
finger_mask = refined_mask - palm_mask;
fingers = imopen(finger_mask, strel('disk', round(palm_kernel_radius/5))); % Get the fingers.
fingers = imbinarize(fingers);

stats = regionprops(fingers, 'Area', 'Centroid');
largest_finger_area = max([stats.Area]);

sizeThreshold = largest_finger_area * 0.2;
fprintf('\nsizeThreshold = %d', sizeThreshold);
finger_mask = bwpropfilt(fingers, 'Area', [sizeThreshold Inf]);

img_titles = {'Refined Mask', 'Palm Mask', 'Finger Mask'};
imgs = {refined_mask, palm_mask, finger_mask};
fn.auto_plot_images('Palm Detection', img_titles, imgs);
end