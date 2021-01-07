function yes = isUsableWithKNN(kernel)
% Whether the kernel can be used with KNN window widths
yes = ~any(strcmpi(kernel, {'GAU', 'GAR'}));
return
