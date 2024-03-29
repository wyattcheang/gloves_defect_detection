function glove_mask = detect_glove(img)
% function glove_mask = detect_glove(lab_img)

% % TODO: Change the input image format to lab color space
% Convert the image to LAB color space
lab_img = rgb2lab(img);

% Perform k-means clustering
ab = lab_img(:,:,2:3);
ab = im2single(ab);
pixel_labels = imsegkmeans(ab, 2, 'NumAttempts', 5);

% For display purpose
B2 = labeloverlay(img,pixel_labels);
mask1 = pixel_labels == 1;
cluster1 = img.*uint8(mask1);
mask2 = pixel_labels == 2;
cluster2 = img.*uint8(mask2);

% Convert pixel_labels to binary masks for each segment
num_segments = max(pixel_labels(:));
segment_masks = cell(1, num_segments);
segment_areas = zeros(1, num_segments);
for i = 1:num_segments
    segment_masks{i} = pixel_labels == i;
    segment_areas(i) = sum(segment_masks{i}(:));
end

% Find the index of the largest segmented region (assumed to be glove)
[~, largest_segment_idx] = max(segment_areas);

% Extract the largest segmented region (glove segment)
glove_mask = ~segment_masks{largest_segment_idx};

figure('Name','Kmeans For Color Segmentation');
subplot(221), imshow(img), title('Original')
subplot(222), imshow(B2), title("Labeled Image a*b*")
subplot(223), imshow(cluster1), title("Objects in Cluster 1");
subplot(224), imshow(cluster2), title("Objects in Cluster 2");
imshow(glove_mask), title('Glove Mask');

end
