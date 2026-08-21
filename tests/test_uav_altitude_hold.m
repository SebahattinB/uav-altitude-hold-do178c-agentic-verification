classdef test_uav_altitude_hold < matlab.unittest.TestCase
    % Model-level unit tests for the uav_altitude_hold controller.
    % Covers nominal control behavior, output saturation, and every
    % input-validity fallback path.

    properties (Constant)
        ModelName = 'uav_altitude_hold'
        Dt = 0.02
        StopTime = 4
    end

    methods (TestClassSetup)
        function loadModel(testCase)
            projectRoot = fileparts(fileparts(mfilename('fullpath')));
            addpath(fullfile(projectRoot,'model'));
            load_system(testCase.ModelName);
            testCase.addTeardown(@() close_system(testCase.ModelName,0));
        end
    end

    methods (Access = private)
        function y = runOnce(testCase, altCmd, altMeas, vzMeas, sensorValid)
            % Run the model for one StopTime with constant inputs (fed to
            % the root Inport ports via ExternalInput) and return the
            % throttle_cmd value at the final time step.
            t = (0:testCase.Dt:testCase.StopTime)';
            n = numel(t);
            ds = Simulink.SimulationData.Dataset;
            ds = ds.addElement(timeseries(altCmd*ones(n,1), t), 'alt_cmd');
            ds = ds.addElement(timeseries(altMeas*ones(n,1), t), 'alt_meas');
            ds = ds.addElement(timeseries(vzMeas*ones(n,1), t), 'vz_meas');
            ds = ds.addElement(timeseries(repmat(logical(sensorValid), n, 1), t), 'sensor_valid');
            in = Simulink.SimulationInput(testCase.ModelName);
            in = in.setModelParameter('StopTime', num2str(testCase.StopTime));
            in = in.setExternalInput(ds);
            out = sim(in);
            logged = out.get('yout');
            sig = logged.getElement(1); % single root Outport (throttle_cmd)
            y = sig.Values.Data(end);
        end
    end

    methods (Test)
        function testNominalTracking_PositiveError(testCase)
            % alt_cmd above alt_meas => throttle above hover trim (0.5)
            y = testCase.runOnce(60, 50, 0, true);
            testCase.verifyGreaterThan(y, 0.5);
        end

        function testNominalTracking_NegativeError(testCase)
            % alt_cmd below alt_meas => throttle below hover trim (0.5)
            y = testCase.runOnce(40, 50, 0, true);
            testCase.verifyLessThan(y, 0.5);
        end

        function testZeroErrorHoldsTrim(testCase)
            % No error, no rate => throttle settles at hover trim (0.5)
            y = testCase.runOnce(50, 50, 0, true);
            testCase.verifyEqual(y, 0.5, 'AbsTol', 1e-6);
        end

        function testRateDamping(testCase)
            % Positive vertical rate at zero error should pull throttle
            % below trim (damping opposes climb).
            y = testCase.runOnce(50, 50, 5, true);
            testCase.verifyLessThan(y, 0.5);
        end

        function testOutputSaturatesHigh(testCase)
            % Large positive error saturates throttle at the upper limit.
            y = testCase.runOnce(500, 0, 0, true);
            testCase.verifyEqual(y, 1.0, 'AbsTol', 1e-9);
        end

        function testOutputSaturatesLow(testCase)
            % Large negative error saturates throttle at the lower limit.
            y = testCase.runOnce(0, 500, 0, true);
            testCase.verifyEqual(y, 0.0, 'AbsTol', 1e-9);
        end

        function testFallbackOnSensorInvalid(testCase)
            y = testCase.runOnce(60, 50, 0, false);
            testCase.verifyEqual(y, 0.5, 'AbsTol', 1e-9);
        end

        function testFallbackOnAltCmdBelowRange(testCase)
            y = testCase.runOnce(-10, 50, 0, true);
            testCase.verifyEqual(y, 0.5, 'AbsTol', 1e-9);
        end

        function testFallbackOnAltCmdAboveRange(testCase)
            y = testCase.runOnce(600, 50, 0, true);
            testCase.verifyEqual(y, 0.5, 'AbsTol', 1e-9);
        end

        function testFallbackOnAltMeasBelowRange(testCase)
            y = testCase.runOnce(60, -10, 0, true);
            testCase.verifyEqual(y, 0.5, 'AbsTol', 1e-9);
        end

        function testFallbackOnAltMeasAboveRange(testCase)
            y = testCase.runOnce(60, 600, 0, true);
            testCase.verifyEqual(y, 0.5, 'AbsTol', 1e-9);
        end

        function testFallbackOnVerticalRateBelowRange(testCase)
            y = testCase.runOnce(60, 50, -20, true);
            testCase.verifyEqual(y, 0.5, 'AbsTol', 1e-9);
        end

        function testFallbackOnVerticalRateAboveRange(testCase)
            y = testCase.runOnce(60, 50, 20, true);
            testCase.verifyEqual(y, 0.5, 'AbsTol', 1e-9);
        end

        function testFallbackOnNonFiniteInput(testCase)
            y = testCase.runOnce(NaN, 50, 0, true);
            testCase.verifyEqual(y, 0.5, 'AbsTol', 1e-9);
        end
    end
end
