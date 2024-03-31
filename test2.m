close all;

% Threshold Seg
% tearing-2-good

%% Dispoable
org_img = imread('gloves/disposable/final/tearing-1-good.jpg');

%% Cotton
% Tearing
% org_img = imread('gloves/cotton/1.jpg');
% org_img = imread('gloves/cotton/6.jpg');

% Stain
% org_img = imread('gloves/cotton/2.jpg');

%% Leather
% org_img = imread('gloves/leather/TRG-1.png');
% org_img = imread('gloves/silicone/dirty_and_stain_1.jpeg');

%% Rubber ??
% org_img = imread('gloves/rubber/1.jpg');

%% Main
[img, mask] = fn.edgeSegmentation(org_img);
imshow(img)
% [img, mask] = fn.thresholdSegmentation(org_img);
% [img, mask] = edge_segmentation(org_img);

lab_img = rgb2lab(img);

%% Extract glove segment
glove_mask = detect_glove(img);

%% Get average clove color
glove_mean_rgb = calculate_mean_glove_color(lab_img, glove_mask);

%% Detect defects
[defects_img, defect_free_mask] = detect_defects(img, glove_mean_rgb);

%% Classify defects - stain / tearing / finger not enough
[stain_bboxess, tearing_bboxes, fne_bboxes] = classify_defects(img, defects_img, defect_free_mask);

%% Highlight defects according to categories
 highlighted_img = highlight_defects(org_img, stain_bboxess, tearing_bboxes, fne_bboxes);
