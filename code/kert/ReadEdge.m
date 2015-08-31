% author: Chi Wang
% create date: Mar 3, 2012 (3.3 Revolution)
function [edgeTriple, edgeSparse] = ReadEdge(edgeFile)
% edgeTriple: [i j A]*m
% edgeSparse: a sparse n*n matrix, A_{i,j}
% edgeFile: %d\t%d\t%d, directed network
    edgeTriple = load(edgeFile);
    m = size(edgeTriple,1);
    if size(edgeTriple,2)<3 
        % be default, edge weight is 1
        edgeTriple(:,3)=ones(m,1);
    end
    edgeSparse = sparse(edgeTriple(:,1),edgeTriple(:,2),edgeTriple(:,3));
end