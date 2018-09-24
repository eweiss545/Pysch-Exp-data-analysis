% CLPS 1590 - Visualizing Vision
% Evan Cesanek
% Factorial Design Template

% You can run line-by-line through the code in the first 6 sections, examining how
% it constructs the arrays that are needed to control the order of the experiment.
% But to run the actual experiment in full, you must click Run in the Editor tab.
% This is because Psychtoolbox takes over the display (with the Screen commands)
% in section 7.

clear % Clear the workspace at the start
Screen('Preference', 'SkipSyncTests', 1);
% addpath('JPGs')
%% OPEN OUTPUT FILE FOR RECORDING DATA

% Using console to collect input
subid = input('Enter subject ID number: ');

% Where will the output file be stored? This is a relative path from the
% current directory when you run this file (see Current Folder panel at left).
% Notice how adding the square brackets lets you concatenate multiple strings,
% and how we do a num2str ("number-to-string") on the subject ID that was input above.
outputFileName = ['subj' num2str(subid) '.txt'];

% Check to AVOID OVERWRITING an existing file
% If this happens, the program displays (disp) a message in the command window
% and the script stops executing here.
% To stop this, you need to enter a different subid or delete the old file.
if exist(outputFileName, 'file')==2
    disp('That file already exists!');
    return; % Exit from the program
end

% OPEN a file stream for writing data out
% this function returns a number, which is the file "handle"
% i.e., a way to grab the open file when you want to use it
outfile = fopen(outputFileName,'wt');

% In the fprintf command below, we use the file handle to write to this file.
% We will print the data as a table, where each trial is a row, and each column
% holds a different piece of identifying information needed for analysis.

% Here we'll just print the Column Headers, separated by tab characters ('\t').
% When we print the data during the experiment, we will supply variables
% that change values during the experiment. Since we're only doing the
% headers here, we type a single string, composed of identifying titles for the
% columns of our data table, tab characters ('\t'), and a new line character ('\n') at the end.
fprintf(outfile, 'subject\t trial\t image1\t image1tex\t image1shape\t image1scene\t image2\t image2tex\t image2shape\t image2scene\t answer\t RT\t\n');

% Here is a visual example of how we are setting up this output file to look in the end
%
% subject    trial    size    distance    probeLength    RT
%       1        1       2           2             56  2.82
%       1        2       2           1             64  1.62
%       1        3       1           2             23  2.42
%     ...      ...     ...         ...            ...   ...
%       1       11       1           2             26  1.12
%       1       12       1           1             30  1.32

%% FACTORIAL DESIGN

% Factors are the variables that you want to measure the effect of.
% You will create numerical representations of your factors in this section.
% We can use these to control the presentation of stimuli in the experiment,
%  and to keep track what was shown on each trial so we can print it in the output file.
% This example is a two-factor experiment, Size and Distance.
% Each factor has 2 levels, so there are 4 cells in the design.
%
%      -------------   % Cell 1 = near small [1 1]
%      | Distance  |   % Cell 2 = far  small [2 1]
% ------------------   % Cell 3 = near large [1 2]
% |    |  1  |  2  |   % Cell 4 = far  large [2 2]
% | Sz |------------
% |    |  3  |  4  |
% ------------------

% We can define our factors with vectors of numerical labels (1 to numLevels)
factor1 = 1:18; % Factor "Image1" has 18 levels: all images
factor2 = 1:18; % Factor "Image2" has 18 levels:
numCells = length(factor1) * length(factor2); % number of cells in design
factorsMap = CombVec(factor1, factor2); % function to get all combinations of factor levels

% By indexing into factorsMap using the number of a specific cell in our design,
%  we can obtain identifying information about the factors being shown on that trial.
% >> factorsMap(:,1)    % >> factorsMap(:,2)    % >> factorsMap(:,3)    % >> factorsMap(:,4)
%     1                 %     2                 %     1                 %     2
%     1                 %     1                 %     2                 %     2


%% CREATE A RANDOM TRIAL ORDER
% How many repetitions do we want for each cell in our design?
numCellRepetitions = 1;
% Repeat the cellIDs (1:numCells) to create a longer vector representing the set of trials
cellIDs_byTrial = repmat(1:numCells, 1, numCellRepetitions);
totalNumberOfTrials = length(cellIDs_byTrial);
% % Randomize the order of the cellIDs across the trials
cellIDs_byTrial = Shuffle(cellIDs_byTrial);
% % Shuffle returns (for example):
% %  [1, 4, 4, 3, 2, 3, 2, 1, 3, 1, 4, 2]
% Notice this ensures that each cell is in there an equal number of times!

