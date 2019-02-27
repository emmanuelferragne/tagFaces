%prompts user to load picture file
fileName = uigetfile('*.jpg; *.png');
myIm = imread(fileName);

%tests if colour image; we want grayscale
if size(myIm, 3) == 3
    grayIm = rgb2gray(myIm);
else
    grayIm = myIm;
end

%resizes image, saves new version
smallIm = imadjust(imresize(grayIm, [800, NaN]));
heightIm = size(smallIm,2);
newImName = [fileName(1:end-4) 'Tag.png'];
imwrite(smallIm, newImName);

%creates and starts writing html
fidHtm = fopen([fileName(1:end-4) 'Tag.html'], 'w');
stringHeader = ['<img src="' newImName '" width="' num2str(heightIm) '" height="800" usemap="#myMap">'];
fprintf(fidHtm, '%s\r\n', stringHeader);
fprintf(fidHtm, '%s\r\n', '<map name="myMap">');

%detects faces and diplays bounding boxes
faceDetector = vision.CascadeObjectDetector();
shapeInserter = vision.ShapeInserter();
shapeInserter.LineWidth = 3;
shapeInserter.BorderColor = 'White';
bbox = step(faceDetector, smallIm);
I_faces = step(shapeInserter, smallIm, int32(bbox));
imshow(I_faces), title('Detected faces');

%displays detected faces sequentially
%prompts user to input person's name
%leave blank text box if false detection
for i=1:size(bbox, 1)
    currentBox = bbox(i,:);
    currentCoord = currentBox;
    currentCoord(3) = currentCoord(1) + currentBox(3);
    currentCoord(4) = currentCoord(2) + currentBox(4);
    stringCoord = sprintf('%.0f,' , currentCoord);
    stringCoord = stringCoord(1:end-1);
    imFace = imcrop(smallIm, currentBox);
    h = figure;
    h.Position = [100, 100, 560, 420];
    imshow(imFace);
    currentName = char(inputdlg('Name')); %leave empty if false alarm
    if ~isempty(currentName)
        linkFile = uigetfile('*.html');
        if linkFile == 0
            fprintf(fidHtm, '%s\r\n',...
                ['  <area shape="rect" coords="' stringCoord '" href="noRecord.html" title="' currentName '">']);
        else
            fprintf(fidHtm, '%s\r\n',...
                ['  <area shape="rect" coords="' stringCoord '" href="' linkFile ' " title="' currentName '">']);
        end
    end
    close(h)
end
%manual face detection
reponse = questdlg('Add face manually?', 'Annotation', 'Yes', 'No', 'Yes');
while strcmp(reponse, 'Yes')
    h = imrect;
    currentCoord = round(h.getPosition);
    currentCoord(3) = currentCoord(1) + currentCoord(3);
    currentCoord(4) = currentCoord(2) + currentCoord(4);
    stringCoord = sprintf('%.0f,' , currentCoord);
    stringCoord = stringCoord(1:end-1);
    imFace = imcrop(smallIm, h.getPosition);
    h = figure;
    h.Position = [100, 100, 560, 420];
    imshow(imFace);
    currentName = char(inputdlg('Name'));
    linkFile = uigetfile('*.html');
    if linkFile == 0
        fprintf(fidHtm, '%s\r\n',...
            ['  <area shape="rect" coords="' stringCoord '" href="noRecord.html" title="' currentName '">']);
    else
        fprintf(fidHtm, '%s\r\n',...
            ['  <area shape="rect" coords="' stringCoord '" href="' linkFile ' " title="' currentName '">']);
    end
    close(h)
    reponse = questdlg('Add face manually?', 'Annotation', 'Yes', 'No', 'Yes');
end
fprintf(fidHtm, '%s\r\n', '</map>');
fclose(fidHtm);

