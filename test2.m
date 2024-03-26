orgImg = imread('gloves/leather/DRT-3-Clean.jpg');

grayImg = rgb2gray(orgImg);

% apply Gaussian filtering for noise reduction
filteredImage = imgaussfilt(grayImg, 3);

stretchedImg = imadjust(filteredImage, [0, 0.95]);

% sharpen the segmented image using unsharp masking
sharpenedImage = imsharpen(stretchedImg, 'Amount', 1.5, 'Radius', 1, 'Threshold', 0);

% Get the edge mask
edgeMask = edge(sharpenedImage, 'Canny');

% use closing remove small line

% use Morphological Opertaion to recontruct the line
strelMask = imclose(edgeMask, strel("line", 10, 0));
strelMask = imclose(strelMask, strel("line", 4, 45));
strelMask = imclose(strelMask, strel("line", 10, 90));
strelMask = imclose(strelMask, strel("line", 4, 125));



% fill the line edge
fillMask = imfill(strelMask, "holes");

% remove the small object
finalMask = dynamicBwareaopen(fillMask, 60000);

% apply the mask
segementedImg = maskout(orgImg, finalMask);

figure;
subplot(231), imshow(orgImg), title('Original')
subplot(232), imshow(grayImg), title('Gray');
subplot(233), imshow(filteredImage), title('Gaussian Filtered');

subplot(234), imshow(stretchedImg), title('Strectched');
subplot(235), imshow(sharpenedImage), title('Sharpened');
subplot(236), imshow(edgeMask), title('Edge (Canny)');

figure;
subplot(231), imshow(strelMask), title('Strel (linked the break lines');
subplot(232), imshow(fillMask), title('Fill Line');
subplot(233), imshow(finalMask), title('Final Mask');
subplot(234), imshow(segementedImg), title('Segemented');

function masked = maskout(src,mask)
    masked = bsxfun(@times, src, cast(mask,class(src)));
end

function finalMask = dynamicBwareaopen(inputImg, minSize)
    % Initial call to bwareaopen
    finalMask = bwareaopen(inputImg, minSize);

    % Check if final mask has at least one object
    if any(finalMask(:))
        return;  % No further processing needed
    end

    % Iterate to find minimum size with at least one object
    while minSize > 0
        % Apply bwareaopen with updated minimum size
        finalMask = bwareaopen(inputImg, minSize);
        
        % Check if final mask has at least one object
        if any(finalMask(:))
            return;  % Stop iteration if at least one object is found
        end
        
        % Reduce the minimum size for the next iteration
        minSize = max(minSize - 100, 1);
    end
end

