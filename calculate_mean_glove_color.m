function glove_mean_lab = calculate_mean_glove_color(lab_img, glove_mask)

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
glove_mean_lab = reshape(glove_mean_lab, [1, 1, 3]); % Reshape to 1x1x3 for broadcasting
glove_mean_rgb = lab2rgb(glove_mean_lab);

% Create a blank image with the same size as the original image
result_image = repmat(uint8(glove_mean_rgb * 255), [size(lab_img, 1), size(lab_img, 2), 1]);
figure('Name','Detect Glove Color'), imshow(result_image), title('Mean color (RGB)');
end
