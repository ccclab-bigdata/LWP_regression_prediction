function w = kernelUniform(u)
w = zeros(size(u));
w(u <= 1) = 1;
return
