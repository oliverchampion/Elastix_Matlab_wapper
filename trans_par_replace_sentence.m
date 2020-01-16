function trans_par_replace_sentence(file_in,file_out,sentencestart,sentenceout)
%%
% replaces a bit of text in a text file; usefull when one wants to use a
% tranformation obtained from elastix to apply to a mask, where one wants
% to replace the bspline order from 3rd to 0th. Here, only part of the
% sentence that one wants to replace is needed to be known.
% file_in is the input file path
% file_out is the output file path
% sentencestart is the starting phrase of the sentence one wants to replace by sentenceout
%%
% Code is written by Oliver Gurney-Champion
% o.j.gurney-chapion@amsterdamumc.nl
%
%%
fid=fopen(file_in,'r');
fid2=fopen(file_out,'w');
while(~feof(fid))
    s=fgetl(fid);
    if size(s,2)>size(sentencestart,2)
        if strcmp(s(1:size(sentencestart,2)),sentencestart)
            s=sentenceout;
        end
    end
    fprintf(fid2,'%s\n',s);
end
fclose(fid);
fclose(fid2);
end