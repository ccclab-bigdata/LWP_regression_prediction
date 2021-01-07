function w = kernelGaussianRikards(dist, h)
nq = size(dist, 2);
for i = 1 : nq
    % dividing dist by the farthest point from the query point
    dist(:,i) = dist(:,i) / max(dist(:,i)); % dist is not squared because it was already
end
w = exp(-h * dist);
return
