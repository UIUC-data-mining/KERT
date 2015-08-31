function OutputNgram(filename,gg,ngramdict,map)
% write the ngram (ids) into a file
% gg - first column is n, followed by the id in ngramdict{n}; last column
%   is the ranking score; 4th column - foreground prob; 6th - background
f = fopen(filename, 'w');
for i=1:size(gg,1)
    if gg(i,4)<=gg(i,6)
%         break;
    end
    n = gg(i,1);
    if exist('map','var')
        seq = map(ngramdict{n}(gg(i,2),1:n));
    else
        seq = ngramdict{n}(gg(i,2),1:n);
    end
    fprintf(f,'%d ',n);
    for j=1:n
        fprintf(f,'%d ',seq(j));
    end
    fprintf(f,'%f\n',gg(i,end));
end
fclose(f);