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
% pulse A.pSC.U(3) =  1 (UP   for ~67ms, ~2 loops)
% pulse A.pSC.U(3) =  0 (NO   for ~67ms, ~2 loops)
% pulse A.pSC.U(3) = -1 (DOWN for ~67ms, ~2 loops)
% pulse A.pSC.U(3) =  0 (NO   for ~67ms, ~2 loops)
% pulse A.pSC.U(3) =  1 (UP   for ~67ms, ~2 loops)
% pulse A.pSC.U(3) =  0 (NO   for ~67ms, ~2 loops)
%_______________________________________________
% Total> 12 control loops + 10sec takeoff

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
tmax        = 12;   % experiment time in seconds
SIG         = 1/10;  % control signal input

%% run 
A.rTakeOff
pause(10) % take flight and hover for 10secs.

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

while NOW < tmax

    % EMERGENCY LOOP-BREAKER 
    J.mRead; % Update joystick data
    if (J.pDigital(DESIRED) == state)
        disp('EMERGENCY BREAK SUCCESSFUL!')
        break
        % stop experiment if DESIRED button is pressed.
    end

    % UPDATE EXP TIME
    NOW = toc(t);

    % COMMAND LOOP
    if toc(tc) > 1/30
        
        tc = tic;

        if NOW<= tmax*(2/12)
            A.pSC.Ud = [0 SIG 0 0]';
            disp('Input:')
            disp(A.pSC.Ud)
        end

        if NOW>= tmax*(2/12) && NOW<= tmax*(4/12)
            A.pSC.Ud = [0 -1.2*SIG 0 0]';
            disp('Input:')
            disp(A.pSC.Ud)
        end

        if NOW>= tmax*(4/12) && NOW<= tmax*(6/12)
            A.pSC.Ud = [0 1.4*SIG 0 0]';
            disp('Input:')
            disp(A.pSC.Ud)
        end

        if NOW>= tmax*(6/12) && NOW<= tmax*(8/12)
            A.pSC.Ud = [0 -1.6*SIG 0 0]';
            disp('Input:')
            disp(A.pSC.Ud)
        end

        if NOW>= tmax*(8/12) && NOW<= tmax*(10/12)
            A.pSC.Ud = [0 1.8*SIG 0 0]';
            disp('Input:')
            disp(A.pSC.Ud)
        end

        if NOW>= tmax*(10/12) && NOW<= tmax
            A.pSC.Ud = [0 -2*SIG 0 0]';
            disp('Input:')
            disp(A.pSC.Ud)
        end

        % Update and save flight data
        A.rGetSensorData
        rb = OPT.RigidBody;
        virtA = getOptData(rb,virtA);

        % TODO prealocate matrices
        X_drone     = [X_drone, A.pPos.X];   
        dX_drone    = [dX_drone, A.pPos.dX];  
        X_opt       = [X_opt, virtA.pPos.X]; 
        dX_opt      = [dX_opt, virtA.pPos.dX];
        controlSig  = [controlSig, A.pSC.U];   
        dControlSig = [dControlSig, A.pSC.Ud];   
        TIME        = [TIME, NOW];
        
        A.rSendControlSignals
    end
end

% Land and close connection
A.rLand
A.rDisconnect

%% Save results
robo = 'LARANJA';
exp = datestr(now);
exp([3,7,12,15,18]) = '_';
exp = ['(Strategies and Solutions)\strats_dataDrivenModel_m\data\','THETA_',exp,'_',robo,'.mat'];
save(exp)