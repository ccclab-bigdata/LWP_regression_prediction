function w = kernelCosine(u)
w = zeros(size(u));
which = u < 1;
w(which) = cos(0.5 * pi * u(which));
return
