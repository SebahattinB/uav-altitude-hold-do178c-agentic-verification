%% generate_harness_tests.m
% Creates tests/uav_altitude_hold_harness_tests.mldatx: a Simulink Test
% file with one baseline test case per harness (Harness1 nominal
% tracking, Harness2 input-validity/fallback edge cases). Captures a
% fresh baseline from the current model behavior, then runs both test
% cases and reports pass/fail. Requires generate_test_harnesses.m to
% have been run first (harness .slx files must exist in model/).

projectRoot = fileparts(fileparts(mfilename('fullpath')));
modelDir = fullfile(projectRoot,'model');
testsDir = fullfile(projectRoot,'tests');
addpath(modelDir);

mdl = 'uav_altitude_hold';
h1Name = 'uav_altitude_hold_Harness1';
h2Name = 'uav_altitude_hold_Harness2';

% Close any stale open test files and clear the Test Manager cache so
% this script can be re-run cleanly.
openFiles = sltest.testmanager.getTestFiles();
for i = 1:numel(openFiles)
    openFiles(i).close();
end
sltest.testmanager.clear();

testFilePath = fullfile(testsDir,'uav_altitude_hold_harness_tests.mldatx');
baseline1 = fullfile(testsDir,'baseline_harness1.mat');
baseline2 = fullfile(testsDir,'baseline_harness2.mat');
for f = {testFilePath, baseline1, baseline2}
    if exist(f{1},'file'); delete(f{1}); end
end

tf = sltest.testmanager.TestFile(testFilePath);

% A fresh TestFile seeds a placeholder "New Test Suite 1" / "New Test
% Case 1"; remove it before adding the real suite.
stubSuites = tf.getTestSuites();
for i = 1:numel(stubSuites)
    stubSuites(i).remove();
end

ts = tf.createTestSuite('Harness Tests');

tc1 = ts.createTestCase('baseline','Harness1 - Nominal Tracking');
tc1.setProperty('Model',mdl,'HarnessOwner',mdl,'HarnessName',h1Name, ...
    'OverrideStopTime',true,'StopTime',6);
tc1.Description = 'Closed-loop response to hover, climb, and descend commands (Harness1).';
tc1.captureBaselineCriteria(baseline1, false);

tc2 = ts.createTestCase('baseline','Harness2 - Input Validity Fallback');
tc2.setProperty('Model',mdl,'HarnessOwner',mdl,'HarnessName',h2Name, ...
    'OverrideStopTime',true,'StopTime',10);
tc2.Description = 'Sensor-invalid, out-of-range altitude, and out-of-range rate all fall back to 0.5 (Harness2).';
tc2.captureBaselineCriteria(baseline2, false);

tf.saveToFile();

result = tf.run();
fileResult = result.getTestFileResults();
fprintf('Harness test file: %s (%d/%d passed)\n', fileResult.Outcome, fileResult.NumPassed, fileResult.NumTotal);

tf.close();
close_system(mdl,0);
