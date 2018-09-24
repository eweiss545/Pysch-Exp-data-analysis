% CLPS1590 - Visualizing Vision
% Spring 2018
% Elena Weissmann
% MATLAB Code for Shape Perception Experiment

%% Section 0: Loading data files

% For this tutorial, we are only loading one file, which contains data from multiple subjects.
% For your project, you likely have multiple participant files, 'subj1.txt'-'subjN.txt',
%  so the FOPEN-TEXTSCAN-FCLOSE sequence below will need to be executed in a loop, once for each file.
% This will load the data file-by-file into one CELL ARRAY object.
% Uncomment the indicated lines to enable the loop.

% Initialize a bunch of empty vectors in a 1 X nCol cell array (nCol = number of columns in your output files)  
% This structure will accumulate the data from multiple files
% It must be initialized before the loop, otherwise it would repeatedly overwrite itself

close all
clear
datadir ='\\files.brown.edu\Home\mrmus\Desktop\clps1590\attachments';
data{1,10} = [];
fileVec = dir('subj*'); % UNCOMMENT for multiple files
numsubs = size(fileVec);
numsubs = numsubs(1);
%% Section 1: LOAD THE DATA

allData = [];
tableAllData = [];
% Loop the loading sequence, incrementing f on each loop iteration to get the filenames from fileVec one by one
for f = 1:numsubs % UNCOMMENT for multiple files
    
    allData = [];

    
    data = importdata(fileVec(f).name);
    subnumber = data.data(:,1);
    trial = data.data(:,2);
    image1 = data.data(:,3);
    image1tex = data.data(:,4);
    image1shape = data.data(:,5);
    image1scene = data.data(:,6);
    image2 = data.data(:,7);
    image2tex = data.data(:,8);
    image2shape = data.data(:,9);
    image2scene = data.data(:,10);
    answer = data.data(:,11);
    RT = data.data(:,12);
    

    
    Img1eqImg2 = image1shape == image2shape; 
    SameDiffScene = image1scene == image2scene;
    Accuracy = answer == Img1eqImg2;

    allData = [subnumber,...
        trial,...
        image1,...
        image1tex,...
        image1shape,...
        image1scene,...
        image2,...
        image2tex,...
        image2shape,...
        image2scene,...
        answer,...
        RT,...
        Img1eqImg2,...
        Accuracy,...
        SameDiffScene,...
        ];
   
    
   tableAllData = [tableAllData;allData]; 
    
end
    
TBL_HDR = {'subject',' trial',' image1',' image1tex',' image1shape' ,...
    ' image1scene',' image2',' image2tex',' image2shape',' image2scene',...
    ' answer',' RT','img1shapeimg2shape','Accuracy','SameDiffScene' };
tableAllData1 = array2table(tableAllData); 
tableAllData1.Properties.VariableNames = TBL_HDR;
keyboard;
%% Section 2: Analyze Means 

% Mean accuracy and reaction times per subject over 324 trials
meansBySub = grpstats(tableAllData1,{'subject'},{'mean'},'DataVars',{'Accuracy'}); % gives the mean accuracy per subject over trials
meansBySubRT = grpstats(tableAllData1,{'subject'},{'mean'},'DataVars',{'RT'}); % gives the mean RT per subject over trials


meansBySub_spec_same = grpstats(tableAllData1(tableAllData1.image1tex== 0 & tableAllData1.image2tex == 0 & tableAllData1.SameDiffScene==1,:),{'subject'},{'mean'},'DataVars',{'Accuracy'});
meansBySub_mat_same = grpstats(tableAllData1(tableAllData1.image1tex== 1 & tableAllData1.image2tex == 1& tableAllData1.SameDiffScene==1,:),{'subject'},{'mean'},'DataVars',{'Accuracy'});
meansBySub_mixed_same = grpstats(tableAllData1(tableAllData1.image1tex == 1 & tableAllData1.image2tex == 0 & tableAllData1.SameDiffScene==1 | tableAllData1.image1tex == 0 & tableAllData1.image2tex ==1 & tableAllData1.SameDiffScene==1 ,:),{'subject'},{'mean'},'DataVars',{'Accuracy'});

