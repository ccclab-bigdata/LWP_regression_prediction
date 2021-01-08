function [Yq, L] = predict(Xtr, Ytr, Xq, w, nTerms, knnIdx, params, failSilently, r, rDegree, rCoef, XqIsXtr)
% Calculate coefs and predict response values
n = size(Xtr, 1);       
nq = size(Xq, 1);
needL = nargout > 1;
if needL
%     nq = n;
    L = zeros(nq, n); % Smoothing matrix
else
    if XqIsXtr
        nq = n;
        Yq = NaN(n, 1);
        FX = buildDesignMatrix(Xtr, [], r);
        FXq = FX;
    else
        nq = size(Xq, 1);
        Yq = NaN(nq, 1);
        [FX, FXq] = buildDesignMatrix(Xtr, Xq, r);
    end
    isOctave = exist('OCTAVE_VERSION', 'builtin');
end
for i = 1 : nq
    if needL
        nonZero = findNonZeroWeights(w(:,i), nTerms + 1, params.safe); % "+1" because 'CV' etc. uses one observation more than 'CVE' to estimate the same stuff
    else
        nonZero = findNonZeroWeights(w(:,i), nTerms, params.safe);
    end
    ww = w(nonZero,i);
    ww = ww / sum(ww); % so that weights sum to 1
    if isempty(nonZero)
        if failSilently
            if needL
                Yq = NaN;
                L = [];
                return;
            else
                continue;
            end
        else
            error('Not enough neighbors with nonzero weights. Try increasing params.h.');
        end
    end
    if isempty(knnIdx)
        idx = nonZero;
    else
        idx = knnIdx(nonZero,i);
    end
    if needL
%         FX = buildDesignMatrix(Xtr(idx,:) - repmat(Xtr(i,:),sum(nonZero),1), [], r);
        FX = buildDesignMatrix(Xtr(idx,:) - repmat(Xq(i,:),sum(nonZero),1), [], r);
        FXW = bsxfun(@times, FX, ww)'; %FXW = FX' * diag(ww);
        Z = (FXW * FX) \ FXW;
        L(i,idx) = Z(1,:);                                                           
    else
        FXnz = FX(idx,:);
        if isOctave
            FXW = bsxfun(@times, FXnz, ww)'; %FXW = FXnz' * diag(ww);
            coefs = (FXW * FXnz) \ (FXW * Ytr(idx));
        else
            coefs = lscov(FXnz, Ytr(idx), ww);
        end
        Yq(i) = FXq(i,:) * coefs;
    end
    if ~isnan(rCoef)
        if needL
            FX = FX(:,rDegree <= (params.degree-1));
            FXW = bsxfun(@times, FX, ww)'; %FXW = FX' * diag(ww);
            Z = (FXW * FX) \ FXW;
            L(i,idx) = rCoef .* L(i,idx) + (1-rCoef) .* Z(1,:);
        else
            which = rDegree <= (params.degree-1);
            FXnz = FXnz(:,which);
            if isOctave
                FXW = bsxfun(@times, FXnz, ww)'; %FXW = FXnz' * diag(ww);
                coefs = (FXW * FXnz) \ (FXW * Ytr(idx));
            else
                coefs = lscov(FXnz, Ytr(idx), ww);
            end
            Yq(i) = rCoef * Yq(i) + (1-rCoef) * FXq(i,which) * coefs;
        end
    end
end
if needL
    if any(any(isnan(L)))
        if failSilently
            Yq = NaN;
            L = [];
            return;
        else
            error('Cannot fully calculate L. Try increasing params.h.');
        end
    end
    Yq = L * Ytr;
end
return