% With this representation, we will be able check the cellID number on each
% trial in the trial loop. We can then use the cellID to index the appropriate
% column of "factorMap", which tells us the factor levels being displayed on
% that trial. cellIDs can also be used to index into stimulus_array, where we
% are holding the stimuli.

% for tr = 1:totalNumberOfTrials
%     ...
%     currentCellID = cellIDs_byTrial(tr);
%     currentSize = factorMap(1,currentCellID);
%     currentDistance = factorMap(2,currentCellID);
%     currentImage = stimulus_array(:,:,:,currentCellID);
%     ...
% end

%% Keyboard Codes
KbName('UnifyKeyNames'); % Cross-platform compatibility (Mac/Windows/Linux)

% Retrieve numeric codes for response keys
left = KbName('LeftArrow');
right = KbName('RightArrow');
spaceKey = KbName('space');
escKey = KbName('q');

% To obtain the names that PTB uses for specific keys (like 'UpArrow'):
% 1. Type KbDemo in the Command Window
% 2. Press the key you're interested in
% 3. It will show the name of that key

% We'll also take this time to set some timing parameters for the experiment
interTrialInterval = .5; % Half a second between each trial
stimulusDisplayTime = 2; % Show each stimulus for half a second (not used in this experiment)

%% --OPENING A GRAPHICS WINDOW--
% Get some important settings in place before getting started
AssertOpenGL; % checks that you have the right version
% Screen('Preference', 'SkipSyncTests', 0); % Disables timing tests that we don't need

% Now we find the monitor screen with the Psychtoolbox Screen() function
screen_number = Screen('Screens'); % Labels the screen with a number
screen_specs = Screen('Resolution', screen_number); % Gets the resolution

% Unlike typical MATLAB functions, Psychtoolbox's Screen() is more like aa "class" containing
% many different functions. These are accessed via strings given as the first argument to Screen.

% Here we open the graphics window - this is where you can no longer go line-by-line in this code!
[windowHandle, screenrect] = Screen('OpenWindow', screen_number);

% If you don't want the window to be full-screen, comment out the line above
%  and uncomment the line below, where we've added the optional [rect] parameter
%  to dictate the window position and size (helpful for debugging).
%[windowHandle, screenrect] = Screen('OpenWindow', 0, [], [0 0 640 480]);

% Two different variables are output from this function (hence the square brackets):
% 1. windowHandle: the window handle, needed when using Screen() commands that draw graphics in the window.
% 2. screenrect: list of x,y coordinates, in pixels, for the screen corners
%     screenrect([1 2]) are x,y coordinates of top left corner (usually [0 0])
%     screenrect([3 4)) are x,y coordinates of bottom left corner (usually [horizontalResolution verticalResolution])

% It will be helpful to draw things with respect to the window's center, so here we store the coordinates.
center = screenrect([3 4])/2; % Get the x-y coordinates of the center of the window

% Fill the window with a colored rectangle [0 0 0] is black (zero intensities for Red, Green, and Blue)
Screen('FillRect', windowHandle, [0 0 0]);

% Display the contents of the graphics buffer (where we drew the text) on the actual screen
Screen('Flip', windowHandle);
% Until this command is given, drawing operations are not visible on the screen.
% 'Flip' also creates a new empty buffer to draw in.

% Two more functions that hand over control to the Psychtoolbox program
ListenChar(2); % Re-routes keyboard inputs so they don't get typed in the Command Window
HideCursor; % The mouse disappears from the screen

%% SHOW EXPERIMENT INSTRUCTIONS
% Set up the display (black background, medium size text)
Screen('FillRect', windowHandle, [0 0 0]); % Draw a black rectangle in the graphics buffer
Screen('TextSize', windowHandle, 24); % Set the size of the text

% DrawFormattedText(window handle, text string to display,
%                   x position, y position, text color,
%                   [], [], [], line spacing)
% The []s are "null inputs" for options we don't care about; see 'help DrawFormattedText'
% DrawFormattedText is a Psychtoolbox function, but notice it is not a Screen() command.
% Write your experiment instructions, being mindful of where you put the newline characters
% and the x-y coordinates of the first line so you get a nice display.
% Also notice that the ellipsis (...) allows you to continue commands on the next line
% But you must terminate strings first or it will just concatenate '...' onto them!
DrawFormattedText(windowHandle, ['Click the left arrow if the images represent the same shape\n' ...
    'Click the right arrow if the images represent different shapes.\n' ...
    'Press Space to start.'], center(1)-500, center(2)-300, [200 200 200],[],[],[],1.5);

