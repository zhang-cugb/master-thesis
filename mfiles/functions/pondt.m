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
## Created: 2018-02-05

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

function pt = pondt (Ks, psif, Dtheta, ri)
#psif: capillary head at wetting front
#ri: rain intensity
# for r > Ks (otherwise result is negative!)

pt = (Ks * psif * Dtheta)/(ri .* (ri - Ks));
