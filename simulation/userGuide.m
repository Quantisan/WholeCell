% User guide
%
% Author: Jonathan Karr, jkarr@stanford.edu
% Affilitation: Covert Lab, Department of Bioengineering, Stanford University
% Last updated: 2/13/2012

%% Lesson 1: run simulation with default parameter values
%1. Supress warnings, add whole-cell code to MATLAB path. These functions
%   only need to called once at the beginning of each MATLAB session.
setWarnings();
setPath();

%2. Run simulation
runSimulation();

%% Lesson 2: override parameter values using XML file and run simulation
%1. Supress warnings, add whole-cell code to MATLAB path. These functions
%   only need to called once at the beginning of each MATLAB session.
setWarnings();
setPath();

%2. Import classes
import edu.stanford.covert.cell.sim.util.SimulationDiskUtil;

%3. Select
%   a. simulation batch output directory and
%   b. simulation output directory
simBatch = datestr(now, 'yyyy_mm_dd_HH_MM_SS');
simIdx = 1;
simBatchDir = [SimulationDiskUtil.getBaseDir() filesep simBatch];
simDir = [SimulationDiskUtil.getBaseDir() filesep simBatch filesep num2str(simIdx)];

%4. Create simulation batch and simulation output directories
if ~isdir(simBatchDir)
    mkdir(simBatchDir); %create simulation batch output directory
end
if ~isdir(simDir)
    mkdir(simDir); %create simulation output directory
end

%5. Generate XML description of desired parameter values from
%   http://wholecell.stanford.edu/simulation/runSimulations.php, save XML
%   file to <simDir>/conditions.xml
%   - Select a short simulation length that is a multiple of 100, eg. 100

%6. Run simulation and save simulated dynamics to disk
runSimulation(simDir);

%% Lesson 3: programmatically override parameter values and run simulation
%import classes
import edu.stanford.covert.cell.sim.util.CachedSimulationObjectUtil;
import edu.stanford.covert.cell.sim.util.DiskLogger;
import edu.stanford.covert.cell.sim.util.SimulationDiskUtil;
import edu.stanford.covert.cell.sim.util.SummaryLogger;

%Select
%(1) simulation batch output directory and
%(2) simulation output directory
simBatch = datestr(now, 'yyyy_mm_dd_HH_MM_SS');
simIdx = 1;
simBatchDir = [SimulationDiskUtil.getBaseDir() filesep simBatch];
simDir = [SimulationDiskUtil.getBaseDir() filesep simBatch filesep num2str(simIdx)];

%create simulation batch and simulation output directories
if ~isdir(simBatchDir)
    mkdir(simBatchDir); %create simulation batch output directory
end
if ~isdir(simDir)
    mkdir(simDir); %create simulation output directory
end

%load simulation object with default parameter values
[sim, kbWID] = CachedSimulationObjectUtil.load();

%set parameter values
sim.applyOptions('lengthSec', 100);

parameterValues = struct();
parameterValues.states = struct();
parameterValues.states.Mass = struct();
parameterValues.states.Mass.cellInitialDryWeight = 4e-15;
parameterValues.processes = struct();
parameterValues.processes.Transcription = struct();
parameterValues.processes.Transcription.rnaPolymeraseElongationRate = 100;
sim.applyParameters(parameterValues);

%verify that parameter values correctly set
sim.getParameters().states.Mass.cellInitialDryWeight
sim.getParameters().processes.Transcription.rnaPolymeraseElongationRate

%setup loggers
summaryLogger = SummaryLogger(1, 1); %print to command line
summaryLogger.setOptions(struct('outputDirectory', simDir)); %save to disk

diskLogger = DiskLogger(simDir, 10); %save complete dynamics to disk
diskLogger.addMetadata(...
    'shortDescription',         'test simulation', ...
    'longDescription',          'test simulation', ...
    'email',                    'jkarr@stanford.edu', ...
    'firstName',                'Jonathan', ...
    'lastName',                 'Karr', ...
    'affiliation',              'Stanford University', ...
    'knowledgeBaseWID',         kbWID, ...
    'revision',                 1, ...
    'differencesFromRevision',  [], ...
    'userName',                 'jkarr', ...
    'hostName',                 'hostname.stanford.edu', ...
    'ipAddress',                '10.0.0.0');

