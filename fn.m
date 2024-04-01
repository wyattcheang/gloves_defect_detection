classdef fn
    methods (Static)
        % TODO: Remove unused functions

        function img = gloves_defects_detection(org_img)
            close all;
            
            % image pre-processing
            gray_img = preprocessing(org_img);
           
            % image segmentation
            [img, mask] = edge_segmentation(org_img, gray_img);

            % Getting the area of the object
            object_area = bwarea(mask);

            lab_img = rgb2lab(img);

            % Palm Finger Extraction
            [palm_mask, finger_mask] = part_extraction(mask);

            % Extract glove segment
            glove_mask = detect_glove(img);

            % Get average clove color
            glove_mean_rgb = calculate_mean_glove_color(lab_img, glove_mask);

            % Detect defects
            [defects_img, ~] = detect_defects(img, glove_mean_rgb);

            % Classify defects - stain / tearing / finger not enough
            [defect_names, defect_boxes] = classify_defects(defects_img, palm_mask, finger_mask, object_area);

            % Highlight defects according to categories
            img = highlight_defects(org_img, defect_names, defect_boxes);
        end

        function img = img2gray(inputImg)
            % Check if the input image is already grayscale
            if size(inputImg, 3) == 1
                % Input image is already grayscale, return it directly
                img = inputImg;
            else
                % Convert the image to grayscale
                img = rgb2gray(inputImg);
                % Replicate the grayscale channel to form an RGB image
                img = cat(3, img, img, img);
            end
        end

        function img = applied_mask(src, mask)
            img = bsxfun(@times, src, cast(mask,class(src)));
        end

        function final_mask = dynamic_bwareaopen(input_img, min_size)
            % Initial call to bwareaopen
            final_mask = bwareaopen(input_img, min_size);

            % Check if final mask has at least one object
            if any(final_mask(:))
                return;  % No further processing needed
            end

            % Iterate to find minimum size with at least one object
            while min_size > 0
                % Apply bwareaopen with updated minimum size
                final_mask = bwareaopen(input_img, min_size);

                % Check if final mask has at least one object
                if any(final_mask(:))
                    return;  % Stop iteration if at least one object is found
                end

                % Reduce the minimum size for the next iteration
                min_size = max(min_size - 100, 1);
            end
        end

        function auto_plot_images(figure_name, image_titles, images)
            
            % Create a new figure with the specified name
            figure('Name', figure_name);
            
            % Determine the number of rows and columns for the subplot layout
            num_images = numel(images);
            num_rows = ceil(sqrt(num_images));
            num_cols = ceil(num_images / num_rows);
            
            % Plot each image with its title
            for i = 1:num_images
                subplot(num_rows, num_cols, i);
                imshow(images{i});
                title(image_titles{i});
            end
        end

    end
end