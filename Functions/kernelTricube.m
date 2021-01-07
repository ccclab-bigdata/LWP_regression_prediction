function w = kernelTricube(u)
w = zeros(size(u));
which = u < 1;
w(which) = (1 - u(which).^3).^3;
return
