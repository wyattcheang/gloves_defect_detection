classdef fn
    methods (Static)
        % TODO: Remove unused functions

        function img = gloves_defects_detection(inputImg)
            close all;
            
            [img, ~] = fn.edgeSegmentation(inputImg);

            lab_img = rgb2lab(img);

            % Extract glove segment
            glove_mask = detect_glove(img);

            % Get average clove color
            glove_mean_rgb = calculate_mean_glove_color(lab_img, glove_mask);

            % Detect defects
            [defects_img, defect_free_mask] = detect_defects(img, glove_mean_rgb);

            % Classify defects - stain / tearing / finger not enough
            [stain_bboxes, tearing_bboxes, fne_bboxes] = classify_defects(defects_img, defect_free_mask);

            % Highlight defects according to categories
            img = highlight_defects(inputImg, stain_bboxes, tearing_bboxes, fne_bboxes);

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

            % 
            stretched_img = imadjust(filtered_img, [0, 0.95]);

            % sharpen the segmented image using unsharp masking
            sharpened_img = imsharpen(stretched_img, 'Amount', 1.5, 'Radius', 1, 'Threshold', 0);

            img = sharpened_img;

            % TODO: remove
            figure('Name', 'Preprocessing');
            subplot(221), imshow(gray_img), title('Gray');
            subplot(222), imshow(filtered_img), title('Gaussian Filtered');
            subplot(223), imshow(stretched_img), title('Strectched');
            subplot(224), imshow(sharpened_img), title('Sharpened');
        end

        function [img, mask]=edgeSegmentation(img)
            % Get the edge mask
            edge_mask = edge(img, 'Canny');

            % use Morphological Opertaion to recontruct the line
            morph_mask = imclose(edge_mask, strel("line", 10, 0));
            morph_mask = imclose(morph_mask, strel("line", 6, 45));
            morph_mask = imclose(morph_mask, strel("line", 10, 90));
            morph_mask = imclose(morph_mask, strel("line", 6, 125));

            % fill the line edge
            filled_mask = imfill(morph_mask, "holes");

            % remove the small object
            final_mask = fn.dynamicBwareaopen(filled_mask, 60000);

            % apply the mask
            segemented_img = fn.maskout(img, final_mask);

            % TODO: remove
            figure;
            subplot(231), imshow(edge_mask), title('Edge (Canny)');
            subplot(232), imshow(morph_mask), title('Strel (linked the break lines');
            subplot(233), imshow(filled_mask), title('Fill Line');
            subplot(234), imshow(final_mask), title('Final Mask');
            subplot(235), imshow(segemented_img), title('Segemented');
            img = segemented_img;
            mask = final_mask;
        end

        function masked = maskout(src,mask)
            masked = bsxfun(@times, src, cast(mask,class(src)));
        end

        function finalMask = dynamicBwareaopen(inputImg, minSize)
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

        % use to replicate the grayscale channe to form an RGB image to
        % display
        function img=cat3GrayscaleImg(inputImg)
            img = rgb2gray(inputImg);
            img = cat(3, img, img, img);
        end

        function img=stretchImg(inputImg)
            img = imadjust(inputImg, [0.3, 0.7], []);
        end

        function [img,mask]=thresholdSegmentation(img)
            grayImg=rgb2gray(img);
            % apply Gaussian filtering for noise reduction
            filteredImage = imgaussfilt(grayImg, 3);

            stretchedImg = imadjust(filteredImage, [0, 0.95]);

            % sharpen the segmented image using unsharp masking
            sharpenedImg = imsharpen(stretchedImg, 'Amount', 1.5, 'Radius', 1, 'Threshold', 0);

            level=graythresh(sharpenedImg);

            mask = imcomplement(imbinarize(grayImg, level));

            fillMask = imfill(mask, "holes");

            mask = fn.dynamicBwareaopen(fillMask, 60000);

            figure;
            subplot(231), title('original'), imshow(img);
            subplot(232), title('gray'), imshow(grayImg);
            subplot(233), title('stretched Img'), imshow(stretchedImg);
            subplot(234), title('sharpen Img'), imshow(sharpenedImg);
            subplot(235), title('mask'), imshow(mask);
            img = fn.maskout(img, mask);
            subplot(236), title('applied mask'), imshow(img);
        end
    end
end