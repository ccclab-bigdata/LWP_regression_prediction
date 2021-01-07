function nonZero = findNonZeroWeights(w, nTerms, safe)
% Finds observations with nonzero weights and checks whether they are sufficiently many
nonZero = w > 0;
if safe
    if sum(nonZero) < nTerms
        nonZero = [];
        return;
    end
else
    if sum(nonZero) < min(2, nTerms)
        nonZero = [];
        return;
    end
end
return
