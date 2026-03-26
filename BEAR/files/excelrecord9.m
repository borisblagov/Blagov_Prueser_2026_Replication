
% script excelrecord9
% records the information contained in the worksheet 'shocks' of the excel spreadsheet 'results.xls'



% create the cell that will be saved on excel
shockcell={};

% build preliminary elements: space between the tables
vertspace=repmat({''},size(stringdates1,1)+3,1);

% loop over variables (horizontal dimension)
for ii=1:n
% create cell of shock record for variable ii
   % if a sign restriction identification scheme has been used, use the structural shock labels
   if IRFt==4
   temp=['structural shock: ' signreslabels{ii,1}];
   % otherwise, the shocks are just orthogonalised shocks from the variables: use variable names
   else
   temp=['structural shock: ' endo{ii,1}];
   end
sshock_i=[temp {''} {''} {''};{''} {''} {''} {''};{''} {'lw. bound'} {'median'} {'up. bound'};stringdates1 num2cell(strshocks_estimates{ii,1}')];
shockcell=[shockcell sshock_i vertspace];
end

% trim
shockcell=shockcell(:,1:end-1);

% write in excel
if pref.results==1
xlswrite([pref.datapath '\results\' pref.results_sub '.xlsx'],shockcell,'shocks','B2');
end











