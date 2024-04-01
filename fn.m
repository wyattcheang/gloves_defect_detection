classdef fn
    methods (Static)
        % TODO: Remove unused functions

        function img = gloves_defects_detection(input_img)
            close all;
            
            % image pre-processing
            gray_img = fn.preprocessing(input_img);
           
            % image segmentation
            [img, mask] = fn.edge_segmentation(input_img, gray_img);

            % Getting the area of the object
            object_area = bwarea(mask);

            lab_img = rgb2lab(img);

            % Palm Finger Extraction
            [plam_mask, finger_mask] = part_extraction(mask);

            % Extract glove segment
            glove_mask = detect_glove(img);

            % Get average clove color
            glove_mean_rgb = calculate_mean_glove_color(lab_img, glove_mask);

            % Detect defects
            [defects_img, defect_free_mask] = detect_defects(img, glove_mean_rgb);

            % Classify defects - stain / tearing / finger not enough
            [stain_bboxess, tearing_bboxes, fne_bboxes] = classify_defects(defects_img, finger_mask, object_area);

            % Highlight defects according to categories
            img = highlight_defects(input_img, stain_bboxess, tearing_bboxes, fne_bboxes);
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

        function [img] = preprocessing(img)
            % change to Gray Scale Image
            gray_img = rgb2gray(img);

            % apply Gaussian filtering for noise reduction
            filtered_img = imgaussfilt(gray_img, 3);

            % histogram equalization
            stretched_img = imadjust(filtered_img, [0, 0.95]);

            % sharpen the segmented image using unsharp masking
            sharpened_img = imsharpen(stretched_img, 'Amount', 1.5, 'Radius', 1, 'Threshold', 0);

            img = sharpened_img;
        end

        function [img, mask]=edge_segmentation(org_ing, gray_img)
            % Get the edge mask
            edge_mask = edge(gray_img, 'canny');

            % use Morphological Opertaion to recontruct the line
            morph_mask = imclose(edge_mask, strel("line", 10, 0));
            morph_mask = imclose(morph_mask, strel("line", 6, 45));
            morph_mask = imclose(morph_mask, strel("line", 10, 90));
            morph_mask = imclose(morph_mask, strel("line", 6, 125));

            % fill the line edge
            filled_mask = imfill(morph_mask, "holes");

            % remove the small object
            mask = fn.dynamic_bwareaopen(filled_mask, 60000);

            % apply the mask
            img = fn.maskout(org_ing, mask);

            subplot
        end

        % use to replicate the grayscale channe to form an RGB image to
        % display
        function img=cat3GrayscaleImg(inputImg)
            img = rgb2gray(inputImg);
            img = cat(3, img, img, img);
        end

        function [img,mask]=threshold_segmentation(org_ing, gray_img)
            % calculate the threshold value
            level = graythresh(gray_img);

            % get the threshold mask
            thresholded_mask = imcomplement(imbinarize(gray_img, level));

            % fill the holes
            fill_mask = imfill(thresholded_mask, "holes");
            
            % remove the small object
            mask = fn.dynamic_bwareaopen(fill_mask, 60000);
            
            % apply the mask
            img = fn.maskout(org_ing, mask);

            figure;
            subplot(221), title('Thresholded Mask'), imshow(thresholded_mask);
            subplot(222), title('Filled Mask'), imshow(fill_mask);
            subplot(223), title('Final Mask'), imshow(mask);
            subplot(224), title('Segemented'), imshow(img);
        end

        function masked = maskout(src,mask)
            masked = bsxfun(@times, src, cast(mask,class(src)));
        end

        function finalMask = dynamic_bwareaopen(inputImg, minSize)
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

    end
end