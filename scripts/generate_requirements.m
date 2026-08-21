%% generate_requirements.m
% Creates requirements/uav_altitude_hold_requirements.slreqx: 7 HLRs, 13 LLRs,
% and 26 traceability links (13 HLR->LLR, 13 LLR->model block).
% Re-run this script any time the requirement set needs to be regenerated
% from scratch; it deletes and rebuilds the .slreqx file.

projectRoot = fileparts(fileparts(mfilename('fullpath')));
modelPath = fullfile(projectRoot,'model');
reqPath = fullfile(projectRoot,'requirements');
addpath(modelPath);

modelName = 'uav_altitude_hold';
load_system(fullfile(modelPath,[modelName '.slx']));

reqFile = fullfile(reqPath,'uav_altitude_hold_requirements.slreqx');

% Close any stale copy already loaded, then start clean.
existing = slreq.find('Type','ReqSet','Name','uav_altitude_hold_requirements');
for i = 1:numel(existing)
    existing(i).close('force',true);
end
slreq.clear();
if exist(reqFile,'file')
    delete(reqFile);
end
lockFile = fullfile(reqPath,'uav_altitude_hold_requirements~slreqx.slmx');
if exist(lockFile,'file')
    delete(lockFile);
end

rs = slreq.new(reqFile);

%% ---- High-Level Requirements (7) ----
hlr = struct();

hlr.HLR1 = rs.add('Summary','Throttle command tracks commanded altitude', ...
    'Type','Functional', ...
    'Description',['The altitude-hold controller shall compute a throttle command that ' ...
    'drives measured altitude toward commanded altitude.']);

hlr.HLR2 = rs.add('Summary','Proportional feedback on altitude error', ...
    'Type','Functional', ...
    'Description',['The controller shall use proportional feedback on the altitude error ' ...
    'between commanded and measured altitude.']);

hlr.HLR3 = rs.add('Summary','Vertical-rate damping', ...
    'Type','Functional', ...
    'Description',['The controller shall use vertical-rate damping to reduce overshoot and ' ...
    'oscillation around the commanded altitude.']);

hlr.HLR4 = rs.add('Summary','Bounded-integral action without windup', ...
    'Type','Functional', ...
    'Description',['The controller shall use a bounded-integral term to eliminate steady-state ' ...
    'altitude error without integrator windup.']);

hlr.HLR5 = rs.add('Summary','Input validity gating', ...
    'Type','Functional', ...
    'Description',['The controller shall validate all inputs for range and validity before ' ...
    'computing a throttle command.']);

hlr.HLR6 = rs.add('Summary','Safe hover fallback on invalid input', ...
    'Type','Functional', ...
    'Description',['Upon detection of an invalid input, the controller shall command a safe ' ...
    '0.50 hover throttle instead of a computed command.']);

hlr.HLR7 = rs.add('Summary','Output saturation and fixed-rate execution', ...
    'Type','Functional', ...
    'Description',['The controller shall limit the throttle command to the range [0.0, 1.0] and ' ...
    'shall execute deterministically at a fixed 0.02 s rate.']);

%% ---- Low-Level Requirements (13) ----
llr = struct();

llr.LLR1 = rs.add('Summary','Compute altitude error', ...
    'Type','Functional', ...
    'Description','The controller shall compute altitude error as commanded altitude minus measured altitude.');

llr.LLR2 = rs.add('Summary','Apply proportional gain Kp', ...
    'Type','Functional', ...
    'Description','The controller shall multiply altitude error by proportional gain Kp = 0.04 to produce the proportional term.');

llr.LLR3 = rs.add('Summary','Apply rate-damping gain Kd', ...
    'Type','Functional', ...
    'Description','The controller shall multiply measured vertical rate by rate-damping gain Kd = -0.06 to produce the damping term.');

llr.LLR4 = rs.add('Summary','Apply integral gain Ki', ...
    'Type','Functional', ...
    'Description','The controller shall multiply altitude error by integral gain Ki = 0.01 before accumulation.');

llr.LLR5 = rs.add('Summary','Accumulate integral at fixed rate', ...
    'Type','Functional', ...
    'Description','The controller shall accumulate the integral term at the model''s fixed 0.02 s sample rate.');

llr.LLR6 = rs.add('Summary','Clamp integral term (anti-windup)', ...
    'Type','Functional', ...
    'Description','The controller shall clamp the accumulated integral term to the range [-0.3, 0.3] to prevent windup.');

