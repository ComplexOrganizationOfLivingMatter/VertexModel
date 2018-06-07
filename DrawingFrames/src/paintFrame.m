function [ ] = paintFrame( inputFile )
%PAINTFRAME Summary of this function goes here
%   Detailed explanation goes here

    inputFileSplitted = strsplit(inputFile, '/');
    
    f = fopen(inputFile);             
    fileInfo = textscan(f,'%s','delimiter','\n');
    fclose(f);

    fileInfo = fileInfo{1};

    frames = {};

    isACell = 0;
    numFrame = 1;
    numCell = 1;
    numVertex = 0;
    actualFrame = {};
    verticesActualCell = [];
    
    cellsColours = {};
    
    for numRow = 1:size(fileInfo, 1)
        row = fileInfo{numRow};
        if isempty(strfind(row, 'Cell')) == 0
            isACell = 1;
            actualCell = [];
            if isempty(verticesActualCell) == 0
                %createPerimeter
                for numVertex = 1:size(verticesActualCell, 1) -1
                    actualCell(numVertex, :) = horzcat(verticesActualCell(numVertex, :), verticesActualCell(numVertex+1,:));
                end
                actualCell(numVertex+1, :) = horzcat(verticesActualCell(numVertex+1, :), verticesActualCell(1, :));

                actualFrame = vertcat(actualFrame, table(str2double(cellId), {actualCell}));
                numCell = numCell + 1;
            end
            
            cellInfo = strsplit(row);
                
           	cellId = cellInfo{4};
            
            numVertex = 1;
            verticesActualCell = [];
        elseif isempty(strfind(row, 'FRAME')) == 0
            numRow
            actualCell = [];
            if isempty(verticesActualCell) == 0
                %createPerimeter
                for numVertex = 1:size(verticesActualCell, 1) -1
                    actualCell(numVertex, :) = horzcat(verticesActualCell(numVertex, :), verticesActualCell(numVertex+1,:));
                end
                actualCell(numVertex+1, :) = horzcat(verticesActualCell(numVertex+1, :), verticesActualCell(1, :));

                actualFrame = vertcat(actualFrame, table(str2double(cellId), {actualCell}));
                
                numCell = numCell + 1;
            end
            numVertex = 1;
            verticesActualCell = [];
            isACell = 0;
            if isempty(actualFrame) == 0
                frames(numFrame) = {actualFrame};
                numFrame = numFrame + 1;
            end
            actualFrame = [];
        elseif isACell
            %actualFrame = 
            pairOfVertices = strsplit(row, '\t');
            verticesActualCell(numVertex, 1) = str2num(pairOfVertices{1});
            verticesActualCell(numVertex, 2) = str2num(pairOfVertices{2});
            numVertex = numVertex+1;
        end

    end

    for numFrame = 1:size(frames, 2)
        actualFrame = frames{numFrame};
        nVectors = size(actualFrame,1);
        h = figure('visible', 'off');
        hold on
        for vecNo = 1:nVectors
            plot ([actualFrame(vecNo,1);actualFrame(vecNo,3)],[actualFrame(vecNo,2);actualFrame(vecNo,4)],'k')
        end
        axis equal
        p = gca;
        set(p, 'visible', 'off');
        print(h, strcat('results/', strrep(inputFileSplitted{end}, '.', ''),'frame_', num2str(numFrame)), '-dpng');
        close(h)
    end

end

