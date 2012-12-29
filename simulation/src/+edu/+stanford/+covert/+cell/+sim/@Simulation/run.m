%Runs the simulation, and optionally logs results. varargin optionally
%contains two input arguments:
%- adf
%- single instance of SimulationLogger or cell array of a SimulationLogger instances
%
% Author: Jonathan Karr, jkarr@stanford.edu
% Affilitation: Covert Lab, Department of Bioengineering, Stanford University
% Last updated: 3/24/2011
function [this, loggers] = run(this, varargin)

%process options
loggers = {};
ic = [];
for i = 1:numel(varargin)
    if isa(varargin{i}, 'edu.stanford.covert.cell.sim.util.Logger') || ...
            (iscell(varargin{i}) && isa(varargin{i}{1}, 'edu.stanford.covert.cell.sim.util.Logger'))
        loggers = varargin{i};
        if ~iscell(loggers)
            loggers = {loggers};
        end
    else
        ic = varargin{i};
    end
end

%references
g = this.state('Geometry');
met = this.state('Metabolite');

%allocate memory
this.allocateMemoryForState(1);

%initialize state
if ~isempty(ic)
    for i = 1:numel(this.states)
        s = this.states{i};
        for j = 1:numel(s.stateNames)
            s.(s.stateNames{j}) = ic.(s.wholeCellModelID(7:end)).(s.stateNames{j});
        end
    end
    
    this.state('Time').values = 0;
    this.state('Mass').initialize();
    this.state('Geometry').initialize();
    
    for i = 1:numel(this.processes)
        proc = this.processes{i};
        proc.copyFromState();
    end
else
    this.initializeState();
end

%apply perturbations
this.applyPerturbations();

%evolve state
for j = 1:numel(loggers)
    loggers{j}.initialize(this);
end

try    
    for i = 1:this.getNumSteps
        [~, requirements, allocations, usages] = this.evolveState();
        met.processRequirements = edu.stanford.covert.util.SparseMat(requirements);
        met.processAllocations = edu.stanford.covert.util.SparseMat(allocations);
        met.processUsages = edu.stanford.covert.util.SparseMat(usages);
        
        for j = 1:numel(loggers)
            loggers{j}.append(this);
        end
        if ~isempty(g) && g.pinched
            break;
        end
    end
catch exception
    for j = 1:numel(loggers)
        loggers{j}.finalize(this);
    end
    exception.rethrow();
end

for j = 1:numel(loggers)
    loggers{j}.finalize(this);
end