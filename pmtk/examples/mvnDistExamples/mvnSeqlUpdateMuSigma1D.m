
nu = 0.001; S = 0.001;
setSeed(1);
muTrue = 5; varTrue = 10;
X = sample(MvnDist(muTrue, varTrue), 500);
muRange = [-5 15]; sigmaRange  = [0.1 15];
figure; hold on;
[styles, colors, symbols] =  plotColors();
ns = [0 2 5 50]
ns = 10;
for i=1:length(ns)
    k = 0.001;
    prior = MvnInvWishartDist('mu', 0, 'k', k, 'dof', nu, 'Sigma', S);
    n = ns(i);
    m = fit(MvnDist(prior, []), 'data', X(1:n));
    post = m.mu;
    [h(i), ps{i}] = plot(post, 'plotArgs', {styles{i}, 'linewidth', 2}, ...
        'xrange', [muRange sigmaRange], 'useContour', true);
    legendstr{i} = sprintf('n=%d', n);
    xbar = mean(X(1:n)); vbar = var(X(1:n));
    h(i)=plot(xbar, vbar, 'x','color',colors(i),'markersize', 12,'linewidth',3);
end
xlabel(sprintf('%s', '\mu'))
ylabel(sprintf('%s', '\sigma^2'))
legend(h,legendstr);
title(sprintf('prior = NIW(mu=0, k=%5.3f, %s=%5.3f, S=%5.3f), true %s=%5.3f, %s=%5.3f', ...
    k, '\nu', nu, S, '\mu', muTrue, '\sigma^2', varTrue))