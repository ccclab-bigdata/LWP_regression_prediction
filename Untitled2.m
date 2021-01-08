%
% MSE = mean((lwppredict(X, Y, params, Xq) - Ytrue) .^ 2);
%  MSE = lwpeval(X, Y, params, 'VD', Xq, fun(Xq));
%%
% figure;
% hold all;
% colors = get(gca, 'ColorOrder');
% for i = 0 : 3
%     % Global polynomial
%     params = lwpparams('UNI', i, true, 1);
%     [MSE, df] = lwpeval(Xp, Yp, params, 'CV');
%     plot(df, MSE, 'x', 'MarkerSize', 10, 'LineWidth', 2, 'Color', colors(i+1,:));
%     % Local polynomial
%     params = lwpparams('GAU', i, false);
%     [hBest, critBest, results] = ...
%         lwpfindh(Xp, Yp, params, 'CV', 0:0.01:1, [], [], [], false, false);
%     plot(results(:,4), results(:,2), '.-', 'MarkerSize', 10, 'Color', colors(i+1,:));
% end
% legend({'Global, degree = 0' 'Local, degree = 0' ...
%     'Global, degree = 1' 'Local, degree = 1' ...
%     'Global, degree = 2' 'Local, degree = 2' ...
%     'Global, degree = 3' 'Local, degree = 3'}, 'Location', 'NorthEast');
% xlabel('Degrees of freedom');
% ylabel('LOOCV MSE');