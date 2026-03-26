function [T_out, date_vec] = usetable(T_in,varargin)
%%-----------------------------------------------------------------------------------------------------%%
% This is a multi-purpose function that accommodates a table, such as an excel table to be used for
% time series analysis. The function can plot the data in the table, shorten or expand the table based on
% NaNs and do standard transformations such as seasonal adjustment, logs, and first differences.
% It works with monthly or quarterly data. The general syntax is usetable(table_in,Options). For the options
% see below
%
%   INPUT:
%           [1]  T: A table or a cell array of tables
%             The table(s) may have a
%               "Description":      String. Will be used as a title
%               "VariableNames":    Used for the legend if the names are simple. Else see "VariableUnits"
%               "VariableUnits":    Cell array of strings. Will be used for a legend when variable names
%                                   are complex, such as '\delta y'.
%               "RowNames":         Cell array of strings OR Numbers. Used to label the x-axis
%               "UserData":         An "Opt" entry with settings for plotting such as fName, fSize, etc.
%
%           Optional input arguments:
%             [1] 'inputformat' :   Date format. Use this if Matlab has trouble reading the dates. For example,
%                                   if you have American dates (MM/DD/YYYY), while Matlab thinks you use European
%                                   dates due to your regional settings (DD/MM/YYYY). In that case you
%                                   would call the fucntion "out_table = usetable(in_table,'inputformat','MM/dd/yyyy')";
%                                   Type "doc datenum" to see optional formats.
%             [1] 'start','Date':   Beginning date to shorten the sample, default is the full sample.
%                                   For 'Date' use a number 1995.25 (without quotes) or '1995Q2' for quarterly
%                                   data and '1995M2' for monthly.
%                                   Example: usetable(table_in,'start',1995.25) or usetable(figtab,'start','1995Q2')
%             [2] 'end','Date':     Beginning date to shorten the sample, default is the full sample.
%                                   For 'Date' use a number 2015.75 (without quotes) or '2015Q4' for quarterly
%                                   data and '2015M11' for monthly.
%                                   Example: usetable(table_in,'end',2015.75) or usetable(figtab,'end','2015Q4')
%             [3] 'plot':           Plots the data.If the input is a cell array of tables it will plot graph
%                                   with subplots.
%                 'cdf','inputformat': "Change date format". Changes the RowNames to a date of your choice specified
%                                   by the input forrmat. !!!!!!!% I need to make
%                                   this outputformat!!!!!
%                 'subplot_dim'     [N,M] Custom subplot dimensions if the input for plotting is a cell
%                                   array of tables
%             [4] Transformations
%                 [+] 'seas':       Seasonally adjusts the table (before doing any other transformation).
%                                   Requires the 'X-13 Toolbox for Matlab, Version 1.3', Mathworks File
%                                   Exchange, 2016 by Yvan Lengwiler
%                 [+] 'log':        Takes logs of all variables.
%                 [+] 'logdiff':    Takes the x_t - x_{t-1} log difference of all variables, in percent.
%                 [+] 'logdiff_4':  Takes the x_t - x_{t-4} log difference of all variables, in percent.
%                 [+] 'logdiff_12': Takes the x_t - x_{t-12} log difference of all variables, in percent.
%                 [+] 'fdiff':      Takes the first difference of the variables.
%                 [+] 'fdiff_12':   Takes the twelfth difference of the variables.
%                 [+] 'notperc':    Divides by hundred, if the logdiff or fdiff weren't needed.
%                 [+] 'perc':    	Multiplies by a hundred.
%             [4] Dealing with NaN
%                 [+] 'NaNbalanced':Outputs a balanced panel without NaNs.
%                 [+] 'NaNfull':    Outputs a panel with NaNs (but still removes initial NaN values
%                                   common NaNs.)
%
%   OUTPUT:
%           [1] T_out: A table with the selected variables and time span
%
%   REQUIREMENTS:
%           [+] seas(table_in):     for Seasoal Adjustment. See 'X-13 Toolbox for Matlab, Version 1.3', Mathworks
%               File Exchange, 2016 by  Yvan Lengwiler
%           [+] time2serial(time):  for extacting datenum dates from time vectors
%           [+] beauty:             for plotting
%-------------------------------------------------------------------------------------------------------%
% Examples:
%           data_tab = usetable(HICP,'start',1995.25,'plot')
%           data_tab = usetable(HICP,'logdiff')
%           data_tab = usetable(HICP,'NaNfull','plot')
%-------------------------------------------------------------------------------------------------------%
% Written by:   Boris Blagov
% Date:         19.09.2016
%               18.06.2018              % Added dateformat as an input option
% Last change:  02.01.2019              % Added custom subplot size if input is a cell
% Version:      1.69
%% This section initiates the function
if istable(T_in)
    plot_idx    = 1;
    tIn_c{1}    = T_in;
    subplot_dim = [1,1];
