function [newdict] = ClassicalOrder(ngramdict, PT,pt)
%loop for answering all queries
newdict = ngramdict;
if iscell(ngramdict)
    maxn = length(ngramdict);
    for n = 2:maxn 
     for j=1:size(ngramdict{n},1)
       current_query = ngramdict{n}(j,1:n);       
       final_set = all(pt(:,current_query));
       final_set = find(final_set);
       if isempty(final_set)
           continue;
       end
       %final_set is the set of all papers which contains some perm of current
       %query
       seq = zeros(length(final_set),n);
       for i = 1:length(final_set)
           tids_in_current_paper = PT{final_set(i)};
            [~, seq(i,:)] = intersect(tids_in_current_paper,current_query);            
       end
        [permutation,~,sel] = unique(seq,'rows');
        count = hist(sel,1:size(permutation,1));
        [~,ind]=max(count);
        newdict{n}(j,1:n) = current_query(permutation(ind,:));
     end
    end
else
    queries = ngramdict;
    for j = 1:length(queries)
       current_query = queries(j);
       n = length(current_query);
       if n<2; continue; end
       final_set = all(pt(:,current_query),2);
       final_set = find(final_set);
%        length(final_set)
       if isempty(final_set)
           continue;
       end
       %final_set is the set of all papers which contains some perm of current
       %query
       seq = zeros(length(final_set),n);
       for i = 1:length(final_set)
           tids_in_current_paper = PT{final_set(i)};
            [~, perm] = intersect(tids_in_current_paper,current_query);            
            seq(i,:) = tids_in_current_paper(sort(perm));
       end
%        seq
        [permutation,~,sel] = unique(seq,'rows');
        count = hist(sel,1:size(permutation,1));
        [~,ind]=max(count);
%         current_query
        newdict(j) = permutation(ind,:);
    end 
end

