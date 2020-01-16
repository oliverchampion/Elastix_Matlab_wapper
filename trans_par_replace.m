function trans_par_replace(file_in,file_out,sentencein,sentenceout)
%%
% replaces a bit of text in a text file; usefull when one wants to use a
% tranformation obtained from elastix to apply to a mask, where one wants to replace the bspline order from 3rd to 0th.
% file_in is the input file path
% file_out is the output file path
% setnencein is the sentence one wants to replace by sentenceout
%%
% Code is written by Oliver Gurney-Champion
% o.j.gurney-chapion@amsterdamumc.nl
%
%%

fid=fopen(file_in,'r');
fid2=fopen(file_out,'w');
while(~feof(fid))
    s=fgetl(fid);
    s=strrep(s,sentencein,sentenceout);
    fprintf(fid2,'%s\n',s);

end
fclose(fid);
fclose(fid2);
end