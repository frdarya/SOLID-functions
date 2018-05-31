%% Find objects for which there are 3 levels of similarity
% in sim_dist input the DI values for the foils (distnace from target)
% data will be saved in 'objects' variable.
%
% (c) Darya Frank & Oliver Gray, May 2018
%% setup
tic
filename = 'Final_Postscaling_Matrices.xls';
sim_distance_1 = 1800;
sim_distance_2 = 2500;
sim_distance_3 = 3200;
acceptablerange = 200;
[~, sheets] = xlsfinfo(filename);
m = 1;

for j = 1:numel(sheets)%for number of sheets
    clear sim_sheet sim lower_sim tmp row column item_1 item_2 item_3 all_items z ;
    sim_sheet = sheets{j}; %reads sheet name
    sim = xlsread(filename, sim_sheet); %imports matrix
    lower_sim = tril(sim,-1);   %takes the lower triangle of values of the matrix. Assigns 0's to upper triangle.
    tmp_1 = abs(lower_sim-sim_distance_1); %finds absolute distance of every matrix value from sim_distance.
    tmp_2 = abs(lower_sim-sim_distance_2);
    tmp_3 = abs(lower_sim-sim_distance_3);
    
    [row_1,column_1] = find(tmp_1<acceptablerange);   %finds the coordinates of all values in tmp within acceptablerange of sim_distance.
    [row_2,column_2] = find(tmp_2<acceptablerange);
    [row_3,column_3] = find(tmp_3<acceptablerange);
    
    item_1 = [row_1,column_1];
    item_2 = [row_2,column_2];
    item_3 = [row_3,column_3];
    try
        [i1,j1] = ndgrid(1:size(item_1,1),1:size(item_1,2));
        [i2,j2] = ndgrid(1:size(item_2,1),(1:size(item_2,2))+size(item_1,2));
        z = accumarray([i1(:),j1(:);i2(:),j2(:)],[item_1(:);item_2(:)]);
        
        [i1,j1] = ndgrid(1:size(z,1),1:size(z,2));
        [i2,j2] = ndgrid(1:size(item_3,1),(1:size(item_3,2))+size(z,2));
        all_items = accumarray([i1(:),j1(:);i2(:),j2(:)],[z(:);item_3(:)]);
        %%
        % grab numbers  that appear in all 3 categories
        [~,~,v] = find(intersect(intersect(all_items(:,1:2),all_items(:,3:4)), all_items(:,5:6)));
        objects(m,1:2) = {v, sheets(j)};
        m = m+1;
    catch
    end
end
save('stim_foils.mat','objects')
toc
