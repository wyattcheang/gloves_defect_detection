%% Provides a visual representation of the detected defects on the original image

function highlighted_img = highlight_defects(org_img, stain_bboxes, tearing_bboxes, fne_bboxes)

figure('Name', 'Final Image'), imshow(org_img), title('Detected Defects');
hold on;

% Draw rectangles and add text labels for stain regions
for i = 1:size(stain_bboxes, 1)
    % Get bounding box coordinates
    x = stain_bboxes(i, 1);
    y = stain_bboxes(i, 2);

    % Draw rectangle around the region
    rectangle('Position', stain_bboxes(i,:), 'EdgeColor', 'g', 'LineWidth', 2);

    % Add text label
    text(x, y-10, 'Stain', 'Color', 'g', 'FontSize', 12, 'FontWeight', 'bold');
end

% Draw rectangles and add text labels for tearing regions
for i = 1:size(tearing_bboxes, 1)
    % Get bounding box coordinates
    x = tearing_bboxes(i, 1);
    y = tearing_bboxes(i, 2);

    % Draw rectangle around the region
    rectangle('Position', tearing_bboxes(i,:), 'EdgeColor', 'r', 'LineWidth', 2);

    % Add text label
    text(x, y-10, 'Tearing', 'Color', 'r', 'FontSize', 12, 'FontWeight', 'bold');
end

% Draw rectangles and add text labels for stain regions
for i = 1:size(fne_bboxes, 1)
    % Get bounding box coordinates
    x = fne_bboxes(i, 1);
    y = fne_bboxes(i, 2);

    % Draw rectangle around the region
    rectangle('Position', fne_bboxes(i,:), 'EdgeColor', 'y', 'LineWidth', 2);

    % Add text label
    text(x, y-10, 'Finger Not Enough', 'Color', 'y', 'FontSize', 12, 'FontWeight', 'bold');
end

hold off;

% Capture the frame and store it as the highlighted image
highlighted_img = getframe(gcf);
highlighted_img = highlighted_img.cdata;

% Close the figure
% close(gcf);

end
