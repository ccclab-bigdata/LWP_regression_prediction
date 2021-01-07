function w = kernelTriweight(u)
w = zeros(size(u));
which = u < 1;
w(which) = (1 - u(which).^2).^3;
return
