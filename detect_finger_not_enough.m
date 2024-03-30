function fne_bboxes = detect_finger_not_enough(img)

% Exposed Finger Extraction
skin_mask = detect_skin(img);

% Accept size within 1000 and 50000 pixels (finger size)
sizeThreshold = [1000, 50000];
finger = bwpropfilt(skin_mask, 'Area', sizeThreshold);

% Record number of fingers
cc  = bwconncomp(finger);
fingerNum = cc.NumObjects;

% Compute the properties of each connected component
stats = regionprops(cc, 'BoundingBox');
fne_bboxes = zeros(cc.NumObjects, 4);

% Loop through each connected component
for i = 1:cc.NumObjects
    bbox = stats(i).BoundingBox;
    fne_bboxes(i, :) = bbox;
end

% Display results
figure;
subplot(131), imshow(img), title('Glove Region');
subplot(132), imshow(skin_mask),title('Skin Exposed');
subplot(133), imshow(finger), title('Fingers Exposed');

% Output finger count
fprintf('Number of fingers: %d\n', fingerNum);

% Check if number of fingers is not 5
if fingerNum ~= 5
    disp('-> Finger count not enough');
else
    disp('-> Finger count is enough');
end
end