elseif iscell(T_in)
    tIn_c = T_in;
    %     tIn_c = tIn_c';
    plot_idx = size(tIn_c,1)*size(tIn_c,2);
    %% Optional argument 'subplot_dim'
    if ~isempty(find(strcmp(varargin,'subplot_dim'),1))                % Changes the default plot settings
        subplot_dim     = varargin{find(strcmp(varargin,'subplot_dim'),1)+1};
    else
        subplot_dim     = [size(tIn_c,1),size(tIn_c,2)];
    end  
    tOut_c = cell(size(tIn_c));
end


%% This is the main loop over the tables, if they are in a cell
for ig = 1:plot_idx
    T                 = tIn_c{ig};
    T_t               = size(T,1);
    T_n               = size(T,2);
    start_ind         = 1;                                      % Default start date index. If 'start' property is missing it is set to 1
    end_ind           = T_t;                                    % Default end date index. If 'end' property is missing it is set to "end"
    Plot              = 0;                                      % Default plot settings; 0 is 'off'
    
    if ~isempty(T.Properties.UserData)
        figP = T.Properties.UserData;
    end
    
    %% Optional argument 'plot'
    if ~isempty(find(strcmp(varargin,'plot'),1))                % Changes the default plot settings
        Plot = 1;
        %     elseif ~isempty(find(strcmp(varargin,'Plot'),1))            % Changes the default plot settings
        %         Plot = 1;
    end
    
    %% Optional argument 'cdf'
    if ~isempty(find(strcmp(varargin,'cdf'),1))                % Changes the default plot settings
        chdf = 1;
        outputformat     = varargin{find(strcmp(varargin,'cdf'),1)+1};
    else
        chdf = 0;
    end 
    %% Optional argument 'dateformat'
    if ~isempty(find(strcmp(varargin,'inputformat'),1))               % Changes the default date format
        inputformat     = varargin{find(strcmp(varargin,'inputformat'),1)+1};
        noformat        = 0;
    elseif isstruct(T.Properties.UserData) && isfield(T.Properties.UserData,'inputformat')
        inputformat     = T.Properties.UserData.inputformat;
        noformat        = 0;
    else
        noformat        = 1;
    end
    %% Optional argument 'start','Date'
    if ~isempty(find(strcmp(varargin,'start'),1))               % Changes the default starting date settings
        if noformat
            [date_vec_in,freq]    = date_extract(T_in);
        else
            [date_vec_in,freq]    = date_extract(T_in,inputformat);
        end
        start_date     = varargin(find(strcmp(varargin,'start'),1)+1);
        if ischar(start_date{1})                                % Check if it is a string or a number
            if freq == 1                                        %   If string and quarterly data
                startd_num = str2double(start_date{1}(1:4))+str2double(start_date{1}(end))*0.25-0.25;
                start_ind  = find(date_vec_in==startd_num);
            else                                                %   If string and monthly data
                startd_dnum = datenum(str2double(start_date{1}(1:4)),str2double(start_date{1}(end)),1);
                datenum_vec = time2serial(date_vec_in);
                start_ind  = find(datenum_vec==startd_dnum);
            end
        else                                                    % If it is a number...
            if freq == 1                                        %   for quaterly data simply find it in date_vec_in
                start_ind  = find( date_vec_in == start_date{1} );
            end
        end
        
        if isempty(start_ind)                                   % If after all this "start_ind" is empty - ERROR!
            disp('The starting date could not be found, resetting to the first observation');
            disp('Are you using quarterly data? If yes, choose start in the format of "2015.25" (Q2)')
            disp('Also make sure that the date is in the table')
            disp('If you are using monthly data, use the convention "2015M12" for Dec. 2015')
            disp('Resetting to the first observation')
            start_ind = 1;
        end
    end
    
    %% Optional argument  'end','Date'
    if ~isempty(find(strcmp(varargin,'end'),1))               % Changes the default starting date settings
        if noformat
            [date_vec_in,freq]    = date_extract(T_in);
        else
            [date_vec_in,freq]    = date_extract(T_in,inputformat);
        end
        end_date     = varargin(find(strcmp(varargin,'end'),1)+1);
        if ischar(end_date{1})                                % Check if it is a string or a number
            if freq == 1                                        %   If string and quarterly data
                endd_num = str2double(end_date{1}(1:4))+str2double(end_date{1}(end))*0.25-0.25;
                end_ind  = find(date_vec_in==endd_num);
            else                                                %   If string and monthly data
                endD_dnum = datenum(str2double(end_date{1}(1:4)),str2double(end_date{1}(end)),1);
                datenum_vec = time2serial(date_vec_in);
                end_ind  = find(datenum_vec==endD_dnum);
            end
        else                                                    % If it is a number...
            if freq == 1                                        %   for quaterly data simply find it in date_vec_in
                end_ind  = find( date_vec_in == end_date{1} );
            end
        end
        
        if isempty(end_ind)                                   % If after all this "end_ind" is empty - ERROR!
            disp('The ending date could not be found, resetting to the first observation');
            disp('Are you using quarterly data? If yes, choose start in the format of "2015.25" (Q2)')
            disp('Also make sure that the date is in the table')
            disp('If you are using monthly data, use the convention "2015M12" for Dec. 2015')
            disp('Resetting to the last observation')
            end_ind = T_t;
        end
    end
    
    
    %     if ~isempty(find(strcmp(varargin,''),1))                 % Changes the default starting date settings
    %         figP      = varargin{find(strcmp(varargin,'figP'),1)+1};
    %     end
    
    %% Transformations
    if      ~isempty(find(strcmp(varargin,'seas'),1))
        T = seas(T);
    end
    
    if      ~isempty(find(strcmp(varargin,'log'),1))
        T{:,:} = log(T{:,:});
    elseif ~isempty(find(strcmp(varargin,'logdiff'),1))                             % Growth rate t vs. t-1
        T{:,:} = [NaN(1,T_n);  (T{2:end,:} - T{1:end-1,:})./T{1:end-1,:}*100];
    elseif ~isempty(find(strcmp(varargin,'logdiff_4'),1))                           % Growth rate t vs. t-4
        T{:,:} = [NaN(4,T_n);  (T{5:end,:} - T{1:end-4,:})./T{1:end-4,:}*100];
    elseif ~isempty(find(strcmp(varargin,'logdiff_12'),1))                          % Growth rate t vs. t-12
        T{:,:} = [NaN(12,T_n); (T{13:end,:} - T{1:end-12,:})./T{1:end-12,:}*100];
    elseif ~isempty(find(strcmp(varargin,'fdiff'),1))
        T{:,:} = [NaN(1,T_n);  ( T{2:end,:} - T{1:end-1,:} )];
    elseif ~isempty(find(strcmp(varargin,'fdiff_12'),1))
        T{:,:} = [NaN(12,T_n); ( T{13:end,:} - T{1:end-12,:} )];
    end
    
    if     ~isempty(find(strcmp(varargin,'notperc'),1))
        T{:,:} = T{:,:}/100;
    elseif ~isempty(find(strcmp(varargin,'perc'),1))
        T{:,:} = T{:,:}*100;
    end
    
    
    
    %% Taking care of NaNs
    % We go column by column and look for missing observations. If we find such we record the
    % index of the first data point after the missing obs. and cut the data by deleting all
    % dates with "NaN" observations.
    nan_ind = ones(2,T_n);
    
    for ii = 1:T_n
        %     if  isempty(find(~isnan(T{:,ii})==1,1))
        %         disp('The table contains only NaNs');
        %         T_out = [];
        %         return
        %     end
        nan_ind(1,ii) = find(~isnan(T{:,ii})==1,1);
        nan_ind(2,ii) = find(~isnan(T{:,ii})==1,1,'Last');
    end
    
    if ~isempty(find(strcmp(varargin,'NaNbalanced'),1))
        start_ind   = max([nan_ind(1,:),start_ind]);
        end_ind     = min([nan_ind(2,:),end_ind]);
        T_out       = T(start_ind:end_ind,:);
    elseif ~isempty(find(strcmp(varargin,'NaNfull'),1))
        start_ind   = max([min(nan_ind(1,:)),start_ind]);
        end_ind     = min([max(nan_ind(2,:)),end_ind]);
        T_out       = T(start_ind:end_ind,:);
    elseif ~isempty(find(strcmp(varargin,'NaNRGDP'),1))
        start_ind   = max([min(nan_ind(1,:)),start_ind]);
        end_ind     = find(~isnan(T.RGDP),1,'Last');
        vars_include_logical    = (nan_ind(2,:)>=end_ind);
        vars_incldue_number     = 1:size(vars_include_logical,2);
        vars_include_final      = nonzeros(vars_incldue_number.*vars_include_logical)';
        T_out       = T(start_ind:end_ind,[vars_include_final]);
    else
        T_out       = T(start_ind:end_ind,:);
    end
    if noformat
        [date_vec, freq] = date_extract(T_out);
    else
        [date_vec, freq] = date_extract(T_out,inputformat);     
    end
    tOut_c{ig} = T_out;
    
    %% This section plots the data
    if Plot
        if ig == 1
            fighnd = figure;
        end
        subplot(subplot_dim(1),subplot_dim(2),ig);
        if freq ~= -1
            datenum_vec = time2serial(date_vec);
            plot(datenum_vec,tOut_c{ig}{:,:});      % datetick('x',27)
        else
            plot(date_vec,tOut_c{ig}{:,:});
        end
        title(T.Properties.Description);
        if size(tOut_c{ig},2)>1
            if ~isempty(T.Properties.VariableUnits)
                figP.hleg = legend(T.Properties.VariableUnits);
            else
                figP.hleg = legend(T.Properties.VariableNames);
            end
        elseif isempty(T.Properties.Description)
            title(T.Properties.VariableNames{1})
        end
        if exist('figP','var') && isfield(figP,'legendoff')
            legend off
        end
        suchbeauty
