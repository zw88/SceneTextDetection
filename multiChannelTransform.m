% Multi-channel image transform
function intensity_maps = multiChannelTransform(rgb)
% rgb = imread('img_1.jpg');
% [m, n, p] = size(rgb);
% % transform matrix
% B = [0.947 0.295 -0.131;-0.118 0.993 0.00737;0.0923 -0.0465 0.995];
% A = [27.1 -22.8 -1.81;-5.65 -7.72 12.9;-4.16 -4.58 -4.58];
% % RGB to YCbCr color space
% ycbcr = rgb2ycbcr(rgb);
% rgb = double(rgb)/255;
% % RGB to CIE xyz space
% xyz = rgb2xyz(rgb);
% x = xyz(:,:,1);y = xyz(:,:,2);z= xyz(:,:,3);
% xyz_sensor = cat(2,x(:),y(:),z(:));
% % xyz to PII space
% pii_xyz_sensor = A * log(B * xyz_sensor'); pii_xyz_sensor =  pii_xyz_sensor';    
% pii_xyz = reshape(pii_xyz_sensor, [m n p]);
% pii_rgb = xyz2rgb(pii_xyz);
% pii_rgb = real(pii_rgb);
% pii_rgb = uint8(floor(pii_rgb * 255));
rgb = im2double(rgb);
pii_rgb = rgb2ill(rgb);
% PII to hsv space
pii_hsv = rgb2hsv(pii_rgb);
% clear xyz xyz_sensor pii_xyz_sensor pii_xyz pii_rgb;
% eight intensity maps; gray in RGB, hue in piiHSV, sat in piiHSV ,cb in YCBCR; and their inverted maps    
gray = rgb2gray(rgb);
pii_hue = pii_hsv(:,:,1);
pii_sat = pii_hsv(:,:,2); 
% cb = double(ycbcr(:,:,2))/255;
intensity_maps = cat(3,gray,1-gray, pii_hue,1-pii_hue,pii_sat,1-pii_sat); 
end