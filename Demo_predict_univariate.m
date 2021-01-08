% Demo
clear;clc;close all

order=2;  kernel_name='GAU';
fun = @(X) (30+(5*X+5).*sin(5*X+5)) .* (4+exp(-(2.5*X+2.5).^2));
X= linspace(-3,3,2/0.01)';
rng(1);
Y = fun(X) + 5 * randn(size(X,1), 1);
params = lwpparams(kernel_name, order, false); %% knn true is not for GAU GAR
[hBest, critBest, results] = lwpfindh(X, Y, params, 'CV');
params = lwpparams(kernel_name, order, false, hBest); %% outer need h select based on the dis
Xq =linspace(-3,3,2/0.005)';
[Yq,Lq] = lwppredict(X, Y, params,Xq);
figure;
plot(Xq,Yq);
hold on;
plot(Xq, fun(Xq), 'r.', 'Markersize', 20);
MSE = lwpeval(X, Y, params, 'VD', Xq, fun(Xq));
%% predict
% params = lwpparams(kernel_name, order, false); %% knn true is not for GAU GAR
% [hBest, critBest, results] = lwpfindh(Xq, Yq, params, 'CV');
params = lwpparams(kernel_name, order, false, []);
params.outer=1;
% params.safe=false;

Xp=linspace(-5,5,2/0.01)';
[Yp] = lwppredict(X, Y, params,Xp);
figure;
plot(Xp,Yp);
hold on;
plot(Xp,fun(Xp), 'r.', 'Markersize', 20);
MSE = lwpeval(X, Y, params, 'VD', Xp, fun(Xp));


