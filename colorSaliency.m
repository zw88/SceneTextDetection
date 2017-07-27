function [idSaliency, salVal] = colorSaliency(image,maskid)

% addpath('./util/Cosaliency/');
% addpath('./util/Cosaliency/');
img_width = size(image,2);
img_height = size(image,1);
if(nargin<2)
    maskid = 1:(img_width*img_height);
end

sa_map_r = double(image(:,:,1));
sa_map_g = double(image(:,:,2));
sa_map_b = double(image(:,:,3));


validate_r = double(sa_map_r(maskid));
validate_g = double(sa_map_g(maskid));
validate_b = double(sa_map_b(maskid));


w = [144 12 1];

rmin = min(validate_r(:));
rmax = max(validate_r(:));

gmin = min(validate_g(:));
gmax = max(validate_g(:));

bmin = min(validate_b(:));
bmax = max(validate_b(:));

validate_r = (validate_r-rmin) / 255;
validate_g = (validate_g-gmin) / 255;
validate_b = (validate_b-bmin) / 255;
tmp_r = validate_r;
tmp_g = validate_g;
tmp_b = validate_b;



validate_img = [validate_r validate_g validate_b];


clrTmp = 12-0.0001;
idx = floor(validate_b*clrTmp)*w(1) + floor(validate_g*clrTmp)*w(2) + floor(validate_r*clrTmp)*w(3);

idx2 = sort(idx(:),'ascend');

[mapKey, mapVal,~] = unique(idx2,'stable');
mapVal = [mapVal(:)' size(image,1)*size(image,2)+1];
mapVal = diff(mapVal);

[mapVal,loc] = sort(mapVal(:),'descend');
mapKey = mapKey(loc);

num = [mapVal,mapKey];


maxDropNum = round(length(validate_r)*(1-0.94999));

cSum = cumsum(mapVal(end:-1:1));
loc = find(cSum>maxDropNum);
loc = loc(1);

maxNum = length(mapKey)-loc+1;

if(maxNum <= 10)
    maxNum = min(10, length(mapVal));
end

tmpId = (0:maxNum-1)';

[tmpKey, tmpLoc] = sort(mapKey(1:maxNum));  
tmpId = tmpId(tmpLoc);

pallet = [tmpKey, tmpId];



color3i = zeros(size(num,1), 3);
color3i(:,1) = num(:,2) / w(1);
color3i(:,2) = mod(num(:,2), w(1)) / w(2);
color3i(:,3) = mod(num(:,2), w(2));

color3i = floor(color3i);


for i = maxNum+1:size(mapVal,1)
    
   res_color_i = color3i(i,:);
   res_color_i = repmat(res_color_i, [maxNum 1]);
   
   dist_i =sum( (res_color_i - color3i(1:maxNum,:)).^2, 2);
   
   [~,loc] = min(dist_i);
    simIdx = loc(1)-1;
    
    pallet(i,1) = num(i,2);
    pallet(i,2) = simIdx;
end


[~,loc] = sort(pallet(:,1));
pallet = pallet(loc,:);

val = pallet(:,1);
id = pallet(:,2);


color_id_map = zeros(length(validate_r),1);

for i = 1:length(val)

    tmpVal = val(i);
    loc = find(idx==tmpVal);
    color_id_map(loc) = id(i);
    
end


tmp = unique(id);
color_table = zeros(length(tmp),3);
color_num = zeros(length(tmp),1);


img_q_r = zeros(length(validate_r),1);
img_q_g = zeros(length(validate_r),1);
img_q_b = zeros(length(validate_r),1);



for i = 1:length(tmp)
    tmpVal = tmp(i);
    loc = find(color_id_map == tmpVal);
    color_num(i) = length(loc);
    
    
    
    color_table(tmpVal+1,1) = sum(tmp_r(loc))/length(loc);
    color_table(tmpVal+1,2) = sum(tmp_g(loc))/length(loc);
    color_table(tmpVal+1,3) = sum(tmp_b(loc))/length(loc);

    img_q_r(loc) = sum(tmp_r(loc))/length(loc);
    img_q_g(loc) = sum(tmp_g(loc))/length(loc);
    img_q_b(loc) = sum(tmp_b(loc))/length(loc);

end




% sa_map_r(maskid) = img_q_r;
% sa_map_g(maskid) = img_q_g;
% sa_map_b(maskid) = img_q_b;
% 
% image_q = cat(3, sa_map_r, sa_map_g, sa_map_b);




%%

% A =[ 27.0744  -22.8078   -1.8067
%    -5.6467   -7.7221   12.8650
%    -4.1631   -4.5794   -4.5760];
% 
% 
% B =[0.9465    0.2947   -0.1313
%    -0.1179    0.9930    0.0074
%     0.0923   -0.0465    0.9946];










color_table_Lab = colorspace('lab<-rgb', color_table);



% color_table_Lab = A*log(B*double(color_table'));
% color_table_Lab = color_table_Lab';







weights = color_num/sum(color_num(:));
weights = weights';

tmpNum = length(weights);

colorSal = zeros(1,tmpNum);

for i = 1:tmpNum
    color_i = color_table_Lab(i,:);
    
    similar_i = zeros(tmpNum,2);

    
    tmpColor_i = repmat(color_i, [tmpNum, 1]);
    dist_i = sum((tmpColor_i-color_table_Lab).^2, 2);
    dist_i = sqrt(dist_i);
    
    [val,index] = sort(dist_i,'ascend');
    similar_i(:,1) = val;
    similar_i(:,2) = index;
    
    similar{i} = similar_i;
    
    
    colorSal(i) = weights*dist_i;
    
end


delta = 0.25;
binN = size(color_table_Lab,1);
n = max(round(binN*delta), 2);


newSal = zeros(1, size(color_table_Lab,1));
totalDist = zeros(1, size(color_table_Lab,1));



for i = 1:tmpNum
    
   similar_i = similar{i};
   
   totalDist(i) = sum(similar_i(1:n,1));
    
    
    
end

for i = 1:tmpNum
    
    similar_i = similar{i};
    dist_i = similar_i(1:n,1);
    id_i = similar_i(1:n,2);
    val = colorSal(id_i);
    val = val(:)';
    
    valCrnt = val*(totalDist(i) - dist_i);
    newSal(i) = valCrnt/(totalDist(i)*n);
    
end



newSal = mat2gray(newSal);


idSaliency = newSal(color_id_map+1);

salVal = sort(newSal,'descend');
























