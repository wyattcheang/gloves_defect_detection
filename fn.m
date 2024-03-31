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

        function [img, mask]=edgeSegmentation(img)
            grayImg = rgb2gray(img);

            % apply Gaussian filtering for noise reduction
            filteredImage = imgaussfilt(grayImg, 3);

            stretchedImg = imadjust(filteredImage, [0, 0.95]);

            % sharpen the segmented image using unsharp masking
            sharpenedImage = imsharpen(stretchedImg, 'Amount', 1.5, 'Radius', 1, 'Threshold', 0);

            % Get the edge mask
            edgeMask = edge(sharpenedImage, 'Canny');

            % use closing remove small line

            % use Morphological Opertaion to recontruct the line
            strelMask = imclose(edgeMask, strel("line", 10, 0));
            strelMask = imclose(strelMask, strel("line", 4, 45));
            strelMask = imclose(strelMask, strel("line", 10, 90));
            strelMask = imclose(strelMask, strel("line", 4, 125));



            % fill the line edge
            fillMask = imfill(strelMask, "holes");

            % remove the small object
            finalMask = fn.dynamicBwareaopen(fillMask, 60000);

            % apply the mask
            segementedImg = fn.maskout(img, finalMask);

            % %TODO: remove after final tuning
            % figure('Name', 'Preprocessing');
            % subplot(231), imshow(img), title('Original')
            % subplot(232), imshow(grayImg), title('Gray');
            % subplot(233), imshow(filteredImage), title('Gaussian Filtered');
            %
            % subplot(234), imshow(stretchedImg), title('Strectched');
            % subplot(235), imshow(sharpenedImage), title('Sharpened');
            % subplot(236), imshow(edgeMask), title('Edge (Canny)');
            %
            % figure;
            % subplot(231), imshow(strelMask), title('Strel (linked the break lines');
            % subplot(232), imshow(fillMask), title('Fill Line');
            % subplot(233), imshow(finalMask), title('Final Mask');
            % subplot(234), imshow(segementedImg), title('Segemented');
            img = segementedImg;
            mask = finalMask;
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