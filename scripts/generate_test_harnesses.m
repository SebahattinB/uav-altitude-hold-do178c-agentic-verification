%% generate_test_harnesses.m
% Creates two Simulink Test harnesses for uav_altitude_hold:
%   Harness1 - nominal closed-loop tracking scenario (3 steps)
%   Harness2 - input-validity / fallback edge-case scenario (5 steps)
% Both use a Test Sequence block as stimulus source. Re-run this script
% any time the harnesses need to be rebuilt from scratch.

projectRoot = fileparts(fileparts(mfilename('fullpath')));
modelDir = fullfile(projectRoot,'model');
addpath(modelDir);

mdl = 'uav_altitude_hold';
close_system(mdl,0);
load_system(fullfile(modelDir,[mdl '.slx']));

h1Name = 'uav_altitude_hold_Harness1';
h2Name = 'uav_altitude_hold_Harness2';

for hn = {h1Name, h2Name}
    try, sltest.harness.delete(mdl, hn{1}); catch, end
    f = fullfile(modelDir, [hn{1} '.slx']);
    if exist(f,'file'); delete(f); end
end

%% ---- Harness1: nominal closed-loop tracking ----
sltest.harness.create(mdl, 'Name',h1Name, 'Source','Test Sequence', ...
    'SaveExternally',true, 'HarnessPath',modelDir, ...
    'Description','Nominal closed-loop tracking: hover, climb command, descend command.');
sltest.harness.open(mdl, h1Name);

rt = sfroot;
m1 = rt.find('-isa','Stateflow.Machine','Name',h1Name);
run1 = m1.find('-isa','Stateflow.State','Name','Run');

steps1 = {
  {'step_1','50','50','0','true'}    % zero error, hover trim
  {'step_2','60','50','1','true'}    % climb command
  {'step_3','40','50','-1','true'}   % descend command
  {'step_4','500','0','0','true'}    % output saturates high
  {'step_5','0','500','0','true'}    % output saturates low
};
buildTestSequenceSteps(run1, steps1);
addLoggedOutport(h1Name);

set_param(h1Name,'SimulationCommand','update');
save_system(h1Name);
close_system(h1Name,0);

%% ---- Harness2: input-validity / fallback edge cases ----
sltest.harness.create(mdl, 'Name',h2Name, 'Source','Test Sequence', ...
    'SaveExternally',true, 'HarnessPath',modelDir, ...
    'Description','Input-validity gating and hover-fallback edge cases.');
sltest.harness.open(mdl, h2Name);

m2 = rt.find('-isa','Stateflow.Machine','Name',h2Name);
run2 = m2.find('-isa','Stateflow.State','Name','Run');

steps2 = {
  {'step_1','55','50','0','true'}     % valid baseline
  {'step_2','55','50','0','false'}    % sensor invalid -> fallback
  {'step_3','600','50','0','true'}    % alt_cmd above range -> fallback
  {'step_4','55','50','25','true'}    % vz_meas above range -> fallback
  {'step_5','-10','50','0','true'}    % alt_cmd below range -> fallback
  {'step_6','55','-10','0','true'}    % alt_meas below range -> fallback
  {'step_7','55','600','0','true'}    % alt_meas above range -> fallback
  {'step_8','55','50','-20','true'}   % vz_meas below range -> fallback
  {'step_9','55','50','0','true'}     % recovery to valid
};
buildTestSequenceSteps(run2, steps2);
addLoggedOutport(h2Name);

set_param(h2Name,'SimulationCommand','update');
save_system(h2Name);
close_system(h2Name,0);

close_system(mdl,0);
fprintf('Harnesses generated: %s.slx, %s.slx\n', h1Name, h2Name);

%% ---------------------------------------------------------------------
function addLoggedOutport(harnessName)
% Test-Sequence-sourced harnesses route their output back into the Test
% Sequence block via a Goto/From pair (for in-sequence assessment) and
% have no root Outport, so nothing lands in the default 'yout' Dataset.
% Branch a root Outport off the Output Conversion Subsystem so
% sim()/Test Manager baseline capture has a real signal to log.
    ocs = [harnessName '/Output Conversion Subsystem'];
    outp = add_block('simulink/Sinks/Out1', [harnessName '/throttle_cmd_out']);
    ocsPorts = get_param(ocs,'PortHandles');
    outpPorts = get_param(outp,'PortHandles');
    add_line(harnessName, ocsPorts.Outport(1), outpPorts.Inport(1), 'autorouting','on');
end

function buildTestSequenceSteps(runState, steps)
% Populate a Test Sequence "Run" superstate with a linear chain of step
% sub-states, each holding constant values for 2 seconds before
% transitioning to the next step.
    n = numel(steps);
    states = cell(1,n);
    stepWidth = 130;
    gap = 30;
    for i = 1:n
        st = Stateflow.State(runState);
        st.Name = steps{i}{1};
        st.LabelString = sprintf('%s\nalt_cmd = %s;\nalt_meas = %s;\nvz_meas = %s;\nsensor_valid = %s;', ...
            steps{i}{1}, steps{i}{2}, steps{i}{3}, steps{i}{4}, steps{i}{5});
        st.Position = [40 + (i-1)*(stepWidth+gap), 100, stepWidth, 70];
        states{i} = st;
    end

    runState.Position = [20, 60, n*(stepWidth+gap)+40, 150];

    dt = Stateflow.Transition(runState);
    dt.Destination = states{1};
    top = [states{1}.Position(1) + states{1}.Position(3)/2, states{1}.Position(2)];
    dt.SourceEndPoint = top + [0 -40];
    dt.DestinationEndPoint = top;
    dt.Midpoint = top + [0 -20];

    for i = 1:n-1
        tr = Stateflow.Transition(runState);
        tr.Source = states{i};
        tr.Destination = states{i+1};
        tr.LabelString = 'after(2,sec)';
    end
end
