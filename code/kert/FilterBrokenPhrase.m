function zfreq = FilterBrokenPhrase(ngramdict, zfreq, frac)
if frac>1
    return;
end
if ~iscell(ngramdict)
    np = length(ngramdict);
    phrases = values(ngramdict);
    maxn = 1;
    for i=1:np
        maxn = max(maxn, length(phrases{i}));
    end
    dict = cell(maxn,1);
    freq = cell(maxn,1);
    for i=1:np
        nw = length(phrases{i});
        dict{nw}=[dict{nw};sort(phrases{i}) i];
        freq{nw}=[freq{nw};zfreq(i,:)];
    end
    ngramdict = dict;
    zfreq = freq;
end
    maxn = length(ngramdict);
    mark = cell(maxn,1);
    for n=2:maxn
        mark{n-1} = zeros(size(zfreq{n-1}));
        ngramnum = size(ngramdict{n-1},1);
        clear prefixdict;
        prefixdict = containers.Map('KeyType','char','ValueType','int32');
        for i=1:ngramnum
            key = mat2str(ngramdict{n-1}(i,:));
            prefixdict(key) = i;
        end
        for i=1:size(ngramdict{n},1)
            for j=1:n
                remain = setdiff(1:n,j);
                key = mat2str(ngramdict{n}(i,remain));
                % slow
%                 logic = ones(ngramnum,1);
%                 for s=1:n-1
%                     logic = logic & ...
%                         ngramdict{n-1}(:,s) == ngramdict{n}(i,remain(s));
%                 end
%                 logic = find(logic);
                if isKey(prefixdict,key) %~isempty(logic)
                    logic = prefixdict(key);
                    ind = zfreq{n-1}(logic,:)*frac< zfreq{n}(i,:);
                    mark{n-1}(logic,ind)=1;%zfreq{n}(i,ind);
                end
            end
        end
    end
    for n=1:maxn-1
        zfreq{n}(logical(mark{n}))=0;
    end
if exist('np','var')
    freq = zeros(np,size(zfreq{1},2));
    for n=1:maxn
        freq(ngramdict{n}(:,end),:) = zfreq{n};
    end
    zfreq = freq;
end