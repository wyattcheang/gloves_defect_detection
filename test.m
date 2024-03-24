orgImg = imread('gloves/leather/DRT-4.jpg');

grayImg = rgb2gray(orgImg);

stretchedImg = fn.stretchImg(grayImg);

% Get the edge mask
edgeMask = edge(stretchedImg, 'Canny');

% use Morphological Opertaion to recontruct the line
strelMask = imclose(edgeMask, strel("line", 8, 0));

% fill the line edge
fillMask = imfill(strelMask, "holes");

% remove the small object
finalMask = bwareaopen(fillMask, 1000);

% apply the mask
segementedImg = maskout(orgImg, finalMask);

figure;
subplot(331), imshow(orgImg), title('Original');
subplot(332), imshow(grayImg), title('Gray');
subplot(333), imshow(grayImg), title('Gray');
subplot(334), imshow(edgeMask), title('Edge (Canny)');
subplot(335), imshow(strelMask), title('Strel (linked the break lines');
subplot(336), imshow(fillMask), title('Fill Line');
subplot(337), imshow(finalMask), title('Final Mask');
subplot(338), imshow(segementedImg), title('Segemented');

function masked = maskout(src,mask)
    % mask: binary, same size as src, but does not have to be same data type (int vs logical)
    % src: rgb or gray image
    masked = bsxfun(@times, src, cast(mask,class(src)));
end