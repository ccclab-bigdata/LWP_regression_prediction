function yes = isMultiplyHByMaxDist(kernel)
% Whether for this kernel the value of h should be multiplied by maxDist
yes = ~any(strcmpi(kernel, {'GAR'}));
return
