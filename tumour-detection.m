% Load image
input_image = imread('Y81.jpg');
gray_image = im2gray(input_image);

% Highpass filter
kernel_size = 11; % Filter size
sigma = 2; % Standard deviation of Gaussian kernel
h = fspecial('gaussian', [kernel_size kernel_size], sigma);
gaussian_image = imfilter(double(gray_image), h, 'symmetric', 'conv');
highpass_image = double(gray_image) - gaussian_image;

% Median filter
window_size = 3;
[rows, cols] = size(highpass_image);
median_image = zeros(rows, cols);
for row = 1:rows
    for col = 1:cols
        row_min = max(row - (window_size - 1) / 2, 1);
        row_max = min(row + (window_size - 1) / 2, rows);
        col_min = max(col - (window_size - 1) / 2, 1);
        col_max = min(col + (window_size - 1) / 2, cols);
        window = highpass_image(row_min:row_max, col_min:col_max);
        median_image(row, col) = median(window(:));
    end
end

% Contrast enhancement
threshold = graythresh(median_image);
if threshold > 0.7
    contrast_enhanced_image = imadjust(gray_image);
else
    contrast_enhanced_image = gray_image;
end

%Graylevel Slicing with background
graysliced_image = contrast_enhanced_image;
[r,c] = size(contrast_enhanced_image);
for i=1:r
    for j=1:c
        if contrast_enhanced_image(i,j) >= 200 && contrast_enhanced_image(i,j) <= 255
            graysliced_image(i,j) = 255;
        end
    end
end

% Threshold segmentation
binary_image = imbinarize(graysliced_image, threshold);

% Watershed segmentation
D = -bwdist(~binary_image);
D(~binary_image) = -Inf;
L = watershed(D);
watershed_image = label2rgb(L, 'jet', 'w', 'shuffle');

% Morphological operation
SE = strel('disk', 3);
morph_image = imopen(watershed_image, SE);


% Display results
figure;
subplot(2,4,1);
imshow(input_image);
title('Original Image');
subplot(2,4,2);
imshow(gray_image);
title('Grayscale Image');
subplot(2,4,3);
imshow(highpass_image, []);
title('Highpass Filtered Image');
subplot(2,4,4);
imshow(median_image, []);
title('Median Filtered Image');
subplot(2,4,5);
imshow(graysliced_image);
title('Graylevel Sliced Image');
subplot(2,4,6);
imshow(binary_image);
title('Threshold Segmented Image');
subplot(2,4,7);
imshow(watershed_image);
title('Watershed Segmented Image');
subplot(2,4,8);
imshow(morph_image);
title('Morphological Operation');