% Flip the buffer with the instructions text to the screen.
Screen('Flip', windowHandle);

%% WAIT FOR KEYPRESS ON INSTRUCTIONS SCREEN
%
% % Set up screen parameters for PTB
%
% Screen('Preference', 'SkipSyncTests', 1);
%
% res = Screen('Resolution',0);
%
% screens = Screen('Screens');
%
% screenNumber = max(screens); HideCursor;
%
% [Screen_X, Screen_Y]=Screen('WindowSize', screenNumber);
%
% HideCursor;
%
%
% %%%%%%%% SET TO ONE WHEN RUNNING SUBJECTS!!
%
%
% % USE THESE LINES FOR SET SCREEN
%
% screenRect  = [0 0 Screen_X Screen_Y];
%
% [w, Rect] = Screen('OpenWindow', screenNumber, 0, screenRect);
%
% white = WhiteIndex(w);
%
% black = BlackIndex(w);
%
% Screen('FillRect', w, [0 0 0]);  % 0 = black background
%
%
% screenX = res.width;
%
% screenY = res.height;
%
% centerX = screenX/2;
%
% centerY = screenY/2;
%
% backColor = black;
%
%
% % defines position
%
%
% shapeSize = 100;
%
% borderThickness = .06;
%
% imageRect = [0,0,shapeSize,shapeSize];
%
% imageCenterRect = [centerX-shapeSize/2,centerY-shapeSize/2,centerX+shapeSize/2,centerY+shapeSize/2];
%
% shapeSize = [0,0,190,200];
%
% shapeX = screenX/2;
%
% shapeY = screenY/2;
%
% shapeLRect = [shapeX-shapeSize(3)-95,shapeY-shapeSize(4)/2,shapeX-95,shapeY+shapeSize(4)/2];
%
% shapeRRect = [shapeX+95,shapeY-shapeSize(4)/2,shapeX+shapeSize(3)+95,shapeY+shapeSize(4)/2];
%
imagepath = '\\files.brown.edu\Home\egweissm\MATLAB_export\SizeDistanceExperiment\JPGs';

for i=1:18
    
    stims{i} = imread(fullfile(imagepath, [num2str(i) '.jpg']));
    
    %     shapeTextures(i) = Screen('MakeTexture', w, stims{i});
    
end


% Infinite loop that checks for keyboard activity
while 1 % 1 always evaluates as true, that's why this is an infinite loop
    % Check for key presses and return variables that help identify the key
    [keyIsDown, secs, keyCode] = KbCheck;
    
    % Clear the event queue of keypress events
    FlushEvents('keyDown');
    
    % If some key was pressed
    if keyIsDown
        
        % We check if that key was one of our response keys using if-elseif.
        
        % If it was SPACE (our "continue" button), break out of this loop
        if keyCode(spaceKey) % See "Keyboard Codes" section above for spaceKey definition
            break ; % Break out of this loop
            
            % If it was 'q', exit the experiment.
        elseif keyCode(escKey)
            ShowCursor; % Display the cursor
            fclose(outfile); % Close the output file
            Screen('CloseAll'); % Close all Psychtoolbox windows
            return; % Stop the script
            
        end
        
    end
    
end

% Wait until all keys are released before continuing to next section
KbReleaseWait;

%% EXPERIMENT AND TRIAL LOOPS - The Most Important Section!
%  The outer loop walks through the trials one by one, running the same code on
%   each trial to set up the trial parameters and write to file.
%  The inner loop controls the flow of each trial, drawing the stimuli, keeping
%   track of the timing of each trial, and controlling mouse/keyboard interactions.

