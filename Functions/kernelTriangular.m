function w = kernelTriangular(u)
w = zeros(size(u));
which = u < 1;
w(which) = 1 - u(which);
return
