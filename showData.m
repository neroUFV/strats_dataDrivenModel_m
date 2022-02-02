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
    
catch
    disp('No file selected!')
    expType = 'NONE';
end

if strcmp(expType,'PHI')
    plot(TIME, dControlSig(1,:))
    grid on
    ylim([-0.21,0.21])
    hold on
    plot(TIME, X_opt(4,:))
    xlabel('Time [s]')
    ylabel('\phi [ -- ]')
    title('\phi')
end

if strcmp(expType,'THETA')
    plot(TIME, dControlSig(2,:))
    grid on
    ylim([-0.21,0.21])
    hold on
    plot(TIME, X_opt(5,:))
    xlabel('Time [s]')
    ylabel('\theta [ -- ]')
    title('\theta')
end

if strcmp(expType,'ZDOT')
    plot(TIME, dControlSig(3,:))
    grid on
    ylim([-1,1])
    hold on
    plot(TIME(1,2:end), diff(X_opt(3,:)))
    xlabel('Time [s]')
end

if strcmp(expType,'PSIDOT')
    plot(TIME, dControlSig(4,:))
    grid on
    ylim([-1,1])
    hold on
    plot(TIME(1,2:end), diff(X_opt(6,:)))
    xlabel('Time [s]')
end
