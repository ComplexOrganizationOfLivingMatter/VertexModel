function [ ] = createFrameFromImage( imgFile, fileName )
%CREATEFRAMEFROMIMAGE Summary of this function goes here
%   Detailed explanation goes here
    tStart = tic;
    image = imread(imgFile);
    logicalImg = image == 255;
    imgWS = watershed(1 - logicalImg);
    l_img = bwlabel(imgWS);
    
    noValidCells = unique(vertcat(l_img(1, :), l_img(:, 1)', l_img(end, :), l_img(:, end)'));
    validCells = setdiff(1:max(l_img(:)), noValidCells);
    
    [neighs_real, ~] = calculateNeighbours(l_img);
    [ verticesInfo ] = calculateVertices( l_img, neighs_real);
    
    vertices = verticesInfo.verticesPerCell;
    neighbours_vertices = verticesInfo.verticesConnectCells;
    
    [~, goodIds] = unique(vertcat(vertices{:}), 'rows');
    vertices = vertices (goodIds);
    neighbours_vertices = neighbours_vertices(goodIds, :);
    
    fileID = fopen(strcat('results/', fileName, '.frm'),'w');
    %NumVertices
    fprintf(fileID, '%i\n', length(vertices));
    
    %Vertices: Index coorX coorY
    for numVertex = 1:size(vertices, 1)
        coordinates = vertices{numVertex};
        fprintf(fileID, '%i %d %d\n', numVertex, coordinates(2), coordinates(1));
    end
    
    %NumCells
    fprintf(fileID, '%i\n', length(validCells));
    
    
    
    %Cells: NumVertices NumCell Growing Dying CellLine LastDivTime TimeInG0
    %GrowthStartTime IndicesVertices CellStatus
    for numCell = validCells
        %verticesNumCell = arrayfun(@(x) any(numCell, x), neighbours_vertices);
        verticesNumCell = any(neighbours_vertices == numCell, 2);
        verticesActualCell = find(verticesNumCell);
        
        K = convhull(vertcat(vertices{verticesNumCell}));
        
%         verticesToPaint = vertcat(vertices{verticesActualCell});
%         plot(verticesToPaint(K, 1),verticesToPaint(K, 2),'r-',verticesToPaint(:, 1), verticesToPaint(:, 2),'b*')
%         
        verticesActualCell = verticesActualCell(K(1:end-1));
        
        %NumVertices NumCell Growing Dying CellLine
        fprintf(fileID, '%i %i 0 0 0 ', length(verticesActualCell), numCell);
        %LastDivTime TimeInG0 GrowthStartTime 
        cl = clock;
        fprintf(fileID, '%i %g 108000 ', toc(tStart)*500, cl(end-1) + cl(end));
        %IndicesVertices
        fprintf(fileID, '%i ', verticesActualCell);
        %CellStatus
        fprintf(fileID, '%g\n', toc(tStart));
    end
    fprintf(fileID, '%i\n', numCell+1);
    fclose(fileID);
end