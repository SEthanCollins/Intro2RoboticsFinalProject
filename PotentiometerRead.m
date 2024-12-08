clear all
close all
clc

% Initialize connection to Arduino
arduinoObj = arduino('COM5', 'Mega2560', 'Libraries', 'Adafruit/MotorShieldV2');

% Create Adafruit motor shield object
shield = addon(arduinoObj, 'Adafruit/MotorShieldV2');

% Define analog input pins and corresponding motors
potentiometerPins = {'A8', 'A9', 'A10', 'A11'};
motorMap = {'Motor 4', 'Motor 2', 'Motor 3', 'Motor 1'};

% Read and display potentiometer values in the workspace
fprintf('Reading potentiometer values:\n');
for i = 1:length(potentiometerPins)
    % Read voltage from potentiometer
    pin = potentiometerPins{i};
    potValue = readVoltage(arduinoObj, pin);

    % Display potentiometer value and corresponding motor
    fprintf('%s (Pin %s): %.2f V\n', motorMap{i}, pin, potValue);
end

clear arduinoObj