%                 beautyfig
       if freq == 1
            datetick('x','YY-QQ','keeplimits');
        elseif freq == 0
            datetick('x','mm/yy');
        end
    end
    %% This section changes the date format of the first row of the table
    if chdf
        datenum_vec = time2serial(date_vec);
        T_out.Properties.RowNames = cellstr(datestr(datenum_vec,outputformat));
        T_out.Properties.UserData.inputformat = strrep(outputformat,'mm','MM');
    end
end

function [f_date, freq] = date_extract(T,varargin)
% Create a date vector from the first row from the Table.Properties.RowNames.
% "freq" returns 1 for quarterly frequency and 0 for monthly frequency
% Varargin is the formatting of dates, if you are not using the US locale (MM/DD/YYYY). Then,
% when calling the function use the one which you see in the table T. See the available by
% typing "doc datenum"

% Date formt options for the RowNames
%   To add your own add it before the final "else... try" statement as an "elseif"
%   0: They do not exist
%   1: "1995.25" a number denoting 1995Q2
%   2: "Q2/95" FERI's convention
%   3: "1995Q2" Eviews' convention
%   4: "1995M2" Eviews' convention
%   5: "Jun'95' FERI's monthly convention
%   6: "01.03.2015" Macrobond format
%   7: "01.03.15" Monthly format of Excel dates which were not converted to Unicode
%   10: "30-Jun-1995" a datestr entry (Unicode date as in Excel or Matlab date)

