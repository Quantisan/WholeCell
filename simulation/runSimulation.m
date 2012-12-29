% Executes whole cell simulation.
%
% Author: Jonathan Karr, jkarr@stanford.edu
% Author: Jared Jacobs, jmjacobs@stanford.edu
% Affilitation: Covert Lab, Department of Bioengineering, Stanford University
% Last updated: 1/9/2011
function simulation = runSimulation(configDirectory, logToDisk, logToDatabase, child1Dir, child2Dir)
%% initialize
setWarnings();
setPath();
setPreferences();

%% import
import edu.stanford.covert.cell.sim.constant.Condition;
import edu.stanford.covert.cell.sim.util.ConditionSet;
import edu.stanford.covert.cell.sim.util.DatabaseLogger;
import edu.stanford.covert.cell.sim.util.DiskLogger;
import edu.stanford.covert.cell.sim.util.SummaryLogger;
import edu.stanford.covert.db.MySQLDatabase;

%% load simulation object
load('data/Simulation_fitted.mat');
simulation.constructRandStream();

%% process options, setup loggers
summaryLogger = SummaryLogger(1, 2);
loggers = {summaryLogger};
ic = [];

if nargin >= 1
    if ~exist([configDirectory filesep 'conditions.xml'], 'file')
        throw(MException('runSimulation:error', 'Directory must contain a condition xml file: %s', [configDirectory filesep 'conditions.xml']));
    end
    
    data = ConditionSet.parseConditionSet(simulation, [configDirectory filesep 'conditions.xml']);
    data.metadata.knowledgeBaseWID = knowledgeBaseWID;
    
    simulation.applyOptions(data.options);
    simulation.applyOptions(data.perturbations);
    simulation.applyParameters(data.parameters);
    summaryLogger.setOptions(struct('verbosity', simulation.verbosity, 'outputDirectory', configDirectory));
end

if nargin >= 1 && exist([configDirectory filesep 'initialConditions.mat'], 'file')
    ic = load([configDirectory filesep 'initialConditions.mat']);
end

if nargin >= 2 && ((ischar(logToDisk) && strcmp(logToDisk, 'true')) || ((islogical(logToDisk) || isnumeric(logToDisk)) && logToDisk))
    diskLogger = DiskLogger(configDirectory, 100);
    diskLogger.addMetadata(data.metadata);
    loggers = [loggers; {diskLogger}];
end

if nargin >= 3 && ((ischar(logToDatabase) && strcmp(logToDatabase, 'true')) || ((islogical(logToDatabase) || isnumeric(logToDatabase)) && logToDatabase))
    databaseLogger = DatabaseLogger(MySQLDatabase(config), 1000);
    databaseLogger.addMetadata(data.metadata);
    loggers = [loggers; {databaseLogger}];
end

%% simulate
try
    % cell cycle up to, but not including division
    simulation.run(ic, loggers);
    
    % division
    if nargin >= 4 && ...
        simulation.state('Chromosome').ploidy == 2 && ...
        simulation.state('Chromosome').segregated && ...
        simulation.state('Geometry').pinchedDiameter == 0
        [~, daughters] = simulation.divideState();
        
        daughter1 = daughters(1);
        daughter2 = daughters(2);
        
        save([child1Dir filesep 'initialConditions.mat'], '-struct', 'daughter1');
        save([child2Dir filesep 'initialConditions.mat'], '-struct', 'daughter2');
    end
catch exception
    if nargin == 0
        errFile = ['tmp' filesep 'simulation_error_' datestr(now, 'yyyy_mm_dd_HH_MM_SS_FFF') '.mat'];
    else
        errFile = [configDirectory filesep 'err.mat'];
    end
	try
		save(errFile, 'simulation');
	catch saveException
		exception.addCause(MException('Simulation:runTimeError', ...
			'Simulation run-time error at %d. Unable to save simulation and exiting.', ...
			simulation.state('Time').values)).addCause(saveException).rethrow();
	end
    exception.addCause(MException('Simulation:runTimeError', ...
        'Simulation run-time error at %d. Saving simulation at ''%s'' and exiting.', ...
        simulation.state('Time').values, errFile)).rethrow();
end