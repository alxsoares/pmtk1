%% Posterior Example

data(1).a = 2;      data(2).a = 5;
data(1).b = 2;      data(2).b = 2;
data(1).N1 = 3;     data(2).N1 = 11;
data(1).N0 = 17;    data(2).N0 = 13;

for i = 1:numel(data)
    a = data(i).a;
    b = data(i).b;
    N0 = data(i).N0;
    N1 = data(i).N1;
    N = N1+N0;
    m = binomDist(N, betaDist(a,b));
    %m = bernoulliDist(betaDist(a,b));
    prior = m.mu; % betaDist
    m = inferParams(m, 'suffStat', [N1 N]);
    post = m.mu; % betaDist
    % The likelihood is the prior with a flat prior
    m2 = binomDist(N, betaDist(1,1));
    m2 = inferParams(m2, 'suffStat', [N1 N]);
    lik = m2.mu; % betaDist
    figure;
    h = plot(prior, 'plotArgs', {'r-', 'linewidth', 3});
    legendstr{1} = sprintf('prior Be(%2.1f, %2.1f)', prior.a, prior.b);
    hold on
    h = plot(lik, 'plotArgs', {'k:', 'linewidth', 3});
    legendstr{2} = sprintf('lik Be(%2.1f, %2.1f)', lik.a, lik.b);
    h = plot(post, 'plotArgs', {'b-.', 'linewidth', 3});
    legendstr{3} = sprintf('post Be(%2.1f, %2.1f)', post.a, post.b);
    legend(legendstr)
end

