function vertices_intensity = projectIntersections(left_multi_intensity, right_multi_intensity, data_type)

multi_intensity = [left_multi_intensity; right_multi_intensity];
if strcmp(data_type, 'binary values') || strcmp(data_type, 'continuous positive values')
    vertices_intensity = max(multi_intensity, [], 2);
elseif strcmp(data_type, 'positive and negative values')
    max_intensity = max(multi_intensity, [], 2);
    min_intensity = min(multi_intensity, [], 2);
    vertices_intensity = zeros(size(multi_intensity, 1), 1);
    for i = 1:size(multi_intensity, 1)
        if abs(max_intensity(i)) >= abs(min_intensity(i))
            vertices_intensity(i) = max_intensity(i);
        else
            vertices_intensity(i) = min_intensity(i);
        end
    end
elseif strcmp(data_type, 'discrete positive values')
    % create a linearly decreasing vector (decrease with distance from the original surface)
    n = size(multi_intensity, 2);
    lin_decrease_vec = zeros(n, 1);
    buttom = 0.33;
    step = (1 - buttom) / (n - 1);
    for i = 1:n
        lin_decrease_vec(i) = buttom + (step * (n - i));
    end
    % count the occurence of each values present in the image along each
    % projection line and find preare to display the value with the highest
    % count for each projection line
    vertices_intensity = zeros(size(multi_intensity, 1), 1);
    values = unique(multi_intensity);
    count = zeros(size(multi_intensity, 1), length(values));
    for i = 1:length(values)
        if values(i) > 0
            count(:, i) = (multi_intensity == values(i)) * lin_decrease_vec;
        end
    end
    max_count = max(count, [], 2);
    for i = 1:size(multi_intensity, 1)
        max_ind = find(count(i, :) == max_count(i));
        vertices_intensity(i) = values(max_ind(1));
    end
end