% for PKDD paper
% function FromPDLDA(ngramdictfile,zfreqfile)
% do ranking based on pdlda results after post processing ngramdict file
% and zfreq file
%% input selection
inputpath = '../ap/';
outputpath = '../ap/omega0.5/';
rootfile = [outputpath '_0.mat'];
% prepare_pdlda;
% save(rootfile,'root');
ngramdictfile = [inputpath 'ngramdict.txt'];
zfreqfile = [inputpath 'zfreq.txt'];
termdictfile = [inputpath 'term.txt'];
unifile = [inputpath 'unizfreq.txt'];
savefile = [inputpath 'frompdlda.mat'];

% rootfile = 'library/cat4/_0.mat';
% pttfile = 'library/cat4/titleterm.1000.1';
% savefile = 'library/cat4/fromblda.mat';
% 
% rootfile = 'arxiv/sampled/k10_0.mat';
% pttfile = 'arxiv/sampled/pt_k10.1000.1';
% savefile = 'arxiv/sampled/fromblda_k10.mat';
% 
% rootfile = 'arxiv/sampled_0.mat';
% pttfile = 'arxiv/sampled/pt.1000.1';
% savefile = 'arxiv/sampled/fromblda.mat';

%% mining
% load(rootfile);
% ptt = load(ngramdictfile);
uname = ReadName(termdictfile);
freq = load(zfreqfile);
unizfreq = load(unifile);
chunksize = 10;
np = sum(unizfreq)/chunksize;
k = length(np);
np = repmat(np,[k 1])+repmat(np',[1 k])-diag(np);
maxn = 11;
minsup = 5;
ngramdict=cell(maxn,1);
zfreq = ngramdict;
f = fopen(ngramdictfile);
line = fgetl(f);
lnum = 1;
while line~=-1
    id = sscanf(line,'%d');
    n = id(1);
    ngramdict{n} = [ngramdict{n}; id(2:end)'];
    zfreq{n} = [zfreq{n}; freq(lnum,:)];
    line = fgetl(f);
    lnum = lnum+1;
end
fclose(f);
% [ngramdict,zfreq,np] = MinePattern(ptt,maxn,minsup);
% pp = PluralPair(root.idterm);
% ordereddict=ClassicalOrder(ngramdict,ptt);
save(savefile,'ngramdict','zfreq','np','uname','unizfreq');

%% ranking
% load(rootfile);
load(savefile);
% wp = root.wp;
% frac = root.gamma;
wp = 1;
frac = 2;
k = size(zfreq{1},2);
top = 200;

ngramname = cell(1,k);
gg = RankNgram7(ngramdict,zfreq,np,wp,frac,unizfreq);
% coverage + purity
for i=1:k
    ngramname{i}=GetNgram(ngramdict,gg{i}(1:min(top,size(gg{i}(:,1))),:),...
        uname);
end    
WriteName([outputpath 'phrase.kert'],ngramname);    

gg = RankNgramByCov(ngramdict,zfreq,np,wp,frac);
% coverage 
for i=1:k
    ngramname{i}=GetNgram(ngramdict,gg{i}(1:min(top,size(gg{i}(:,1))),:),...
        uname);
end    
WriteName([outputpath 'phrase.likelihood'],ngramname);    

%% output 
% OutputPhrase4MI([root.prefix 'kert'],gg,ngramdict,zfreq,root.map);

