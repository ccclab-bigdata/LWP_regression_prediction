function [FX, FXq] = buildDesignMatrix(Xtr, Xq, r)
% Builds design matrix for both, training data and query points
n = size(Xtr, 1);
nTerms = size(r, 1);
FX = ones(n, nTerms);
if nargout == 1
    for idx = 2 : nTerms
        rr = r(idx,:);
        which = find(rr > 0);
        for column = which
            exponent = rr(column);
            if exponent == 1
                FX(:,idx) = FX(:,idx) .* Xtr(:,column);
            else
                FX(:,idx) = FX(:,idx) .* Xtr(:,column) .^ exponent;
            end
        end
    end
else
    nq = size(Xq, 1);
    FXq = ones(nq, nTerms);
    for idx = 2 : nTerms
        rr = r(idx,:);
        which = find(rr > 0);
        for column = which
            exponent = rr(column);
            if exponent == 1
                FX(:,idx) = FX(:,idx) .* Xtr(:,column);
                FXq(:,idx) = FXq(:,idx) .* Xq(:,column);
            else
                FX(:,idx) = FX(:,idx) .* Xtr(:,column) .^ exponent;
                FXq(:,idx) = FXq(:,idx) .* Xq(:,column) .^ exponent;
            end
        end
    end
end
return
