## Copyright (C) 2018 Sebastiano Rusca
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##g
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
## Author: Sebastiano Rusca <sebastiano.rusca@gmail.com>
## Created: 2018-03-08

#clear all
pkg load statistics

load ('input_Q.dat');
load ('extracted_data.dat');

#addpath ('~/Resources/gpml-matlab-v4.1-2017-10-19');
#startup

## Functions
f_Qw = @(C,h,a) C*h.^a;

function err = f_rmse (y, yp)
  err = sqrt (meansq (y(:) - yp(:)));
endfunction

function err = f_mae (y, yp)
  err = max (abs (y(:) - yp(:)));
endfunction

function theta = lin_reg (x,y)
  n = length (x);
  X = [ones(n,1) x];
  theta = (pinv(X.'*X))*X.'*y;
endfunction



# Remove unusable experiments
i = 1;
while i <= size (H)(2)
  if weircenter_head(i) < 0.3 #0.3
    weircenter_head(i) = [];
    Qin(i)             = [];
    H(:,i)             = [];
    HZ(:,i)            = [];
    H_max(i)           = [];
    h0(i)              = [];
    v0(i)              = [];
  endif
  i+=1;
endwhile


# Transform the data
Qin = sort (abs(Qin));
hw = sort (h0 - weir_height);

## Define training data
#
xtrn = [0.01;hw.'];#0.01
ytrn = [0.0044;Qin.'];#0.0044
#xtrn = xtrn + 0.01*rand(size(xtrn));
#ytrn = ytrn +0.01*rand(size(xtrn));

xmax = max (xtrn);
ymax = max (ytrn);

# linearize the data
lxtrn = log10 (xtrn);
lytrn = log10 (ytrn);

## Perform linear regression
theta = polyfit (lxtrn, lytrn, 1);
C = 10^theta(2) / B;
a = theta(1);


# define evaluation points
xp = linspace (0, xmax+0.1*xmax, 200);
yp = zeros (length (xp), 3);

# evaluate linear regression on xp
yp(:,3) = 10.^polyval(theta, log10 (xp)); % this should be f_Qw(C,xp,a);

# perform linear and spline interpolations
yp(:,1) = interp1 (xtrn, ytrn, xp, 'linear', 'extrap');
yp(:,2) = interp1 (xtrn, ytrn, xp, 'spline', 'extrap');


## Compute cross-validation error
#
idx_short = [1 3 4 5 6 9 11 12 15 16 19 18 21 length(xtrn)];
xtrn_short = xtrn(idx_short);
ytrn_short = ytrn(idx_short);
lxtrn_short = lxtrn(idx_short);
lytrn_short = lytrn(idx_short);

if !exist('data_RMSE.dat','file')
  n1 = length (xtrn_short);
  indexes = 2:n1-1;
  n2 = length (indexes) - 2;

  idx_off = cell (1,n2);
  n_idx = zeros(1,n2);
  for i = 1:n2
    idx_off{i} = nchoosek (indexes,i);
    n_idx(i) = length (idx_off{i}); 
  endfor
  n_idx_total = sum (n_idx);


  for i = 1:n2
    toremove = idx_off{i};
    rmse{i} = zeros (n_idx(i),3);

    for j = 1:n_idx(i)
  #    printf ('%d of %d\n', j, nchoosek (n2,i))
      idx_trn = logical (ones (1,n1));
      idx_trn(toremove(j,:)) = false;
      
      # local trainig sets
      xe_trn = xtrn_short(idx_trn);
      ye_trn = ytrn_short(idx_trn);
      ## log of data
      lxe_trn = lxtrn_short(idx_trn);
      lye_trn = lytrn_short(idx_trn);

      # local test sets
      idx_tst = !idx_trn;
      xe_tst = xtrn_short(idx_tst);
      ye_tst = ytrn_short(idx_tst);
      ## log of data
      lxe_tst = lxtrn_short(idx_tst);

      theta_e = polyfit (lxe_trn, lye_trn, 1);
      %C_e = 10^theta_e(2);
      %a_e = theta_e(1);
      
      ye_pred = zeros (length(xe_tst),3);
      ye_pred(:,3) = 10.^polyval (theta, lxe_tst); % same as f_Qw (C_e, xe_tst,
                                                   %               a_e);
      ye_pred(:,1) = interp1 (xe_trn, ye_trn, xe_tst, 'linear');
      ye_pred(:,2) = interp1 (xe_trn, ye_trn, xe_tst, 'spline');
      for k = 1:3
        rmse{i}(j,k) = f_rmse (ye_pred(:,k), ye_tst);
        mae{i}(j,k) = f_mae (ye_pred(:,k), ye_tst);
      endfor
    endfor
  endfor

endif
mean_rmse = cell2mat (cellfun (@mean, rmse, 'uniformOutput', false).');
std_rmse = cell2mat (cellfun (@std, rmse, 'uniformOutput', false).');

mean_mae = cell2mat (cellfun (@mean, mae, 'uniformOutput', false).');
std_mae = cell2mat (cellfun (@std, mae, 'uniformOutput', false).');

save ('data_RMSE.dat', 'mean_rmse');


#-------------------------------------------------------------------------------
## Plot the results
fontsize1 = 10;
fontsize2 = 11;

# plot 1: different fittings all data
f = 1;
figure (f)
f+=1;
plot (ytrn, xtrn, 'ok')
col = {'r', 'g', 'b'};

hold on
for i = 1:3
  plot (yp(:,i), xp, col{i});
endfor
hold off

legend ('training dataset', 'lin. interp.', 'cub. spl. interp.', ...
             sprintf ('weir equation\n(C = %0.2f, a = %0.2f)', C, a), ...
             'location', 'northwest');
set (gco, 'fontsize', 12)
axis tight;
xlabel ('Q [m^3/s]', 'fontsize', fontsize2);
ylabel ('h_w [m]', 'fontsize', fontsize2)
set (gca, 'fontsize', fontsize1)
print ('fitting_results.png', '-r300')


# plot 2: error plot without std
figure (f)
f+=1;
npoints = length(indexes) - (1:n2).' + 2;
semilogy (npoints, mean_rmse, col)
axis tight
legend ('lin. interp.', 'cub. spl. interp.', 'weir equation', ...
             'location', 'northeast');
set (gco, 'fontsize', 12)
xlabel ('# of observations', 'fontsize', fontsize2)
#xlabel ('left-out points', 'fontsize', fontsize2)
ylabel ('RMSE [m]', 'fontsize', fontsize2)

#xtickn = 1:length (mean_rmse);
#xtickl = num2cell (xtickn);
#for i = 1:length(mean_rmse)
#  xtickl{i} = num2str(xtickl{i});
#endfor
#set (gca, 'xtick', xtickn, 'xticklabel', xtickl, 'fontsize', fontsize1);
print ('fitting_errors.png', '-r300')


# plot 3: error plot with std
eu = std_rmse(:,2:3);
el = eu;
mask_l = mean_rmse(:,2:3) - eu < 0;
el(mask_l) = mean_rmse(:,2:3)(mask_l);
figure (f)
f+=1;
e = errorbar (repmat (npoints,1,2), mean_rmse(:,2:3), el, eu, '~');
for i = 1:2
  set (e(i), 'color', col{i+1});
endfor
#set(gca, 'yscale', 'log');
axis tight;
legend ('cub. spl. interp.', 'weir equation', 'location', 'northeast');
xlabel ('# of observations', 'fontsize', fontsize2);
ylabel ('RMSE [m]', 'fontsize', fontsize2);
print ('fitting_std.png', '-r300')


# plot 4: boxplot
figure (f)
f+=1;
bp = boxplot (mean_rmse);
axis ([0.5 3.5]);
set (gca, 'xtick', [1 2 3], 'xticklabel', ... 
    {'lin. interp.', 'cub. spl. interp.', 'weir equation'});
ylabel ('RMSE [m]')
print ('boxplot_models.png', '-r300');





## shadow plot
#rgb = {[255 0 0]/255; [0 255 0]/255; [0 0 255]/255};
#ergb = {[255 77 77]/255; [77 255 77]/255; [77 77 255]/255};
#frgb = {[255 179 179]/255; [179 255 179]/255; [179 179 255]/255};

#shadow  = [mean_rmse + 2*std_rmse; flipdim(mean_rmse - 2*std_rmse,1)];
#shadow(shadow<0) = 0;
#figure (f)
#f+=1;
#hold on
#for i = 1:3
#  hf = fill ([npoints; flipdim(npoints,1)], shadow(:,i), frgb{i});
##  plot (npoints, mean_rmse(:,i), rgb{i})
#endfor
#hold off
 











