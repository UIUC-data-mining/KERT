% for PKDD paper
% function FromBLDA(pttfile)
% do ranking based on blda results pttopic file
%% input selection
inputpath = '../news/';
% outputpath = '../news/wp1.0/';
% outputpath = '../news/nobg/';
% outputpath = '../news/nobg_0.01_0.01/';
outputpath = '../news/50nobg_0.01_0.01/';
rootfile = [outputpath '_0.mat'];
prepare_news;
save(rootfile,'root');
pttfile = [inputpath 'pt50_0.01_0.01.1000.0'];
savefile = [outputpath 'fromblda.mat'];

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

%% new20conf input selection
inputpath = '../new20conf/';
outputpath = '../new20conf/wp1.0/';
rootfile = [outputpath '_0.mat'];
prepare_dblp;
save(rootfile,'root');
pttfile = [inputpath 'pt.1000.1'];
savefile = [outputpath 'fromblda.mat'];

%% mining for new20conf
load(rootfile);
ptt = load(pttfile);

maxn = 5;
minsup = 5;
[ngramdict,zfreq,np] = MinePattern(ptt,maxn,minsup);
% pp = PluralPair(root.idterm);
% ordereddict=ClassicalOrder(ngramdict,ptt);
% ordereddict = ngramdict;
save(savefile,'ngramdict','zfreq','np','ordereddict');
StorePTSeq(ptt,savefile);

%% dblp input selection
% k30
%inputpath = '../dblp/';
% outputpath = '../dblp/wp1.0/';
% k100
inputpath = '../dblp/k100/';
outputpath = '../dblp/k100/';

rootfile = [outputpath '_0.mat'];
prepare_news;
save(rootfile,'root');
pttfile = [inputpath 'ptt.txt'];
savefile = [outputpath 'fromlda.mat'];

%% mining for dblp
load(rootfile);
ptt = load(pttfile);
ptt = ptt + 1;

maxn = 5;
minsup = 20;
[ngramdict,zfreq,np] = MinePattern(ptt,maxn,minsup);
% pp = PluralPair(root.idterm);
% ordereddict=ClassicalOrder(ngramdict,ptt);
% ordereddict = ngramdict;
save(savefile,'ngramdict','zfreq','np');
StorePTSeq(ptt,savefile);

%% ranking
load(rootfile);
load(savefile);
wp = root.wp;
frac = root.gamma;
maxn = 4;
k = size(zfreq{1},2);
top = 1000;

gg = RankNgram7(ngramdict(1:maxn),zfreq,np,wp,frac);
% full ranking function
ngramname = cell(1,k);
for i=1:k
    ngramname{i}=GetNgram(ngramdict,gg{i}(1:min(top,size(gg{i}(:,1))),:),...
        root.idterm,PT,pt);
%     OutputNgram([root.prefix int2str(i) '.score'],gg{i},ordereddict,root.map);
end    
%% output 
WriteName([root.prefix '_' int2str(k) '.kert'],ngramname);    
% OutputPhrase4MI([root.prefix 'kert'],gg,ngramdict,zfreq,root.map);


