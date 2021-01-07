function yes = isKernel(kernel)
% Whether there is such kernel
yes = any(strcmpi(kernel, {'UNI', 'TRI', 'EPA', 'BIW', 'TRW', 'TRC', 'COS', 'GAU', 'GAR'}));
return
