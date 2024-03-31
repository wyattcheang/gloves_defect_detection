%% Detect defects utilizing Delta E

function [defects_img, defect_free_mask] = detect_defects(img, glove_mean_rgb)

% Compute color difference (Delta E) between image and reference color
de = deltaE(img, glove_mean_rgb);

% Apply threshold to Delta E values to segment the image
deltaE_threshold = 35;
defect_free_mask = de < deltaE_threshold;

% Apply the mask to original mask to get defects
defects_img = img .* uint8(~defect_free_mask);

% Morphology operations to enhance the defects_img
defects_img = imopen(defects_img, strel('disk', 3));

figure('Name', 'Delta E for Defects Detection');
subplot(221), imshow(img), title('Original Image');
subplot(222), imshow(de, []), title('Delta E');
subplot(223), imshow(defect_free_mask), title('Defects free mask');
subplot(224), imshow(defects_img), title('Defects image');

end