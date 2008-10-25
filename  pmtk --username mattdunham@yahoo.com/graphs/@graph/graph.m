classdef graph 
  
  properties
    adjMat;
  end
  
 %methods(Abstract = true)
 %  e = nedges(obj);
 %  ns = neighbors(obj, v);
 %end

 %% Main methods
 methods
   function obj = graph(adjMat)
     if nargin == 0
       obj.adjMat = [];
     else
       obj.adjMat = adjMat;
     end
   end
   
   function h=draw(obj)
     h = graphlayout('adjMatrix',obj.adjMat);
   end
   
   %{
   function h=draw(obj)
     % Use graphviz to layout graph and visualize it
     % If you have the bioinformatics toolbox, you can edit the
     % resulting layout eg.
     % h = draw(graph(rand(5,5)>0.5));
     % set(h,'layouttype','hierarchical')
     % dolayout(h)
     if bioToolboxInstalled
       d = length(obj.adjMat);
       for i=1:d, names{i}=sprintf('%d', i); end
       biog = biograph(obj.adjMat, names);
       h=view(biog);
       set(h,'layouttype', 'equilibrium')
       dolayout(h)
     else
       drawGraph(obj.adjMat);
     end
   end
   %}
   
   function d = nnodes(obj)
     d = length(obj.adjMat);
   end
   
   function ns = neighbors(obj, i)
     ns = union(find(obj.adjMat(i,:)), find(obj.adjMat(:,i))');
   end
   
   function [d, pre, post, cycle, f, pred] = dfs(obj, start, directed)
     % Depth first search
     % Input:
     % adj_mat(i,j)=1 iff i is connected to j.
     % start is the root vertex of the dfs tree; if [], all nodes are searched
     % directed = 1 if the graph is directed
     %
     % Output:
     % d(i) is the time at which node i is first discovered.
     % pre is a list of the nodes in the order in which they are first encountered (opened).
     % post is a list of the nodes in the order in which they are last encountered (closed).
     % 'cycle' is true iff a (directed) cycle is found.
     % f(i) is the time at which node i is finished.
     % pred(i) is the predecessor of i in the dfs tree.
     %
     % If the graph is a tree, preorder is parents before children,
     % and postorder is children before parents.
     % For a DAG, topological order = reverse(postorder).
     %
     % See Cormen, Leiserson and Rivest, "An intro. to algorithms" 1994, p478.
     [d, pre, post, cycle, f, pred] = dfsHelper(obj.adjMat, start, directed);
   end
   
  
   
   % We overload the syntax so that obj(i,j) refers to obj.adjMat(i,j)
   
   function B = subsref(obj, S)
     if (numel(S) > 1) % eg. obj.adjMat(1:3,:)
       B = builtin('subsref', obj, S);
     else
       switch S.type    %eg obj(1:3,:)
         case {'()'}
           B = obj.adjMat(S.subs{1}, S.subs{2});
         case '.' % eg. obj.adjMat
           B = builtin('subsref', obj, S);
       end
     end
   end
   
   function obj2 = subsasgn(obj, S, value)
     if (numel(S) > 1) % eg. obj.adjMat(1:3,:) = value
       obj2 = builtin('subsasgn', obj, S, value);
     else
       switch S.type    %eg obj(1:3,:)
         case {'()'}
           obj2 = obj;
           obj2.adjMat(S.subs{1}, S.subs{2}) = value;
         case '.' % eg. obj.adjMat = value
           obj2 = builtin('subsasgn', obj, S, value);
       end
     end
   end

 end
 
 %% Demos
 methods(Static = true)
   function demo()
     % demo of various methods
     % Do the example in fig 23.4 p479 of Cormen, Leiserson and Rivest (1994)

     u = 1; v = 2; w = 3; x = 4; y = 5; z = 6;
     n = 6;
     G=zeros(n,n);
     G(u,[v x])=1;
     G(v,y)=1;
     G(w,[y z])=1;
     G(x,v)=1;
     G(y,x)=1;
     G(z,z)=1;

     % u1 -> v2  w3
     % |    ^ |  / |
     % |  /   | /  |
     % v      v    v
     % x4<-- y5   z6 (self)

     GG = directedGraph(G);
     draw(GG)
     [d, pre, post, cycle, f, pred] = dfs(GG, [], 1);
     assert(isequal(d, [1 2 9 4 3 10]))
     assert(isequal(f, [8 7 12 5 6 11]))
     assert(cycle)

     % break self loop
     %GG(z,z)=0;
     GG.adjMat(z,z) =0;
     assert(~checkAcyclic(GG))

     % break y->x edge, leaving only undirected cycle uvx

     % u1 -> v2  w3
     % |    ^ |  / |
     % |  /   | /  |
     % v      v    v
     % x4    y5   z6

     %GG(y,x) = 0;
     GG.adjMat(y,x)=0;
     assert(checkAcyclic(GG))
     G1 = dag(GG.adjMat);
     G1.topoOrder % [3 6 1 4 2 5]


     % Now give it an undirected cyclic graph
     G = undirectedGraph('type', 'lattice2D', 'nrows', 2, 'ncols', 2, 'wrapAround', 0);
     % 1 - 3
     % |   |
     % 2 - 4
     assert(~checkAcyclic(G))

     % Now break the cycle
     %G(1,2)=0; G(2,1)=0;
     G.adjMat(1,2)=0; G.adjMat(2,1)=0;
     assert(checkAcyclic(G))

     % Make all UGs
     %UGs = mkAllUG(undirectedGraph(), 5);


     % Test min span tree using example from Cormen, Leiserson, Rivest 1997 p509
     A = zeros(9,9);
     A(1,2)=4; A(2,3) = 8; A(3,4) = 7; A(4,5) = 9; A(4,6) = 14; A(5,6)=10;
     A(1,8)=8; A(8,9)=7; A(9,3)=2; A(9,7)=6; A(8,7)=1; A(3,6)=4; A(7,6)=2;
     A = mkGraphSymmetric(A);
     [T,cost] = minSpanTree(undirectedGraph(A))
     assert(cost==37)

   end
 end
  
end