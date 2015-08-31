function name = ReadName(filename)
f = fopen(filename);
name = textscan(f,'%d\t%[^\n]');
fclose(f);
for i=1:length(name{2})    
    if ~isempty(name{2}{i}) && name{2}{i}(end)<32
        name{2}{i}(end) = [];
    end
end