meansBySub_spec_diff = grpstats(tableAllData1(tableAllData1.image1tex== 0 & tableAllData1.image2tex == 0& tableAllData1.SameDiffScene==0,:),{'subject'},{'mean'},'DataVars',{'Accuracy'});
meansBySub_mat_diff = grpstats(tableAllData1(tableAllData1.image1tex== 1 & tableAllData1.image2tex == 1& tableAllData1.SameDiffScene==0,:),{'subject'},{'mean'},'DataVars',{'Accuracy'});
meansBySub_mixed_diff = grpstats(tableAllData1(tableAllData1.image1tex == 1 & tableAllData1.image2tex == 0 & tableAllData1.SameDiffScene==0 | tableAllData1.image1tex == 0 & tableAllData1.image2tex ==1 & tableAllData1.SameDiffScene==0 ,:),{'subject'},{'mean'},'DataVars',{'Accuracy'});

acc_mat = [mean(meansBySub_spec_same.mean_Accuracy),mean(meansBySub_spec_diff.mean_Accuracy); 
    mean(meansBySub_mat_same.mean_Accuracy),mean(meansBySub_mat_diff.mean_Accuracy);
     mean(meansBySub_mixed_same.mean_Accuracy),mean(meansBySub_mixed_diff.mean_Accuracy)];
sem_mat = [std(meansBySub_spec_same.mean_Accuracy)/sqrt(10),std(meansBySub_spec_diff.mean_Accuracy)/sqrt(10); 
    std(meansBySub_mat_same.mean_Accuracy)/sqrt(10),std(meansBySub_mat_diff.mean_Accuracy)/sqrt(10);
     std(meansBySub_mixed_same.mean_Accuracy)/sqrt(10),std(meansBySub_mixed_diff.mean_Accuracy)/sqrt(10)];

% Figure mapping texture vs accuracy
f= figure;
f.Color = 'w';
hold on;
f.CurrentAxes.LineWidth = 2;
f.Chiildren.FontSize = 14;
f.Children.FontWeight = 'Bold';
f.Children.TickDir = 'out';
f.Children.FontName = 'Myriad Pro';
% position/size

ctrs = 1:3;
data = acc_mat*100;
figure(1)
hBar = bar(ctrs, data);
for k1 = 1:size(data,2)
    ctr(:,k1) = bsxfun(@plus, hBar(k1).XData, hBar(k1).XOffset)';
    ydt(:,k1) = hBar(k1).YData;
end
% hold on
errorbar(ctr, ydt, sem_mat*100, '.k')
hold off

ticks = [1 2 3];
xticks([ticks]);
xticklabels({'spec','mat','mixed'});
ylabel('Accuracy (%)');
xlabel('Material of Compared Objects');
legend('same scene', 'diff scene');

%% Section 3: RM ANOVA

% Use the function TABLE to create the required data structure
%  The first N arguments should be each of the columns you want to have in the table
%  The 'VariableNames' option should be immediately followed by a cell list of strings
%    containing the names of the columns (in the same order they are listed). 
%  Keep the names of the columns as c1 - cN, expanding the list to match the number of cells you're analyzing.  
%  You will have to type in an equation below that requires this numbered naming scheme. 
t = table((1:10)', meansBySub_spec_same.mean_Accuracy, meansBySub_mat_same.mean_Accuracy, meansBySub_mixed_same.mean_Accuracy, ...
    meansBySub_spec_diff.mean_Accuracy, meansBySub_mat_diff.mean_Accuracy, meansBySub_mixed_diff.mean_Accuracy, ...
    'VariableNames',{'subject','c1','c2','c3','c4','c5','c6'});

% Since we don't have the factors clearly separated in that table, FITRM also needs labels 
% specifying the within-subject factor levels corresponding the columns c1 - cN in the table.
%  First N arguments: Cell lists of strings (vertically oriented, hence the ; separations)
%                     each containing the values of one factor across the columns c1 - cN.
%  'VariableNames' option: Give names to the factors in the same order as the factor level lists
%                          You'll use these later in the RANOVA function.
% ***************************************************
% ** Make sure you know what variable combinations **
% ** correspond to the columns you loaded into the **
% ** table ******************************************
% ***********

WD = table({'Spec';'Mat';'Mixed';'Spec';'Mat';'Mixed'}, {'Same';'Same';'Same';'Diff';'Diff';'Diff'}, 'VariableNames', {'Material','Scenes'});

