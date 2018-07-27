clear, clc, close all

fldr = 'C:\Users\cege-user\Dropbox\UCL\Data\Reference Data\Ennis Data\skins_pca\pca';
cd(fldr);
fls = dir('*.mat'); %files

for i=1:3 %length(fls)
    filename = [fldr,'\',fls(i).name];
    fls(i).hyper = readCompressedDAT(filename);
    fls(i).mask  = logical(imread([fldr(1:62),'skins_masks\masks\',fls(i).name(1:regexp(fls(i).name,'_')),'CroppedMask.png']));
    fls(i).mask  = fls(i).mask(:,:,1);
    [fls(i).rgb, ~] = colormatch(fls(i).hyper);
    
    % gamma correct the linear RGB image
    fls(i).grgb = gammaCorr(fls(i).rgb);

    disp(i)
end
%%
figure,
imshow(fls(1).grgb.*~fls(1).mask);

% this is good for display but what I really want is something that can
% select that area and say take an average of it.

%% the format of the hyperspectral data:
% rows = number of pixels along the vertical direction
% columns = number of pixels along the horizontal direction
% layers = different wavelength bands (345 bands ranging
% from 396.40nm to 779.61nm at steps of ~1.12nm)
[r, c, l] = size(hyper);

% plot a spectrum from a random pixel

wlns = csvread('hyperWavelengths.csv');
wlns = wlns(20:364);

x = round(rand()*c); 
y = round(rand()*r);
x=1:c; y=10;
plot(wlns,squeeze(hyper(y,x,:)))

%% convert the hyperspectral image to its linear RGB and
% CIE1931 XYZ representation
[rgb, xyz] = colormatch(hyper);

% gamma correct the linear RGB image
grgb = gammaCorr(rgb);

% display the gamma corrected image
figure,
imshow(grgb);