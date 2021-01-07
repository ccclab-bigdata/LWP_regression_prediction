function r = exponents(d, degree)
% Builds array of exponents for polynomial of given degree
if degree == 0
	r = zeros(1, d);
    return
end
if d == 1
	r = (0:degree)';
    return;
end
r = zeros(0, d);
for i = 0 : degree
    rr = exponents(d - 1, degree - i);
    r = [r; [repmat(i, size(rr,1), 1) rr]];
end
return
