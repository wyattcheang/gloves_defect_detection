function fingernum = finger_counter(img)
% Exposed Finger Extraction
skin_mask = skin_detector(img);

% Accept size within 1000 and 50000 pixels (finger size)
sizeThreshold = [1000, 50000];
finger = bwpropfilt(skin_mask, 'Area', sizeThreshold);

% Record number of fingers
[~,fingernum]  = bwlabel(finger);

% Display results
figure;
subplot(131), imshow(img), title('Glove Region');
subplot(132), imshow(skin_mask),title('Skin Exposed');
subplot(133), imshow(finger), title('Fingers Exposed');

% Output finger count
fprintf('Number of fingers: %d\n', fingernum);

% Check if number of fingers is not 5
if fingernum ~= 5
    disp('-> Finger count not enough');
else
    disp('-> Finger count is enough');
end
end
