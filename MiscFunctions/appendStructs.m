function S_out = appendStructs(S1,S2)
% S_out = APPENDSTRUCTS(S1,S2)
% Merge two struct arrays and return a single struct containing the fields
% of the two. If any fields have overlapping names, the data from S1 is
% replaced with the data from S2. Input structs must have the same
% dimensions.
%
% S_out = APPENDSTRUCTS(S1,{S2,...,Sn-1,Sn})
% Append multiple structs at once. Structs are appended in descending
% order, such that Sn values will overwrite Sn-1 values. This is done 
% recursively, so be cautions with very large struct arrays potentially
% causing memory issues.

p = inputParser;
addRequired(p,'S1',@(x) isstruct(x));
addRequired(p,'S2',@(x) isstruct(x) || iscell(x));
addOptional(p,'otherStructs',[]);
parse(p,S1,S2);

% Recursively run this on all but the first struct input, until we are left
% with only two structs to append.
if iscell(p.Results.S2)
    if length(p.Results.S2)>1
        S2 = appendStructs(p.Results.S2{1},p.Results.S2(2:end));
    else
        S2 = p.Results.S2{:};
    end
else
    S2 = p.Results.S2;
end

S1 = p.Results.S1;

if any(size(S1) ~= size(S2))
    error('All input structs must be the same size');
end
S1_fnames = fieldnames(S1);
S2_fnames = fieldnames(S2);


S_out = S2;
for i = 1:length(S1_fnames)
    if ~ismember(S1_fnames{i},S2_fnames)
        S_out.(S1_fnames{i}) = S1.(S1_fnames{i});
    end
end