if isempty(T.Properties.RowNames)
    dateformat = 0;
    freq       = -1;
else
    t_first_obs = T.Properties.RowNames{1};
    if ~isnan(str2double(t_first_obs))                  % Is this a number?
        dateformat = 1;
        t_second_obs = T.Properties.RowNames{2};
        if str2double(t_second_obs) - str2double(t_first_obs) == 0.25
            freq = 1;
        else
            freq = 0;
        end
    elseif size(t_first_obs,2) == 5 && strfind(t_first_obs,'/')==3 && ~isempty(str2double(t_first_obs(:,end-1:end)))
        %   2: "Q2/95" FERI's convention
        dateformat = 2;
        freq = 1;
    elseif size(t_first_obs,2) == 6 && ~isempty(strfind(t_first_obs,'Q')==5)
        %   3: "1995Q2" Eviews' convention
        dateformat = 3;
        freq = 1;
    elseif size(t_first_obs,2) == 7 && ~isempty(strfind(t_first_obs,'M')==5)
        dateformat = 4;
        freq = 0;
    elseif size(t_first_obs,2) == 6 && strfind(t_first_obs,'''')==4 && ~isempty(str2double(t_first_obs(:,end-2:end-1)))
        dateformat = 5;
        freq = 0;
    elseif size(t_first_obs,2) == 10 && size(strfind(t_first_obs,'.'),2) == 2
        t_second_obs = T.Properties.RowNames{2};
        dateformat = 6;
        if str2double(t_second_obs(4:5))-str2double(t_first_obs(4:5)) == 1
            freq = 0;
        elseif str2double(t_second_obs(4:5))-str2double(t_first_obs(4:5)) == 3
            freq = 1;
        end
    else
        try datestr(t_first_obs);
            dateformat = 10;
            if ~isempty(varargin)
                inputformat = varargin{1};
                noformat = 0;
            else
                noformat = 1;
            end
        catch
            disp('Unknown date format in RowNames. If you want to add  your own type "open usetable"')
            disp('and add your convention at the bottom as a "dateformat"')
        end
    end
end
T_t           = size(T,1);
% quart_list      = {'.00' 'Q1' '31-Mar-';...
%     '.25' 'Q2' '30-Jun-';...
%     '.50' 'Q3' '30-Sep-';...
%     '.75' 'Q4' '31-Dec-'} ;

%         quart_dt = vlookup(t_first_obs(1,1:2),quart_list,3);
switch dateformat
    case 0
        f_date = 1:T_t;
    case 1
        f_date       = str2double(T.Properties.RowNames);
    case 2
        year_digits  = str2double(t_first_obs(1,end-1:end));    % Reads the year digits from a date of the form "Q2/95"
        quart_st     = -0.25 + str2double(t_first_obs(1,2))*0.25; % Reads the quarter digits
    case 3
        year_digits  = str2double(t_first_obs(1,3:4));          % Reads the year digits from a date of the form "1995Q2"
        quart_st     = -0.25 + str2double(t_first_obs(1,end))*0.25; % Reads the quarter digits
    case 4
        year_digits  = str2double(t_first_obs(1,3:4));          % Reads the year digits from a date of the form "1995M2"
        month_st     = str2double(t_first_obs(1,end));          % Reads the month's digits
    case 5
        year_digits   = str2double(t_first_obs(1,end-1:end));  % Reads the year digits from a date of the form "Jan'90"
        
        Months       = {'Jan'; 'Feb'; 'Mar'; 'Apr'; 'May'; 'Jun'; 'Jul'; 'Aug'; 'Sep'; 'Oct'; 'Nov'; 'Dec'}; % Creates a cell array with the months in three digit codes
        month_digits = t_first_obs(1,1:3);                     % Reads the first three letters for the month
        month_st      = find(strcmp(month_digits,Months)==1);               % Finds the index, i.e. Dec = 12
    case 6
        year_digits  = str2double(t_first_obs(1,end-1:end));
        if freq == 0
            month_st = str2double(t_first_obs(1,4:5));
        elseif freq == 1
            quart_st     = -0.25 + ceil(str2double(t_first_obs(1,4:5))/3)*0.25; % ceil([1 4 7 10]/3) gives you the quarters
        end
    case 10
        if noformat
            year_st     = year(datetime(t_first_obs));
            t_second_obs = T.Properties.RowNames{2};
        else
            t_first_obs = datetime(t_first_obs,'InputFormat',inputformat);
            year_st     = year(t_first_obs);
            t_second_obs = T.Properties.RowNames{2};
            t_second_obs = datetime(t_second_obs,'InputFormat',inputformat);
        end
        mnth2       = month(datetime(t_second_obs));
        mnth        = month(datetime(t_first_obs));
        if mnth2 - mnth == 1
            freq = 0;
            month_st = month(datetime(t_first_obs));
        else
            freq = 1;
            quart_st = ceil(mnth/3)*0.25-0.25;
        end
end

if exist('year_digits','var')
    if year_digits > 30                                                 % Extends the year digits to a full date, i.e. 76 into 1976
        year_st      = year_digits + 1900;
    else
        year_st      = year_digits + 2000;
    end
end

if exist('quart_st','var')
    f_date_start = year_st+quart_st;
    f_date_end   = f_date_start + T_t/4 - 0.25;                         % End date
    f_date       = f_date_start:0.25:f_date_end;                        %
    freq = 1;
end

if exist('month_st','var')
    f_date_start = year_st + 1/12*month_st - 1/12;                      % Start date, 1976 is Jan, 1976+1/12 is Feb, etc. This is why we need the "- 1/12"
    f_date_end   = f_date_start + T_t/12 - 1/12;                        % End date
    f_date       = f_date_start:1/12:f_date_end;
    freq = 0;
end

if size(f_date,2)~=1
    f_date = f_date';
end

%% Changelog

