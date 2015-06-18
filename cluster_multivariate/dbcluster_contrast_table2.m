function OUT = db_cluster_table(clusters,DB,varargin)
% function OUT = db_cluster_table(clusters,DB,varargin)
%
% tor wager
% counts studies and contrasts in each cluster
%
% clusters is a struct in which XYZmm field has list of points
% --should be output of database2clusters, which contains all fields
% DB is database output of database2clusters
%
% Prints one row per coordinate in any cluster, along with study names,
% cluster ID, and values in fields you specify in fnames
%
% This prints outputs by cluster!  ALSO takes multiple DBs
% order is always CLUSTER, CLUSTERDB, CLUSTER2,CLUSTERDB2, etc.
%
% optional arguments:
% fnames is a cell array that has names of all fields in clusters to use
% first cell is which factor, following cells are levels to include
% enter one argument per factor:
%
% example:
% OUT = dbcluster_contrast_table(PAIN,PAINDB,{'Right_vs_Left' 'Right' 'Left'})
% perc_barplot(OUT.cond_by_cl_counts,OUT.conditioncounts,OUT.levels{1},'test',OUT.clusternames)
%
% see also db_cluster_table.m 

% enter input arguments

for i = 1:length(varargin), 
    if isstruct(varargin{i})
       % do nothing yet
    else
        fnames{i} = varargin{i}{1};
        if length(varargin{i}) > 1
            levels{i} = varargin{i}(2:end);
        else
            eval(['levels{i} = unique(DB. ' varargin{i}{1} ');'])
        end
    end
end


% get indicator for all levels

for i = 1:length(varargin), 
    if isstruct(varargin{i}) & length(varargin{i}) > 1  % if clusters
        [fmatx{i},rmatx{i},ustudyout{i},taskindic{i},tasknms{i},allsuni{i}] = dbcluster2indic(varargin{i},varargin{i+1},fnames);
        
    end
end



fprintf(1,'%3.0f Unique contrasts\n',length(ustudyout))

% select only levels of interest
newti = []; newnames = {};

for i = 1:length(fnames)
    for j = 1:length(levels{i})
        wh = find(strcmp(tasknms,levels{i}{j}));
        
        newti = [newti taskindic(:,wh)];
        newnames = [newnames tasknms(wh)];
    end
end
           

% Display header

fprintf(1,'Study\t')
for i = 1:length(newnames)
    fprintf(1,'%s\t',newnames{i})
end
    for i = 1:size(fnames,2)
        fprintf(1,['%s\t'],fnames{i})
    end
    
    for i = 1:size(rmatx,2)
        if ~isfield(clusters,'shorttitle')
            fprintf(1,['Clust%3.0f\t'],num2str(i))
        else
            fprintf(1,['%s\t'],clusters(i).shorttitle)
        end
    end
    
fprintf(1,'\n')


% Display table body
[yr,ustudyout] = getYear(ustudyout);

for i = 1:length(ustudyout)
    
    
    % print study name, task values, and number of peaks in each cluster
    fprintf(1,'%s\t',[ustudyout{i} ' ' yr{i}]);
    
    for j = 1:size(newti,2)
        fprintf(1,['%3.0f\t'],newti(i,j))
    end
    
    for j = 1:size(fmatx,2)
        fprintf(1,['%s\t'],fmatx{i,j})
    end
    
    for j = 1:size(rmatx,2)
        fprintf(1,['%3.0f\t'],rmatx(i,j))
    end
    
    fprintf(1,'\n')
    
end

% Summary and percentages for columns

totals = sum(newti > 0);
clustertotals = sum(rmatx > 0);

fprintf(1,'\n')
fprintf(1,['Total\t' repmat('%3.0f\t',1,size(totals,2))],totals);
for i = 1:size(fnames,2), fprintf(1,'\t'),end
fprintf(1,[repmat('%3.0f\t',1,size(clustertotals,2))],clustertotals);

