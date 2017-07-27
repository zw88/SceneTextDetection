function [bbox,idx] = repeatFilt(boxes)

boxesNum = size(boxes, 1);
scores = boxes(:, 5);

[~,id] = sort(scores, 'descend');
boxes = boxes(id,:);
num_final = 0;
labels = zeros(boxesNum);

for i = 1:boxesNum
    if(labels(i)~=0)
        continue;
    end
    
    box_i = boxes(i, :);
    ol_area = rectint(box_i(1:4), boxes(:,1:4));
    comb_area = rectbbox(box_i(1:4), boxes(:,1:4));
    ol = double(ol_area)./double(comb_area);
    id2 = find(ol>0.5);
    
    %id2 = find(ol>0.7);
    
    %boxes_tmp = boxes(id2,:);
    %[~,id3] = max(boxes_tmp(:,5));
    
    labels(id2) = 1;
    num_final = num_final + 1;
    bbox(num_final,:) = box_i;%boxes_tmp(id3);
    idx(num_final) = id(i);
end