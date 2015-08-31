function gg = RankNgram7(ngramdict, zfreq, np, wp, frac, unizfreq)
% similar as ngram_7, just no mining, only ranking from mined topical frequency
% npz - k by k matrix, diagnal is the number of papers containing topic 1
% to k, and other elements are the number of papers containing topic i and
% j
maxn = length(ngramdict);
k = size(zfreq{1},2);
npz = diag(np)';
gg = cell(k,1);
if exist('unizfreq','var')
    
    uniprob = bsxfun(@rdivide, unizfreq, npz);
else
    nuni = max(ngramdict{1}(:,1));
    uniprob = zeros(nuni,k);
    uniprob(ngramdict{1},:) = bsxfun(@rdivide, zfreq{1}, npz );
end
zfreq2 = FilterBrokenPhrase(ngramdict,zfreq, frac);
for z=1:k
    theta = uniprob(:,z);
    for n=1:maxn
        if isempty(zfreq{n}) break; end
        ind = find(zfreq2{n}(:,z)>0);
        l = length(ind);
        if l>0
            uni = ngramdict{n}(ind,1:n);
            valid = all(uni<=nuni,2);
            if ~any(valid) continue; end
            ind = ind(valid);
            uni = uni(valid,:);
            thetan = theta(uni);
            if l==1
                unifg = prod(thetan);
            else
                unifg = prod(thetan,2);
            end
            validuni = unifg>0;
            ind = ind(validuni);
            l = length(ind);
            if ~l continue; end
            unifg = unifg(validuni);
            freqz = zfreq2{n}(ind,z);
            bg = bsxfun(@rdivide,bsxfun(@plus,zfreq{n}(ind,:),freqz),np(z,:));
            bg(:,z) = 0;
            bg = max(bg,[],2);
            ngramfg = freqz/npz(z);
            score = PointKL(ngramfg,bg)+wp*PointKL(ngramfg,unifg);
    %         [size(ones(l,1)) size((1:l)'), size(zfreq{n}(:,z))]
    %         [size(ngramfg) size(unifg) size(bg) size(score)]
            gg{z} = [gg{z}; n*ones(l,1), ind, freqz, ...
                ngramfg, unifg, bg, score];
        end
    end
    [~,ind] = sort(gg{z}(:,end),'descend');
    gg{z} = gg{z}(ind,:);
end
