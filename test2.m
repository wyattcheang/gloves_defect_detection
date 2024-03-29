orgImg = imread('gloves/disposable/STN-2.jpg');
% orgImg = imread('gloves/disposable/TRG-1.jpeg');
% orgImg = imread('gloves/cotton/5.jpg');
% orgImg = imread('gloves/leather/3.jpg');

[img, mask] = fn.edgeSegmentation(orgImg);

lab_img = rgb2lab(img);

% Extract Glove Segment
glove_mask = detect_glove(img);
% glove_mask = detect_glove(lab_img);

% Detect Glove Color
glove_mean_lab = calculate_mean_glove_color(lab_img, glove_mask);

stain_detection_img = stain_detection(img, glove_mean_lab, 25);
figure, imshow(stain_detection_img), title('Result image');