% Now we can fit the model using 
%  FITRM(data_table, 'design ~ equation', 'WithinDesign', table_of_factor_labels) 
% Syntax of FITRM is a little different than we're used to, but nothing too crazy.
% First argument is the data table.
% Second argument is a model equation:
%    LHS: names of the columns (i.e., cells) in the table, using a "span" notation (for N cells, write 'c1-cN ~ 1') 
%     ~ : this is like an equals sign (read "is predicted by")
%    RHS: between-subjects factors... here we have none! FITRM requires you to have something, so put a constant ('~ 1') 
% Third part is the 'WithinDesign' option, which takes the table of factor level labels we constructed above.
RM = fitrm(t, 'c1-c6 ~ 1', 'WithinDesign',WD);

% Finally, compute a 2-way repeated-measures anova for this model using RANOVA. 
%   RANOVA(RepeatedMeasuresModel, 'WithinModel','model*equation')
% Only thing to do here is specify the model equation.
% We assume a linear model where the responses are predicted by the factors 'distance' and 'size' (names from WD).
% Our model equation will be 'distance*size', which is equivalent to 'distance + size + distance:size'
% It can be read: "main effect of distance PLUS main effect of size PLUS distance-by-size interaction" 
ranova(RM, 'WithinModel', 'Material*Scenes')

%% Section 4: Post hoc tests

[h, p, ci, stats] = ttest(mean([meansBySub_spec_same.mean_Accuracy meansBySub_spec_diff.mean_Accuracy],2), ...
    mean([meansBySub_mat_same.mean_Accuracy meansBySub_mat_diff.mean_Accuracy],2));
stats
p
% comparing the differences of mat vs specular -  p = 0.0196

[h, p, ci, stats] = ttest(mean([meansBySub_spec_same.mean_Accuracy meansBySub_spec_diff.mean_Accuracy],2), ...
    mean([meansBySub_mixed_same.mean_Accuracy meansBySub_mixed_diff.mean_Accuracy],2));
stats
p

% comparing the differences of spec vs mixed - p = 0.822

[h, p, ci, stats] = ttest(mean([meansBySub_mat_same.mean_Accuracy meansBySub_mat_diff.mean_Accuracy],2), ...
    mean([meansBySub_mixed_same.mean_Accuracy meansBySub_mixed_diff.mean_Accuracy],2));
stats
p

% comparing the differences of mat vs mixed - p = 0.0169

% Post hoc for interaction -- is effect of scene in specular condition
% different than effect of scene in matte condition?
[h, p, ci, stats] = ttest(meansBySub_mat_same.mean_Accuracy-meansBySub_mat_diff.mean_Accuracy, ...
    meansBySub_spec_same.mean_Accuracy-meansBySub_spec_diff.mean_Accuracy);
stats
p % Nope, not significant...

% is effect of scene in matte condition different than effect of scene in mixed condition?
[h, p, ci, stats] = ttest(meansBySub_mat_same.mean_Accuracy-meansBySub_mat_diff.mean_Accuracy, ...
    meansBySub_mixed_same.mean_Accuracy-meansBySub_mixed_diff.mean_Accuracy);
stats
p % Nearly!


% is effect of scene in specular condition different than effect of scene in mixed condition?
[h, p, ci, stats] = ttest(meansBySub_spec_same.mean_Accuracy-meansBySub_spec_diff.mean_Accuracy, ...
    meansBySub_mixed_same.mean_Accuracy-meansBySub_mixed_diff.mean_Accuracy);
stats
p % Also Nearly! So this and the above drive the interaction.


% is effect of scene in specular condition significant?
[h, p, ci, stats] = ttest(meansBySub_spec_same.mean_Accuracy-meansBySub_spec_diff.mean_Accuracy);
stats
p % Also Nearly! So this and the above drive the interaction.


%% Section 5: Linear Regression 

% Regression on texture & RT

LinearRegression1 = fitlm(tableAllData1,'RT~image1tex+image2tex');
GLME = fitglme(tableAllData1,...
    'Accuracy~image1tex*image2tex+(1+image1tex*image2tex|subject)',...
    'Distribution','Binomial',...
    'FitMethod','Laplace');

[~,fixedEffects1] = fixedEffects(GLME,'DFmethod','Residual');

% Regression on scene & RT

LinearRegression2 = fitlm(tableAllData1,'RT~image1scene+image2scene');

GLME_scene = fitglme(tableAllData1,...
    'Accuracy~SameDiffScene+(1+SameDiffScene|subject)',...
    'Distribution','Binomial',...
    'FitMethod','Laplace');

[~,fixedEffects1_scene] = fixedEffects(GLME_scene,'DFmethod','Residual');



