function [h, w] = readCompressedDAT(fn)
	load(fn, 'wc', 'pcc', 'wid', 'hei');
	spectra = pcc * wc';
	h = reshape(spectra', hei, wid, size(spectra, 1));
	w = csvread('hyperWavelengths.csv');
	return
end
