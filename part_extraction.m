function [palm_mask, finger_mask] = part_extraction(mask)

    % Refine the defect_free_mask;
    refined_mask = imopen(mask, strel('diamond', 10));
    refined_mask = imfill(refined_mask, "holes");
    
    % Get the palm from binary mask.
    area = bwarea(refined_mask);
    ratio = 5.0; % claculate base of testing
    palm_kernel_radius = round(sqrt(area/(ratio * pi)));
    palm_mask = imopen(refined_mask, strel('disk', palm_kernel_radius));
    
    % Get only the fingers.
    raw_finger_mask = refined_mask - palm_mask;
    opened_finger_mask = imopen(raw_finger_mask, strel('disk', round(palm_kernel_radius/5))); % Get the fingers.
    opened_finger_mask = imbinarize(opened_finger_mask);
    
    stats = regionprops(opened_finger_mask, 'Area', 'Centroid');
    largest_finger_area = max([stats.Area]);
    
    size_threshold = largest_finger_area * 0.2;
    finger_mask = bwpropfilt(opened_finger_mask, 'Area', [size_threshold Inf]);

    fn.print_title_value_pairs({'area', 'kernel', 'size_threshold'}, {area, palm_kernel_radius, size_threshold});
    
    img_titles = {'Refined Mask', 'Palm Mask', 'Raw Finger Mask', 'Open Finger Mask', 'Finger Mask'};
    imgs = {refined_mask, palm_mask, raw_finger_mask, opened_finger_mask, finger_mask};
    fn.auto_plot_images('Palm Detection', img_titles, imgs);
end

