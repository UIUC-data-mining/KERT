function WriteName(filename,name)
% write name cell to filename
% name - 1*k cell
f = fopen(filename,'w');
for i=1:length(name)
    for j=1:length(name{i});
        fprintf(f,'%s\t',name{i}{j});
    end
    fprintf(f,'\n');
end
fclose(f);