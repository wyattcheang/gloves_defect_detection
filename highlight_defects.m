function highlighted_img = highlight_defects(org_img, defect_names, bboxes)

% Function to provide a visual representation of detected defects on the original image

% Define custom RGB colors
colors = {...
    [0 0.4470 0.7410], ... % Blue
    [0.8500 0.3250 0.0980], ... % Orange
    [0.9290 0.6940 0.1250], ... % Yellow
    [0.4940 0.1840 0.5560], ... % Purple
    [0.4660 0.6740 0.1880], ... % Green
    [0.3010 0.7450 0.9330], ... % Light Blue
    [0.6350 0.0780 0.1840], ... % Maroon
    [1 0 1], ... % Magenta
    [0 1 1], ... % Cyan
    };

% Display original image
figure;
imshow(org_img);
hold on;

% Loop through different types of defects
for d = 1:numel(bboxes)
    % Get bounding boxes and defect names for the current defect type
    cur_bboxes = bboxes{d};
    cur_color = colors{mod(d-1, numel(colors))+1}; % Wrap around colors if there are more defect types than colors
    cur_defect_name = defect_names{d};

    % Draw rectangles and add text labels for the current defect type
    for i = 1:size(cur_bboxes, 1)
        % Get bounding box coordinates
        x = cur_bboxes(i, 1);
        y = cur_bboxes(i, 2);

        % Draw rectangle around the region
        rectangle('Position', cur_bboxes(i,:), 'EdgeColor', cur_color, 'LineWidth', 2);

        % Add text label
        text(x, y-10, cur_defect_name, 'Color', cur_color, 'FontSize', 12, 'FontWeight', 'bold');
    end
end

% Capture the frame and store it as the highlighted image
highlighted_img = getframe(gcf);
highlighted_img = highlighted_img.cdata;

hold off;
end
