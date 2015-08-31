% for PKDD paper
% function postBLDA(pttfile)
% do simple ranking based coverage with blda results pttopic file
%% input selection
inputpath = '../new20conf/';
outputpath = '../new20conf/wp1.0/nobg';
% outputpath = '../new20conf/wp1.0/bg';
prepare_dblp;
% inputpath = '../news/';
% outputpath = '../news/wp1.0/';
% outputpath = '../news/nobg/';
% outputpath = '../news/nobg_0.01_0.01/';
% outputpath = '../news/50nobg_0.01_0.01/';
% inputpath = '../new20conf/';
% prepare_news;
rootfile = [outputpath '_0.mat'];
save(rootfile,'root');
pttfile = [inputpath 'pt.1000.0'];
savefile = [outputpath 'fromlda.mat'];
% pttfile = [inputpath 'pt.1000.1'];
% savefile = [outputpath 'fromblda.mat'];

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
load(rootfile);
ptt = load(pttfile);

maxn = 1;
minsup = 0;
[ngramdict,zfreq,np] = MinePattern(ptt,maxn,minsup);
% pp = PluralPair(root.idterm);
% ordereddict=ClassicalOrder(ngramdict,ptt);
save(savefile,'ngramdict','zfreq','np');

%% ranking
load(rootfile);
load(savefile);
wp = 0;
frac = 2;
k = size(zfreq{1},2);
top = 1000;

gg = RankNgramByCov(ngramdict,zfreq,np,wp,frac);
% full ranking function
ngramname = cell(1,k);
for i=1:k
    ngramname{i}=GetNgram(ngramdict,gg{i}(1:min(top,size(gg{i}(:,1))),:),...
        root.idterm);
end    
%% output 
WriteName([root.prefix '_' int2str(k) '.cov'],ngramname);    
% OutputPhrase4MI([root.prefix 'kert'],gg,ngramdict,zfreq,root.map);

