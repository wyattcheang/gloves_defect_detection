function [img, mask] = edge_segmentation(org_ing, gray_img)

% Get the edge mask
edge_mask = edge(gray_img, 'canny');

% Fill the holes in the edge mask
filled_mask = imfill(edge_mask, 'holes');

morph_mask = edge_mask;
for i = 1:100
    cc = bwconncomp(morph_mask);
    num_objects = cc.NumObjects;
    if num_objects > 2
        % use Morphological Opertaion to recontruct the line
        morph_mask = imdilate(morph_mask, strel("line", 2, 0));
        morph_mask = imdilate(morph_mask, strel("line", 2, 45));
        morph_mask = imdilate(morph_mask, strel("line", 2, 90));
        morph_mask = imdilate(morph_mask, strel("line", 2, 125));
        morph_mask = imfill(morph_mask, 'holes');
    else
        break
    end
end

% remove the small object
removed_mask = fn.dynamic_bwareaopen(morph_mask, 60000);

% reduce the extra segmented boundaries
eroded_mask = removed_mask;
for j = 1:i
    se = strel('disk', 3);
    eroded_mask = imerode(eroded_mask, se); % Opening operation to remove small boundaries
end
mask = eroded_mask;

% apply the mask
img = fn.applied_mask(org_ing, mask);

img_titles = {'Edge Mask', 'Morph Mask', 'Filled Mask', 'Removed Small Objects', 'Dilated Mask', 'Applied Mask'};
imgs = {edge_mask, morph_mask, filled_mask, removed_mask, eroded_mask, img};
fn.auto_plot_images('Edge Segmentation', img_titles, imgs);
end

