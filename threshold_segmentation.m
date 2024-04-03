function [img,mask] = threshold_segmentation(org_ing, gray_img)
% calculate the threshold value
level = graythresh(gray_img);

% get the threshold mask
thresholded_mask = imcomplement(imbinarize(gray_img, level));

% fill the holes
fill_mask = imfill(thresholded_mask, "holes");

% remove the small object
mask = fn.dynamic_bwareaopen(fill_mask, 60000);

% apply the mask
img = fn.applied_mask(org_ing, mask);

img_titles = {'Thresholded Mask', 'Filled Mask','Removed Small Objects', 'Applied Mask'};
imgs = {thresholded_mask, fill_mask, mask, img};
fn.auto_plot_images('Threshold Segmentation', img_titles, imgs);
end