global CONFIG 
CONFIG = ini2struct('config.ini');


if CONFIG.TARGET.POST_NOVEMBER
    CONFIG.TARGET.referenceSRGBValues(:,1) = [0.454	0.774	0.356	0.359	0.514	0.374	0.879	0.269	0.774	0.364	0.612	0.892	0.156	0.238	0.699	0.927	0.75	0.000	0.945	0.789	0.633	0.473	0.325	0.194]';
    CONFIG.TARGET.referenceSRGBValues(:,2) = [0.311	0.563	0.472	0.425	0.498	0.74	0.487	0.351	0.313	0.226	0.734	0.632	0.241	0.577	0.21	0.782	0.309	0.521	0.947	0.793	0.64	0.474	0.329	0.195]';
    CONFIG.TARGET.referenceSRGBValues(:,3) = [0.255	0.497	0.609	0.25	0.685	0.673	0.189	0.656	0.373	0.407	0.228	0.153	0.57	0.275	0.222	0.057	0.574	0.648	0.923	0.788	0.638	0.475	0.331	0.197]';

    CONFIG.TARGET.referenceLABValues(:,1) = [37.31	  64.37	   49.62	43.35       55.18       70.67       62.11       40.05       50.06       30.21       71.52       70.96       29.15       54.35       41.82	   81.29        50.40	  50.10	   95.17        81.29	   66.89        50.76	   35.64        20.64]';
    CONFIG.TARGET.referenceLABValues(:,2) = [13.39	  18.05	  -1.16     -14.62      12.16       -31.91      33.40       16.27       48.12       24.40       -28.38      14.79       21.68       -42.65      50.35	  -1.83         52.51	 -24.97    -1.26        -0.58	  -0.71         -0.09	  -0.40         0.13]';
    CONFIG.TARGET.referenceLABValues(:,3) = [14.58	  17.05	 -22.16     22.86       -24.57      0.08        55.77       -44.37      15.60       -20.88      58.85       67.25       -48.74      32.87       27.36	  80.92         -14.82	 -27.52	   2.92         0.45	  -0.05         -0.14	  -0.47         -0.46]';
else
    %aggiungere
end

if CONFIG.APPLICATION.USE_DC_RAW
    CONFIG.APPLICATION.STR_DEVELOPMENT_APP = ' DCRAW';
else
    CONFIG.APPLICATION.STR_DEVELOPMENT_APP = ' RAWTHERAPEE';
end