% Each loop iteration is a trial, and tr is assigned the trial number
for tr = 1:totalNumberOfTrials
    % 1. SETTING UP THE TRIAL
    disp(tr)
    % Get the relevant information for the current trial - see first section
    currentCellID = cellIDs_byTrial(tr); % Get the cell ID for this trial
    currentImage1 = factorsMap(1,currentCellID); % Get the factor 1 value
    currentImage2 = factorsMap(2,currentCellID); % Get the factor 2 value
    currentImage1file = stims{currentImage1};   % (:,:,:,currentCellID); % Get the stimulus image
    currentImage2file = stims{currentImage2};   % (:,:,:,currentCellID); % Get the stimulus image
    
    switch(currentImage1)
        case 1
            image1tex = 0;
            image1shape = 0;
            image1scene = 0;
            
        case 2
            image1tex = 1;
            image1shape = 0;
            image1scene = 0;
            
        case 3
            image1tex = 0;
            image1shape = 0;
            image1scene = 1;
            
        case 4
            image1tex = 1;
            image1shape = 0;
            image1scene = 1;
            
        case 5
            image1tex = 0;
            image1shape = 0;
            image1scene = 2;
            
        case 6
            image1tex = 1;
            image1shape = 0;
            image1scene = 2;
            
        case 7
            image1tex = 0;
            image1shape = 1;
            image1scene = 0;
            
        case 8
            image1tex = 1;
            image1shape = 1;
            image1scene = 0;
            
        case 9
            image1tex = 0;
            image1shape = 1;
            image1scene = 1;
            
        case 10
            image1tex = 1;
            image1shape = 1;
            image1scene = 1;
            
        case 11
            image1tex = 0;
            image1shape = 1;
            image1scene = 2;
            
        case 12
            image1tex = 1;
            image1shape = 1;
            image1scene = 2;
            
        case 13
            image1tex = 0;
            image1shape = 2;
            image1scene = 0;
            
        case 14
            image1tex = 1;
            image1shape = 2;
            image1scene = 0;
            
        case 15
            image1tex = 0;
            image1shape = 2;
            image1scene = 1;
            
        case 16
            image1tex = 1;
            image1shape = 2;
            image1scene = 1;
            
        case 17
            image1tex = 0;
            image1shape = 2;
            image1scene = 2;
            
        case 18
            image1tex = 1;
            image1shape = 2;
            image1scene = 2;
            
    end
    
    switch(currentImage2)
        case 1
            image2tex = 0;
            image2shape = 0;
            image2scene = 0;
            
        case 2
            image2tex = 1;
            image2shape = 0;
            image2scene = 0;
            
        case 3
            image2tex = 0;
            image2shape = 0;
            image2scene = 1;
            
        case 4
            image2tex = 1;
            image2shape = 0;
            image2scene = 1;
            
        case 5
            image2tex = 0;
            image2shape = 0;
            image2scene = 2;
            
        case 6
            image2tex = 1;
            image2shape = 0;
            image2scene = 2;
            
        case 7
            image2tex = 0;
            image2shape = 1;
            image2scene = 0;
            
        case 8
            image2tex = 1;
            image2shape = 1;
            image2scene = 0;
            
        case 9
            image2tex = 0;
            image2shape = 1;
            image2scene = 1;
            
        case 10
            image2tex = 1;
            image2shape = 1;
            image2scene = 1;
            
        case 11
            image2tex = 0;
            image2shape = 1;
            image2scene = 2;
            
        case 12
            image2tex = 1;
            image2shape = 1;
            image2scene = 2;
            
        case 13
            image2tex = 0;
            image2shape = 2;
            image2scene = 0;
            
        case 14
            image2tex = 1;
            image2shape = 2;
            image2scene = 0;
            
        case 15
            image2tex = 0;
            image2shape = 2;
            image2scene = 1;
            
        case 16
            image2tex = 1;
            image2shape = 2;
            image2scene = 1;
            
        case 17
            image2tex = 0;
            image2shape = 2;
            image2scene = 2;
            
        case 18
            image2tex = 1;
            image2shape = 2;
            image2scene = 2;
            
    end
    
    % Randomize the starting probe length, 10 - 60 pixels
    
    
    % Make sure the program doesn't think any keys are being pressed
    keyIsDown=0;
    
    % Wait during the inter-trial interval
    WaitSecs(interTrialInterval);
    % Record the trial start time
    timeStart = GetSecs;
    
    Image1Location = [157.5,270,802.5,810];
    Image2Location = [1117.5,270,1762.5,810];
    % TRIAL LOOP - this is an infinite loop until a response is given
    while 1
        
        % 2. DRAWING THE STIMULUS AND THE RESPONSE LINE
        lol= GetSecs-timeStart;
        if lol < stimulusDisplayTime
            % Draw image data in the window. Seems to place image in center of screen by default.
            Screen('PutImage', windowHandle, currentImage1file, Image1Location);
            Screen('PutImage', windowHandle, currentImage2file, Image2Location);
        else
            Screen('FillRect', windowHandle, [0 0 0]); % Draw a black rectangle in the graphics buffer
        end
        
        % Draw the probe line off to the right of the stimulus (x = 1100).
        % Notice that the y coordinate of one end is based on the variable 'probeLength'.
        %         Screen('DrawLine', windowHandle, [200 200 200], ...
        %             1100, center(2)-probeLength, ...
        %             1100, center(2), 6);
        % The parameters of this function are:
        % Screen('DrawLine', window handle, color, xPos_start, yPos_start, xPos_end, yPos_end, line width)
        
        % Flip the window to show what you've drawn.
        Screen('Flip', windowHandle);
        %trialstart = tic;
        timedout = 1;
        
        % 3. CHECKING FOR KEYBOARD INPUT, RESPONSE HANDLING
        
        % Check for key presses and return variables that help identify the key
        [keyIsDown, secs, keyCode] = KbCheck;
        
        % Clear the event queue of keypress events
        FlushEvents('keyDown');
        
        % If a key was pressed
        %         while toc(trialstart) < stimulusDisplayTime
        %             if keyIsDown && ~keyCode(escKey)
        %                 timedout = 0;
        %                 rt = 1000*toc(trialstart);
        %                 if keyCode(left)
        %                     keyPressed=find(keyCode); % get the key number from the logical array
        %                     answer = 1;
        %                 else
        %                     keyPressed=find(keyCode); % get the key number from the logical array
        %                     answer = 0;
        %                 end
        %             elseif keyIsDown && keyCode(escKey)
        %                 ShowCursor; ListenChar(0); fclose(outfile); Screen('CloseAll'); return;
        %             end
        %         end
        
        
        % keyCode is a logical array, each element corresponds to a key.
        % It is 1 at the key's index if the key was pressed, 0 if not.
        
        
        % If q was pressed, quit and close output file
        
        if keyCode(escKey)
            ShowCursor; ListenChar(0); fclose(outfile); Screen('CloseAll'); return;
            
            % If Space was pressed, compute RT and escape from the infinite loop
        elseif keyCode(left)
            rt = 1000*(GetSecs-timeStart); % compute RT in milliseconds
            keyPressed=find(keyCode); % get the key number from the logical array
            answer = 1;
            % escape from this infinite loop
            break
            
        elseif keyCode(right)
            rt = 1000*(GetSecs-timeStart); % compute RT in milliseconds
            keyPressed=find(keyCode); % get the key number from the logical array
            answer = 0;
            % escape from this infinite loop
            break
        end
    end
    keyIsDown=0; keyCode=0; % Reset these variables
    
    % Draw and Flip another black square to replace the stimulus after the response is given
    Screen('FillRect', windowHandle, [0 0 0]);
    Screen('Flip', windowHandle);
    
    % 4. WRITE DATA TO OUTPUT FILE (fprintf)
    % Usage: fprintf(output file handle, formatting string, entry1, entry2, entry3, ..., entryN)
    % The first argument is the handle returned by fopen (see first section).
    % The second argument is a funny-looking string that tells MATLAB what kind of data to expect in the file.
    % The data type of each column is specified by the '%' sign, followed by a letter denoting the format.
    %  (%d for double, %s for string, %6.2f for a 6-digit number where 2 digits follow the decimal point)
    % In our file, the columns are tab-delimited, so we separate the data type specifiers with '\t'.
    % And finally, again we have a new line character '\n' at the end of the line.
    % Then you just list the variables you want to print in the correct order.
    % Make sure this order is consistent with the order of your headers (see section 1).
    fprintf(outfile, '%d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %6.2f\t \n', ...
        subid, tr, currentImage1, image1tex, image1shape, image1scene, currentImage2, image2tex, image2shape, image2scene, answer, rt);
    
    % See 'help fprintf' for details about this function
    
    % Again, here's the example of how this output file should look.
    %
    % subject    trial    size    distance    probeLength    RT
    %       1        1       2           2             56  2.82
    %       1        2       2           1             64  1.62
    %       1        3       1           2             23  2.42
    %     ...      ...     ...         ...            ...   ...
    %       1       11       1           2             26  1.12
    %       1       12       1           1             30  1.32
    
    % Wait until all keys are released before beginning next trial
    KbReleaseWait;
