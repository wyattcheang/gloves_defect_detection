%% Computes the mean color of the glove region
function glove_mean_rgb = calculate_mean_glove_color(lab_img, glove_mask)

% Extract LAB channels
L = lab_img(:,:,1);
A = lab_img(:,:,2);
B = lab_img(:,:,3);

% Initialize sum of colors and count of non-black pixels
sum_L = 0;
sum_A = 0;
sum_B = 0;
count = 0;

% Calculate the mean color of non-black pixels in the glove segment
for i = 1:size(glove_mask, 1)
    for j = 1:size(glove_mask, 2)
        if glove_mask(i, j) == 1 && L(i, j) > 0 % Check if it belongs to glove and not black
            sum_L = sum_L + L(i, j);
            sum_A = sum_A + A(i, j);
            sum_B = sum_B + B(i, j);
            count = count + 1;
        end
    end
end

% Calculate mean color
mean_L = sum_L / count;
mean_A = sum_A / count;
mean_B = sum_B / count;

% Display mean color
fprintf('Mean color of the glove: L = %.2f, A = %.2f, B = %.2f\n', mean_L, mean_A, mean_B);

% Convert mean LAB color to RGB
glove_mean_lab = [mean_L, mean_A, mean_B];
glove_mean_rgb = lab2rgb(glove_mean_lab);

% % Create a blank image with the same size as the original image
% result_image = zeros(size(lab_img), 'uint8');
% 
% % Fill the image with the mean RGB color
% result_image(:,:,1) = glove_mean_rgb(1) * 255;
% result_image(:,:,2) = glove_mean_rgb(2) * 255;
% result_image(:,:,3) = glove_mean_rgb(3) * 255;
% 
% figure('Name','Detect Glove Color'), imshow(result_image), title('Mean color (RGB)');
end
