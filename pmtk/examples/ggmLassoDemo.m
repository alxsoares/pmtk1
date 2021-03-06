%% Learn GGM structure using graphical lasso on flow cytometry data
% HTF 2e p637

load('sachsCtsHTF.mat'); % 7466 x 11
lambdas = 36; %[36 27 7 0];
%lambdas = [logspace(5,0,5) 0];
S = cov(X)/1000; % same as http://www-stat.stanford.edu/~tibs/ElemStatLearn/datasets/sachs.info
debug = false;
folder = 'C:\kmurphy\PML\pdfFigures';
doPrint = false;

for i=1:length(lambdas)
  lambda = lambdas(i);
  [P] = ggmLassoHtf(S, lambda);
  A = precmatToAdjmat(P, 1e-9);
  %M = fitStructure(UgmGaussDist, 'data', X, 'lambda', lambda);
  %A = M.G.adjMat;
  nedges(i) = sum(A(:))/2;
  ttl=sprintf('lambda=%3.2f, nedges=%d', lambda, nedges(i))
  g=Graphlayout('adjMatrix', A, 'undirected', true, ...
    'nodeLabels', labels, 'currentLayout', CircleLayout());
  f=freeze(g); % convert to regular figure
  title(ttl)
  %figure; imagesc(P); colorbar; title(ttl);
  precMat{i} = P;
  if doPrint
    fname = fullfile(folder, sprintf('glassoSachs%d.pdf',lambda))
    fname = fullfile(folder, sprintf('glassoSachs%d.png',lambda))
    %pdfcrop;
    print(gcf, '-dpng', fname);
    %print_pdf(fname,gcf);
  end
  
  if debug
    tol = 1e-2;
    [PR] = ggmLassoR(S, lambda);
    assert(max(P(:)- PR(:)) < tol);
    [PM] = ggmLassoCoordDescQP(S, lambda);
    assert(max(P(:)- PM(:)) < tol);
  end
end
