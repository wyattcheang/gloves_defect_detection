function [img, mask] = edge_segmentation(img)
grayImg = rgb2gray(img);

% Adaptive histogram equalization for contrast enhancement
adapthisteqImg = adapthisteq(grayImg);

% apply Gaussian filtering for noise reduction
filteredImage = imgaussfilt(adapthisteqImg, 3);

% Laplacian of Gaussian (LoG) for edge enhancement
edgeEnhancedImg = edge(filteredImage, 'log');

% Get the edge mask
edgeMask = edge(edgeEnhancedImg, 'Canny');

% Refinement of edge mask using morphological operations
strelMask = imclose(edgeMask, strel('disk', 5));
strelMask = imclose(strelMask, strel("line", 4, 45));
strelMask = imfill(strelMask, 'holes');
strelMask = bwareaopen(strelMask, 1000); % Remove small objects

% % Adaptive morphological operations based on local characteristics
% adaptiveStrelMask = adaptthresh(uint8(strelMask));
% adaptiveStrelMask = bwareaopen(adaptiveStrelMask, 1000); % Remove small objects

% fill the line edge
fillMask = imfill(strelMask, 'holes');

% remove the small object
finalMask = fn.dynamicBwareaopen(fillMask, 60000);

% apply the mask
segmentedImg = fn.maskout(img, finalMask);

% Display intermediate results (optional)
figure;
subplot(231), imshow(img), title('Original')
subplot(232), imshow(grayImg), title('Gray');
subplot(233), imshow(adapthisteqImg), title('Adaptive Histogram Equalization');

subplot(234), imshow(filteredImage), title('Gaussian Filtered');
subplot(235), imshow(edgeEnhancedImg), title('Edge Enhanced (LoG)');
subplot(236), imshow(edgeMask), title('Edge (Canny)');

figure;
subplot(231), imshow(strelMask), title('Refined Edge Mask');
% subplot(232), imshow(adaptiveStrelMask), title('Adaptive Morphological Operations');
subplot(233), imshow(fillMask), title('Fill Line');
subplot(234), imshow(finalMask), title('Final Mask');
subplot(235), imshow(segmentedImg), title('Segmented');

img = segmentedImg;
mask = finalMask;
end
