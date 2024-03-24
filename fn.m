classdef fn
    methods (Static)
        function img=gloveDetection(inputImg)
            mask = fn.imgSegmentation(inputImg);
            img = inputImg.*repmat(double(mask),[1,1,3]);
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

        function mask=imgSegmentation(inputImg)
            % convert to grayscale image
            grayImg = rgb2gray(inputImg);

            % Get the edge mask
            edgeMask = edge(grayImg, 'Canny');
            
            % use Morphological Opertaion to recontruct the line
            strelMask = imclose(edgeMask, strel("line", 10, 0));
            
            % fill the line edge
            fillMask = imfill(strelMask, "holes");
            
            % remove the small object
            mask = bwareaopen(fillMask, 100);
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

        function 

    end
end