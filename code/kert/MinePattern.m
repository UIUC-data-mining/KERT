function [ngramdict,zfreq,np] = MinePattern(ptt,maxn,minsup)
% ngramdict{n} = list of n-grams, x by n
% zfreq{n} = topical frequency for each ngram, x by k
% ptt - paper, term, topic, y by 3
k = max(ptt(:,3));

ptt = ptt(ptt(:,3)>0,:);
y = size(ptt,1);
ptmat = sparse(ptt(:,1),ptt(:,3),ones(y,1));
np = ones(k)*size(ptmat,1);
disp(['in total ' int2str(np(1)) ' docs']);
% alltopic = 1:k;
for i=1:k
    np(i,i) = nnz(ptmat(:,i));
end
for i=1:k-1
    for j=i+1:k
        np(i,j) = nnz(ptmat(:,i)|ptmat(:,j));
        np(j,i) = np(i,j);
    end
end
% slow
% for i=1:size(ptmat,1)
%     if mod(i,1000)==0
%         display([int2str(i/1000) 'K']);
%     end
%     topics = find(~ptmat(i,:));
%     np(topics,topics) = np(topics,topics)-1;
% %     othert = setdiff(alltopic, topics);
% %     np(topics,othert) = np(topics,othert)+1;
% %     np(othert,topics) = np(othert,topics)+1;
% end

ngramdict = cell(maxn,1);
zfreq = cell(maxn,1);
zfreq{1} = zeros(max(ptt(:,2)),k);
% length 1
for i=1:y
%     if ptt(i,3)>0
        zfreq{1}(ptt(i,2),ptt(i,3)) = zfreq{1}(ptt(i,2),ptt(i,3))+1;
%     end
end
maxfreq = max(zfreq{1},[],2);
remain = find(maxfreq>minsup);
zfreq{1} = zfreq{1}(remain,:);
ngramdict{1} = remain;
size(ngramdict{1})
if maxn<2 return; end
% length 2
edge = cell(k,1);
pumat = cell(k,1);
alledges = [];
count = zeros(k+1,1);
for z=1:k
    topicz = (ptt(:,3)==z);
    pumat{z} = sparse(ptt(topicz,1),ptt(topicz,2),ones(sum(topicz),1));
    pumat{z} = pumat{z}(:,remain(remain<=size(pumat{z},2)));
    uumat = pumat{z}'*pumat{z};    
    uumat = triu(uumat,1);
%     uumat(uumat<minsup)=0;
%     edge{z} = uumat;    
    [i,j,s] = find(uumat);
    keep = s>minsup;
    i = i(keep);
    j = j(keep);
    s = s(keep);
    edge{z} = sparse(i,j,s);
    count(z) = size(alledges,1);
    alledges = [alledges;i,j,s];
end
count(z+1) = size(alledges,1);
uumat = sparse(alledges(:,1),alledges(:,2),ones(size(alledges,1),1));
[i,j] = find(uumat);
ngramdict{2} = [i,j];
zfreq{2} = zeros(length(i),k);
% edge{1}(find(remain==96,1),find(remain==529,1))
for z=1:k
    disp(['topic ' int2str(z) ' bigrams']);
    [~,ia,ib] = intersect([i,j],alledges(count(z)+1:count(z+1),1:2),'rows');
    zfreq{2}(ia,z) = alledges(count(z)+ib,3);
end
% slow
% for t=1:length(i)
%     it = i(t);
%     jt = j(t);
%     for z=1:k
%         if it<=size(edge{z},1) && jt<=size(edge{z},2)
%             zfreq{2}(t,z) = edge{z}(it,jt);
%         end
%     end
% end
size(ngramdict{2})
% length 3 to maxn
pcontainu = cell(k,1);

for n=3:maxn
    % grow from (n-1) grams
    clear dict;
    dict = containers.Map('KeyType','char','ValueType','int32');
    for j=1:size(ngramdict{n-1},1)
        if mod(j,1000)==0
            display([int2str(j/1000) 'K']);
        end
        frequent = find(zfreq{n-1}(j,:)>minsup);
        uni = ngramdict{n-1}(j,:);
        lastu = uni(end);
        for zid=1:length(frequent)
            z = frequent(zid);
            if lastu>=size(edge{z},1) continue; end
            candidate = find(edge{z}(lastu,:));
            for s=1:n-2
                if isempty(candidate)
                    break;
                end
                candi = find(edge{z}(uni(s),lastu+1:end))+lastu;
                candidate = intersect(candidate,candi);
            end
            if ~isempty(candidate) % found candidate item to grow
                for zz=1:k
                    pcontainu{zz} = pumat{zz}(:,lastu);
                    for s=1:n-2
                        pcontainu{zz} = pcontainu{zz} & pumat{zz}(:,uni(s));
                    end
                end
            end % find papers containing the old patterns
            for i=1:length(candidate)
%                 ind = edge{z}(uni,candidate(i));
                key = mat2str([uni candidate(i)]);                
                % slow
%                 [~,~,ib] = intersect([uni candidate(i)],...
%                     ngramdict{n},'rows');
                if ~isKey(dict,key)                    
                    tfz = nnz(pcontainu{z} & pumat{z}(:,candidate(i)));
                    if tfz>minsup % found a frequent phrase
                        tfzz = zeros(1,k);
                        tfzz(z) = tfz;
                        for zz=1:k
                            if z~=zz && candidate(i)<=size(pumat{zz},2)
                                tfzz(zz) = nnz(pcontainu{zz} & ...
                                    pumat{zz}(:,candidate(i)));
                            end
                        end
                        ngramdict{n} = [ngramdict{n}; ...
                            full([uni candidate(i)])];
                        zfreq{n} = [zfreq{n}; tfzz];
                        dict(key) = size(ngramdict{n},1);
                    end
                end
            end
        end
    end
    size(ngramdict{n})
end
remain = remain';
for n=2:maxn
    ngramdict{n} = remain(ngramdict{n});
end
