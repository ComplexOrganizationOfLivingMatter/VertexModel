
addpath('src');
addpath('lib');

inputDir = 'data/images';
files = dir('data/images');
files = files(3:end);
for numImg = 1:length(files)
    createFrameFromImage(strcat(inputDir, '/', files(numImg).name), files(numImg).name)
end

%paintFrame('data/Atrophy#1.mov');
%paintFrame('data/ToTest.mov');
%paintFrame('data/Scenario1.mov');