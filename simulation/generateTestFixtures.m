% Generates test fixtures for whole cell simulation.
%
% Author: Jonathan Karr, jkarr@stanford.edu
% Author: Jared Jacobs, jmjacobs@stanford.edu
% Affilitation: Covert Lab, Department of Bioengineering, Stanford University
% Last updated: 5/31/2011

%% initialize
setWarnings();
setPath();
setPreferences();

[knowledgeBase, knowledgeBaseWID] = cacheKnowledgeBase();
[simulation] = cacheSimulation(knowledgeBase, knowledgeBaseWID);

%% verify initial growth rate distribution
mr = simulation.state('MetabolicReaction');
initialGrowthFilterWidth = mr.initialGrowthFilterWidth;
mr.initialGrowthFilterWidth = Inf;
growths = zeros(100, 1);
for i = 1:100
    simulation.applyOptions('seed', i);
    simulation.initializeState();
    growths(i) = mr.growth;
end
mr.initialGrowthFilterWidth = initialGrowthFilterWidth;
assertElementsAlmostEqual(mr.meanInitialGrowthRate, mean(growths(growths > 1e-6)), 'relative', 10e-2);
assertElementsAlmostEqual(mr.meanInitialGrowthRate, median(growths(growths > 1e-6)), 'relative', 10e-2);

%% write simulation data
data = {'options', 'parameters', 'fixedConstants', 'fittedConstants'};
for  i = 1:numel(data)
    fid = fopen(sprintf('data/%s.json', data{i}), 'w');
    tmp = simulation.(['get' upper(data{i}(1)) data{i}(2:end)])();
    if ismember(data{i}, {'fixedConstants', 'fittedConstants'})
        for j = 1:numel(simulation.states)
            stateID = simulation.states{j}.wholeCellModelID(7:end);
            fields = fieldnames(tmp.states.(stateID));
            for k = 1:numel(fields)
                tmp.states.(stateID).(fields{k}) = [];
            end
        end
        for j = 1:numel(simulation.processes)
            processID = simulation.processes{j}.wholeCellModelID(9:end);
            fields = fieldnames(tmp.processes.(processID));
            for k = 1:numel(fields)
                tmp.processes.(processID).(fields{k}) = [];
            end
        end
    end
    fwrite(fid, edu.stanford.covert.io.jsonFormat(tmp));
    fclose(fid);
end
clear data tmp fid i j k stateID processID fields;

%% write simulation test fixture
import edu.stanford.covert.cell.sim.SimulationFixture;
simulation.applyOptions('lengthSec', 1, 'verbosity', 0);
SimulationFixture.store(simulation, 'Simulation.mat');

%% unset mass reference in geometry state to reduce fixture sizes
mass = simulation.state('Mass');
simulation.state('Geometry').mass = [];

%% write state test fixtures
for i = 1:length(simulation.states)
    edu.stanford.covert.cell.sim.CellStateFixture.store(simulation.states{i});
end

%% write process test fixtures
for i = 1:length(simulation.processes)
    edu.stanford.covert.cell.sim.ProcessFixture.store(simulation.processes{i});
end

%% reset mass reference in geometry state, and regenerate fixtures
simulation.state('Geometry').mass = mass;
edu.stanford.covert.cell.sim.CellStateFixture.store(simulation.state('Geometry'));
edu.stanford.covert.cell.sim.ProcessFixture.store(simulation.process('Metabolism'));

%% clean up
clear simulation mr mass ans i o initialGrowthFilterWidth;
clear knowledgeBase knowledgeBaseWID;