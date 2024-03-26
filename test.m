orgImg = imread('gloves/leather/TRG-1.png');
coins=imread('standard_test_images/coins.png');
[img, mask] = fn.edgeSegmentation(orgImg);

[img2, mask2] = fn.thresholdSegmentation(orgImg);



