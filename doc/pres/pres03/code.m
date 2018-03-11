nQ  = 25; #number of experiments
Qin = linspace (0.1, 10, nQ); #Qin values [m3/s]

# ------------------------------------------------------------------------------

rain_intensities = linspace (10, 35, 10); #[mm/h]
soil_saturations = linspace (0, 1, 5); #[-]
rain_duration    = 6; #[h]
sim_duration     = 9; #[h]