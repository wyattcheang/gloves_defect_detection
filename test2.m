close all;

% Threshold Seg
% tearing-2-good

%% Dispoable
% org_img = imread('gloves/disposable/FNE-3.jpg');
org_img = imread('gloves/disposable/final/tearing-1-good.jpg');

%% Cotton
% Tearing
org_img = imread('gloves/cotton/2.jpg');
% org_img = imread('gloves/cotton/6.jpg');

% Stain
% org_img = imread('gloves/cotton/2.jpg');

%% Leather
% org_img = imread('gloves/leather/TRG-1.png');
% org_img = imread('gloves/silicone/dirty_and_stain_1.jpeg');


%%
[img, mask] = fn.edgeSegmentation(org_img);
% [img, mask] = fn.thresholdSegmentation(org_img);
% [img, mask] = edge_segmentation(org_img);

fne_bboxes = detect_finger_not_enough(img);

lab_img = rgb2lab(img);

% Extract glove segment
glove_mask = detect_glove(img);
% glove_mask = detect_glove(lab_img);

% Get average clove color
glove_mean_rgb = calculate_mean_glove_color(lab_img, glove_mask);

% Detect defects - stain & tearing
[stain_bboxes, tearing_bboxes] = detect_stain_tearing(img, glove_mean_rgb);

% Highlight defects according to categories
highlight_defects(org_img, stain_bboxes, tearing_bboxes, fne_bboxes);
