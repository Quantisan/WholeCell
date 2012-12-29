% Stores/loads simulatons
%
% Author: Jonathan Karr, jkarr@stanford.edu
% Affilitation: Covert Lab, Department of Bioengineering, Stanford University
% Last updated: 6/30/2011
classdef CachedSimulationObjectUtil
    methods (Static = true)
        function store(simulation, knowledgeBaseWID) %#ok<INUSD>
            save('data/Simulation_fitted.mat', 'simulation', 'knowledgeBaseWID');
            
            revision = edu.stanford.covert.util.revision;
            if ~isnan(revision)
                save(sprintf('data/Simulation_fitted-R%4d.mat', revision + 1), 'simulation', 'knowledgeBaseWID');
            end
        end
        
        function [sim, kbWID] = load(revision)
            if nargin == 0
                tmp = load('data/Simulation_fitted.mat');
            else
                files = dir('data/Simulation_fitted-R*.mat');
                fileRevisions = cellfun(@(name) str2double(name(20:23)), {files.name}');
                idx = find(fileRevisions <= revision, 1, 'last');
                if isempty(idx)
                    throw(MException('CachedSimulationObjectUtil:error', 'No cached simulation object matches revision %d', revision));
                end
                tmp = load(['data' filesep files(idx).name]);
            end
            sim = tmp.simulation;
            kbWID = tmp.knowledgeBaseWID;
            
            sim.constructRandStream();
        end
    end
end
