function [dH,dV] = get_distances(x,y)
% function [dH,dV] = get_distances(x,y)
% GET_DISTANCES calculates the distance of the vertical and horizontal axe
% given the coordinates x, y according to Car Control Series 7 (G) for the
% fuzzy assignment 2020
%
% Inputs:
% x         : x coordinate
% y         : y coordinate
% Outputs:
% dH        : distance to horizontal object
% dV        : distance to vertical object

if x <= 10
    if y<= 5
        dH = 10 - x;
    else
        dH = 1;
    end
elseif x <= 11
    if y<= 6
        dH = 11 - x;
    else
        dH = 1;
    end
elseif x <= 12 
    if y<= 7
        dH = 12 - x;
    else
        dH = 1;
    end
elseif x <= 15
        dH = 1;
else
        dH = 0;
end

if y <= 5
    dV = 1;
elseif y <= 6
    if x >= 10
        dV = y - 5;
    else
        dV = 1;
    end
elseif y <= 7
    if x >= 11
        dV = y - 6;
    else
        dV = 1;
    end 
elseif y <= 7.2
    dV = y - 7;
else
    dV = 1;
end

end

