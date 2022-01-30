%% Experiment requires:
% !Robots/robots_ardrone_m 
% (Accessories and Tools)/tools_xboxJoystick_m
% (Accessories and Tools)/tools_optitrack_m
% Motive 2.1.1 or later versions + Optitrack Odometry System

% Connects to robot, excites high-level commands and records output.
% Adapted code from tools_xboxJoystick_m/Examples/Exp_JoyCtrl_VTOL.m

% Recommended: comment A.rTakeOff, A.rSendControlSignals and A.rLand
% in order to test the script on a DRY RUN.

% !WARNING: turn ArDrone ON and connect this machine to it's Wi-Fi.

%% Experiment script
% TAKEOFF 3s
% pulse A.pSC.U(3) =  1 (UP   for 60ms, 2 loops)
% pulse A.pSC.U(3) =  0 (NO   for 60ms, 2 loops)
% pulse A.pSC.U(3) = -1 (DOWN for 60ms, 2 loops)
% pulse A.pSC.U(3) =  0 (NO   for 60ms, 2 loops)
% pulse A.pSC.U(3) =  1 (UP   for 60ms, 2 loops)
% pulse A.pSC.U(3) =  0 (NO   for 60ms, 2 loops)
%_______________________________________________
% Total> 360ms, 12 control loops + 5sec takeoff
% -> this was too fast!




%% cleanup
clearvars;close all;clc;

%% startup
% Create OptiTrack object and initialize virtual drone to get coordinates
OPT = OptiTrack;
OPT.Initialize;
virtA = ArDrone;

% Instatiate and connect to joystick and robot
J = JoyControl;
J.mConnect;

A = ArDrone;
A.rConnect;

% Set up B digital button for emergency break
DESIRED = 2; 
state = 1;

% Experiment variables
X_drone     = [];   % [x,y,z,phi,theta,psi] 12x1
dX_drone    = [];   % [derivatives of X]    12x1
X_opt       = []; 
dX_opt      = [];
controlSig  = [];   % A.pSC.U
dControlSig = [];   % A.pSC.Ud
TIME        = [];
loopCount   = 0;
tmax        = 60; % experiment time in seconds

%% run 
A.rTakeOff
pause(10) % take flight and hover for 5secs.

% Get EXACT hover position just after takeoff (usually not 0)
A.rGetSensorData
startPos_drone = A.pPos.X;
rb = OPT.RigidBody;
virtA = getOptData(rb,virtA);
startPos_opt = virtA.pPos.X;

disp('STARTING EXPERIMENT')
t = tic;
tc = tic;
NOW = toc(t);
last = NOW;

while NOW < tmax
    NOW = toc(t);
    
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

        if last-NOW+1 <= 0  % each loopCount now takes 1s
            loopCount = loopCount+1;
            last = NOW;
        end

        switch loopCount
            case 1||2
                A.pSC.U = [0 0 1 0]';
            
            case 3||4
                A.pSC.U = [0 0 0 0]';

            case 4||5
                A.pSC.U = [0 0 -1 0]';

            case 5||7
                A.pSC.U = [0 0 0 0]';

            case 8||9
                A.pSC.U = [0 0 1 0]';
            
            case 10||11
                A.pSC.U = [0 0 0 0]';
        end

        % Update and save flight data
        A.rGetSensorData
        rb = OPT.RigidBody;
        virtA = getOptData(rb,virtA);

        X_drone     = [X_drone, A.pPos.X];   
        dX_drone    = [dX_drone, A.pPos.dX];  
        X_opt       = [X_opt, virtA.pPos.X]; 
        dX_opt      = [dX_opt, virtA.pPos.dX];
        controlSig  = [controlSig, A.pSC.U];   
        dControlSig = [dControlSig, A.pSC.Ud];   
        TIME        = [TIME, NOW];

        % TODO prealocate matrices

        A.rSendControlSignals
    end
end

% Land and close connection
A.rLand
A.rDisconnect

%% Save results
exp = datestr(now);
exp([3,7,12,15,18]) = '_';
exp = ['(Strategies and Solutions)\strats_dataDrivenModel_m\data\','teste',exp,'.mat'];
save(exp)