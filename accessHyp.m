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
% On request the authors kindly provided the lamp SPD.

clear, clc, close all

fldr = 'C:\Users\cege-user\Dropbox\UCL\Data\Reference Data\Ennis Data\skins_pca\pca\';
fls = dir([fldr,'*','.mat']); %files

%%
rgb   = 1; %calculate rgb data for each dataset
plt_i = 0; %plot individual white data

% % - % If you only want wlns and w (the spectrus) then:
% load('C:\Users\cege-user\Dropbox\Documents\MATLAB\Downloaded functions\matlabHyper\results.mat')

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


% for i = 1:length(fls)
%     figure,
%     imagesc(fls(i).grgb)
%     axis equal
% end

avo_white = squeeze(fls(3).hyper(52,181,:)); %The avocado has quite a shiny surface, this might theoretically be useful as a standard for the lighting (?)

%% Pick out areas of each image from where a reflectance could be calculated

% i=1;
% figure,
% imagesc(fls(i).grgb) %show original image, zoom in and select
% axis equal

% %avoiding specular highlights, aiming for normal of 45deg, which
% %practically means just aiming for the upper half of the image
% fls(1).hs = fls(1).hyper(70:110, 70:120,:); 
% fls(2).hs = fls(2).hyper(140:200, 530:630,:); 
% fls(3).hs = fls(3).hyper(150:200, 350:400,:); 
% fls(4).hs = fls(4).hyper(115:160, 210:290,:); 
% fls(5).hs = fls(5).hyper(11:16, 88:93,:);
% fls(6).hs = fls(6).hyper(54:74, 45:80,:); 
% fls(7).hs = fls(7).hyper(19:25, 60:72,:); 
% fls(8).hs = fls(8).hyper(30:70, 260:360,:); 
% fls(9).hs = fls(9).hyper(100:200, 50:350,:);
% fls(10).hs = fls(10).hyper(100:150, 360:460,:);

fls(1).loc = [70,120,70,110]; %loc: 'location', x then y, origin top left
fls(2).loc = [530,630,140,200];
fls(3).loc = [350,400,150,200];
fls(4).loc = [210,290,115,160];
fls(5).loc = [88,93,11,16];
fls(6).loc = [45,80,54,74];
fls(7).loc = [60,72,19,25];
fls(8).loc = [260,360,30,72];
fls(9).loc = [50,350,100,200];
fls(10).loc = [360,460,100,150];

for i=1:10%length(fls)
    
    figure,
    imagesc(fls(i).grgb) %show original image, zoom in and select
    axis equal
    
    rectangle('Position',[...
        fls(i).loc(1), ...
        fls(i).loc(3), ...
        fls(i).loc(2) - fls(i).loc(1),...
        fls(i).loc(4) - fls(i).loc(3)],...
        'Edgecolor', 'g');
    
    %hs: 'hyper selection'
    fls(i).hs = fls(i).hyper(fls(i).loc(3):fls(i).loc(4), fls(i).loc(1):fls(i).loc(2),:);
    
end

% Would be good to visualise this to check that I've picked sensible areas
%   and haven't typo'd

%% Plot all spectra
plt_i = 0;
figure(100), hold on

load('C:\Users\cege-user\Dropbox\Documents\MATLAB\Downloaded functions\matlabHyper\Light measurements\thorlabs_lightMeasurement.mat');
mlight = spectra(1).spectralData; clear spectra
plot(380:780,mlight,'DisplayName','Spectralon (Ennis)') %Pre-plot light

for i=1:10
    
    if plt_i
        figure(i),hold on
        plot(reshape(fls(i).hs,size(fls(i).hs,1)*size(fls(i).hs,2),345)','k') %plot full hs
        plot(fls(i).av,'r');
        title(fls(i).name(1:regexp(fls(i).name,'_')-1));
    end
    
    fls(i).av=median(reshape(fls(i).hs,size(fls(i).hs,1)*size(fls(i).hs,2),345));
        
    fls(i).av_i = interp1(wlns,fls(i).av,380:780);
    fls(i).av_i(isnan(fls(i).av_i)) = 0;
    
    figure(100),
    plot(380:780,fls(i).av_i,'DisplayName',fls(i).name(1:regexp(fls(i).name,'_')-1))
end
title('Average spectral radiance from chosen patches')
legend('Location','Best')

%% Calculate refelctance using light measurement from Ennis
%   which was measurement of spectralon, which should be pretty
%   non-spectrally-selective
%   (see https://github.com/terraref/reference-data/blob/master/Zenith%20LiteT%20Diffuse%20Reflectance%20Target%20-%2095%25R.pdf)
%   but was measured with Konica 

colors = hsv(10);

figure, hold on
for i=1:10
    fls(i).ref = fls(i).av_i./mlight';    
    plot(380:780,fls(i).ref,'Color',colors(i,:),'DisplayName',fls(i).name(1:regexp(fls(i).name,'_')-1))
end
xlim([380 780])
ylim([0 1])

legend('Location','Best')
