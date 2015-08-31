function phrase = GetNgram(ngramdict,idlist,idterm,PT,pt,pp)
% return ngrams according to idlist
% idlist - 2 columns of (i,j), ngramdict{i}(j,1:i) is the terms
% pp - plural pairs
nphrase = size(idlist,1);
% filter phrases with plural and non-plural forms
remove = zeros(nphrase,1);
if exist('pp','var')
    plural = pp(:,1);
    single = pp(:,2);
    for i=1:nphrase
        n = idlist(i,1);
        id = idlist(i,2);
        p1 = ngramdict{n}(id,1:n);
        [plurals, ~,ib] = intersect(p1,plural);
        if ~isempty(plurals)
            singles = single(ib);
            for j=1:nphrase
%                 if i==2 && j==1
%                     [singles plurals]
%                 end
                n2 = idlist(j,1);
                if n2==n
                    id2 = idlist(j,2);
                    p2 = ngramdict{n2}(id2,1:n);
%                     if i==2 && j==1
%                         [p1; p2]
%                     end
                    diff1 = setdiff(p1,p2);
                    if length(diff1)==1
                        pluralid = find(plurals==diff1,1);
                        if ~isempty(pluralid)
                            diff2 = setdiff(p2,p1);
                            if length(diff2)==1 && diff2 == singles(pluralid)
                                remove(i) = remove(i) | idlist(i,3)<idlist(j,3);
                                remove(j) = remove(j) | idlist(i,3)>idlist(j,3);
%                                 if i==1 && j==2
%                                     [remove(i) remove(j)]
%                                 end
                                break;
                            end
                        end
                    end
                end
            end
        end
    end
end
phrase = cell(nphrase-sum(remove),1);
phrasedict = containers.Map('KeyType','int32','ValueType','any');
pc = 0;
for i=1:nphrase
    if remove(i) continue; end
    n = idlist(i,1);
    id = idlist(i,2);
    pc = pc + 1;
    phrasedict(pc) = ngramdict{n}(id,:);
end
if exist('PT','var')
    phrasedict = ClassicalOrder(phrasedict,PT,pt);
end
for i=1:pc
    p = phrasedict(i);
    phrase{i} = idterm{2}{p(1)};
    n = length(p);
    for j=2:n
        phrase{i} = [phrase{i} ' ' idterm{2}{p(j)}];
    end
end