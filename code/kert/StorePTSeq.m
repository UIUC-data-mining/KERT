function StorePTSeq(PTmat,filename)
tic;
np = max(PTmat(:,1));
PT = cell(np,1);
for i=1:size(PTmat,1)
    pid = PTmat(i,1);
    PT{pid} = [PT{pid} PTmat(i,2)];
end
% PT = containers.Map('KeyType','int32','ValueType','any');
% for i=1:size(PTmat,1)
%     pid = PTmat(i,1);
%     if isKey(PT,pid)
%         PT(pid) = [PT(pid) PTmat(i,2)];
%     else
%         PT(pid) = PTmat(i,2);
%     end
% end
pt = sparse(PTmat(:,1), PTmat(:,2), ones(size(PTmat,1),1));
clear PTmat;
timept = toc
save(filename,'-append','PT','pt','timept');
