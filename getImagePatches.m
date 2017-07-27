function image_patches = getImagePatches(image, boxes)
img_width = size(image, 2);
img_height = size(image, 1);

for i = 1: size(boxes, 1)
    xmin = boxes(i,1);
    ymin = boxes(i,2);
    width = boxes(i,3);
    height = boxes(i,4);
    xcenter = floor(xmin + width/2);
    ycenter = floor(ymin + height/2);
    xmax = xmin + width;
    ymax = ymin + height;
    
    mar = max(width, height);
    
    xmin_new = max(xcenter-floor(mar/2+width/15), 1);
    ymin_new = max(ycenter-floor(mar/2+height/15), 1);
    xmax_new = min(xcenter+floor(mar/2+width/15), img_width);
    ymax_new = min(ycenter+floor(mar/2+height/15), img_height);
    
    mar_left = xcenter - xmin_new;
    mar_right = xmax_new - xcenter;
    
    if mar_left>mar_right
        xmin_new = xcenter - mar_right;
    else
        xmax_new = xcenter + mar_left;
    end
    
    image_patch = image(ymin_new:ymax_new, xmin_new:xmax_new, :);
    image_patch = imresize(image_patch,[32 32], 'bilinear');
    image_patch = single(image_patch);
    image_patches(:,:,:,i) = image_patch;
end
end