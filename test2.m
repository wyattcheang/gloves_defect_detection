orgImg = imread('gloves/leather/TRG-3.png');

% apply Gaussian filtering for noise reduction
filteredImage = imgaussfilt(orgImg, 2);

grayImg = rgb2gray(filteredImage);

stretchedImg = imadjust(grayImg);

% sharpen the segmented image using unsharp masking
sharpenedImage = imsharpen(stretchedImg, 'Amount', 1.5, 'Radius', 1, 'Threshold', 0);

% Get the edge mask
edgeMask = edge(sharpenedImage, 'Canny');

% use Morphological Opertaion to recontruct the line
strelMask = imclose(edgeMask, strel("line", 17, 0));

% fill the line edge
fillMask = imfill(strelMask, "holes");

% remove the small object
finalMask = bwareaopen(fillMask, 1000);

% apply the mask
segementedImg = maskout(orgImg, finalMask);

figure;
subplot(431), imshow(orgImg), title('Original')
subplot(432), imshow(filteredImage), title('Filtered');
subplot(433), imshow(grayImg), title('Gray');
subplot(434), imshow(stretchedImg), title('Strectched');
subplot(435), imshow(sharpenedImage), title('Sharpened');
subplot(436), imshow(edgeMask), title('Edge (Canny)');
subplot(437), imshow(strelMask), title('Strel (linked the break lines');
subplot(438), imshow(fillMask), title('Fill Line');
subplot(439), imshow(finalMask), title('Final Mask');
subplot(4,3,10), imshow(segementedImg), title('Segemented');

function masked = maskout(src,mask)
    % mask: binary, same size as src, but does not have to be same data type (int vs logical)
    % src: rgb or gray image
    masked = bsxfun(@times, src, cast(mask,class(src)));
end