function writeWeka(vec1,vec2,fileName)
    fid = fopen(sprintf('%s.arff',fileName),'w');
    fprintf(fid,'@RELATION vs\n');
    for i=1:size(vec1,2)
        fprintf(fid,'@ATTRIBUTE char%d NUMERIC\n',i);
    end        
    fprintf(fid,'@ATTRIBUTE class        {c1,c2}\n');     
    fprintf(fid,'@DATA\n');
    for i=1:size(vec1,1)
        for j=1:size(vec1,2)
            fprintf(fid,'%f,',vec1(i,j));
        end
        fprintf(fid,'c1\n');
    end
    for i=1:size(vec2,1)
        for j=1:size(vec2,2)
            fprintf(fid,'%f,',vec2(i,j));
        end
        fprintf(fid,'c2\n');
    end    

    fclose(fid);
    %dos(sprintf('java -cp weka.jar weka.filters.supervised.instance.SMOTE -C 0 -K 3 -P 100.0 -S 1 -i %s.arff -o %s%s.arff -c last',fileName,fileNameOver,selectedChar));
    