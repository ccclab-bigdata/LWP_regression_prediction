[gridX1, gridX2] = meshgrid(0:2/50:2, 0:2/50:2);
Yp = reshape(Yp, size(gridX1));
Ytrue = fun(Xp);


figure;
surf(gridX1, gridX2, Yp);
axis([-1 1 -1 1 80 200]);
hold on;
plot3(Xp(:,1), Xp(:,2), Ytrue, 'r.', 'Markersize', 20);
