%% Find three values with equal dissimilarity 
%
% loads similarity matrix files, find image triplets where all similarities 
% are within specified range of a specified value, outputs a file for each  
% matrix with dissimilarity values and coordinates of applicable triplets.
% 
% Detailed explanation of variables:
% tmp = matrix of absolute distances from value defined (sim_distance)
% column = how many times in a column is there a value of less than acceptable change?
% The value is the column coordinate, count is the # of repeats.
% row = row coordinate in which the acceptable change value appeared 
% triplets = 1st, 2nd, and 3rd comparisons and their coordinates
% 
% (c) Oliver Gray & Darya Frank, May 2018
%
%% def similarity distances
clear
tic
filename = 'Final_Postscaling_Matrices.xls';
sim_distance = 900;
acceptablerange = 100;
%% find closest triplets
header = {'column', 'row1', 'row2', 'Dist_col_row1', 'Dist_col_row2', 'Dist_row1_row2'};
[a, sheets] = xlsfinfo(filename);
for j = 1:numel(sheets)%for number of sheets
    clear sim_sheet sim lower_sim tmp row column m n f i x y c aa d e third triplets;
    sim_sheet = sheets{j}; %reads sheet name
    sim = xlsread(filename, sim_sheet); %imports matrix   
    lower_sim = tril(sim,-1);   %takes the lower triangle of values of the matrix. Assigns 0's to upper triangle.
    tmp = abs(lower_sim-sim_distance); %finds absolute distance of every matrix value from sim_distance.
    [row,column] = find(tmp<acceptablerange);   %finds the coordinates of all values in tmp within acceptablerange of sim_distance.
    m = 1;
    nextline = 1;
    RowValuesAssessed = 0;
    for i = 1:size(tmp,1)-2     %loops through every column (by counting the number of rows) of matrix.
        try
            [x,y] = find(column==i);        %identifies which rows in each tmp column are within the acceptablerange.
            CombinationMatrix = sort(combnk(1:length(x),2),2);      %produces a matrix with the coordinates that should be assessed in the 'third' comparison. Requires at least 2 values - if only 1 is within range, error is produced and next column will be assessed.
            for aa = 1:length(CombinationMatrix)  %loops through number of combinations.
                First = CombinationMatrix(aa,1);    %selects 1st/2nd/3rd/...row within acceptable range in column.
                Second = CombinationMatrix(aa,2);    %selects 2nd/3rd/...row within acceptable range in column.
                third = tmp(row(RowValuesAssessed+Second),row(RowValuesAssessed+First));     %finds dissimilarity of third comparison.  
                if third < acceptablerange
                    %stores value of 1st, 2nd, and 3rd comparisons and their coordinates
                    triplets(nextline,m:m+5) = [i, row(RowValuesAssessed+First), row(RowValuesAssessed+Second), lower_sim(row(RowValuesAssessed+First),i), lower_sim(row(RowValuesAssessed+Second),i),lower_sim(row(RowValuesAssessed+Second),row(RowValuesAssessed+First))];
                    nextline=nextline+1;
                end
            end
        catch
        end
        RowValuesAssessed = RowValuesAssessed + length(x);  %stores number of values with acceptablerange in other columns. Enables targeting of correct value in row vector.
    end
    try
        triplets = cell2table(num2cell(triplets),'VariableNames',header);
        writetable(triplets,strcat('triplets_', sim_sheet,'.csv'));
    catch
    end
end
toc
