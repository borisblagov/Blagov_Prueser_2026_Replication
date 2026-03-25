delete([pref.datapath '\results\' pref.results_sub '.xlsx']);


% then copy the blank excel file from the files to the data folder
sourcefile=[pwd '\results.xlsx'];
destinationfile=[pref.datapath '\results\' pref.results_sub '.xlsx'];
copyfile(sourcefile,destinationfile);