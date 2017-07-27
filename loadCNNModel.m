function [net1, net2, IMAGE_MEAN] = loadCNNModel()
addpath('/home/zhuwei/caffe/matlab');
% load model1
definition_file1 = './model/forward.prototxt';
model_file1 = './model/model1.caffemodel';
mean_file = load('./data/mean.mat');
IMAGE_MEAN = mean_file.image_mean;
IMAGE_MEAN = imresize(IMAGE_MEAN, [32 32]);

phase = 'test';
net1 = caffe.Net(definition_file1, model_file1, phase);

% load model2
definition_file_RF = './model/forward2.prototxt';
model_file_RF = './model/modelRF.caffemodel';
net2 = caffe.Net(definition_file_RF, model_file_RF, phase);
caffe.set_mode_cpu();
end