perc = 100* sum(newti > 0) ./ length(ustudyout);
clusterperc = 100 * sum(rmatx > 0) ./ length(ustudyout);

fprintf(1,'\n')
fprintf(1,['Percentage\t' repmat('%3.0f\t',1,size(perc,2))],perc);
for i = 1:size(fnames,2), fprintf(1,'\t'),end
fprintf(1,[repmat('%3.2f\t',1,size(clusterperc,2))],clusterperc);

fprintf(1,'\n')
fprintf(1,'\n')

% Summary and percentages by condition


for j = 1:size(newti,2)
    
    for k = 1:size(rmatx,2)
        
        clcondtotal(j,k) = sum(rmatx(:,k) > 0 & newti(:,j));
        clcondperc(j,k) = 100 * clcondtotal(j,k) / totals(j);   % % of studies in condition
        
    end
    
end

fprintf(1,'Totals by condition and cluster\n')

% header

fprintf(1,'\t')
    for i = 1:size(rmatx,2)
        if ~isfield(clusters,'shorttitle')
            fprintf(1,['Clust%3.0f\t'],num2str(i))
        else
            fprintf(1,['%s\t'],clusters(i).shorttitle)
        end
    end
    fprintf(1,'\n')
    
for j = 1:size(newti,2)
    
    fprintf(1,'%s\t',newnames{j})
    
    str = [repmat('%3.0f\t',1,size(clcondtotal,2))];
    fprintf(1,str,clcondtotal(j,:))
    fprintf(1,'\n')
    
end


fprintf(1,'Percentages by condition and cluster\n')
for j = 1:size(newti,2)
    
    fprintf(1,'%s\t',newnames{j})
    
    str = [repmat('%3.0f\t',1,size(clcondperc,2))];
    fprintf(1,str,clcondperc(j,:))
    fprintf(1,'\n')
    
end

OUT.cond_by_cl_counts = clcondtotal;
OUT.clustercounts = clustertotals;
OUT.conditioncounts = totals;
OUT.ustudyout = ustudyout;
OUT.fmatx = fmatx;
OUT.rmatx = rmatx;
OUT.factornames = fnames;
OUT.levels = levels;

for i = 1:length(clusters),
    if isfield(clusters,'shorttitle')
        OUT.clusternames{i} = clusters(i).shorttitle;,
    else
        OUT.clusternames{i} = ['CL' num2str(i)];
    end
end

%perc_barplot(OUT.cond_by_cl_counts,OUT.conditioncounts,OUT.levels{1},'test',OUT.clusternames)
  
return
  
  
  

function [b,a] = getYear(ustudy)
% b is year, a is study
clear a, clear b
for i = 1:length(ustudy)
    a{i} = ustudy{i}(1:end-2);
    b{i} = ustudy{i}(end-2:end);
    
    if strcmp(b{i}(end-1:end),'00') | strcmp(b{i}(end-1:end),'01') | strcmp(b{i}(end-1:end),'02') | ...
            strcmp(b{i}(end-2:end-1),'00') | strcmp(b{i}(end-2:end-1),'01') | strcmp(b{i}(end-2:end-1),'02')
        c = '20';
    else
        c = '19';
    end
    
    if ~(strcmp(b{i}(end),'a') | strcmp(b{i}(end),'b') | strcmp(b{i}(end),'c'))
        b{i} = b{i}(end-1:end);
    end
    b{i} = [c b{i}];
end



return


    
function dummy 
    cl = clusters(i);
    
    for k = 1:length(clusters(i).x)
    
        fprintf(1,['%s\t%3.0f\t%3.0f\t%3.0f\t%3.0f\t'],cl.Study{k},i,cl.x(k),cl.y(k),cl.z(k))
        
        for j = 1:length(fnames)

            eval(['tmp1 = cl.' fnames{j} '(k);'])
            if iscell(tmp1)
                fprintf(1,'%s\t',tmp1{1})
            else
                fprintf(1,'%3.0f\t',tmp1)
            end
            
        end
        
        fprintf(1,'\n')
        
    end
    

return