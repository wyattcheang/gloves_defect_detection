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
disp([stats.Area])
largest_finger_area = max([stats.Area]);

sizeThreshold = largest_finger_area * 0.3;
fprintf('\nsizeThreshold = %d', sizeThreshold);
finger_mask = bwpropfilt(fingers, 'Area', [sizeThreshold Inf]);

figure('Name', 'Palm Detection');
subplot(131), imshow(refined_mask), title('Defects Free Mask');
subplot(132), imshow(palm_mask), title('Palm Mask');
subplot(133), imshow(finger_mask), title('Finger Image');
end