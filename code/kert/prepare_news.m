% build the term-term network on dblp
%% prepare
% [pu, pumat] = ReadEdge([inputpath 'PT.txt']);
% validpaper = unique(pu(:,1));
uname = ReadName(dictfile);
uname{1} = uname{1}+1;

root.idterm = uname;
root.prefix = outputpath;
