function [img, mask]=edge_segmentation(org_ing, gray_img)
    % Get the edge mask
    edge_mask = edge(gray_img, 'canny');

    % use Morphological Opertaion to recontruct the line
    morph_mask = imclose(edge_mask, strel("line", 6, 0));
    morph_mask = imclose(morph_mask, strel("line", 6, 45));
    morph_mask = imclose(morph_mask, strel("line", 6, 90));
    morph_mask = imclose(morph_mask, strel("line", 6, 125));

    % fill the line edge
    filled_mask = imfill(morph_mask, "holes");

    % remove the small object
    mask = fn.dynamic_bwareaopen(filled_mask, 60000);

    % apply the mask
    img = fn.applied_mask(org_ing, mask);

    img_titles = {'Edge Mask', 'Morph Mask', 'Filled Mask','Removed Small Objects', 'Applied Mask'};
    imgs = {edge_mask, morph_mask, filled_mask, mask, img};
    fn.auto_plot_images('Edge Segmentation', img_titles, imgs);
end

