%Comparing measurements:1
% 1. Measurements of the light source provided by the author (Ennis)
% 2. Computed spectra from the white sections of the cube from the hyperspectral images
% 3. Measurements from thorlabs 

clc, clear, close all

%% 1

load('C:\Users\cege-user\Downloads\thorlabs.mat')

% figure,
% col=hsv(3);
% for i=1:3
%     plot(380:780,spectra(i).spectralData',':','Color',col(:,i))
%     drawnow
%     %pause(1) %they're all essentially the same
% end

%% 2

load('C:\Users\cege-user\Dropbox\Documents\MATLAB\Downloaded functions\matlabHyper\results.mat')

%% 3

thor_file_light = 'C:\Users\cege-user\Dropbox\Documents\MATLAB\Downloaded functions\matlabHyper\Light measurements\OSL2_Raw_Data2.xlsx';
thor_file_filter = 'C:\Users\cege-user\Dropbox\Documents\MATLAB\Downloaded functions\matlabHyper\Light measurements\Temperature_Balancing_Transmission.xlsx';

thor_light  = xlsread(thor_file_light,'Emission Spectrum','C3:D3400');
thor_filt = xlsread(thor_file_filter,'Filters Transmission','C4:E2404');

thor_light_wlns = thor_light(:,1);
thor_light      = thor_light(:,2);

thor_filt_wlns = thor_filt(:,1);
thor_filt      = thor_filt(:,3);

% figure, hold on
% plot(thor_light_wlns,thor_light)
% plot(thor_filt_wlns,thor_filt)

thor_filt_int = interp1(thor_filt_wlns, thor_filt,thor_light_wlns);

%% Plot
figure, hold on
plot(380:780,spectra(1).spectralData'/max(spectra(1).spectralData'),...
    'DisplayName','Ennis Measurement')
plot(wlns,w/max(w),'DisplayName',...
    'White box, calculated from hyperspectral images')
plot(thor_light_wlns,(thor_light.*thor_filt_int)/max(thor_light.*thor_filt_int),...
    'DisplayName','Calculated from online Thor data - with filter')
% plot(thor_light_wlns,thor_light/max(thor_light),...
%     'DisplayName','Calculated from online Thor data - without filter')


ylim([-0.1 1])
xlabel('Wavelength(nm)')
ylabel('normalised power')
