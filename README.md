This code is based upon code provided at http://www.allpsych.uni-giessen.de/GHIFVD/matlab/ presumably by Rob Ennis or a co-author. 

It is used to handle data from:
http://www.allpsych.uni-giessen.de/GHIFVD/images/
(back up: doi.org/10.5281/zenodo.1186649)

which is described in:
doi.org/10.1364/JOSAA.35.00B256

This fork was created in order to explore the possibility of computing rough reflectance data from the hyperspectral images, for use in github.com/da5nsy/Melanopsin_Computational
The current conclusion is: something weird is happening at the extreme low wavelengths, which I cannot currently explain, and so I do not plan to use this data further.

Main analysis file: Hyp2Ref.m