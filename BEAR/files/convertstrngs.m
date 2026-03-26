



% as a preliminary task, fix all the strings that may require it
startdate=fixstring(startdate);
enddate=fixstring(enddate);
varendo=fixstring(varendo);
varexo=fixstring(varexo);
datapath=fixstring(pref.datapath);
if F==1
Fstartdate=fixstring(Fstartdate);
Fenddate=fixstring(Fenddate);
end
if VARtype==4
unitnames=fixstring(unitnames);
end

% first recover the names of the different endogenous variables; 
% to do so, separate the string 'varendo' into individual names
% look for the spaces and identify their locations
findspace=isspace(varendo);
locspace=find(findspace);
% use this to set the delimiters: each variable string is located between two delimiters
delimiters=[0 locspace numel(varendo)+1];
% count the number of endogenous variables
% first count the number of spaces
nspace=sum(findspace(:)==1);
% each space is a separation between two variable names, so there is one variable more than the number of spaces
numendo=nspace+1;
% now finally identify the endogenous
endo=cell(numendo,1);
for ii=1:numendo
endo{ii,1}=varendo(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
end

% proceed similarly for exogenous series; note however that it may be empty
% so check first whether there are exogenous variables altogether
if isempty(varexo==1)
exo={};
% if not empty, repeat what has been done with the exogenous
else
findspace=isspace(varexo);
locspace=find(findspace);
delimiters=[0 locspace numel(varexo)+1];
nspace=sum(findspace(:)==1);
numexo=nspace+1;
exo=cell(numexo,1);
   for ii=1:numexo
   exo{ii,1}=varexo(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
   end
end

% finally, if applicable, recover the names of the different units
if VARtype==4
% look for the spaces and identify their locations
findspace=isspace(unitnames);
locspace=find(findspace);
% use this to set the delimiters: each unit string is located between two delimiters
delimiters=[0 locspace numel(unitnames)+1];
% count the number of units
% first count the number of spaces
nspace=sum(findspace(:)==1);
% each space is a separation between two unit names, so there is one unit more than the number of spaces
numunits=nspace+1;
% now finally identify the units
Units=cell(numunits,1);
   for ii=1:numunits
   Units{ii,1}=unitnames(delimiters(1,ii)+1:delimiters(1,ii+1)-1);
   end 
end


