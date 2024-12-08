% Final Project: Industrial Robot Sorting Colored Boxes
% 12/2/2024
% Amber Jozwiak (1939687) and Ethan Collins (1918067)
% Introduction to Robotics - Dr. Becker

clear all
close all
clc
% Initialize connection to Arduino
arduinoObj = arduino('COM5', 'Mega2560', 'Libraries', 'Adafruit/MotorShieldV2'); 
% Create Adafruit motor shield object
shield = addon(arduinoObj, 'Adafruit/MotorShieldV2');

% Define the motors for left-right and up-down movement
% % motorBase = dcmotor(shield, 1);  % Motor 1 robot base
% % motorLink2 = dcmotor(shield, 3);  % Motor 3 for 2nd arm link
% % motorLink1 = dcmotor(shield, 2);  % Motor 2 for 1st arm link
% % motorClaw = dcmotor(shield, 4);  % Motor 4 for the claw

% Define analog input pins and corresponding motors
potentiometerPins = {'A9', 'A10', 'A11', 'A8'};
motorMap = {'First Link', 'Second Link', 'Base', 'Claw'};



% Define initial potentiometer values
initialPotValues =  [2.33, 0.87, 2.41, 2.42];
finalPotValues = [2.33, 0.87, 2.41, 2.42];
postSortPotValues = [1.90 , 1.25, 3.00, 2.42];

% Define bin-specific potentiometer values
yellowBinPotValues = [1.65, 0.60, 1.74, 3.05];
blueBinPotValues = [1.67, 0.60, 1.86, 3.05];
redBinPotValues = [1.49, 0.87, 2.05, 3.06];

% Initialize USB camera
camera = webcam('USB Camera');

% Function to move motors ORDER: Base, Link1, Link2, Claw
function moveMotorsToPotValues2(shield, arduinoObj, potentiometerPins, targetValues)
    for i = [3,1,2,4]
        motor = dcmotor(shield, i); % Get the motor object corresponding to the current pin
        currentValue = readVoltage(arduinoObj, potentiometerPins{i}); % Read the current potentiometer value
        fprintf('Current value on %s: %.2f V. Target: %.2f V\n', potentiometerPins{i}, currentValue, targetValues(i));

        % Adjust motor direction and speed until target value is reached
        while abs(currentValue - targetValues(i)) > 0.01 % Allowable error margin
            if currentValue < targetValues(i)
                motor.Speed = 0.4; % Move forward
                warning('off')
            else
                motor.Speed = -0.4; % Move backward
                warning('off')
            end

            start(motor); % Start the motor
            pause(0.1); % Allow movement
            currentValue = readVoltage(arduinoObj, potentiometerPins{i}); % Update current value
        end

        stop(motor); % Stop the motor once the target is reached
        fprintf('Motor %d adjusted to %.2f V\n', i, currentValue);
    end
end

% Function to move motors ORDER: Link1, Link2, Base, Claw
function moveMotorsToPotValues(shield, arduinoObj, potentiometerPins, targetValues)
    for i = 1:length(potentiometerPins)
        motor = dcmotor(shield, i); % Get the motor object corresponding to the current pin
        currentValue = readVoltage(arduinoObj, potentiometerPins{i}); % Read the current potentiometer value
        fprintf('Current value on %s: %.2f V. Target: %.2f V\n', potentiometerPins{i}, currentValue, targetValues(i));

        % Adjust motor direction and speed until target value is reached
        while abs(currentValue - targetValues(i)) > 0.01 % Allowable error margin
            if currentValue < targetValues(i)
                motor.Speed = 0.4; % Move forward
                warning('off')
            else
                motor.Speed = -0.4; % Move backward
                warning('off')
            end

            start(motor); % Start the motor
            pause(0.1); % Allow movement
            currentValue = readVoltage(arduinoObj, potentiometerPins{i}); % Update current value
        end

        stop(motor); % Stop the motor once the target is reached
        fprintf('Motor %d adjusted to %.2f V\n', i, currentValue);
    end
end

% Move motors to initial potentiometer readings
fprintf('Moving to initial potentiometer values:\n');
moveMotorsToPotValues(shield, arduinoObj, potentiometerPins, initialPotValues);

% Detect bin color using USB camera
fprintf('Detecting bin color:\n');
img = snapshot(camera);
imshow(img); % Display the captured image
color = ''; % Placeholder for color detection logic

% Detect red, blue, or yellow colors using a USB camera

    % Convert the frame to HSV for easier color segmentation
    hsvFrame = rgb2hsv(img);
    hue = hsvFrame(:, :, 1); % Hue channel
    saturation = hsvFrame(:, :, 2); % Saturation channel
    value = hsvFrame(:, :, 3); % Value channel

    % Thresholds for color detection
    redMask = (hue < 0.05 | hue > 0.95) & saturation > 0.5 & value > 0.5; % Red
    blueMask = (hue > 0.55 & hue < 0.65) & saturation > 0.5 & value > 0.5; % Blue
    yellowMask = (hue > 0.12 & hue < 0.17) & saturation > 0.5 & value > 0.5; % Yellow

    % Count the number of pixels in each mask
    redCount = sum(redMask(:));
    blueCount = sum(blueMask(:));
    yellowCount = sum(yellowMask(:));

    % Determine the dominant color
    [~, idx] = max([redCount, blueCount, yellowCount]);
    switch idx
        case 1
            color = 'red';
            disp('Detected Color: Red');
        case 2
            color = 'blue';
            disp('Detected Color: Blue');
        case 3
            color = 'yellow';
            disp('Detected Color: Yellow');
        otherwise
            color = 'none';
            disp('No dominant color detected.');
    end


% Wait 3 seconds after detecting the color
fprintf('Bin color detected: %s\n', color);
pause(3);

% Move motors based on detected bin color
if strcmp(color, 'yellow')
    fprintf('Moving to yellow bin potentiometer values:\n');
    moveMotorsToPotValues2(shield, arduinoObj, potentiometerPins, yellowBinPotValues);
elseif strcmp(color, 'blue')
    fprintf('Moving to blue bin potentiometer values:\n');
    moveMotorsToPotValues2(shield, arduinoObj, potentiometerPins, blueBinPotValues);
elseif strcmp(color, 'red')
    fprintf('Moving to red bin potentiometer values:\n');
    moveMotorsToPotValues2(shield, arduinoObj, potentiometerPins, redBinPotValues);
end

% Move motors to post-sort potentiometer values
fprintf('Moving to post-sort potentiometer values:\n');
moveMotorsToPotValues(shield, arduinoObj, potentiometerPins, postSortPotValues);
pause(2); % Wait 2 seconds

% Move motors back to final potentiometer readings
fprintf('Returning to final potentiometer values:\n');
moveMotorsToPotValues(shield, arduinoObj, potentiometerPins, finalPotValues);

fprintf('Program complete.\n');
