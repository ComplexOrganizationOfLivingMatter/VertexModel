function [ verticesInfo ] = calculateVertices( L_img, neighbours )
 
    % With a labelled image as input, the objective is get all vertex for each
    % cell
    % We alse capture the border vertices

    ratio=3;
    se=strel('square',ratio);


    neighboursVertices = buildTripletsOfNeighs( neighbours );%intersect dilatation of each cell of triplet
    vertices = cell(size(neighboursVertices, 1), 1);

    % We first calculate the perimeter of the cell to improve efficiency
    % If the image is small, is better not to use bwperim
    % For larger images it improves a lot the efficiency
    
    dilatedCells=cell(max(max(L_img)),1);
    vertexWithFourFold = cell(max(max(L_img)), 1);
    for numCell=1:max(max(L_img))
        BW=zeros(size(L_img));
        BW(L_img==numCell)=1;
        BW_dilated=imdilate(bwperim(BW),se);
        dilatedCells{numCell}=BW_dilated;
        
        %Check if a forfold exists
        actualNeighbours = neighbours{numCell};
        vertexWithFourFold(numCell) = {actualNeighbours(cellfun(@(x) sum(ismember(actualNeighbours, x))>2, neighbours(actualNeighbours)))'};
    end
    
    borderImg=zeros(size(L_img));
    borderImg(L_img==0)=1;
    
    cellsWithAFourFold = find(cellfun(@isempty, vertexWithFourFold) == 0);
    vertexWithFourFold(cellfun(@isempty, vertexWithFourFold)) = {[0 0]};
    
    vertexWithFourFold = cell2mat(vertexWithFourFold);
    fourFoldMotifs = [];
    
    for numCell = 1:length(cellsWithAFourFold)
        actualCell = cellsWithAFourFold(numCell);
        if ismember(actualCell, fourFoldMotifs) == 0
            correspondanceBetweenExistingFourFold = any(ismember(fourFoldMotifs, vertexWithFourFold(actualCell, :)), 2);
            if any(correspondanceBetweenExistingFourFold)
                for numCorr = 1:length(correspondanceBetweenExistingFourFold)
                    if correspondanceBetweenExistingFourFold(numCorr)
                        newCells = unique(horzcat(fourFoldMotifs(correspondanceBetweenExistingFourFold(numCorr), :), actualCell));
                        newCells(newCells==0) = [];
                        fourFoldMotifs(correspondanceBetweenExistingFourFold(numCorr), 1:length(newCells)) = newCells;
                    end
                end
            else
                fourFoldMotifs(end+1, 1:4) = horzcat(vertexWithFourFold(actualCell, :), actualCell, 0);
            end
        end
    end
    
    if (isempty(fourFoldMotifs) == 0)
        warning('Some fourfold vertices exist: %s', mat2str(fourFoldMotifs(1, :)));
    end
    
    for numTriplet = 1 : size(neighboursVertices,1)

        BW1_dilate=dilatedCells{neighboursVertices(numTriplet, 1),1};
        BW2_dilate=dilatedCells{neighboursVertices(numTriplet, 2),1};
        BW3_dilate=dilatedCells{neighboursVertices(numTriplet, 3),1};
         

        %It is better use '&' than '.*' in this function
        [row,col]=find((BW1_dilate.*BW2_dilate.*BW3_dilate.*borderImg)==1);

        possibleFourFoldVertex = unique(L_img(BW1_dilate & BW2_dilate & BW3_dilate));
        
        possibleFourFoldVertex = possibleFourFoldVertex(possibleFourFoldVertex~=0);
        
        if length(row)>1
            vertices{numTriplet} = round(mean([row,col]));
        else
            vertices{numTriplet} = [row,col];
        end
    end

    %%Adding vertices of border images
    [col] = find(L_img(1, :) == 0);
    verticesOfBorders = horzcat(ones(length(col), 1), col');
    [col] = find(L_img(end, :) == 0);
    verticesOfBorders = vertcat(verticesOfBorders, horzcat(ones(length(col), 1)*size(L_img, 1), col'));
    
    [row] = find(L_img(:, end) == 0);
    verticesOfBorders = vertcat(verticesOfBorders, horzcat(row, ones(length(row), 1)*size(L_img, 2)));
    [row] = find(L_img(:, 1) == 0);
    verticesOfBorders = vertcat(verticesOfBorders, horzcat(row, ones(length(row), 1)));
    
    connectingBorderCells = zeros(size(verticesOfBorders, 1), 2);
    
    for numVertex = 1:size(verticesOfBorders, 1)
        row = verticesOfBorders(numVertex, 1);
        col = verticesOfBorders(numVertex, 2);
        if row == 1 || row == size(L_img, 1)
            connectingBorderCells(numVertex, 1) = L_img(row, col+1);
            connectingBorderCells(numVertex, 2) = L_img(row, col-1);
        else
            connectingBorderCells(numVertex, 1) = L_img(row+1, col);
            connectingBorderCells(numVertex, 2) = L_img(row-1, col);
        end
    end
    connectingBorderCells(:, 3) = nan;
    
    %Add corners as vertex of a cell
    cornerVertices = {[1, 1]; [1, size(L_img, 2)]; [size(L_img, 1), 1]; [size(L_img, 1), size(L_img, 2)]};
    cornerNeighbours = vertcat(L_img(1,1), L_img(1, end), L_img(end, 1), L_img(end, end));
    cornerNeighbours(:, 2:3) = nan;
    
    verticesInfo.verticesPerCell = vertcat(vertices, mat2cell(verticesOfBorders, ones(size(verticesOfBorders, 1), 1), 2), cornerVertices);
    verticesInfo.verticesConnectCells = vertcat(neighboursVertices, connectingBorderCells, cornerNeighbours);
    
    verticesInfo.verticesConnectCells = sort(verticesInfo.verticesConnectCells, 2);
    [verticesInfo.verticesConnectCells, indices] = sortrows(verticesInfo.verticesConnectCells);
    verticesInfo.verticesPerCell = verticesInfo.verticesPerCell(indices);
end

