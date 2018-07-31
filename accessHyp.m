% Here I'm attempting to compute a stereotypical reflectance spectrum for
% each object.
% I use the masks provided, and take the median of what remains outside
% the mask, assuming that this would roughly represent the spectrum of the
% white space surrounding the object (though this definitely isn't ideal 
% and throw up some really clear problems)
% From the paper (fig 3) I know that the reflectance of the box material is
% roughly uniform apart from below about 430nm.
% I also know that the "CIE1931 xyY coordinates of the daylight like
% illuminant were 0.3324; 0.3435; 36.97 cd?m2." which I should be able to
% cross reference my results to.
% On request the authors kindly provided the lamp SPD. I should ask whether
% I can upload it to this git repository.

clear, clc, close all

fldr = 'C:\Users\cege-user\Dropbox\UCL\Data\Reference Data\Ennis Data\skins_pca\pca\';
fls = dir([fldr,'*','.mat']); %files

%%
rgb   = 1; %calculate rgb data for each dataset
plt_i = 0; %plot individual white data

% - % If you only want wlns and w (the spectrus) then:
load('C:\Users\cege-user\Dropbox\Documents\MATLAB\Downloaded functions\matlabHyper\results.mat')

wlns = csvread('hyperWavelengths.csv');
wlns = wlns(20:364);

for i=1:length(fls)
    filename = [fldr,'\',fls(i).name];
    fls(i).hyper = readCompressedDAT(filename);
    fls(i).mask  = logical(imread([fldr(1:62),'skins_masks\masks\',fls(i).name(1:regexp(fls(i).name,'_')),'CroppedMask.png']));
    fls(i).mask  = fls(i).mask(:,:,1);
    
    if rgb
        [fls(i).rgb, fls(i).XYZ] = colormatch(fls(i).hyper);
        % gamma correct the linear RGB image
        fls(i).grgb = gammaCorr(fls(i).rgb);
    end
    
    fls(i).whiteFromMask = fls(i).hyper(1:45,:,:).*~fls(i).mask(1:45,:,:);
    fls(i).whiteFromMask = reshape(fls(i).whiteFromMask,size(fls(i).whiteFromMask,1)*size(fls(i).whiteFromMask,2),size(fls(i).whiteFromMask,3))';
    fls(i).whiteFromMask(fls(i).whiteFromMask == 0) = NaN; %make zeros nans for better averaging
    fls(i).whiteFromMaskAv = prctile(fls(i).whiteFromMask,95,2);
    
    if plt_i
        % plot individual image data as you go
        figure, hold on
        plot(wlns,fls(i).whiteFromMask(:,1:50:end),'k')
        plot(wlns,fls(i).whiteFromMaskAv,'r:','LineWidth',3)
        drawnow
    end
    
%     figure(100),hold on
%     plot(wlns,fls(i).whiteFromMaskAv)
    w(:,i) = fls(i).whiteFromMaskAv;
    
    disp(i) % simple progress counter
end

%replot with overall median 
figure(100),hold on
plot(wlns,w)
plot(wlns,median(w,2),'g:','LineWidth',3)


for i = 1:length(fls)
    figure,
    imagesc(fls(i).grgb)
end

avo_white = squeeze(fls(3).hyper(52,181,:));

%%
for i=39 %39 is a red pepper and gives a weird white rating because the stem is included in the ~mask space
    %grgb is complex for some reason, and so I'm brute forcing the non
    %   gamma corrected image
    figure
%    imagesc(fls(i).rgb*50)
    imagesc((fls(i).rgb(1:45,:,:).*~fls(i).mask(1:45,:,:))*20)
end
axis equal

%% Check colorimetry of white vs the colorimetry quoted in the paper

load T_xyz1931.mat %PsychToolbox
XYZ = median(w,2)'*interp1(SToWls(S_xyz1931),T_xyz1931',wlns); %PTB
xy = [XYZ(1)/sum(XYZ);XYZ(2)/sum(XYZ)];
Y = XYZ(2) * 683;

%that's roughly in line with what I would expect from taking roughly 80% of
%the power out of the lights from refelctions

%% Pick out areas of each image from where a reflectance could be calculated

i=10;
figure,
imagesc(fls(i).grgb.*fls(i).mask) %show original image, zoom in and select
axis equal

%avoiding specular highlights, aiming for normal of 45deg, which
%practically means just aiming for the upper half of the image
fls(1).hs = fls(1).hyper(70:110, 70:120,:); %hyper selection
fls(2).hs = fls(2).hyper(140:200, 530:630,:); 
fls(3).hs = fls(3).hyper(150:200, 350:400,:); 
fls(4).hs = fls(4).hyper(115:160, 210:290,:); 
fls(5).hs = fls(5).hyper(11:16, 88:93,:);
fls(6).hs = fls(6).hyper(54:74, 45:80,:); 
fls(7).hs = fls(7).hyper(19:25, 60:72,:); 
fls(8).hs = fls(8).hyper(30:70, 260:360,:); 
fls(9).hs = fls(9).hyper(100:200, 50:350,:);
fls(10).hs = fls(10).hyper(100:150, 360:460,:);

% I've only bothered doing the first 10 for now

% Would be good to visualise this to check that I've picked sensible areas
%   and haven't typo'd

% figure, hold on
% plot(reshape(fls(2).hs,61*101,345)','k') %plot hs
% fls(2).av= median(reshape(fls(2).hs,61*101,345));
% plot(fls(2).av,'r');

figure, hold on
for i=1:length(fls)
    fls(i).av= median(reshape(fls(i).hs,size(fls(i).hs,1)*size(fls(i).hs,2),345));
    fls(i).av_i = interp1(wlns,fls(i).av,380:780);
    
    fls(i).av_i(isnan(fls(i).av_i)) = 0;
    
    plot(380:780,fls(i).av_i)
end
title('Average spectral radiance from chosen patches')

%% Compare white and light

load('C:\Users\cege-user\Downloads\thorlabs.mat');
light = spectra(1).spectralData; clear spectra

load('C:\Users\cege-user\Dropbox\Documents\MATLAB\Downloaded functions\matlabHyper\results.mat');
wht = w(:,1); clear w

figure, hold on
plot(380:780,light,'DisplayName','Light (Ennis)');
plot(wlns,wht,'DisplayName','White wall, measured from images');
plot(wlns,avo_white,'DisplayName','Avo white')

legend('Location','Best')

%% Calculate refelctance using light measurement from Ennis
%       and then using white measurement taken from back wall of cube in hyp images
clc
colors = hsv(10);

figure, hold on
for i=10%1:10
    fls(i).ref = fls(i).av_i./light';    
    plot(380:780,fls(i).ref,'Color',colors(i,:),'DisplayName','Light (Ennis)');

    fls(i).ref = fls(i).av./wht';
    plot(wlns,fls(i).ref,':','Color',colors(i,:),'DisplayName','Sampled white');
end

legend('Location','Best')

% Comparing to apple spd in doi: 10.1016/S0925-5214(02)00066-2
% This apple is red/yellow

%%
wht_i = interp1(wlns,wht,380:780);
wht_i(isnan(wht_i))=0;

figure,
plot(wht_r)

wht_r = wht_i./light';
