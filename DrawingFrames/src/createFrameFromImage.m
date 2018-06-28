function [ ] = createFrameFromImage( imgFile, fileName )
%CREATEFRAMEFROMIMAGE Summary of this function goes here
%   Detailed explanation goes here
    tStart = tic;
    image = imread(imgFile);
    logicalImg = image == 255;
    imgWS = watershed(1 - logicalImg);
    l_img = bwlabel(imgWS);
    

    %noValidCells = unique(vertcat(l_img(1, :), l_img(:, 1)', l_img(end, :), l_img(:, end)'));
    %validCells = setdiff(1:max(l_img(:)), noValidCells);
    validCells = 1:max(l_img(:));
    
    [neighs_real, ~] = calculateNeighbours(l_img);
    [ verticesInfo ] = calculateVertices( l_img, neighs_real);
    
    vertices = verticesInfo.verticesPerCell;
    neighbours_vertices = verticesInfo.verticesConnectCells;
    
%     [~, goodIds] = unique(vertcat(vertices{:}), 'rows');
%     vertices = vertices (goodIds);
%     neighbours_vertices = neighbours_vertices(goodIds, :);
    
    newOrderCells = [];
    for numVertex = 1:length(vertices)
        newCells = ismember(neighbours_vertices(numVertex, :), newOrderCells) == 0 & ismember(neighbours_vertices(numVertex, :), validCells);
        if any(newCells)
            newOrderCells = horzcat(newOrderCells, neighbours_vertices(numVertex, newCells));
        end
    end
    
    fileID = fopen(strcat('D:/Pablo/Simulations/VertexModel/VertexModel/VertexModel/InitialFrames/', fileName, '.frm'),'w');
    %NumVertices
    fprintf(fileID, '%i\n', length(vertices));
    
    %Vertices: Index coorX coorY
    for numVertex = 1:size(vertices, 1)
        coordinates = vertices{numVertex}/20;
        fprintf(fileID, '%i %.3f %.3f\n', numVertex-1, coordinates(1), coordinates(2));
    end
    
    %NumCells
    fprintf(fileID, '%i\n', length(validCells));
    
    
    
    %Cells: NumVertices NumCell Growing Dying CellLine LastDivTime TimeInG0
    %GrowthStartTime IndicesVertices CellStatus
    for numCell = 1:max(newOrderCells)
        if any(newOrderCells == numCell) == 0
            continue
        end
        %verticesNumCell = arrayfun(@(x) any(numCell, x), neighbours_vertices);
        verticesNumCell = any(neighbours_vertices == numCell, 2);
        verticesActualCell = find(verticesNumCell);
        
%         K = convhull(vertcat(vertices{verticesNumCell}));
%         
%         verticesToPaint = vertcat(vertices{verticesActualCell});
%         plot(verticesToPaint(K, 1),verticesToPaint(K, 2),'r-',verticesToPaint(:, 1), verticesToPaint(:, 2),'b*')
%         hold on;
%         verticesActualCell = verticesActualCell(K(1:end-1));
        
        %NumVertices NumCell Growing Dying CellLine
        fprintf(fileID, '%i %i 0 0 0 ', length(verticesActualCell), numCell-1);
        %LastDivTime TimeInG0 GrowthStartTime 
        fprintf(fileID, '0 0 0 ');
        %IndicesVertices
        fprintf(fileID, '%i ', verticesActualCell-1);
        %CellStatus
        fprintf(fileID, '1.001\n');
    end
    fprintf(fileID, '%i\n', numCell+1);
    fclose(fileID);
end