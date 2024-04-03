close all;

%% Dispoable
% org_img = imread('gloves/disposable/1.jpeg');
org_img = imread('gloves/disposable/2.png');
% org_img = imread('gloves/disposable/3.jpg');
% org_img = imread('gloves/disposable/4.png');
% org_img = imread('gloves/disposable/5.png');

%% Cotton
% org_img = imread('gloves/cotton/1.jpg');
% org_img = imread('gloves/cotton/2.jpg');
% org_img = imread('gloves/cotton/3.png');
% org_img = imread('gloves/cotton/4.jpg');

%% Leather
% % org_img = imread('gloves/leather/1.jpg');
% org_img = imread('gloves/leather/2.jpg');
% org_img = imread('gloves/leather/3.jpg');
% % org_img = imread('gloves/leather/4.png');
% org_img = imread('gloves/leather/5.jpg');

%% Main
gray_img = preprocessing(org_img);

[img, mask] = edge_segmentation(org_img, gray_img);
lab_img = rgb2lab(img);
object_area = bwarea(mask);

% Palm Finger Extraction
[palm_mask, finger_mask] = part_extraction(mask);

% Extract glove segment
glove_mask = detect_glove(img);

% Get average glove color
glove_mean_rgb = calculate_mean_glove_color(lab_img, glove_mask);

% Detect defects
[defects_img, defect_free_mask] = detect_defects(img, glove_mean_rgb);

% Classify defects 
[defect_names, defect_boxes] = classify_defects(org_img, defects_img, palm_mask, finger_mask, object_area);

% Highlight defects according to categories
highlighted_img = highlight_defects(org_img, defect_names, defect_boxes);












