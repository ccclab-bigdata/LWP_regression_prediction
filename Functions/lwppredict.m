function [Yq, L] = lwppredict(Xtr, Ytr, params, Xq, weights, failSilently)
% lwppredict
% Predicts response values for the given query points using Locally
% Weighted Polynomial regression. Can also provide the smoothing matrix L.
%
% Call:
%   [Yq, L] = lwppredict(Xtr, Ytr, params, Xq, weights, failSilently)
%
% All the input arguments, except the first three, are optional. Empty
% values are also accepted (the corresponding defaults will be used).
%
% Input:
%   Xtr, Ytr      : Training data. Xtr is a matrix with rows corresponding
%                   to observations and columns corresponding to input
%                   variables. Ytr is a column vector of response
%                   values. To automatically standardize Xtr to unit
%                   standard deviation before performing any further
%                   calculations, set params.standardize to true.
%                   If Xq is not given or is empty, Xtr also serves as
%                   query points.
%                   If the dataset contains observations with coincident
%                   Xtr values, it is recommended to merge the observations
%                   before using the LWP toolbox. One can simply reduce the
%                   dataset by averaging the Ytr at the tied values of Xtr
%                   and supplement these new observations at the unique
%                   values of Xtr with an additional weight.
%   params        : A structure of parameters for LWP. See function
%                   lwpparams for details.
%   Xq            : A matrix of query data points. Xq should have the same
%                   number of columns as Xtr. If Xq is not given or is
%                   empty, query points are Xtr.
%   weights       : Observation weights for training data (which multiply
%                   the kernel weights). The length of the vector must be
%                   the same as the number of observations in Xtr and Ytr.
%                   The weights must be nonnegative.
%   failSilently  : In case of any errors, whether to fail with an error
%                   message or just output NaN. This is useful for
%                   functions that perform parameter optimization and could
%                   try to wander out of ranges (e.g., lwpfindh) as well as
%                   for drawing plots even if some of the response values
%                   evaluate to NaN. Default value = false. See also
%                   argument safe of function lwpparams.
%
% Output:
%   Yq            : A column vector of predicted response values at the
%                   query points (or NaN where calculations failed).
%   L             : Smoothing matrix. Available only if Xq is empty.

% =========================================================================
% Locally Weighted Polynomials toolbox for Matlab/Octave
% Author: Gints Jekabsons (gints.jekabsons@rtu.lv)
% URL: http://www.cs.rtu.lv/jekabsons/
%
% Copyright (C) 2009-2016  Gints Jekabsons
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <http://www.gnu.org/licenses/>.
% =========================================================================

% Citing the LWP toolbox:
% Jekabsons G., Locally Weighted Polynomials toolbox for Matlab/Octave,
% 2016, available at http://www.cs.rtu.lv/jekabsons/

% Last update: September 3, 2016

if nargin < 3
    error('Not enough input arguments.');
end
if isempty(Xtr) || isempty(Ytr)
    error('Training data is empty.');
end
[n, d] = size(Xtr);
if size(Ytr,1) ~= n
    error('The number of rows in Xtr and Ytr should be equal.');
end
if size(Ytr,2) ~= 1
    error('Ytr should have one column.');
end
if isempty(params)
    error('params is empty.');
end
if (nargin < 4)
    Xq = [];
end
if iscell(Xtr) || iscell(Ytr) || iscell(Xq)
    error('Xtr, Ytr, and Xq should not be cell arrays.');
end
if any(any(isnan(Xtr))) || ((~isempty(Xq)) && any(any(isnan(Xq))))
    error('The toolbox cannot handle missing values (NaN).');
end
if (nargin < 5)
    weights = [];
else
    if (~isempty(weights)) && ...
       ((size(weights,1) ~= n) || (size(weights,2) ~= 1))
        error('weights vector is of wrong size.');
    end
end
if (nargin < 6) || isempty(failSilently)
    failSilently = false;
end

if (~failSilently) && size(unique(Xtr, 'rows'),1) < size(Xtr,1)
    warning('Matrix Xtr has duplicate rows.');
end

if ~isKernel(params.kernel)
    error('No such kernel.');
end
if isnan(params.h) || (params.h < 0)
    if failSilently
        Yq = NaN;
        L = NaN;
        return;
    else
        error(['Bad value for params.h (' num2str(params.h) ').']);
    end
end

if params.standardize
    meanX = mean(Xtr);
    stdX = std(Xtr);
    Xtr = bsxfun(@rdivide, bsxfun(@minus, Xtr, meanX), stdX + 1e-10);
    if ~isempty(Xq)
        Xq = bsxfun(@rdivide, bsxfun(@minus, Xq, meanX), stdX + 1e-10);
    end
end

if params.robust > 0
    w = weights;
    for i = 1 : floor(double(params.robust) + eps)
        Yq = weightAndPredict(Xtr, Ytr, params, Xtr, weights, failSilently, true);
        if any(isnan(Yq))
            Yq = NaN;
            L = NaN;
            return;
        end
        e = Ytr - Yq;
        if isempty(w)
            weights = kernelBiweight(abs(e / (6 * median(abs(e)))));
        else
            weights = w .* kernelBiweight(abs(e / (6 * median(abs(e)))));
        end
    end
end

if nargout > 1
    if ~params.safe
        error('Output argument L is not available when params.safe = false.');
    end
%     if ~isempty(Xq)
%         error('Xq should be empty when output argument L is requested.');
%     end
%     [Yq, L] = weightAndPredict(Xtr, Ytr, params, Xtr, weights, failSilently, true);
    [Yq, L] = weightAndPredict(Xtr, Ytr, params, Xq, weights, failSilently, true);
else
    if isempty(Xq)
        Yq= weightAndPredict(Xtr, Ytr, params, Xtr, weights, failSilently, true);
    else
        if d ~= size(Xq, 2)
            error('The number of columns in Xtr and Xq should be equal.');
        end
        Yq= weightAndPredict(Xtr, Ytr, params, Xq, weights, failSilently, false);
    end
end
return

%==========================================================================