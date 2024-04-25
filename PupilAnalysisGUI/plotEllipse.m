function plotHandles = plotEllipse(s,varargin)
% PLOTELLIPSE(s) plots an ellipse on the current axis with the properties
% specified in the structure s. If s has length > 1, this plots an ellipse
% for each row in the structure. s must contain the following fields:
% "Orientation", "MajorAxisLength", "MinorAxisLength", "Eccentricity", 
% and "Centroid." These can all be obtained from the function regionprops.
% PLOTELLIPSE(s,'Parent',ax) plots onto the specified axes ax
% ellipse = PLOTELLIPSE(___) returns a handle to the object(s) created.

% For reference: 
% https://blogs.mathworks.com/steve/2010/07/30/visualizing-regionprops-ellipse-measurements/?s_tid=srchtitle_regionprops_3

p = inputParser;
addRequired(p,'s');
addParameter(p,'Parent',gca);

parse(p,s,varargin{:});

s = p.Results.s;

phi = linspace(0,2*pi,50);
cosphi = cos(phi);
sinphi = sin(phi);

if nargout == 1
    plotHandles = struct;
end

for k = 1:length(s)
    try
        xbar = s(k).Centroid(1);
    catch
        disp('pausing')
    end
    ybar = s(k).Centroid(2);

    a = s(k).MajorAxisLength/2;
    b = s(k).MinorAxisLength/2;

    theta = pi*s(k).Orientation/180;
    R = [ cos(theta)   sin(theta)
         -sin(theta)   cos(theta)];

    xy = [a*cosphi; b*sinphi];
    xy = R*xy;

    x = xy(1,:) + xbar;
    y = xy(2,:) + ybar;
    if nargout == 1
        plotHandles(k).Ellipse = plot(p.Results.Parent,x,y,'g','LineWidth',0.5);
    else
        plot(p.Results.Parent,x,y,'g','LineWidth',0.5);
    end
end
