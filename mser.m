function [mserRegion, RegPixels] = mser(img,threshold)
% addpath('/home/tonghe/MSERs/')
% img = imread('img_170.jpg');
% threshold = 1;

if nargin<2
    threshold = 1;
end

[row,col]=size(img);
allPixel=row*col;
para.ThresholdDelta=threshold;
% para.RegionAreaRange = [max(1,round(0.00001*allPixel)) round(0.3*allPixel)];
para.RegionAreaRange = [1 allPixel];
para.MaxAreaVariation=10;
% para.MaxAreaVariation= 0.25*allPixel;

RegBox=[];

if size(img,3)>1
    img=rgb2gray(img);
end

Regs=detectMSERFeatures(img,para);

numRegs = Regs.Count
numPixels = 0;
pixelsRange = zeros(numRegs,2);

for i = 1:numRegs
    numPixels = numPixels + size(Regs.PixelList{i}, 1);
end
pixels = single(zeros(numPixels,2));
numPixels = 0;
for i = 1:numRegs
    numPixels = numPixels + size(Regs.PixelList{i}, 1);
    if i==1
        b = 1;
    else 
        b = pixelsRange(i-1,2) + 1;
    end
    
    e = numPixels;
    
    pixelsRange(i,1) = b;
    pixelsRange(i,2) = e;
    
    pixels(b:e,:) = Regs.PixelList{i};
    
end

RegPixels.pixelsRange = pixelsRange;
RegPixels.pixels = pixels;
mserRegion = Regs;


