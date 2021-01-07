function yes = isUniform(kernel)
% Whether the kernel gives uniform weights to all neighbors
yes = any(strcmpi(kernel, {'UNI'}));
return
