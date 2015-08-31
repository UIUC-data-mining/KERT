% for PKDD paper
% function FromPDLDA(ngramdictfile,zfreqfile)
% do ranking based on pdlda results after post processing ngramdict file
% and zfreq file
%% input selection
inputpath = '../ap/';
outputpath = '../ap/gamma2/';
rootfile = [outputpath '_0.mat'];
% prepare_pdlda;
% save(rootfile,'root');
ngramdictfile = [inputpath 'ngramdict.txt'];
zfreqfile = [inputpath 'zfreq.txt'];
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
pname = ReadName(ngramdictfile);
zfreq = load(zfreqfile);
np = sum(zfreq);
k = length(np);
np = repmat(np,[k 1])+repmat(np',[1 k])-diag(np);
ngramdict={(1:size(zfreq,1))'};
zfreq = {zfreq};
maxn = 5;
minsup = 5;
% [ngramdict,zfreq,np] = MinePattern(ptt,maxn,minsup);
% pp = PluralPair(root.idterm);
% ordereddict=ClassicalOrder(ngramdict,ptt);
save(savefile,'ngramdict','zfreq','np','pname');

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
gg = RankNgram7(ngramdict,zfreq,np,wp,frac);
% coverage + purity
for i=1:k
    ngramname{i}=GetNgram(ngramdict,gg{i}(1:min(top,size(gg{i}(:,1))),:),...
        pname);
end    
WriteName([outputpath 'phrase.kert'],ngramname);    

gg = RankNgramByCov(ngramdict,zfreq,np,wp,frac);
% coverage 
for i=1:k
    ngramname{i}=GetNgram(ngramdict,gg{i}(1:min(top,size(gg{i}(:,1))),:),...
        pname);
end    
WriteName([outputpath 'phrase.cov'],ngramname);    

%% output 
% OutputPhrase4MI([root.prefix 'kert'],gg,ngramdict,zfreq,root.map);

