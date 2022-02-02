%% Selects, reads and plots info from strats_dataDrivenModel_m experiments 
% 
clearvars;close all;clc;

try
    disp('Select a COMPLETED experiment:')
    file = uigetfile('*.mat');
    
    if contains(file,'COMPLETO')
        expType = extractBefore(file,'_');
        load(file,'TIME','dControlSig','X_opt','X_drone')
    else
        disp('Incomplete experiment chosen.')
        error('')
    end

%% Display input vs. output

% Approximate and filter derivatives (velocities)
for ii = 7:12
   nElem = 3;
   Tclock = 1/3;
   X_opt(ii,:) = [X_opt(ii,1),...
                  filter(ones(1,nElem),nElem,diff(X_opt(ii-6,:))./Tclock)];
end
        
if strcmp(expType,'PHI')
    pos = 1;
    plot(TIME, dControlSig(pos,:))
    grid on
%     ylim([-0.21,0.21])
    hold on
    plot(TIME, X_opt(4,:)*(180/pi))
    xlabel('Time [s]')
    ylabel('\phi [ -- ]')
    title('\phi')
end

if strcmp(expType,'THETA')
    pos = 2;
    plot(TIME, dControlSig(pos,:))
    grid on
%     ylim([-0.21,0.21])
    hold on
    plot(TIME, X_opt(5,:)*(180/pi))
    xlabel('Time [s]')
    ylabel('\theta [ -- ]')
    title('\theta')
end

if strcmp(expType,'ZDOT')
    pos = 3;
    figure(1)
    plot(TIME, dControlSig(pos,:))
    grid on
%     ylim([-1,1])
    hold on
    plot(TIME, X_opt(9,:))
    xlabel('Time [s]')
    ylabel('d\z')
end

if strcmp(expType,'PSIDOT')
    pos = 4;
    plot(TIME, dControlSig(pos,:))
    grid on
%     ylim([-1,1])
    hold on
    plot(TIME, X_opt(12,:)*(180/pi))
    xlabel('Time [s]')
    ylabel('d\psi')
end

%% Displays x,y,z,phi,theta,psi

figure(2)
subplot(421)
plot(TIME, X_opt(1,:))
ylabel('x [m]')
grid on
hold on
% plot(TIME, dControlSig(pos,:))

subplot(423)
plot(TIME, X_opt(2,:))
ylabel('y [m]')
grid on
hold on
% plot(TIME, dControlSig(pos,:))

subplot(425)
plot(TIME, X_opt(3,:))
ylabel('z [m]')
xlabel('t [s]')
grid on
hold on
% plot(TIME, dControlSig(pos,:))

subplot(422)
title('X')
plot(TIME, X_opt(4,:))
ylabel('\phi [ º]')
grid on
hold on
% plot(TIME, dControlSig(pos,:))

subplot(424)
plot(TIME, X_opt(5,:)*(180/pi))
ylabel('\theta [ º]')
grid on
hold on
% plot(TIME, dControlSig(pos,:))

subplot(426)
plot(TIME, X_opt(6,:)*(180/pi))
ylabel('\psi [ º]')
xlabel('t [s]')
grid on
hold on
% plot(TIME, dControlSig(pos,:))

subplot(427)
plot(TIME, dControlSig(pos,:))
grid on

subplot(428)
plot(TIME, dControlSig(pos,:))
grid on

%% Displays dx,dy,dz,dphi,dtheta,dpsi

figure(3)
subplot(421)
plot(TIME, X_opt(7,:))
ylabel('dx [m/s]')
grid on
hold on
% plot(TIME, dControlSig(pos,:))

subplot(423)
plot(TIME, X_opt(8,:))
ylabel('dy [m/s]')
grid on
hold on
% plot(TIME, dControlSig(pos,:))

subplot(425)
plot(TIME, X_opt(9,:))
ylabel('dz [m/s]')
xlabel('t [s]')
grid on
hold on
% plot(TIME, dControlSig(pos,:))

subplot(422)
title('dX')
plot(TIME, X_opt(10,:)*(180/pi))
ylabel('d\phi [ º]')
grid on
hold on
% plot(TIME, dControlSig(pos,:))

subplot(424)
plot(TIME, X_opt(11,:)*(180/pi))
ylabel('d\theta [ º]')
grid on
hold on
% plot(TIME, dControlSig(pos,:))

subplot(426)
plot(TIME, X_opt(12,:)*(180/pi))
ylabel('d\psi [ º]')
xlabel('t [s]')
grid on
hold on
% plot(TIME, dControlSig(pos,:))

subplot(427)
plot(TIME, dControlSig(pos,:))
grid on

subplot(428)
plot(TIME, dControlSig(pos,:))
grid on

catch
    disp('No file selected!')
    expType = 'NONE';
end
    