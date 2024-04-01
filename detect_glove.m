%% Performs glove detection in an input image using color segmentation based on k-means clustering
function glove_mask = detect_glove(img)

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

img_titles = {'Original', 'Labeled Image a*b*', 'Objects in Cluster 1', 'Objects in Cluster 2', 'Glove Mask'};
imgs = {img, B2, cluster1, cluster2, glove_mask};
fn.auto_plot_images('Kmeans For Color Segmentation', img_titles, imgs);
end
