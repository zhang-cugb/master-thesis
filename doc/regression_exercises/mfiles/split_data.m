## Copyright (C) 2018 Sebastiano Rusca
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
## Author: Sebastiano Rusca <sebastiano.rusca@gmail.com>
## Created: 2018-01-24


## -*- texinfo -*-
## @defun {@var{outarg} =} funcname (@var{inarg}, @dots{})
## @defunx {@var{outarg2} =} funcname (@var{inarg2}, @dots{})
## Oneliner
##
## Explanation usage 1
##
## Explanation usage 2
##
## @seealso{func1, func2}
## @end defun


function [ss1 ss2] = split_data (ds, n1)  

  n = length (ds);
  if n1 >= n
    error ('Octave:invalid-input-arg', ...
           'Subset length n1 has to be smaller than dataseth length n');
  endif

  p = randperm (n);
  ds = ds(p,:);
  ss1 = ds(1:n1,:);
  ss2 = ds(n1+1:end,:);

endfunction


%!demo
%! D = [10 20 30 40 50; 11 22 33 44 55].'
%! [Dp1 Dp2] = split_data (D, 3)
%! print (D)
%! print (Dp1, Dp2)

