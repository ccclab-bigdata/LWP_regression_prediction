function w = kernelGaussian(dist, h)
w = exp(-1 / (2 * h^2) * dist); % dist is not squared because it was already
return
