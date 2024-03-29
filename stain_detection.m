function stain_detection_img = stain_detection(img, background_lab, threshold)
    % Convert the image to Lab color space
    lab_img = rgb2lab(img);

    % Calculate Delta E for each pixel
    delta_E = sqrt((lab_img(:,:,1) - background_lab(1)).^2 + ...
                   (lab_img(:,:,2) - background_lab(2)).^2 + ...
                   (lab_img(:,:,3) - background_lab(3)).^2);

    % Apply threshold to Delta E values
    stain_mask = delta_E > threshold;

    % Apply the stain mask to the original image
    stain_detection_img = bsxfun(@times, img, uint8(stain_mask));
end
