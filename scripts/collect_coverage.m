%% collect_coverage.m
% Collects Simulink structural coverage (Decision/Condition/MCDC) for
% uav_altitude_hold across all 10 MATLAB unit test scenarios plus both
% Simulink Test harness scenarios, merges it, and writes a single HTML
% coverage report to evidence/coverage/report.html.

projectRoot = fileparts(fileparts(mfilename('fullpath')));
modelDir = fullfile(projectRoot,'model');
testsDir = fullfile(projectRoot,'tests');
evidenceDir = fullfile(projectRoot,'evidence');
addpath(modelDir);

mdl = 'uav_altitude_hold';
bdclose('all');
load_system(fullfile(modelDir,[mdl '.slx']));
set_param(mdl,'CovEnable','on');
set_param(mdl,'CovMetricStructuralLevel','MCDC');
set_param(mdl,'CovSaveOutputData','on');
set_param(mdl,'CovSaveSingleToWorkspaceVar','on');

% Same 14 scenarios as tests/test_uav_altitude_hold.m.
scenarios = {
  % altCmd, altMeas, vzMeas, sensorValid
  {60,  50, 0,  true}   % nominal positive error
  {40,  50, 0,  true}   % nominal negative error
  {50,  50, 0,  true}   % zero error, holds trim
  {50,  50, 5,  true}   % rate damping
  {500, 0,  0,  true}   % saturates high
  {0,   500,0,  true}   % saturates low
  {60,  50, 0,  false}  % fallback: sensor invalid
  {-10, 50, 0,  true}   % fallback: alt_cmd below range
  {600, 50, 0,  true}   % fallback: alt_cmd above range
  {60, -10, 0,  true}   % fallback: alt_meas below range
  {60, 600, 0,  true}   % fallback: alt_meas above range
  {60,  50,-20, true}   % fallback: vz below range
  {60,  50, 20, true}   % fallback: vz above range
  {NaN, 50, 0,  true}   % fallback: non-finite input
};

dt = 0.02; stopTime = 4;
t = (0:dt:stopTime)';
n = numel(t);

cvTotal = [];
for i = 1:numel(scenarios)
    sc = scenarios{i};
    ds = Simulink.SimulationData.Dataset;
    ds = ds.addElement(timeseries(sc{1}*ones(n,1), t), 'alt_cmd');
    ds = ds.addElement(timeseries(sc{2}*ones(n,1), t), 'alt_meas');
    ds = ds.addElement(timeseries(sc{3}*ones(n,1), t), 'vz_meas');
    ds = ds.addElement(timeseries(repmat(logical(sc{4}),n,1), t), 'sensor_valid');

    in = Simulink.SimulationInput(mdl);
    in = in.setModelParameter('StopTime', num2str(stopTime));
    in = in.setExternalInput(ds);
    out = sim(in);

    if isempty(cvTotal)
        cvTotal = out.covdata;
    else
        cvTotal = cvTotal + out.covdata;
    end
end

% Fold in both Simulink Test harness scenarios (Test Manager coverage).
openFiles = sltest.testmanager.getTestFiles();
for i = 1:numel(openFiles)
    try, openFiles(i).close(); catch, end
end
sltest.testmanager.clear();

tf = sltest.testmanager.TestFile(fullfile(testsDir,'uav_altitude_hold_harness_tests.mldatx'));
cs = tf.getCoverageSettings();
cs.RecordCoverage = true;
result = tf.run();
harnessCov = result.getCoverageResults();
tf.close();

cvTotal = cvTotal + harnessCov;

covReportDir = fullfile(evidenceDir,'coverage');
if ~exist(covReportDir,'dir'); mkdir(covReportDir); end
cvhtml(fullfile(covReportDir,'report'), cvTotal);
fprintf('Coverage report written to %s\n', fullfile(covReportDir,'report.html'));
