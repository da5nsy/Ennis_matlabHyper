% Here I'm attempting to compute a stereotypical reflectance spectrum for
% each object.
% I use the masks provided, and take the median of what remains outside
% the mask, assuming that this would roughly represent the spectrum of the
% white space surrounding the object.
% From the paper (fig 3) I know that the reflectance of the box material is
% roughly uniform apart from below about 430nm.
% I also know that the "CIE1931 xyY coordinates of the daylight like
% illuminant were 0.3324; 0.3435; 36.97 cd?m2." which I should be able to
% cross reference my results to.
% It might be easier just to ask the authors for the spectra of the lamp...

clear, clc, close all

fldr = 'C:\Users\cege-user\Dropbox\UCL\Data\Reference Data\Ennis Data\skins_pca\pca\';
fls = dir([fldr,'*','.mat']); %files

%%
rgb   = 1; %calculate rgb data for each dataset
plt_i = 1; %plot individual white data

wlns = csvread('hyperWavelengths.csv');
wlns = wlns(20:364);

for i=1:length(fls)
    filename = [fldr,'\',fls(i).name];
    fls(i).hyper = readCompressedDAT(filename);
    fls(i).mask  = logical(imread([fldr(1:62),'skins_masks\masks\',fls(i).name(1:regexp(fls(i).name,'_')),'CroppedMask.png']));
    fls(i).mask  = fls(i).mask(:,:,1);
    
    if rgb
        [fls(i).rgb, ~] = colormatch(fls(i).hyper);
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
    
    figure(100),hold on
    plot(wlns,fls(i).whiteFromMaskAv)
    w(:,i) = fls(i).whiteFromMaskAv;
    
    disp(i) % simple progress counter
end

%replot with overall median 
figure(100),hold on
plot(wlns,w)
plot(wlns,median(w,2),'g:','LineWidth',3)

%%
for i=39 %39 is a red pepper and gives a weird white rating because the stem is included in the ~mask space
    %grgb is complex for some reason, and so I'm brute forcing the non
    %   gamma corrected image
    figure
%    imagesc(fls(i).rgb*50)
    imagesc((fls(i).rgb(1:45,:,:).*~fls(i).mask(1:45,:,:))*20)
end
axis equal

%%

load T_xyz1931.mat %PsychToolbox
XYZ = median(w,2)'*interp1(SToWls(S_xyz1931),T_xyz1931',wlns); %PTB
xy = [XYZ(1)/sum(XYZ);XYZ(2)/sum(XYZ)];
Y = XYZ(2) * 683;

%that's roughly in line with what I would expect from taking roughly 80% of
%the power out of the lights from refelctions