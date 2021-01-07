function yes = isHCanBeZero(kernel)
% Whether for this kernel the value of h is allowed to be 0
yes = any(strcmpi(kernel, {'GAR'}));
return