end



% %     % 1. SETTING UP THE TRIAL
% %
% % %     % Get the relevant information for the current trial - see first section
% % %     currentCellID = cellIDs_byTrial(tr); % Get the cell ID for this trial
% % %     currentDistance = factorsMap(1,currentCellID); % Get the factor 1 value
% % %     currentSize = factorsMap(2,currentCellID); % Get the factor 2 value
% % %     currentImage = stimulus_array(:,:,:,currentCellID); % Get the stimulus image
% % %
% % %     % Randomize the starting probe length, 10 - 60 pixels
% % %     probeLength = randi(50)+10; % randomize starting length of probe line
% % %
% %     % Make sure the program doesn't think any keys are being pressed
% %     keyIsDown=0;
% %
% %     % Wait during the inter-trial interval
% %     WaitSecs(interTrialInterval);
% %     % Record the trial start time
% %     timeStart = GetSecs;
% %     %curr_node = randi(18);
% %    %next_nodes = randsample(setdiff(length(stims),curr_node));
% %
% %
% % % presents two images on the screen
% %
% % node = Screen('MakeTexture', w, stims{curr_node}); %stims{curr_node}
% %
% %     Screen('DrawTexture', w, node, [], shapeLRect, rotation);
% %
% %     next = Screen('MakeTexture', w, stims{next_nodes}); %stims{next_nodes}
% %
% %     Screen('DrawTexture', w, next, [], shapeRRect);
% %
% %     % Screen('Flip', w);
% %
% %     fliptime = Screen('Flip',w);
% %
% %  trialstart = tic;
% %  timedout = 1;
% %
% %
% %     while toc(trialstart) < stimulusDisplayTime && timedout
% %         [keyIsDown, keyTime, keyCode] = KbCheck;
% %         if keyIsDown && ~strcmp(KbName(keyCode), 'q')
% %             timedout = 0;
% %             timeElapsed = toc(trialStart);
% %         elseif keyIsDown && strcmp(KbName(keyCode), 'q')
% %             ShowCursor;
% %             Listenchar(0);
% %             Screen('CloseAll');
% %             return;
% %         end
% %     end
% %
% %     if ~timedout
% %         rsp.RT(i) = timeElapsed;
% %         rsp.KeyName{i} = KbName(keyCode);
% %     else
% %         rsp.RT(i) = stimulusDisplayTime;
% %         rsp.keyName{i} = 'none';
% %     end
% % keyboard
%   %% Put in for loop
%
%     % Draw and Flip another black square to replace the stimulus after the response is given
%     Screen('FillRect', windowHandle, [0 0 0]);
%     Screen('Flip', windowHandle);
%
%     % 4. WRITE DATA TO OUTPUT FILE (fprintf)
%     % Usage: fprintf(output file handle, formatting string, entry1, entry2, entry3, ..., entryN)
%     % The first argument is the handle returned by fopen (see first section).
%     % The second argument is a funny-looking string that tells MATLAB what kind of data to expect in the file.
%     % The data type of each column is specified by the '%' sign, followed by a letter denoting the format.
%     %  (%d for double, %s for string, %6.2f for a 6-digit number where 2 digits follow the decimal point)
%     % In our file, the columns are tab-delimited, so we separate the data type specifiers with '\t'.
%     % And finally, again we have a new line character '\n' at the end of the line.
%     % Then you just list the variables you want to print in the correct order.
%     % Make sure this order is consistent with the order of your headers (see section 1).
%     fprintf(outfile, '%d\t %d\t %d\t %d\t %d\t %6.2f\t \n', ...
%         subid, tr, currentSize, currentDistance, probeLength, rt);
%
%     % See 'help fprintf' for details about this function
%
%     % Again, here's the example of how this output file should look.
%     %
%     % subject    trial    size    distance    probeLength    RT
%     %       1        1       2           2             56  2.82
%     %       1        2       2           1             64  1.62
%     %       1        3       1           2             23  2.42
%     %     ...      ...     ...         ...            ...   ...
%     %       1       11       1           2             26  1.12
%     %       1       12       1           1             30  1.32
%
%     % Wait until all keys are released before beginning next trial
%     KbReleaseWait;
%
% keyboard
%% Ending the experiment
ListenChar(0); % Give up control of the keyboard
Screen('CloseAll'); % Close the Psychtoolbox window
fclose(outfile); % Close output file when you're finished or it could get messed up!

