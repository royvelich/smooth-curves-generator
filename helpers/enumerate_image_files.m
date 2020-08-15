function imageFilesPaths = enumerate_image_files(relative_folder_path)
    % Define a starting folder.
    topLevelFolder = fullfile(relative_folder_path);

    % Ask user to confirm or change.
    % topLevelFolder = uigetdir(topLevelFolder);
    % if topLevelFolder == 0
    % 	return;
    % end

    % Get list of all subfolders.
    allSubFolders = genpath(topLevelFolder);

    % Parse into a cell array.
    remain = allSubFolders;
    listOfFolderNames = {};
    while true
        [singleSubFolder, remain] = strtok(remain, ';');
        if isempty(singleSubFolder)
            break;
        end
        listOfFolderNames = [listOfFolderNames singleSubFolder];
    end

    numberOfFolders = length(listOfFolderNames);

    % Process all image files in those folders.
    imageFilesPaths = [];
    for k = 1 : numberOfFolders
        % Get this folder and print it out.
        thisFolder = listOfFolderNames{k};
        fprintf('Processing folder %s\n', thisFolder);

        % Get PNG files.
        filePattern = sprintf('%s/*.png', thisFolder);
        baseFileNames = dir(filePattern);

        % Add on TIF files.
        filePattern = sprintf('%s/*.tif', thisFolder);
        baseFileNames = [baseFileNames; dir(filePattern)];

        % Add on JPG files.
        filePattern = sprintf('%s/*.jpg', thisFolder);
        baseFileNames = [baseFileNames; dir(filePattern)];

        % Add on JPEG files.
        filePattern = sprintf('%s/*.jpeg', thisFolder);
        baseFileNames = [baseFileNames; dir(filePattern)];
        
        % Add on GIF files.
        filePattern = sprintf('%s/*.gif', thisFolder);
        baseFileNames = [baseFileNames; dir(filePattern)];

        numberOfImageFiles = length(baseFileNames);
        % Now we have a list of all files in this folder.
        
        if numberOfImageFiles >= 1
            % Go through all those image files.
            for f = 1 : numberOfImageFiles
                fullFileName = fullfile(thisFolder, baseFileNames(f).name);
                
                filePathObject = {};
                filePathObject.path = fullFileName;
                
                imageFilesPaths = [imageFilesPaths; filePathObject];
            end
        end
    end
end

