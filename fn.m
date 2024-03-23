classdef fn
    methods (Static)
        function img = img2gray(inputImg)
            % Example processing: convert image to grayscale
            img = rgb2gray(inputImg);
            img = cat(3, img, img, img);
        end
    end
end