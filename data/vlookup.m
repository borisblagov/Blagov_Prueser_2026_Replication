function [str_out, str_idx] = vlookup(str_in,in_cell,col_out)
%%-----------------------------------------------------------------------------------------------------%%
%   [str_out, str_idx] = vlookup(str_in,in_cell,col_out)
% This is a VLOOKUP function for Matlab.
%   It takes a cell array of strings, searches for a string "str_in" and returns a value on the same row
%   as "str_in" from column "col_out"
%   INPUT: 
%           [1] str:        String: String to search for
%           [2] in_cell:    Cell;   The cell array of strings
%           [3] col_out:    Number, The column from which the output should be returned
%
%   OUTPUT:
%           [1] str_out:    The string from column 'col_out' that corresponds to the same row as 'str_in'
%           [2] str_idx:    The index of the row
%-------------------------------------------------------------------------------------------------------%
% Written by:   Boris Blagov
% Date:         22.01.2017
% Last change:  20.03.2017
%-------------------------------------------------------------------------------------------------------%


[str_idx, ~]   = find(ismember(in_cell,str_in));
if isempty(str_idx)
    fprintf('ERROR (vlookup.m): the requested string %s is not present in the table',str_in);
    str_out = str_idx;
else
    str_out        = in_cell{str_idx,col_out};
end