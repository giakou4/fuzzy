function [] = simulation(fis,x0,y0,xd,yd,theta_arr,u)
% function [] = simulation(fis,x0,y0,xd,yd,theta_arr,u)
% SIMULATION simulated the car route in the x-y plain for fixed boundaries
% and obstacles defined inside this function
%
% Inputs:
% fis:         the FIS model
% x0:          inital position in x axe
% y0:          initial position in y axe
% xd:          desired position in x axe
% yd:          desired position in y axe
% theta_arr:   starting angle array of the car
% u:           the velocity of the car

for iter = 1:length(theta_arr)
    flag_lost = 0;      % if out of border flag_lost = 1;
    x_arr = [];         % keep the x coordinate of car's route
    y_arr = [];         % keep the y coordinate of car's route
    x = x0;             % initialzie x with x0
    y = y0;             % initialzie y with y0
    theta = theta_arr(iter);    % initialize theta with one value each time
    while flag_lost == 0        % iterate while not out of borders
        [dH, dV] =  get_distances(x, y); % find the distance 
        Dtheta = evalfis([dV dH theta], fis); % use the FIR model to calculate the change of theta
        theta = theta + Dtheta; % new theta is old theta plus the change of theta
        x = x + u * cosd(theta); % new x is the old x plus u times cos(theta) in degrees
        y = y + u * sind(theta); % new y is the old y plus u times sin(theta) in degrees
        x_arr = [x_arr; x]; % save new x
        y_arr = [y_arr; y]; % save new y
        if (x < 0) || (x>15) || (y <0) || (y > 10) % check if out of borders
            flag_lost = 1;
        end
    end
    x_error = xd - x; % calculate error in x coordinate
    y_error = yd - y; % calculate error in y coordinate
    eucl_error = norm([xd - x, yd - y]); % calculate the euclidean error - norm
    x_obstacles = [10; 10; 11; 11; 12; 12; 15]; % saves the values of obstacles in a way to plot them
    y_obstacles = [0; 5; 5; 6; 6; 7; 7]; % saves the values of obstacles in a way to plot them
    figure; % plot the route of car
    plot(x_arr, y_arr , 'Color','blue');
    hold on;
    plot(x_obstacles, y_obstacles, 'Color','red','LineWidth',2);
    hold on;
    plot(xd, yd, '*','Color','blue','LineWidth',2);
    text(xd+0.1,yd-0.1,'Desired Position');
    text(xd+0.1,yd-0.4,'(15, 7.2)');
    hold on;
    plot(x0, y0, '*','Color','blue','LineWidth',2);
    text(x0+0.1,y0-0.1,'Initial Position');
    text(x0+0.1,y0-0.4,'(9.1, 4.3)');
    text(13,4,['\theta_0 = ', num2str(theta_arr(iter))]);
    text(13,3,['error of x = ', num2str(x_error)]);
    text(13,2,['error of y = ', num2str(y_error)]);
    text(13,1,['euclidean error = ', num2str(eucl_error)]);
    title(['Simulation of Cars Route with \theta_0 = ',num2str(theta_arr(iter))])
    xlim([x0-1 16])
    ylim([0 9])
end

end

