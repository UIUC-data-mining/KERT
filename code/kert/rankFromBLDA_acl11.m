% for ACL paper
% function FromBLDA(pttfile)
% do ranking based on blda results pttopic file
%% input selection
rootfile = 'new20conf/gamma0.5/_0.mat';
pttfile = 'new20conf/pt.1000.1';
ptfile = 'new20conf/pt.txt';
savefile = 'new20conf/acl11.mat';

rootfile = 'library/cat4/_0.mat';
pttfile = 'library/cat4/titleterm.1000.1';
ptfile = 'library/cat4/title-term.txt';
savefile = 'library/cat4/acl11.mat';

rootfile = 'arxiv/sampled_0.mat';
pttfile = 'arxiv/sampled/pt.1000.1';
savefile = 'arxiv/sampled/acl11.mat';
ptfile = 'arxiv/sampled/pt.txt';

rootfile = 'arxiv/sampled/k10_0.mat';
pttfile = 'arxiv/sampled/pt_k10.1000.1';
savefile = 'arxiv/sampled/acl11_k10.mat';
%% prepare

load(rootfile);
% load('library/cat4/_0.mat');
% pttfile = 'library/cat4/titleterm.1000.1';
ptt = load(pttfile);

minsup = 5;

k = max(ptt(:,3));
tfmat = cell(k,1);
y = size(ptt,1);
n = max(ptt(:,2));
zfreq = zeros(n,k);
% length 1
for i=1:y
    if ptt(i,3)>0
        zfreq(ptt(i,2),ptt(i,3)) = zfreq(ptt(i,2),ptt(i,3))+1;
    end
end

% length 2
pumat = cell(k,1);
for z=1:k
    topicz = (ptt(:,3)==z);
    pumat{z} = sparse(ptt(topicz,1),ptt(topicz,2),ones(sum(topicz),1));
    uumat = pumat{z}'*pumat{z};    
    [i,j,s] = find(uumat);
    tfmat{z} = sparse([(1:n)';i],[(1:n)';j],[zfreq(:,z);s]);
end

np = max(ptt(:,1));
path('../Ranking',path);
[score,phrases]=top_level_wrapper(tfmat,k,np,n, ptfile);
[score2,phrases2]=top_level_wrapper(tfmat,k,np,n,ptfile,0);
% [score,phrases]=top_level_wrapper(tfmat,k,np,n,...
%     'library/cat4/title-term.txt');
pp = PluralPair(root.idterm);
save(savefile,'score','score2','phrases','phrases2','pp','ptt');

%% ranking
load(savefile);
ngramname = cell(1,k);
for i=1:k
    [m,id] = sort(score{i},'descend');
    orderedphrase=ClassicalOrder(phrases{i},ptt);
    ngramname{i} = GetNgramFromContainer(orderedphrase,id,root.idterm,pp);
end    
% WriteName([root.prefix '_' int2str(k) '.acl11nolenpref'],ngramname);    
WriteName([root.prefix '_' int2str(k) '.acl11'],ngramname);    

for i=1:k
    [m,id] = sort(score2{i},'descend');
    orderedphrase=ClassicalOrder(phrases2{i},ptt);
    ngramname{i} = GetNgramFromContainer(orderedphrase,id,root.idterm,pp);
end    
WriteName([root.prefix '_' int2str(k) '.acl11rel'],ngramname);    

%% output for mutual info, for library/arxiv data
load(savefile);
top = 1000;
allphrases = containers.Map('KeyType','char','ValueType','int32');
k = length(score);
idmap = zeros(k,top);
zfreq = [];
np = 0;
for i=1:k
    [m,gg] = sort(score{i},'descend');
    topk = min(top,length(gg));
    for j=1:topk
        phrase = mat2str(phrases{i}(gg(j)));
        if isKey(allphrases,phrase)
            id = allphrases(phrase);
            zfreq(id,i) = 1;
            idmap(i,j) = id;
        else
            np = np + 1;
            allphrases(phrase) = np;
            zfreq(np,i) = 1;
            idmap(i,j) = np;
        end
    end
end
ngramdict = containers.Map(values(allphrases),keys(allphrases));
OutputPhrase4MI([root.prefix 'acl11'],idmap,ngramdict,zfreq);

allphrases = containers.Map('KeyType','char','ValueType','int32');
k = length(score2);
idmap = zeros(k,top);
zfreq = [];
np = 0;
for i=1:k
    [m,gg] = sort(score2{i},'descend');
    topk = min(top,length(gg));
    for j=1:topk
        phrase = mat2str(phrases2{i}(gg(j)));
        if isKey(allphrases,phrase)
            id = allphrases(phrase);
            zfreq(id,i) = 1;
            idmap(i,j) = id;
        else
            np = np + 1;
            allphrases(phrase) = np;
            zfreq(np,i) = 1;
            idmap(i,j) = np;
        end
    end
end
ngramdict = containers.Map(values(allphrases),keys(allphrases));
OutputPhrase4MI([root.prefix 'acl11rel'],idmap,ngramdict,zfreq);
