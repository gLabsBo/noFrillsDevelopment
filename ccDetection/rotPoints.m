function [xr yr]=rotPoints(x,y,angle)

%Rotate the coordinate points x and y by an angle "angle" given in degrees

xr=cosd(angle)*x-sind(angle)*y;
yr=sind(angle)*x+cosd(angle)*y;