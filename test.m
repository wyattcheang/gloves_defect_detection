orgImg = imread('gloves/cotton/2.jpg');
[img, mask] = fn.edgeSegmentation(orgImg);
[img2, mask2] = fn.thresholdSegmentation(orgImg);
figure;
subplot(131), imshow(orgImg), title('orgImg');
subplot(132), imshow(img), title('img');
subplot(133), imshow(mask), title('mask');

%%
% Load the segmented hand shape object (binary mask)
handMask = mask;

gloveBoundaryLineMask = bwperim(handMask); %
handBoundaryPixels = regionprops(gloveBoundaryLineMask, 'PixelList');
handBoundaryPixels = handBoundaryPixels.PixelList;

% Compute the convex hull of the hand boundary
convexHullMask = false(size(handMask));
convexHullIndices = convhull(handBoundaryPixels(:,1), handBoundaryPixels(:,2));
convexHullPixels = handBoundaryPixels(convexHullIndices, :);
convexHullMask(sub2ind(size(handMask), convexHullPixels(:,2), convexHullPixels(:,1))) = true;

palmMask = convexHullMask & handMask;

palmRegionProps = regionprops(palmMask, 'Centroid');
% Assuming the fingertips are at the topmost points within the palm region
% Filter out centroids near the boundaries
filteredCentroids = [];
minDistanceThreshold = 500;
for i = 1:numel(palmRegionProps)
    centroid = palmRegionProps(i).Centroid;
    if centroid(2) > 10 && centroid(2) < size(palmMask, 1) - 10 % Ignore points near the top and bottom boundaries
        % Check if the centroid is far enough from existing centroids
        if isempty(filteredCentroids) || ...
                all(sqrt(sum((centroid - filteredCentroids).^2, 2)) > minDistanceThreshold)
            filteredCentroids = [filteredCentroids; centroid];
        end
    end
end

% Plot the segmented palm and detected fingertips
figure;
subplot(121);
imshow(handMask);
hold on;
plot(convexHullPixels(:,1), convexHullPixels(:,2), 'r', 'LineWidth', 2); % Convex hull
plot(filteredCentroids(:,1), filteredCentroids(:,2), 'bo', 'MarkerSize', 10); % Fingertip locations
hold off;
title('Palm and Fingertips Detection');


%%
% Load the segmented hand shape object (binary mask)
handMask = mask;

% Palm Segmentation based on Circularity
handProperties = regionprops(handMask, 'Area', 'Centroid', 'Circularity');
disp(handProperties);
[~, maxCircularityIdx] = max([handProperties.Circularity]); % Find the most circular region

% Extract the circular palm region
palmCentroid = handProperties(maxCircularityIdx).Centroid;
palmRadius = sqrt(handProperties(maxCircularityIdx).Area / pi); % Estimate radius from area
[x, y] = meshgrid(1:size(handMask, 2), 1:size(handMask, 1));
palmMask = ((x - palmCentroid(1)).^2 + (y - palmCentroid(2)).^2) <= palmRadius.^2;

% Hand Landmark Detection within the palm area
% Example: Detect fingertips by finding the centroids of each finger segment
palmRegionProps = regionprops(palmMask, 'Centroid');
% Assuming the fingertips are at the topmost points within the palm region
% Filter out centroids near the boundaries
filteredCentroids = [];
for i = 1:numel(palmRegionProps)
    centroid = palmRegionProps(i).Centroid;
    if centroid(2) > 10 && centroid(2) < size(palmMask, 1) - 10 % Ignore points near the top and bottom boundaries
        filteredCentroids = [filteredCentroids; centroid];
    end
end

% Plot the segmented palm and detected fingertips
subplot(122);
imshow(handMask);
hold on;
viscircles(palmCentroid, palmRadius, 'Color', 'r', 'LineWidth', 2); % Circular palm
plot(filteredCentroids(:,1), filteredCentroids(:,2), 'bo', 'MarkerSize', 10); % Fingertip locations
hold off;
title('Palm and Fingertips Detection');






