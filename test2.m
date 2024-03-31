close all;

% Threshold Seg
% tearing-2-good

%% Dispoable
org_img = imread('gloves/disposable/final/tearing-2-good.png');

%% Cotton
% Tearing
% org_img = imread('gloves/cotton/2.jpg');
% org_img = imread('gloves/cotton/6.jpg');

% Stain
% org_img = imread('gloves/cotton/2.jpg');

%% Leather
% org_img = imread('gloves/leather/TRG-1.png');

%% Rubber ??
% org_img = imread('gloves/rubber/dirty.jpg');

%% Main
gray_img = fn.preprocessing(org_img);

[img, mask] = fn.edge_segmentation(org_img, gray_img);
%[img, mask] = fn.threshold_segmentation(org_img, gray_img);
lab_img = rgb2lab(img);
object_area = bwarea(mask);

%% Palm Finger Extraction
[plam_mask, finger_mask] = part_extraction(mask);

%% Extract glove segment
glove_mask = detect_glove(img);

%% Get average clove color
glove_mean_rgb = calculate_mean_glove_color(lab_img, glove_mask);

%% Detect defects
[defects_img, defect_free_mask] = detect_defects(img, glove_mean_rgb);

%% Classify defects - stain / tearing / finger not enough
[stain_bboxess, tearing_bboxes, fne_bboxes] = classify_defects(defects_img, finger_mask, object_area);

%% Highlight defects according to categories
 highlighted_img = highlight_defects(org_img, stain_bboxess, tearing_bboxes, fne_bboxes);