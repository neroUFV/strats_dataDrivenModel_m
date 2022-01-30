%% Experiment requires:
% !Robots/robots_ardrone_m 
% (Accessories and Tools)/tools_xboxJoystick_m

% Connects to robot, excites high-level commands and records output.
% Adapted code from tools_xboxJoystick_m/Examples/Exp_JoyCtrl_VTOL.m

% !WARNING: turn ArDrone ON and connect this machine to it's Wi-Fi.

%% cleanup
clearvars;close all;clc;

%% startup
% Instatiate and connect to joystick and robot
J = JoyControl;
J.mConnect;

A = ArDrone;
A.rConnect;

% Set up B digital button for emergency break
DESIRED = 2; 
state = 1;

% Experiment variables
XX = []; 
tmax = 30;   % experiment time in seconds

%% run 
A.rTakeOff
pause(3) % take flight and hover for 3secs.

t = tic;
tc = tic;

while toc(t) < tmax

    % EMERGENCY LOOP-BREAKER 
    J.mRead; % Update joystick data
    if (J.pDigital(DESIRED) == state)
        disp('EMERGENCY BREAK SUCCESSFUL!')
        break
        % stop experiment if DESIRED button is pressed.
    end

    % COMMAND LOOP
    if toc(tc) > 1/30
        tc = tic;

        % Update and save flight data
        A.rGetSensorData
        XX = [XX [A.pPos.Xd; A.pPos.X; tt]];
        
    end


end

% Land and close connection
A.rLand
A.rDisconnect

%% Plot results
figure(1)
subplot(211),plot(XX(end,:),XX([4 16],:)'*180/pi)
legend('\phi_{Des}','\phi_{Atu}')
grid
subplot(212),plot(XX(end,:),XX([5 17],:)'*180/pi)
legend('\theta_{Des}','\theta_{Atu}')
grid

figure(2)
plot(XX([1,13],:)',XX([2,14],:)')
axis equal

figure(3)
subplot(211),plot(XX(end,:),XX([1 13],:)')
legend('x_{Des}','x_{Atu}')
grid
subplot(212),plot(XX(end,:),XX([2 14],:)')
legend('y_{Des}','y_{Atu}')
grid