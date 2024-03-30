close all;

% org_img = imread('gloves/disposable/1.jpg');
org_img = imread('gloves/disposable/not_suitable/STN-1.jpg');
% org_img = imread('gloves/disposable/TRG-FT-2.jpg');
% org_img = imread('gloves/disposable/TRG-5.jpg');
% org_img = imread('gloves/cotton/5.jpg');
% org_img = imread('gloves/leather/3.jpg');
% org_img = imread('gloves/silicone/dirty_and_stain_1.jpeg');

[img, mask] = fn.edgeSegmentation(org_img);
% [img, mask] = edge_segmentation(orgImg);

lab_img = rgb2lab(img);

% Extract glove segment
glove_mask = detect_glove(img);
% glove_mask = detect_glove(lab_img);

% Get average clove color
glove_mean_rgb = calculate_mean_glove_color(lab_img, glove_mask);

% Detect defects - stain & tearing
[stain_bboxes, tearing_bboxes] = detect_stain_tearing(img, glove_mean_rgb, 35, 250);

% Highlight defects according to categories
% TODO: maybe this can be used to display final image in our app
highlight_defects(org_img, stain_bboxes, tearing_bboxes);