llr.LLR7 = rs.add('Summary','Combine trim, P, D, and I terms', ...
    'Type','Functional', ...
    'Description','The controller shall sum a fixed 0.5 hover-trim value with the proportional, damping, and integral terms to form the unsaturated throttle command.');

llr.LLR8 = rs.add('Summary','Reject out-of-range altitude', ...
    'Type','Functional', ...
    'Description','The controller shall reject a commanded or measured altitude that is outside the range [0, 500] meters.');

llr.LLR9 = rs.add('Summary','Reject out-of-range vertical rate', ...
    'Type','Functional', ...
    'Description','The controller shall reject a measured vertical rate that is outside the range [-15, 15] m/s.');

llr.LLR10 = rs.add('Summary','Reject inputs when sensor invalid', ...
    'Type','Functional', ...
    'Description','The controller shall reject all inputs when the sensor-valid flag is false.');

llr.LLR11 = rs.add('Summary','Treat non-finite values as invalid', ...
    'Type','Functional', ...
    'Description','The controller shall treat non-finite (NaN/Inf) commanded altitude, measured altitude, or vertical rate values as failing the range checks in LLR-8/LLR-9.');

llr.LLR12 = rs.add('Summary','Select fallback vs. computed command', ...
    'Type','Functional', ...
    'Description','The controller shall select between the computed throttle command and the fixed 0.50 fallback command using the combined validity result as the selector.');

llr.LLR13 = rs.add('Summary','Saturate final throttle command', ...
    'Type','Functional', ...
    'Description','The controller shall saturate the final throttle command to the range [0.0, 1.0] using a fixed upper/lower limit.');

%% ---- HLR -> LLR traceability links (13) ----
slreq.createLink(hlr.HLR2, llr.LLR1);
slreq.createLink(hlr.HLR2, llr.LLR2);
slreq.createLink(hlr.HLR3, llr.LLR3);
slreq.createLink(hlr.HLR4, llr.LLR4);
slreq.createLink(hlr.HLR4, llr.LLR5);
slreq.createLink(hlr.HLR4, llr.LLR6);
slreq.createLink(hlr.HLR1, llr.LLR7);
slreq.createLink(hlr.HLR5, llr.LLR8);
slreq.createLink(hlr.HLR5, llr.LLR9);
slreq.createLink(hlr.HLR5, llr.LLR10);
slreq.createLink(hlr.HLR5, llr.LLR11);
slreq.createLink(hlr.HLR6, llr.LLR12);
slreq.createLink(hlr.HLR7, llr.LLR13);

%% ---- LLR -> model block traceability links (13) ----
bh = @(path) get_param([modelName '/' path],'Handle');

slreq.createLink(llr.LLR1,  bh('Control Law/Altitude Error'));
slreq.createLink(llr.LLR2,  bh('Control Law/Kp (Proportional)'));
slreq.createLink(llr.LLR3,  bh('Control Law/Kd (Rate Damping)'));
slreq.createLink(llr.LLR4,  bh('Control Law/Ki (Integral Gain)'));
slreq.createLink(llr.LLR5,  bh('Control Law/Bounded Integral'));
slreq.createLink(llr.LLR6,  bh('Control Law/Bounded Integral'));
slreq.createLink(llr.LLR7,  bh('Control Law/Combine Terms'));
slreq.createLink(llr.LLR8,  bh('Input Validity Gate/All Conditions AND'));
slreq.createLink(llr.LLR9,  bh('Input Validity Gate/All Conditions AND'));
slreq.createLink(llr.LLR10, bh('Input Validity Gate/All Conditions AND'));
slreq.createLink(llr.LLR11, bh('Input Validity Gate/All Conditions AND'));
slreq.createLink(llr.LLR12, bh('Fallback Switch'));
slreq.createLink(llr.LLR13, bh('Control Law/Output Saturation'));

rs.save();

topLevel = rs.children();
totalLinks = 0;
for i = 1:numel(topLevel)
    totalLinks = totalLinks + numel(topLevel(i).outLinks());
end
fprintf('Requirements: %d (expected 20: 7 HLR + 13 LLR)\n', numel(topLevel));
fprintf('Links: %d (expected 26)\n', totalLinks);

rs.close('force',true);
