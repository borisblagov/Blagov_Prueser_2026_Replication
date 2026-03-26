function [signrestable signresperiods signreslabels]=loadsignres(endo,pref, IRFt)










% preliminary tasks

% identify the number of endogenous variables
numendo=size(endo,1);
% initiate the cells signrestable, signresperiods and signreslabels
signrestable=cell(numendo,numendo);
signresperiods=cell(numendo,numendo);
signreslabels=endo;
% load the data from Excel
% sign restrictions values
[num1 txt1 strngs1]=xlsread('data.xlsx','sign res values');
[num2 txt2 strngs2]=xlsread('data.xlsx','sign res periods');
% replace NaN entries by blanks
strngs1(cellfun(@(x) any(isnan(x)),strngs1))={[]};
strngs2(cellfun(@(x) any(isnan(x)),strngs2))={[]};
% convert all numeric entries into strings
strngs1(cellfun(@isnumeric,strngs1))=cellfun(@num2str,strngs1(cellfun(@isnumeric,strngs1)),'UniformOutput',0);
strngs2(cellfun(@isnumeric,strngs2))=cellfun(@num2str,strngs2(cellfun(@isnumeric,strngs2)),'UniformOutput',0);
% identify the non-empty entries (pairs of rows and columns)
[nerows1 neclmns1]=find(~cellfun('isempty',strngs1));
[nerows2 neclmns2]=find(~cellfun('isempty',strngs2));
% count the number of such entries
neentries1=size(nerows1,1);
neentries2=size(nerows2,1);
% all these entries contrain strings: fix them to correct potential user formatting errors
% loop over entries (value table)
for ii=1:neentries1
strngs1{nerows1(ii,1),neclmns1(ii,1)}=fixstring(strngs1{nerows1(ii,1),neclmns1(ii,1)});
end
% loop over entries (period table)
for ii=1:neentries2
strngs2{nerows2(ii,1),neclmns2(ii,1)}=fixstring(strngs2{nerows2(ii,1),neclmns2(ii,1)});
end


if IRFt==4 % fill in signrestable, signresperiods and signreslabels only if identification scheme is set to sign restrictions


% sign restriction values

% first recover checkalgo, the value determining whether the algorithm should be checked at some point
% if strcmp(strngs1{2,6},'yes')
% checkalgo=1;
% else
% checkalgo=0;
% end
% % recover the number of iterations at which the algorithm has to be checked
% if checkalgo==1
% checkiter=str2num(strngs1{3,6});
%    % if the value is non-numeric, return an error
%    if isempty(checkiter)
%    message='Sign restriction error: the number of iterations at which the algorithm must be checked is either empty or non-numerical. Please verify that the ''sign res values'' sheet of the Excel data file is properly filled.';
%    msgbox(message);
%    error('programme termination: sign restriction error');   
%    end
% end
% recover the rows and columns of each endogenous variable
% loop over endogenous variables
for ii=1:numendo
% for each variable, there should be two entries in the table corresponding to its name
% one is the column lable, the other is the row label
[r,c]=find(strcmp(strngs1,endo{ii,1}));
   % if it is not possible to find two entries, return an error
   if size(r,1)<2
   message=['Sign restriction error: endogenous variable ' endo{ii,1} ' cannot be found in both rows and columns of the table. Please verify that the ''sign res values'' sheet of the Excel data file is properly filled.'];
   msgbox(message);
   error('programme termination: sign restriction error');   
   end
% otherwise, the greatest number in r corresponds to the row of the column labels: record it
rows(ii,1)=max(r);
% the greatest number in c corresponds to the column of the row labels: record it
clmns(ii,1)=max(c);
end
% now recover the values for the cell signrestable
% loop over endogenous (rows)
for ii=1:numendo
   % loop over endogenous (columns)
   for jj=1:numendo
   signrestable{ii,jj}=strngs1{rows(ii,1),clmns(jj,1)};
   end
end
% check whether the restriction table is valid: return an error if the the column requirement for zero restrictions is not satisfied
% loop over columns
for ii=1:numendo
% count the number of zero restrictions in this column
numzerores=sum(strcmp(signrestable(:,ii),'0'));
   % if there are too many zero restrictions for the column, return an error
   if numzerores>numendo-ii
   temp=['Zero restriction issue: you have requested ' num2str(numzerores) ' zero restrictions in column ' num2str(ii) ' of the restriction matrix, but at most ' num2str(numendo-ii) ' such restrictions can be implemented.'];
   msgbox(temp);
   error('Zero restriction error');
   end
end





% sign restriction periods

% recover the rows and columns of each endogenous variable
% loop over endogenous variables
for ii=1:numendo
% for each variable, there should be two entries in the table corresponding to its name
% one is the column lable, the other is the row label
[r,c]=find(strcmp(strngs2,endo{ii,1}));
   % if it is not possible to find two entries, return an error
   if size(r,1)<2
   message=['Sign restriction error: endogenous variable ' endo{ii,1} ' cannot be found in both rows and columns of the table. Please verify that the ''sign res periods'' sheet of the Excel data file is properly filled.'];
   msgbox(message);
   error('programme termination: sign restriction error');   
   end
% the greatest number in r corresponds to the row of the column labels: record it
rows(ii,1)=max(r);
% the greatest number in c corresponds to the column of the row labels: record it
clmns(ii,1)=max(c);
end
% now recover the values for the cell signresperiods
% loop over endogenous (rows)
for ii=1:numendo
   % loop over endogenous (columns)
   for jj=1:numendo
   % record the value
   signresperiods{ii,jj}=str2num(strngs2{rows(ii,1),clmns(jj,1)});
   end
end

% recover the labels, if any
% initiate
signreslabels=cell(numendo,1);
% loop over endogenous (columns)
for ii=1:numendo
% the label for shock ii is found in strngs2, row 3 and column 'clmns(ii,1)'
temp=strngs1{4,clmns(ii,1)};
   % if empty, give the generic name 'shock ii'
   if isempty(temp)
   signreslabels{ii,1}=['shock ' num2str(ii)];
   % else, record the name
   else
   signreslabels{ii,1}=temp;
   end
end

else
    checkalgo = [];
    checkiter = [];
    
end

% finally, record on Excel
if pref.results==1
    xlswrite([pref.datapath '\results\' pref.results_sub '.xlsx'],strngs1,'sign res values','B2');
    xlswrite([pref.datapath '\results\' pref.results_sub '.xlsx'],strngs2,'sign res periods','B2');
end
























