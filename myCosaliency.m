function Saliency_Map_single = myCosaliency(image)

% addpath('./util/Cosaliency/COS_code');

%para.result_path = './img_output/';


para.Bin_num_single = 6;
para.Scale = 300;

data.image{1} = image;

[orgH, orgW, channel]=size(data.image{1});

% single sliency detection
single_map = Single_saliency_main( data, 1, para.Scale, para.Bin_num_single);

Saliency_Map_single=imresize(Gauss_normal(single_map), [orgH, orgW]);
Saliency_Map_single = uint8(255*Saliency_Map_single);
%imwrite(data.image{1},[para.result_path  para.img_name(1:end-4) '_org.png'],'png');
%imwrite(Saliency_Map_single, [para.result_path  para.img_name(1:end-4) '_single.png'],'png');

%figure,subplot(1,2,1), imshow(data.image{1}),title('Input images');
%subplot(1,2,2),imshow(Saliency_Map_single),title('Single Saliency');



