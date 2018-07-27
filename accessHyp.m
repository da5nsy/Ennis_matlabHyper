clear, clc, close all

fldr = 'C:\Users\cege-user\Dropbox\UCL\Data\Reference Data\Ennis Data\skins_pca\pca';
cd(fldr);
fls = dir('*.mat'); %files

for i=1:3%length(fls)
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
close all

for i=1:3
    figure,
    imagesc(fls(i).grgb.*~fls(i).mask);
end

%selecting white sections of 'floor', preferably from behind the object
fls(1).white = fls(1).hyper(70:90,1:15,:);
fls(2).white = fls(2).hyper(205:215,55:80,:);

%trying selecting white just using the mask
fls(1).whiteFromMask = fls(i).hyper.*~fls(i).mask;
figure, hold on
plot(squeeze(fls(1).whiteFromMask(100,:,:))')
fls(1).whiteFromMask(fls(1).whiteFromMask == 0) = NaN;
plot(nanmedian(squeeze(fls(1).whiteFromMask(100,:,:))),'r','LineWidth',4)


%% plot 'white' spectra

wlns = csvread('hyperWavelengths.csv');
wlns = wlns(20:364);

figure, hold on
i=1;
plot(wlns,reshape(fls(i).white,size(fls(i).white,1)*size(fls(i).white,2),size(fls(i).white,3)),'r')
i=2;
plot(wlns,reshape(fls(i).white,size(fls(i).white,1)*size(fls(i).white,2),size(fls(i).white,3)),'g')

%% convert the hyperspectral image to its linear RGB and
% CIE1931 XYZ representation
[rgb, xyz] = colormatch(hyper);

% gamma correct the linear RGB image
grgb = gammaCorr(rgb);

% display the gamma corrected image
figure,
imshow(grgb);