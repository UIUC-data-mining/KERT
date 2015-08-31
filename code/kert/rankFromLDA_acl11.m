% function FromBLDA(pttfile)
% do ranking based on blda results pttopic file
function KpRel(datapath,options)
% the name of term dictionary file
dictfile = [datapath 'word_index.txt'];
% the name of the topic model result file
pttfile = [datapath 'ptt.txt'];
% the name of the output file
outputfile = [datapath 'phrase.kprel'];
% the final maximal length of phrases you want to output
maxn = options.maxn;
% the number of phrases you want to output for each topic
top = options.top;

% you don't need to change the following
savefile = [datapath 'kprel_fromlda.mat'];
idterm = ReadName(dictfile);

%% prepare
tic;
ptt = load(pttfile);

k = max(ptt(:,3));
options.num_of_topics=k;
tfmat = cell(k,1);
y = size(ptt,1);
n = max(ptt(:,2));
options.dictionary_size=n;
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
options.corpus_size=np;
path('../Ranking',path);
[score,phrases]=top_level_wrapper(tfmat,options, pttfile);
[score2,phrases2]=top_level_wrapper(tfmat,options,pttfile,0);
toc;
StorePTSeq(ptt,savefile);
save(savefile,'-append','score','score2','phrases','phrases2');

%% ranking
load(savefile);
tic;
ngramname = cell(1,k);
for i=1:k
    [m,id] = sort(score{i},'descend');
    orderedphrase = ClassicalOrder(phrases{i},PT,pt);
    ngramname{i} = GetNgramFromContainer(orderedphrase,id,root.idterm);
end    
WriteName([outputfile 'Int'],ngramname);    

for i=1:k
    [m,id] = sort(score2{i},'descend');
    orderedphrase=ClassicalOrder(phrases2{i},ptt);
    ngramname{i} = GetNgramFromContainer(orderedphrase,id,root.idterm,pp);
end    
WriteName(outputfile,ngramname);    
toc;