loggers = {summaryLogger; diskLogger};

%run simulation
sim.run(loggers);

%% lesson 4: analyze summary log
%load summary log into memory
log = load([simDir filesep 'summary.mat']);

%plot data
subplot(2, 2, 1);
plot(log.time, log.mass * 1e15);
xlabel('Time (s)');
ylabel('Mass (fg)');

subplot(2, 2, 2);
plot(log.time, log.ploidy);
xlabel('Time (s)');
ylabel('Chr Copy No.');

subplot(2, 2, 3);
plot(log.time, log.rnas(1, :));
xlabel('Time (s)');
ylabel('RNA');

subplot(2, 2, 4);
plot(log.time, log.proteins(1, :));
xlabel('Time (s)');
ylabel('Protein');

%% lesson 5: analyze complete log
%import classes
import edu.stanford.covert.cell.sim.util.CachedSimulationObjectUtil;
import edu.stanford.covert.cell.sim.util.SimulationEnsemble;

%load simulaton object
sim = CachedSimulationObjectUtil.load();
comp = sim.compartment;
met = sim.process('Metabolism');
pc = sim.state('ProteinComplex');
pm = sim.state('ProteinMonomer');
rna = sim.state('Rna');
fluxIdx = met.reactionIndexs('AckA');
cpxIdx = pc.matureIndexs(pc.getIndexs('MG_357_DIMER'));
monIdx = pm.matureIndexs(pm.getIndexs('MG_357_MONOMER'));
rnaIdx = rna.matureIndexs(rna.getIndexs('TU_260'));

%load data
stateNames = {
    'Time'              'values'
    'Mass'              'cell'
    'MetabolicReaction' 'fluxs'
    'ProteinComplex'    'counts'
    'ProteinMonomer'    'counts'
    'Rna'               'counts'
    };
states = SimulationEnsemble.load(simBatchDir, stateNames, [], [], 1, 'extract', simIdx);

%plot
subplot(5, 1, 1);
plot(permute(states.Time.values, [1 3 2]), permute(sum(states.Mass.cell, 2), [1 3 2]) * 1e15);
ylabel('Mass (fg)');

subplot(5, 1, 2);
plot(permute(states.Time.values, [1 3 2]), permute(states.MetabolicReaction.fluxs(fluxIdx, :, :), [1 3 2]) * 1e-3);
ylabel({'Flux' '(10^3 rxn s^{-1})'});

subplot(5, 1, 3);
plot(permute(states.Time.values, [1 3 2]), permute(states.ProteinComplex.counts(cpxIdx, comp.cytosolIndexs, :), [1 3 2]));
ylabel('Complex');

subplot(5, 1, 4);
plot(permute(states.Time.values, [1 3 2]), permute(states.ProteinMonomer.counts(monIdx, comp.cytosolIndexs, :), [1 3 2]));
ylabel('Monomer');

subplot(5, 1, 5);
plot(permute(states.Time.values, [1 3 2]), permute(states.Rna.counts(rnaIdx, comp.cytosolIndexs, :), [1 3 2]));
ylabel('RNA');
xlabel('Time (s)');

%% lesson 6: construct and fit simulation
% import classes
import edu.stanford.covert.cell.kb.KnowledgeBaseUtil;
import edu.stanford.covert.cell.kb.KnowledgeBase;
import edu.stanford.covert.cell.sim.Simulation;
import edu.stanford.covert.cell.sim.util.FitConstants;
import edu.stanford.covert.db.MySQLDatabase;

% initialize
dbParams = config();
db = MySQLDatabase(dbParams);

% construct latest knowledge base from database
knowledgeBaseWID = KnowledgeBaseUtil.selectLatestKnowledgeBase(db);
kb = KnowledgeBase(db, knowledgeBaseWID);

% construct simulation and initialize its constants
simulation = Simulation(kb.states, kb.processes);
simulation.initializeConstants(kb);
fitter = FitConstants(simulation);
fitter.run();

% write simulation data
save('data/Simulation_fitted.mat', 'simulation', 'knowledgeBaseWID');

% clean up
db.close();