/*
BioWarehouseProcedures.sql
   Defines functions for manipulating BioWarehouse schema v4.1
   - building, editing, and retrieving knowledgeBases
   - saving and retrieving simulations

   Notes:
   - need to set CLIENT_MULTI_RESULTS flag to execute stored procedures
     - had to edit amfphp\services\MySQL\database.php function open

   References:
   - BioWarehouse Schema documentation
     http://biowarehouse.ai.sri.com/repos/schema/doc/

   Last Updated: 7/24/2008
   Author: Jonathan Karr
   Affiliation: Covert Lab, Department of Bioengineering, Stanford University
*/

#############################################################
## drop all procedures
#############################################################
SELECT CONCAT("DROP PROCEDURE IF EXISTS ", SPECIFIC_NAME) AS DeleteStorePrecedure
FROM information_schema.ROUTINES R
WHERE R.ROUTINE_TYPE = "PROCEDURE"
AND R.ROUTINE_SCHEMA = DATABASE();

DELIMITER $$

#############################################################
## Alter schema
#############################################################

#add all necessary columns and tables to BioWarehouse schema
DROP PROCEDURE IF EXISTS `update_schema` $$
CREATE PROCEDURE `update_schema` ()
BEGIN

#entry
CALL add_column('Entry','InsertUserID','bigint','ModifiedDate');
CALL add_column('Entry','ModifiedUserID','bigint','InsertUserID');
ALTER TABLE Entry ADD Key `InsertUserID` (`InsertUserID`);
ALTER TABLE Entry ADD Key `ModifiedUserID` (`ModifiedUserID`);

#parameter
CALL add_column('Parameter','Description','varchar(255)','Name');
CALL add_column('Parameter','DefaultValue','text','Description');
CALL add_column('Parameter','UnitsWID','bigint','Parameter_DefaultValue');
CALL add_column('Parameter','ExperimentallyConstrained','char(1)','UnitsWID');
ALTER TABLE Parameter ADD Key `UnitsWID` (`UnitsWID`);

#chemical
CALL add_column('Chemical','TraditionalName','varchar(255)','SystematicName');
CALL add_column('Chemical','Category','varchar(255)','SystematicName');
CALL add_column('Chemical','Subcategory','varchar(255)','Category');
CALL add_column('Chemical','OctH2ODistributionCoeff','varchar(255)','OctH2OPartitionCoeff');
CALL add_column('Chemical','pI','varchar(255)','PKA3');
CALL add_column('Chemical','Volume','varchar(255)','pI');
ALTER TABLE Chemical DROP KEY CHEMICAL_SMILES;
ALTER TABLE Chemical CHANGE `Smiles` `Smiles` TEXT CHARACTER SET latin1 COLLATE latin1_general_ci NULL DEFAULT NULL;

#gene
CALL add_column('Gene', 'Symbol', 'varchar(255)', 'WID');
CALL add_column('Gene', 'NTSequence', 'text', 'Name');
CALL add_column('Gene', 'Length', 'smallint', 'NTSequence');
CALL add_column('Gene', 'GCContent', 'float', 'Length');
CALL add_column('Gene', 'MolecularWeightExp', 'float', 'Direction');
CALL add_column('Gene', 'MolecularWeightCalc', 'float', 'MolecularWeightExp');
CALL add_column('Gene', 'Essential', 'char(1)', 'Interrupted');
CALL add_column('Gene', 'StartCodon', 'char(1)', 'Essential');
CALL add_column('Gene', 'Codons', 'varchar(255)', 'StartCodon');
CALL add_column('Gene', 'AminoAcidWID',' bigint', 'Codons');
CALL add_column('Gene', 'Expression', 'float', 'AminoAcidWID');
CALL add_column('Gene', 'ExpressionColdShock', 'float', 'Expression');
CALL add_column('Gene', 'ExpressionHeatShock', 'float', 'ExpressionColdShock');
CALL add_column('Gene', 'HalfLifeExp', 'float', 'ExpressionHeatShock');
CALL add_column('Gene', 'HalfLifeCalc', 'float','HalfLifeExp');
CALL add_column('Gene', 'PIExp', 'float', 'HalfLifeCalc');
CALL add_column('Gene', 'PICalc', 'float', 'PIExp');
CALL add_column('Gene', 'CompartmentWID', 'bigint', 'PICalc');
ALTER TABLE Gene ADD Key `CompartmentWID` (`CompartmentWID`);

#transcription unit
CALL add_column('TranscriptionUnit','CompartmentWID','bigint','Name');
ALTER TABLE TranscriptionUnit ADD Key `CompartmentWID` (`CompartmentWID`);

#transcription unit component
CALL add_column('TranscriptionUnitComponent','CompartmentWID','bigint','OtherWID');
ALTER TABLE TranscriptionUnitComponent ADD Key `CompartmentWID` (`CompartmentWID`);

#feature
CALL add_column('Feature','SubSequenceWID','bigint','SequenceWID');
CALL add_column('Feature','Direction','varchar(25)','EndPositionApproximate');

#protein
CALL add_column('Protein','NegAA','smallint','LengthApproximate');
CALL add_column('Protein','PosAA','smallint','NegAA');
CALL add_column('Protein','Atoms','smallint','PosAA');
CALL add_column('Protein','Formula','varchar(255)','Atoms');
CALL add_column('Protein','HalfLifeExp','char(1)','PIExp');
CALL add_column('Protein','HalfLifeCalc','char(1)','HalfLifeExp');
CALL add_column('Protein','Instability','float','HalfLifeCalc');
CALL add_column('Protein','Stability','char(1)','Instability');
CALL add_column('Protein','Aliphatic','float','Stability');
CALL add_column('Protein','GRAVY','float','Aliphatic');
CALL add_column('Protein','ExtinctionCoefficient','float','GRAVY');
CALL add_column('Protein','Absorption','float','ExtinctionCoefficient');
CALL add_column('Protein','Topology','varchar(255)','Absorption');
CALL add_column('Protein','ActiveSite','varchar(255)','Topology');
CALL add_column('Protein','MetalBindingSite','varchar(255)','ActiveSite');
CALL add_column('Protein','DNAFootprint','int','MetalBindingSite');
CALL add_column('Protein','DNAFootprintBindingStrandedness','enum(\'ssDNA\',\'dsDNA\')','DNAFootprint');
CALL add_column('Protein','DNAFootprintRegionStrandedness','enum(\'ssDNA\',\'dsDNA\',\'Either\')','DNAFootprintBindingStrandedness');
CALL add_column('Protein','CompartmentWID','bigint','DNAFootprintRegionStrandedness');
CALL add_column('Protein','MolecularInteraction','tinytext','CompartmentWID');
CALL add_column('Protein','ChemicalRegulation','tinytext','MolecularInteraction');
CALL add_column('Protein','Subsystem','tinytext','ChemicalRegulation');
CALL add_column('Protein','GeneralClassification','tinytext','Subsystem');
CALL add_column('Protein','ProteaseClassification','tinytext','GeneralClassification');
CALL add_column('Protein','TransporterClassification','tinytext','ProteaseClassification');
CALL add_column('Protein','ComplexFormationProcessWID','bigint','TransporterClassification');
ALTER TABLE Protein ADD Key `CompartmentWID` (`CompartmentWID`);

#GeneWIDProteinWID
CALL add_column('GeneWIDProteinWID','CompartmentWID','bigint','ProteinWID');
ALTER TABLE GeneWIDProteinWID ADD Key `CompartmentWID` (`CompartmentWID`);

#subunit
CALL add_column('Subunit', 'CompartmentWID', 'bigint', 'SubunitWID');
ALTER TABLE Subunit ADD Key `CompartmentWID` (`CompartmentWID`);
ALTER TABLE Subunit DROP FOREIGN KEY FK_Subunit2; #allow RNAs to be subunits

#Interaction
CALL add_column('Interaction', 'Affinity', 'float', 'Name');
CALL add_column('Interaction', 'Activity', 'float', 'Affinity');
CALL add_column('Interaction', 'Element', 'varchar(255)', 'Activity');
CALL add_column('Interaction', '`Condition`', 'varchar(255)', 'Element');
CALL add_column('Interaction', 'Rule', 'text', '`Condition`');
ALTER TABLE Interaction ADD KEY `Type` (`Type`);

#Interaction Participant
CALL add_column('InteractionParticipant','CompartmentWID','bigint','OtherWID');
CALL add_column('InteractionParticipant','Role','varchar(255)','Coefficient');
ALTER TABLE InteractionParticipant ADD KEY `CompartmentWID` (`CompartmentWID`);
ALTER TABLE InteractionParticipant ADD KEY `Role` (`Role`);
ALTER TABLE InteractionParticipant DROP FOREIGN KEY FK_InteractionParticipant1;

#reaction
CALL add_column('Reaction','Type','varchar(255)','Name');
CALL add_column('Reaction','DeltaGExp','float','Type');
CALL add_column('Reaction','DeltaGCalc','float','DeltaGExp');
CALL add_column('Reaction','Direction','char(1)','DeltaG');
CALL add_column('Reaction','LowerBound','float','Spontaneous');
CALL add_column('Reaction','UpperBound','float','LowerBound');
CALL add_column('Reaction','BoundUnitsWID','bigint','UpperBound');
ALTER TABLE Reaction ADD KEY `BoundUnitsWID` (`BoundUnitsWID`);
ALTER TABLE Reaction ADD KEY `Type` (`Type`);

#reactant
CALL add_column('Reactant','CompartmentWID','bigint','Coefficient');
ALTER TABLE Reactant ADD KEY `CompartmentWID` (`CompartmentWID`);

#product
CALL add_column('Product','CompartmentWID','bigint','Coefficient');
ALTER TABLE Product ADD KEY `CompartmentWID` (`CompartmentWID`);

#enzymatic reaction
CALL add_column('EnzymaticReaction','CompartmentWID','bigint','ComplexWID');
CALL add_column('EnzymaticReaction','RateLawForward','tinytext','ReactionDirection');
CALL add_column('EnzymaticReaction','RateLawBackward','tinytext','RateLawForward');
CALL add_column('EnzymaticReaction','KmForward','varchar(255)','RateLawBackward');
CALL add_column('EnzymaticReaction','KmBackward','varchar(255)','KmForward');
CALL add_column('EnzymaticReaction','VmaxExpForward','float','KmBackward');
CALL add_column('EnzymaticReaction','VmaxExpBackward','float','VmaxExpForward');
CALL add_column('EnzymaticReaction','VmaxExpUnitForward','varchar(255)','VmaxExpBackward');
CALL add_column('EnzymaticReaction','VmaxExpUnitBackward','varchar(255)','VmaxExpUnitForward');
CALL add_column('EnzymaticReaction','VmaxCalcForward','float','VmaxExpUnitBackward');
CALL add_column('EnzymaticReaction','VmaxCalcBackward','float','VmaxCalcForward');
CALL add_column('EnzymaticReaction','OptimalpH','float','VmaxCalcBackward');
CALL add_column('EnzymaticReaction','OptimalTemp','float','OptimalpH');
CALL add_column('EnzymaticReaction','Activators','tinytext','OptimalTemp');
CALL add_column('EnzymaticReaction','Inhibitors','tinytext','Activators');
ALTER TABLE EnzymaticReaction ADD KEY `CompartmentWID` (`CompartmentWID`);

#EnzReactionCofactor
CALL add_column('EnzReactionCofactor','CompartmentWID','bigint','ChemicalWID');
CALL add_column('EnzReactionCofactor','Coefficient','smallint','Prosthetic');
ALTER TABLE EnzReactionCofactor ADD KEY `CompartmentWID` (`CompartmentWID`);

#nucleic acid
CALL add_column('NucleicAcid','Sequence','longtext','CumulativeLengthApproximate');

#cross reference
ALTER TABLE CrossReference ADD KEY `DatabaseName` (`DatabaseName`);

#simulation
CALL add_column('Experiment','UserName','varchar(255)','ArchiveWID');
CALL add_column('Experiment','HostName','varchar(255)','UserName');
CALL add_column('Experiment','IPAddress','varchar(255)','HostName');
CALL add_column('Experiment','OutputDirectory','text','IPAddress');
CALL add_column('Experiment','Length','float','OutputDirectory');
CALL add_column('Experiment','SegmentStep','float','Length');
CALL add_column('Experiment','SampleStep','float','SegmentStep');

#experiment data
CALL add_column('ExperimentData','ModuleWID','bigint','MageData');
ALTER TABLE ExperimentData MODIFY Role varchar(50);
ALTER TABLE ExperimentData DROP FOREIGN KEY FK_ExpDataMD;

#citation
CALL add_column('Citation','Type','enum(\'article\',\'book\',\'misc\',\'thesis\')','Citation');
CALL add_column('Citation','ISBN','bigint','PMID');
ALTER TABLE Citation MODIFY Authors text;
ALTER TABLE Citation MODIFY Editor text;
ALTER TABLE Citation MODIFY Title text;

#parameter-otherwids
CREATE TABLE IF NOT EXISTS ParameterWIDOtherWID (
  ParameterWID bigint NOT NULL,
  OtherWID bigint NOT NULL,
  Type varchar(255) NOT NULL,
  KEY `ParameterWID` (`ParameterWID`),
  KEY `OtherWID` (`OtherWID`),
  KEY `Type` (`Type`)
) ENGINE=INNODB;

#processes
CREATE TABLE IF NOT EXISTS Process (
  WID bigint NOT NULL,
  Name varchar(255) NOT NULL,
  Description text,
  InitializationOrder smallint,
  EvaluationOrder smallint,
  `Class` varchar(255),
  DataSetWID bigint NOT NULL,
  PRIMARY KEY (`WID`),
  KEY `DataSetWID` (`DataSetWID`)
) ENGINE=INNODB;

#states
CREATE TABLE IF NOT EXISTS State (
  WID bigint NOT NULL,
  Name varchar(255) NOT NULL,
  Description text,
  `Class` varchar(255),
  DataSetWID bigint NOT NULL,
  PRIMARY KEY (`WID`),
  KEY `DataSetWID` (`DataSetWID`)
) ENGINE=INNODB;

#reaction-otherwids
CREATE TABLE IF NOT EXISTS ReactionWIDOtherWID (
  ReactionWID bigint NOT NULL,
  OtherWID bigint NOT NULL,
  Type varchar(255) NOT NULL,
  KEY `ReactionWID` (`ReactionWID`),
  KEY `OtherWID` (`OtherWID`),
  KEY `Type` (`Type`)
) ENGINE=INNODB;

#compartments
CREATE TABLE IF NOT EXISTS Compartment (
  WID bigint NOT NULL,
  Name varchar(255) NOT NULL,
  DataSetWID bigint NOT NULL,
  PRIMARY KEY (`WID`),
  KEY `DataSetWID` (`DataSetWID`)
) ENGINE=INNODB;

#biomass composition
CREATE TABLE IF NOT EXISTS BiomassComposition(
  WID bigint NOT NULL,
  OtherWID bigint NOT NULL,
  CompartmentWID bigint NOT NULL,
  Coefficient float,
  DataSetWID bigint NOT NULL,
  PRIMARY KEY `WID` (`WID`),  
  KEY `OtherWID` (`OtherWID`),
  KEY `CompartmentWID` (`CompartmentWID`),
  KEY `DataSetWID` (`DataSetWID`)
) ENGINE=INNODB;

#Modification Reactions
CREATE TABLE IF NOT EXISTS ModificationReaction (
  ReactionWID bigint NOT NULL,
  OtherWID bigint NOT NULL,
  CompartmentWID bigint NOT NULL,
  Position bigint,
  KEY `ReactionWID` (`ReactionWID`),
  KEY `CompartmentWID` (`CompartmentWID`),
  KEY `OtherWID` (`OtherWID`)
) ENGINE=INNODB;

#media
CREATE TABLE IF NOT EXISTS MediaComposition (
  WID bigint NOT NULL,	
  OtherWID bigint NOT NULL,
  CompartmentWID bigint NOT NULL,
  Concentration float,
  InitialTime float,
  FinalTime float,
  DataSetWID bigint NOT NULL,
  PRIMARY KEY `WID` (`WID`),  
  KEY `OtherWID` (`OtherWID`),
  KEY `CompartmentWID` (`CompartmentWID`),
  KEY `DataSetWID` (`DataSetWID`)
) ENGINE=INNODB;

#stimuli
CREATE TABLE IF NOT EXISTS Stimulus (
  WID bigint NOT NULL,
  Name varchar(255),
  DataSetWID bigint NOT NULL,
  PRIMARY KEY (`WID`),
  KEY `DataSetWID` (`DataSetWID`)
) ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS StimulusValue (
  WID bigint NOT NULL,
  StimulusWID bigint NOT NULL,
  CompartmentWID bigint NOT NULL,
  `Value` float,
  UnitsWID bigint,
  InitialTime float,
  FinalTime float,
  DataSetWID bigint NOT NULL,
  PRIMARY KEY `WID` (`WID`),
  KEY `StimulusWID` (`StimulusWID`),
  KEY `CompartmentWID` (`CompartmentWID`),
  KEY `UnitsWID` (`UnitsWID`),
  KEY `DataSetWID` (`DataSetWID`)
) ENGINE=INNODB;

#contact
CREATE TABLE IF NOT EXISTS ContactWIDOtherWID (
  ContactWID bigint NOT NULL,
  OtherWID bigint NOT NULL,
  KEY `ContactWID` (`ContactWID`),
  KEY `OtherWID` (`OtherWID`)
) ENGINE=INNODB;

#illusration
CREATE TABLE IF NOT EXISTS Illustration (
  WID bigint NOT NULL,
  OtherWID bigint NOT NULL,
  CompartmentWID bigint NOT NULL,
  Illustration varchar(255) NOT NULL,
  `Value` tinytext NOT NULL,
  DataSetWID bigint NOT NULL,
  PRIMARY KEY `WID` (`WID`),
  KEY `OtherWID` (`OtherWID`),
  KEY `CompartmentWID` (`CompartmentWID`),
  KEY `DataSetWID` (`DataSetWID`)
) ENGINE=INNODB;

#text search
CREATE TABLE IF NOT EXISTS TextSearch (
	OtherWID bigint NOT NULL,
	Text longtext NOT NULL,
	Type varchar(255) NOT NULL,	
	KEY `OtherWID` (`OtherWID`),
	KEY `Type` (`Type`)
) Engine=MyISAM;
CREATE FULLTEXT INDEX `Text` ON TextSearch (`Text`);

#user
CREATE TABLE IF NOT EXISTS User (
	ID bigint NOT NULL AUTO_INCREMENT,
	UserName varchar(20) NOT NULL,
	Password varchar(20) NOT NULL,	
	FirstName varchar(255) NOT NULL,	
	MiddleName varchar(255),	
	LastName varchar(255) NOT NULL,	
	Affiliation varchar(255) NOT NULL,	
	Email varchar(255) NOT NULL,	
	PRIMARY KEY `ID` (`ID`),
	KEY `UserName` (`UserName`),
	KEY `Password` (`Password`)
) Engine=MyISAM;

END $$


#add a column to a table
DROP PROCEDURE IF EXISTS `add_column` $$
CREATE PROCEDURE `add_column` (IN _Table varchar(255), IN _ColumnName varchar(255), IN _ColumnType varchar(255), IN _ColumnBefore varchar(255))
BEGIN

DECLARE _ColumnExists varchar(255);

SELECT COLUMN_NAME INTO _ColumnExists
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = _Table && COLUMN_NAME=_ColumnName;

IF _ColumnExists IS NULL THEN
  SET @SQL=CONCAT('ALTER TABLE ',_Table,' ADD COLUMN ',_ColumnName,' ',_ColumnType,' AFTER ',_ColumnBefore);
  PREPARE stmt FROM @SQL;
  EXECUTE stmt;
END IF;

END $$

#############################################################
## knowledgeBases
#############################################################

## create knowledgeBase
DROP PROCEDURE IF EXISTS `set_knowledgebase` $$
CREATE PROCEDURE `set_knowledgebase` (IN _WID bigint, IN _Version varchar(50),
  IN _Taxonomy text, IN _ATCCID varchar(50),
  IN _TranslationTable smallint, 
  IN _URL varchar(255), IN _Investigator varchar(255),
  IN _Application varchar(255), IN _ApplicationVersion varchar(255))
BEGIN

DECLARE _GeneticCodeWID bigint;
DECLARE _TaxonWID       bigint;
DECLARE _ParentTaxonWID bigint;
DECLARE _BioSourceWID   bigint;
DECLARE _GenomeWID      bigint;

DECLARE _NoRank         varchar(255);
DECLARE _SuperKingdom   varchar(255);
DECLARE _Phylum         varchar(255);
DECLARE _Class          varchar(255);
DECLARE _Order          varchar(255);
DECLARE _Family         varchar(255);
DECLARE _Genus          varchar(255);
DECLARE _Species        varchar(255);
DECLARE _Strain         varchar(255);

SET _NoRank         = SUBSTRING_INDEX(_Taxonomy,';',1);
SET _SuperKingdom   = SUBSTRING_INDEX(SUBSTRING_INDEX(_Taxonomy,';',2), ';',-1);
SET _Phylum         = SUBSTRING_INDEX(SUBSTRING_INDEX(_Taxonomy,';',3), ';',-1);
SET _Class          = SUBSTRING_INDEX(SUBSTRING_INDEX(_Taxonomy,';',4), ';',-1);
SET _Order          = SUBSTRING_INDEX(SUBSTRING_INDEX(_Taxonomy,';',5), ';',-1);
SET _Family         = SUBSTRING_INDEX(SUBSTRING_INDEX(_Taxonomy,';',6), ';',-1);
SET _Genus          = SUBSTRING_INDEX(SUBSTRING_INDEX(_Taxonomy,';',7), ';',-1);
SET _Species        = SUBSTRING_INDEX(SUBSTRING_INDEX(_Taxonomy,';',8), ';',-1);
SET _Strain         = SUBSTRING_INDEX(_Taxonomy,';',-1);

#update dataset
CALL set_dataset(_WID, CONCAT_WS(' ',_Genus,_Species), _Version,_URL,_URL,_Investigator,_Application,_ApplicationVersion);

SELECT WID INTO _BioSourceWID
FROM BioSource
WHERE DataSetWID=_WID;

IF _BioSourceWID IS NULL THEN
    #create biosource
    CALL set_entry('F',_WID,_BioSourceWID,NULL);
    INSERT INTO BioSource(WID,TaxonWID,Name,Strain,ATCCId,DataSetWID)
    VALUES(_BioSourceWID,_TaxonWID, CONCAT_WS(' ',_Genus,_Species),_Strain,_ATCCID,_WID);

    #create genetic code
    CALL set_entry('F',_WID,_GeneticCodeWID,NULL);
    INSERT INTO GeneticCode(WID,NCBIID,DataSetWID)
    VALUES(_GeneticCodeWID,_TranslationTable,_WID);

    #create circular genome
    CALL set_entry('F',_WID,_GenomeWID,NULL);
    INSERT INTO NucleicAcid(WID,Type,Class,Topology,Strandedness,Fragment,GeneticCodeWID,BioSourceWID,DataSetWID)
    VALUES(_GenomeWID,'DNA','Chromosome','Circular','ds','F',_GeneticCodeWID,_BioSourceWID,_WID);

    #Taxonomy
    SET _TaxonWID=NULL;
    CALL set_entry('F',_WID,_TaxonWID,NULL);
    INSERT INTO Taxon(WID,ParentWID,Name,Rank,DataSetWID) VALUES(_TaxonWID,_ParentTaxonWID,_NoRank,'no rank',_WID);
    SET _ParentTaxonWID=_TaxonWID;

    SET _TaxonWID=NULL;
    CALL set_entry('F',_WID,_TaxonWID,NULL);
    INSERT INTO Taxon(WID,ParentWID,Name,Rank,DataSetWID) VALUES(_TaxonWID,_ParentTaxonWID,_SuperKingdom,'superkingdom',_WID);
    SET _ParentTaxonWID=_TaxonWID;

    SET _TaxonWID=NULL;
    CALL set_entry('F',_WID,_TaxonWID,NULL);
    INSERT INTO Taxon(WID,ParentWID,Name,Rank,DataSetWID) VALUES(_TaxonWID,_ParentTaxonWID,_Phylum,'phylum',_WID);
    SET _ParentTaxonWID=_TaxonWID;

    SET _TaxonWID=NULL;
    CALL set_entry('F',_WID,_TaxonWID,NULL);
    INSERT INTO Taxon(WID,ParentWID,Name,Rank,DataSetWID) VALUES(_TaxonWID,_ParentTaxonWID,_Class,'class',_WID);
    SET _ParentTaxonWID=_TaxonWID;

    SET _TaxonWID=NULL;
    CALL set_entry('F',_WID,_TaxonWID,NULL);
    INSERT INTO Taxon(WID,ParentWID,Name,Rank,DataSetWID) VALUES(_TaxonWID,_ParentTaxonWID,_Order,'order',_WID);
    SET _ParentTaxonWID=_TaxonWID;

    SET _TaxonWID=NULL;
    CALL set_entry('F',_WID,_TaxonWID,NULL);
    INSERT INTO Taxon(WID,ParentWID,Name,Rank,DataSetWID) VALUES(_TaxonWID,_ParentTaxonWID,_Family,'family',_WID);
    SET _ParentTaxonWID=_TaxonWID;

    SET _TaxonWID=NULL;
    CALL set_entry('F',_WID,_TaxonWID,NULL);
    INSERT INTO Taxon(WID,ParentWID,Name,Rank,DataSetWID) VALUES(_TaxonWID,_ParentTaxonWID,_Genus,'genus',_WID);
    SET _ParentTaxonWID=_TaxonWID;

    SET _TaxonWID=NULL;
    CALL set_entry('F',_WID,_TaxonWID,NULL);
    INSERT INTO Taxon(WID,ParentWID,Name,Rank,DataSetWID) VALUES(_TaxonWID,_ParentTaxonWID,_Species,'species',_WID);
    SET _ParentTaxonWID=_TaxonWID;

    SET _TaxonWID=NULL;
    CALL set_entry('F',_WID,_TaxonWID,NULL);
    INSERT INTO Taxon(WID,ParentWID,Name,Rank,GencodeWID,DataSetWID) VALUES(_TaxonWID,_ParentTaxonWID,_Strain,'strain',_GeneticCodeWID,_WID);
    SET _ParentTaxonWID=_TaxonWID;
ELSE
    #biosource
    UPDATE BioSource
    SET
            TaxonWID=_TaxonWID,
            Name=CONCAT_WS(' ',_Genus,_Species),
            Strain=_Strain,
            ATCCId=_ATCCID
    WHERE BioSource.DataSetWID=_WID;

    #genetic code
    UPDATE GeneticCode
    SET NCBIID=_TranslationTable
    WHERE GeneticCode.DataSetWID=_WID;

    #Taxonomy
    UPDATE Taxon SET Name=_NoRank       WHERE Taxon.DataSetWID=_WID && Rank='no rank';
    UPDATE Taxon SET Name=_SuperKingdom WHERE Taxon.DataSetWID=_WID && Rank='superkingdom';
    UPDATE Taxon SET Name=_Phylum       WHERE Taxon.DataSetWID=_WID && Rank='phylum';
    UPDATE Taxon SET Name=_Class        WHERE Taxon.DataSetWID=_WID && Rank='class';
    UPDATE Taxon SET Name=_Order        WHERE Taxon.DataSetWID=_WID && Rank='order';
    UPDATE Taxon SET Name=_Family       WHERE Taxon.DataSetWID=_WID && Rank='family';
    UPDATE Taxon SET Name=_Genus        WHERE Taxon.DataSetWID=_WID && Rank='genus';
    UPDATE Taxon SET Name=_Species      WHERE Taxon.DataSetWID=_WID && Rank='species';
    UPDATE Taxon SET Name=_Strain       WHERE Taxon.DataSetWID=_WID && Rank='strain';
END IF;

#text search
CALL set_textsearch(_WID, _ATCCId,	     'cross reference - ATCC');
CALL set_textsearch(_WID, _NoRank,       'no rank');
CALL set_textsearch(_WID, _SuperKingdom, 'superkingdom');
CALL set_textsearch(_WID, _Phylum,       'phylum');
CALL set_textsearch(_WID, _Class,        'class');
CALL set_textsearch(_WID, _Order,        'order');
CALL set_textsearch(_WID, _Family,       'family');
CALL set_textsearch(_WID, _Genus,        'genus');
CALL set_textsearch(_WID, _Species,      'species');
CALL set_textsearch(_WID, _Strain,       'strain');

SELECT _WID WID;

END $$

#remove knowledgebase
DROP PROCEDURE IF EXISTS `delete_knowledgeBase` $$
CREATE PROCEDURE `delete_knowledgeBase` (IN _WID bigint)
BEGIN

CALL delete_knowledgeBases(_WID,_WID);

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_knowledgeBases` $$
CREATE PROCEDURE `delete_knowledgeBases` (IN _KnowledgeBaseWIDMin bigint, IN _KnowledgeBaseWIDMax bigint)
BEGIN

DELETE RelatedTerm                      FROM RelatedTerm			JOIN Entry ON Entry.OtherWID=RelatedTerm.OtherWID		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE PathwayReaction			FROM PathwayReaction			JOIN Entry ON Entry.OtherWID=ReactionWID				WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE EnzReactionCofactor		FROM EnzReactionCofactor		JOIN Entry ON Entry.OtherWID=EnzymaticReactionWID		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE Product				FROM Product				JOIN Entry ON Entry.OtherWID=ReactionWID				WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE Reactant				FROM Reactant				JOIN Entry ON Entry.OtherWID=ReactionWID				WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE ModificationReaction		FROM ModificationReaction		JOIN Entry ON Entry.OtherWID=ReactionWID				WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE InteractionParticipant		FROM InteractionParticipant		JOIN Entry ON Entry.OtherWID=InteractionWID				WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE GeneWIDProteinWID		FROM GeneWIDProteinWID			JOIN Entry ON Entry.OtherWID=GeneWID					WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE Subunit				FROM Subunit				JOIN Entry ON Entry.OtherWID=SubunitWID					WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE TranscriptionUnitComponent	FROM TranscriptionUnitComponent         JOIN Entry ON Entry.OtherWID=TranscriptionUnitWID		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE DBID				FROM DBID				JOIN Entry ON Entry.OtherWID=DBID.OtherWID				WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE SynonymTable			FROM SynonymTable			JOIN Entry ON Entry.OtherWID=SynonymTable.OtherWID		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE CrossReference			FROM CrossReference			JOIN Entry ON Entry.OtherWID=CrossReference.OtherWID	WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE CommentTable			FROM CommentTable			JOIN Entry ON Entry.OtherWID=CommentTable.OtherWID		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE Description			FROM Description			JOIN Entry ON Entry.OtherWID=Description.OtherWID		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE TextSearch			FROM TextSearch				JOIN Entry ON Entry.OtherWID=TextSearch.OtherWID		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE CitationWIDOtherWID		FROM CitationWIDOtherWID		JOIN Entry ON Entry.OtherWID=CitationWID				WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE ParameterWIDOtherWID     FROM ParameterWIDOtherWID		JOIN Entry ON Entry.OtherWID=ParameterWID				WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;

DELETE FROM Citation		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Illustration	WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Process		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM State		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Parameter		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Term		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Compartment		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Pathway		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM BiomassComposition  WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM MediaComposition    WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Chemical		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM EnzymaticReaction   WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Reaction		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Interaction		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Feature		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Protein		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM TranscriptionUnit   WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Gene		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Archive		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM ExperimentData	WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Experiment		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Contact		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM GeneticCode		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Taxon		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM BioSource		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM NucleicAcid		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Stimulus		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM StimulusValue	WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;
DELETE FROM Entry		WHERE DataSetWID>=_KnowledgeBaseWIDMin && DataSetWID<=_KnowledgeBaseWIDMax;

DELETE FROM DataSet	WHERE WID>=_KnowledgeBaseWIDMin && WID<=_KnowledgeBaseWIDMax;

END $$


DROP PROCEDURE IF EXISTS `get_knowledgebases` $$
CREATE PROCEDURE `get_knowledgebases` (IN _DataSetType varchar(255), IN _ShowAllVersions char(1))
BEGIN

DECLARE _HomeURL varchar(255);
SET @Idx:=0;

IF _DataSetType='BioCyc' THEN
  SET _HomeURL='http://www.biocyc.org';
ELSEIF _DataSetType='WholeCell' THEN
  SET _HomeURL='http://covertlab.stanford.edu/projects/WholeCell';
END IF;

IF _ShowAllVersions='Y' THEN
  SELECT @Idx:=@Idx+1 AS Idx, WID, DBID.XID WholeCellModelID, Name, DataSet.Version, Entry.InsertDate, LoadedBy Investigator
  FROM DataSet
  JOIN Entry ON Entry.OtherWID=DataSet.WID
  JOIN DBID ON DBID.OtherWID=DataSet.WID
  WHERE (_HomeURL IS NULL) || (HomeURL=_HomeURL)
  ORDER BY DataSet.Name ASC, DataSet.Version DESC, Entry.InsertDate DESC, DataSet.WID DESC;
ELSE
  SELECT @Idx:=@Idx+1 AS Idx, WID, WholeCellModelID, Name, Version, InsertDate, Investigator FROM (
    SELECT WID, DBID.XID WholeCellModelID, Name, DataSet.Version, Entry.InsertDate, LoadedBy Investigator
    FROM DataSet
	JOIN Entry ON Entry.OtherWID=DataSet.WID
    JOIN DBID ON DBID.OtherWID=DataSet.WID
    WHERE (_HomeURL IS NULL) || (HomeURL=_HomeURL)
    ORDER BY DataSet.Name ASC, DataSet.Version DESC, Entry.InsertDate DESC, DataSet.WID DESC
  ) AS DataSet
  GROUP BY Name;
END IF;

END $$

DROP PROCEDURE IF EXISTS `get_latest_knowledgebase` $$
CREATE PROCEDURE `get_latest_knowledgebase` (IN _DataSetType varchar(255))
BEGIN

DECLARE _HomeURL varchar(255);

IF _DataSetType='BioCyc' THEN
  SET _HomeURL='http://www.biocyc.org';
ELSEIF _DataSetType='WholeCell' THEN
  SET _HomeURL='http://covertlab.stanford.edu/projects/WholeCell';
END IF;

SELECT DataSet.WID, DBID.XID WholeCellModelID, DataSet.Name, DataSet.Version, Entry.InsertDate, DataSet.LoadedBy Investigator
FROM DataSet
JOIN Entry ON Entry.OtherWID=DataSet.WID
JOIN DBID ON DBID.OtherWID=DataSet.WID
WHERE (_HomeURL IS NULL) || (DataSet.HomeURL=_HomeURL)
ORDER BY DataSet.Version DESC, Entry.InsertDate DESC, DataSet.WID DESC
LIMIT 1;

END $$

-- ---------------------------------------------------------
-- summary
-- ---------------------------------------------------------

## get knowledgebase
DROP PROCEDURE IF EXISTS `get_knowledgebase` $$
CREATE PROCEDURE `get_knowledgebase` (IN _KnowledgeBaseWID bigint)
BEGIN

SELECT
  _KnowledgeBaseWID WID,
  DBID.XID WholeCellModelID,
  DataSet.Name, DataSet.Version, 
  DataSet.LoadedBy Investigator,
  DataSet.HomeURL URL,
  DataSet.Application,
  DataSet.ApplicationVersion,

  Taxonomy.Name Taxonomy,
  BioSource.ATCCId ATCCID,
  GeneticCode.NCBIID+0 TranslationTable,
  Genome.GenomeLength,

  Simulation.Count Simulations,

  Process.Count processes,
  State.Count States,
  Parameter.Count Parameters,
  Compartment.Count Compartments,
  Pathway.Count Pathways,
  Stimulus.Count Stimuli,
  Metabolite.Count Metabolites,
  Gene.Count Genes,
  TranscriptionUnit.Count TranscriptionUnits,
  GenomeFeature.Count GenomeFeatures,
  ProteinMonomer.Count ProteinMonomers,
  ProteinComplex.Count ProteinComplexs,
  Reaction.Count Reactions,
  Reference.Count `References`,
  Note.Count Notes,

  GeneStatistics.MaxGeneLength,
  TranscriptionUnitStatistics.MaxTranscriptionUnitLength,
  GeneStatistics.MaxGeneExpression,6 MaxTranscriptionUnitExpression,
  1 MaxAvgMetConc,
  1 MaxAvgRxnFlux,

  MetabolicMap.MetabolicMapMinX, MetabolicMap.MetabolicMapMinY, MetabolicMap.MetabolicMapMaxX, MetabolicMap.MetabolicMapMaxY

FROM
  (SELECT * FROM DataSet WHERE WID=_KnowledgeBaseWID) AS DataSet,
  (SELECT * FROM DBID WHERE OtherWID=_KnowledgeBaseWID) AS DBID,
  (SELECT * FROM BioSource WHERE DataSetWID=_KnowledgeBaseWID) AS BioSource,
  (SELECT GROUP_CONCAT(Taxon.Name ORDER BY Taxon.Rank SEPARATOR ';') Name FROM
    (SELECT DataSetWID, Name,1 Rank FROM Taxon WHERE DataSetWID=_KnowledgeBaseWID && rank='no rank'
     UNION
     SELECT DataSetWID, Name,2 Rank FROM Taxon WHERE DataSetWID=_KnowledgeBaseWID && rank='superkingdom'
     UNION
     SELECT DataSetWID, Name,3 Rank FROM Taxon WHERE DataSetWID=_KnowledgeBaseWID && rank='phylum'
     UNION
     SELECT DataSetWID, Name,4 Rank FROM Taxon WHERE DataSetWID=_KnowledgeBaseWID && rank='class'
     UNION
     SELECT DataSetWID, Name,5 Rank FROM Taxon WHERE DataSetWID=_KnowledgeBaseWID && rank='order'
     UNION
     SELECT DataSetWID, Name,6 Rank FROM Taxon WHERE DataSetWID=_KnowledgeBaseWID && rank='family'
     UNION
     SELECT DataSetWID, Name,7 Rank FROM Taxon WHERE DataSetWID=_KnowledgeBaseWID && rank='genus'
     UNION
     SELECT DataSetWID, Name,8 Rank FROM Taxon WHERE DataSetWID=_KnowledgeBaseWID && rank='species'
     UNION
     SELECT DataSetWID, Name,9 Rank FROM Taxon WHERE DataSetWID=_KnowledgeBaseWID && rank='strain'
    ) AS Taxon
   GROUP BY DataSetWID
  ) AS Taxonomy,
  (SELECT * FROM GeneticCode WHERE DataSetWID=_KnowledgeBaseWID) AS GeneticCode,
  (SELECT MoleculeLength GenomeLength FROM NucleicAcid WHERE DataSetWID=_KnowledgeBaseWID && Class='Chromosome') AS Genome,

  #counts
  (SELECT COUNT(*) Count 	FROM Experiment 		WHERE DataSetWID=_KnowledgeBaseWID) AS Simulation,
  (SELECT COUNT(*) Count 	FROM Process 			WHERE DataSetWID=_KnowledgeBaseWID) AS Process,
  (SELECT COUNT(*) Count 	FROM State 			WHERE DataSetWID=_KnowledgeBaseWID) AS State,
  (SELECT COUNT(*) Count 	FROM Parameter			WHERE DataSetWID=_KnowledgeBaseWID) AS Parameter,
  (SELECT COUNT(*) Count 	FROM Compartment 		WHERE DataSetWID=_KnowledgeBaseWID) AS Compartment,
  (SELECT COUNT(*) Count 	FROM Pathway 			WHERE DataSetWID=_KnowledgeBaseWID) AS Pathway,
  (SELECT COUNT(*) Count 	FROM Stimulus 			WHERE DataSetWID=_KnowledgeBaseWID) AS Stimulus,
  (SELECT COUNT(*) Count 	FROM Chemical 			WHERE DataSetWID=_KnowledgeBaseWID) AS Metabolite,
  (SELECT COUNT(*) Count 	FROM Gene 			WHERE DataSetWID=_KnowledgeBaseWID) AS Gene,  
  (SELECT COUNT(*) Count	FROM TranscriptionUnit          WHERE DataSetWID=_KnowledgeBaseWID) AS TranscriptionUnit,
  (SELECT COUNT(*) Count
	FROM Feature 
	JOIN NucleicAcid ON Feature.SequenceWID=NucleicAcid.WID 
	WHERE 
		Feature.SequenceType='N' && 
		Feature.DataSetWID=_KnowledgeBaseWID && 
		NucleicAcid.DataSetWID=_KnowledgeBaseWID) AS GenomeFeature,
  (SELECT COUNT(*) Count	
	FROM Protein
	JOIN GeneWIDProteinWID ON GeneWIDProteinWID.ProteinWID=Protein.WID 
	WHERE DataSetWID=_KnowledgeBaseWID) AS ProteinMonomer,
  (SELECT COUNT(DISTINCT WID) Count 
	FROM Protein 
	JOIN Subunit ON ComplexWID=WID 
	WHERE DataSetWID=_KnowledgeBaseWID) AS ProteinComplex,
  (SELECT COUNT(*) Count 	FROM Reaction 			WHERE DataSetWID=_KnowledgeBaseWID) AS Reaction,
  (SELECT COUNT(*) Count 	FROM Citation 			WHERE DataSetWID=_KnowledgeBaseWID) AS Reference,
  (SELECT COUNT(*) Count 	FROM Description JOIN Entry ON Entry.OtherWID=Description.OtherWID WHERE Entry.DataSetWID=_KnowledgeBaseWID && Description.TableName='DataSet') AS Note,

	#statistics
	(SELECT MAX(Length) MaxGeneLength, MAX(Expression) MaxGeneExpression
	FROM Gene 
	WHERE DataSetWID=_KnowledgeBaseWID
	) AS GeneStatistics,
	
    (SELECT COUNT(*) Count,AVG(TranscriptionUnitLength)+2*STD(TranscriptionUnitLength) MaxTranscriptionUnitLength
	FROM (
		SELECT MAX(CodingRegionEnd)-MIN(CodingRegionStart)+1 TranscriptionUnitLength
		FROM Gene
		JOIN TranscriptionUnitComponent ON OtherWID=WID
		WHERE DataSetWID=_KnowledgeBaseWID
		GROUP BY TranscriptionUnitWID
		) AS TranscriptionUnit
	) AS TranscriptionUnitStatistics,

   #metabolic map
   (SELECT
     MIN((SUBSTRING_INDEX(Value,';', 1)+0)) MetabolicMapMinX,
     MIN((SUBSTRING_INDEX(Value,';',-1)+0)) MetabolicMapMinY,
     MAX((SUBSTRING_INDEX(Value,';', 1)+0)) MetabolicMapMaxX,
     MAX((SUBSTRING_INDEX(Value,';',-1)+0)) MetabolicMapMaxY
   FROM Chemical
   LEFT JOIN Illustration ON Illustration.OtherWID=Chemical.WID
   WHERE Chemical.DataSetWID=_KnowledgeBaseWID
   ) AS MetabolicMap;

END $$

DROP PROCEDURE IF EXISTS `get_wholecellmodelids` $$
CREATE PROCEDURE `get_wholecellmodelids` (IN _KnowledgeBaseWID bigint, IN _WID bigint, IN _WholeCellModelID varchar(150))
BEGIN

SELECT IDs.*
FROM (

SELECT DataSet.WID, DBID.XID WholeCellModelID, DataSet.Name, 'summary' TableID
FROM DataSet
JOIN DBID ON DBID.OtherWID=DataSet.WID
WHERE
    DataSet.WID=_KnowledgeBaseWID &&
    ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT Process.WID, DBID.XID WholeCellModelID, Process.Name, 'processes' TableID
FROM Process
JOIN DBID ON DBID.OtherWID=Process.WID
WHERE Process.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT State.WID, DBID.XID WholeCellModelID, State.Name, 'states' TableID
FROM State
JOIN DBID ON DBID.OtherWID=State.WID
WHERE State.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT Parameter.WID, DBID.XID WholeCellModelID, Parameter.Name, 'parameters' TableID
FROM Parameter
JOIN DBID ON DBID.OtherWID=Parameter.WID
WHERE Parameter.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT Compartment.WID, DBID.XID WholeCellModelID, Compartment.Name, 'compartments' TableID
FROM Compartment
JOIN DBID ON DBID.OtherWID=Compartment.WID
WHERE Compartment.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT Pathway.WID, DBID.XID WholeCellModelID, Pathway.Name, 'pathways' TableID
FROM Pathway
JOIN DBID ON DBID.OtherWID=Pathway.WID
WHERE Pathway.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT Chemical.WID, DBID.XID WholeCellModelID, Chemical.Name, 'metabolites' TableID
FROM Chemical
JOIN DBID ON DBID.OtherWID=Chemical.WID
WHERE Chemical.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT Feature.WID, DBID.XID WholeCellModelID, Feature.Description Name, 'genomeFeatures' TableID
FROM Feature
JOIN DBID ON DBID.OtherWID=Feature.WID
JOIN NucleicAcid ON Feature.SequenceWID=NucleicAcid.WID
WHERE Feature.DataSetWID=_KnowledgeBaseWID && NucleicAcid.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=Feature.WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT Gene.WID, DBID.XID WholeCellModelID, Gene.Name, 'genes' TableID
FROM Gene
JOIN DBID ON DBID.OtherWID=Gene.WID
WHERE Gene.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT TranscriptionUnit.WID, DBID.XID WholeCellModelID, TranscriptionUnit.Name, 'transcriptionUnits' TableID
FROM TranscriptionUnit
JOIN DBID ON DBID.OtherWID=TranscriptionUnit.WID
WHERE TranscriptionUnit.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT GeneWIDProteinWID.ProteinWID WID, DBID.XID WholeCellModelID, Gene.Name, 'proteinMonomers' TableID
FROM Gene
JOIN GeneWIDProteinWID ON Gene.WID=GeneWIDProteinWID.GeneWID
JOIN Protein ON Protein.WID=GeneWIDProteinWID.ProteinWID
JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
WHERE Gene.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=Protein.WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT Protein.WID, DBID.XID WholeCellModelID, Protein.Name, 'proteinComplexs' TableID
FROM Protein
JOIN Subunit ON Subunit.ComplexWID=Protein.WID
JOIN DBID ON DBID.OtherWID=Protein.WID
WHERE Protein.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT Reaction.WID, DBID.XID WholeCellModelID, Reaction.Name, 'reactions' TableID
FROM Reaction
JOIN DBID ON DBID.OtherWID=Reaction.WID
JOIN ReactionWIDOtherWID ON Reaction.WID=ReactionWIDOtherWID.ReactionWID
WHERE Reaction.DataSetWID=_KnowledgeBaseWID &&
((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT Stimulus.WID, DBID.XID WholeCellModelID, Stimulus.Name, 'stimuli' TableID
FROM Stimulus
JOIN DBID ON DBID.OtherWID=Stimulus.WID
WHERE Stimulus.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT Citation.WID, DBID.XID WholeCellModelID, NULL Name, 'references' TableID
FROM Citation
JOIN DBID ON DBID.OtherWID=Citation.WID
WHERE Citation.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT Entry.OtherWID WID, DBID.XID WholeCellModelID, NULL Name, 'notes' TableID
FROM Entry
JOIN Description on Description.OtherWID=Entry.OtherWID
JOIN DBID ON DBID.OtherWID=Description.OtherWID
WHERE Description.TableName='DataSet' && Entry.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=Entry.OtherWID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT StimulusValue.WID, DBID.XID WholeCellModelID, NULL Name, 'stimuliValues' TableID
FROM StimulusValue
JOIN DBID ON DBID.OtherWID=StimulusValue.WID
WHERE StimulusValue.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT MediaComposition.WID, DBID.XID WholeCellModelID, NULL Name, 'mediaComponents' TableID
FROM MediaComposition
JOIN DBID ON DBID.OtherWID=MediaComposition.WID
WHERE MediaComposition.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT BiomassComposition.WID, DBID.XID WholeCellModelID, NULL Name, 'biomassCompositions' TableID
FROM BiomassComposition
JOIN DBID ON DBID.OtherWID=BiomassComposition.WID
WHERE BiomassComposition.DataSetWID=_KnowledgeBaseWID && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT Interaction.WID, DBID.XID WholeCellModelID, NULL Name, 'transcriptionalRegulations' TableID
FROM Interaction
JOIN DBID ON DBID.OtherWID=Interaction.WID
WHERE Interaction.DataSetWID=_KnowledgeBaseWID && Interaction.Type='transcriptional regulation' && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT Interaction.WID, DBID.XID WholeCellModelID, NULL Name, 'proteinActivations' TableID
FROM Interaction
JOIN DBID ON DBID.OtherWID=Interaction.WID
WHERE Interaction.DataSetWID=_KnowledgeBaseWID && Interaction.Type='activation' && ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT Illustration.WID, DBID.XID WholeCellModelID, NULL Name, 'metabolicMapMetabolites' TableID
From Illustration
JOIN DBID ON DBID.OtherWID=Illustration.WID
JOIN Chemical ON Illustration.OtherWID=Chemical.WID
WHERE
  Illustration.DataSetWID=_KnowledgeBaseWID &&
  Illustration.Illustration='MetabolicMap' &&
  ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=Illustration.WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

UNION

SELECT Illustration.WID, DBID.XID WholeCellModelID, NULL Name, 'metabolicMapReactions' TableID
From Illustration
JOIN DBID ON DBID.OtherWID=Illustration.WID
JOIN Reaction ON Illustration.OtherWID=Reaction.WID
WHERE
  Illustration.DataSetWID=_KnowledgeBaseWID &&
  Illustration.Illustration='MetabolicMap' &&
  ((_WID IS NULL && _WholeCellModelID IS NULL) || (_WholeCellModelID IS NULL && _WID=Illustration.WID) || (_WID IS NULL && _WholeCellModelID=DBID.XID))

) AS IDs
ORDER BY IDs.WholeCellModelID, IDs.TableID;

END $$

DROP PROCEDURE IF EXISTS `search_knowledgebase` $$
CREATE PROCEDURE `search_knowledgebase` (IN _KnowledgeBaseWID bigint, IN _Keywords text)
BEGIN

SELECT 
	TextSearch.OtherWID WID, DBID.XID WholeCellModelID,
	Entry.InsertDate, Entry.ModifiedDate,
	InsertUser.UserName InsertUser, ModifiedUser.UserName ModifiedUser
FROM TextSearch
JOIN DBID ON DBID.OtherWID=TextSearch.OtherWID
JOIN Entry ON Entry.OtherWID=TextSearch.OtherWId
JOIN User InsertUser ON Entry.InsertUserID=InsertUser.ID
JOIN User ModifiedUser ON Entry.ModifiedUserID=ModifiedUser.ID
WHERE
 (MATCH(TextSearch.Text) AGAINST (_Keywords IN BOOLEAN MODE) || TextSearch.Text RLIKE CONCAT('(^|[^a-z])',_Keywords,'([^a-z]|$)')) &&
  Entry.DataSetWID=_KnowledgeBaseWID
GROUP BY TextSearch.OtherWID
ORDER BY DBID.XID;

END $$

DROP PROCEDURE IF EXISTS `get_newknowledgebaseobjects` $$
CREATE PROCEDURE `get_newknowledgebaseobjects` (IN _KnowledgeBaseWID bigint)
BEGIN

SELECT 
	Entry.OtherWID WID, DBID.XID WholeCellModelID,
	Entry.InsertDate, Entry.ModifiedDate,
	InsertUser.UserName InsertUser, ModifiedUser.UserName ModifiedUser
FROM Entry
JOIN DBID ON Entry.OtherWID=DBID.OtherWID
JOIN User InsertUser ON Entry.InsertUserID=InsertUser.ID
JOIN User ModifiedUser ON Entry.ModifiedUserID=ModifiedUser.ID
WHERE Entry.DataSetWID=_KnowledgeBaseWID
GROUP BY Entry.OtherWID
ORDER BY Entry.InsertDate DESC
LIMIT 100;

END $$

DROP PROCEDURE IF EXISTS `get_modifiedknowledgebaseobjects` $$
CREATE PROCEDURE `get_modifiedknowledgebaseobjects` (IN _KnowledgeBaseWID bigint)
BEGIN

SELECT 
	Entry.OtherWID WID, DBID.XID WholeCellModelID,
	Entry.InsertDate, Entry.ModifiedDate,
	InsertUser.UserName InsertUser, ModifiedUser.UserName ModifiedUser
FROM Entry
JOIN DBID ON Entry.OtherWID=DBID.OtherWID
JOIN User InsertUser ON Entry.InsertUserID=InsertUser.ID
JOIN User ModifiedUser ON Entry.ModifiedUserID=ModifiedUser.ID
WHERE Entry.DataSetWID=_KnowledgeBaseWID && Entry.InsertDate!=Entry.ModifiedDate
GROUP BY Entry.OtherWID
ORDER BY Entry.ModifiedDate DESC
LIMIT 100;

END $$

-- ---------------------------------------------------------
-- genome
-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS `set_genome_sequence` $$
CREATE PROCEDURE `set_genome_sequence` (IN _KnowledgeBaseWID bigint,IN _Sequence longtext)
BEGIN

UPDATE NucleicAcid
SET 
	Sequence=_Sequence,
	MoleculeLength=LENGTH(_Sequence)
WHERE DataSetWID=_KnowledgeBaseWID;

SELECT WID
FROM NucleicAcid
WHERE DataSetWID=_KnowledgeBaseWID && Class='Chromosome';

END $$

DROP PROCEDURE IF EXISTS `get_genome` $$
CREATE PROCEDURE `get_genome` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SELECT WID,Topology,Sequence
FROM NucleicAcid
WHERE
  DataSetWID=_KnowledgeBaseWID &&
  (_WID IS NULL || NucleicAcid.WID=_WID) &&
  Class='Chromosome' ;

END $$


-- ---------------------------------------------------------
-- process
-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS `set_process` $$
CREATE PROCEDURE `set_process` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
    IN _Name varchar(255),
    IN _InitializationOrder smallint, IN _EvaluationOrder smallint,
    IN _Class varchar(255))
BEGIN

DECLARE _ProcessWID bigint;

#process
SELECT WID INTO _ProcessWID FROM Process WHERE WID=_WID;
IF _ProcessWID IS NULL THEN
    INSERT INTO Process(WID, Name, InitializationOrder, EvaluationOrder,`Class`,DataSetWID)
    VALUES(_WID, _Name, _InitializationOrder, _EvaluationOrder, _Class, _KnowledgeBaseWID);
ELSE
    UPDATE Process
    SET
        Name=_Name,
        InitializationOrder=_InitializationOrder,
        EvaluationOrder=_EvaluationOrder,
        `Class`=_Class
    WHERE WID=_WID;
END IF;

CALL set_textsearch(_WID, _Name, 'name');

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_process` $$
CREATE PROCEDURE `delete_process` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

DECLARE _ForeignWID bigint;
DECLARE done INT DEFAULT 0;
DECLARE cur1 CURSOR FOR SELECT ParameterWID FROM ParameterWIDOtherWID WHERE OtherWID=_WID;
DECLARE cur2 CURSOR FOR SELECT ReactionWID FROM ReactionWIDOtherWID WHERE OtherWID=_WID;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

#process
DELETE FROM Process WHERE WID=_WID;

SET done=0;
OPEN cur1;
REPEAT
    FETCH cur1 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_parameter(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur1;

SET done=0;
OPEN cur2;
REPEAT
    FETCH cur2 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_reaction(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur2;

#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `get_processs` $$
CREATE PROCEDURE `get_processs` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Process.WID, DBID.XID WholeCellModelID,
  Process.Name,
  Process.InitializationOrder,
  Process.EvaluationOrder,
  Process.`Class`,
  GROUP_CONCAT(DISTINCT ParameterDBID.XID ORDER BY ParameterDBID.XID SEPARATOR ';') Parameters,
  GROUP_CONCAT(DISTINCT ReactionDBID.XID ORDER BY ReactionDBID.XID SEPARATOR ';') Reactions

FROM Process
JOIN DBID ON Process.WID=DBID.OtherWID

#parameters
LEFT JOIN (SELECT * FROM ParameterWIDOtherWID WHERE Type='Process') AS ParameterWIDOtherWID ON ParameterWIDOtherWID.OtherWID=Process.WID
LEFT JOIN DBID ParameterDBID ON ParameterWIDOtherWID.ParameterWID=ParameterDBID.OtherWID

#reactions
LEFT JOIN (SELECT * FROM ReactionWIDOtherWID WHERE Type='Process') AS ReactionWIDOtherWID ON ReactionWIDOtherWID.OtherWID=Process.WID
LEFT JOIN DBID ReactionDBID ON ReactionWIDOtherWID.ReactionWID=ReactionDBID.OtherWID

WHERE
  Process.DataSetWID=_KnowledgeBaseWID &&
  (_WID IS NULL || Process.WID=_WID)
GROUP BY Process.WID
ORDER BY DBID.XID;

END $$

-- ---------------------------------------------------------
-- state
-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS `set_state` $$
CREATE PROCEDURE `set_state` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
    IN _Name varchar(255), IN _Class varchar(255))
BEGIN

DECLARE _StateWID bigint;

#state
SELECT WID INTO _StateWID FROM State WHERE WID=_WID;
IF _StateWID IS NULL THEN
    INSERT INTO State(WID, Name, `Class`, DataSetWID)
    VALUES(_WID, _Name, _Class, _KnowledgeBaseWID);
ELSE
    UPDATE State
    SET
        Name=_Name,
        `Class`=_Class
    WHERE WID=_WID;
END IF;

CALL set_textsearch(_WID, _Name, 'name');

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_state` $$
CREATE PROCEDURE `delete_state` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

DECLARE _ForeignWID bigint;
DECLARE done INT DEFAULT 0;
DECLARE cur1 CURSOR FOR SELECT ParameterWID FROM ParameterWIDOtherWID WHERE OtherWID=_WID;
DECLARE cur2 CURSOR FOR SELECT ReactionWID FROM ReactionWIDOtherWID WHERE OtherWID=_WID;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

#state
DELETE FROM State WHERE WID=_WID;

SET done=0;
OPEN cur1;
REPEAT
    FETCH cur1 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_parameter(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur1;

SET done=0;
OPEN cur2;
REPEAT
    FETCH cur2 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_reaction(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur2;

#entry
CALL delete_entry(_WID);

END $$


DROP PROCEDURE IF EXISTS `get_states` $$
CREATE PROCEDURE `get_states` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  State.WID, DBID.XID WholeCellModelID,
  State.Name,
  State.`Class`,
  GROUP_CONCAT(DISTINCT ParameterDBID.XID ORDER BY ParameterDBID.XID SEPARATOR ';') Parameters,
  GROUP_CONCAT(DISTINCT ReactionDBID.XID ORDER BY ReactionDBID.XID SEPARATOR ';') Reactions

FROM State
JOIN DBID ON State.WID=DBID.OtherWID

#parameters
LEFT JOIN (SELECT * FROM ParameterWIDOtherWID WHERE Type='State') AS ParameterWIDOtherWID ON ParameterWIDOtherWID.OtherWID=State.WID
LEFT JOIN DBID ParameterDBID ON ParameterWIDOtherWID.ParameterWID=ParameterDBID.OtherWID

#reactions
LEFT JOIN (SELECT * FROM ReactionWIDOtherWID WHERE Type='State') AS ReactionWIDOtherWID ON ReactionWIDOtherWID.OtherWID=State.WID
LEFT JOIN DBID ReactionDBID ON ReactionWIDOtherWID.ReactionWID=ReactionDBID.OtherWID

WHERE
  State.DataSetWID=_KnowledgeBaseWID &&
  (_WID IS NULL || State.WID=_WID)
GROUP BY State.WID
ORDER BY DBID.XID;

END $$

-- ---------------------------------------------------------
-- parameter
-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS `set_parameter` $$
CREATE PROCEDURE `set_parameter` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _Name varchar(255),IN _Index varchar(255), 
  IN _Value text, IN _Units varchar(255), IN _ExperimentallyConstrained char(1),
  IN _Process varchar(255), IN _State varchar(255), IN _Reactions varchar(255), IN _Molecules varchar(255))
BEGIN

DECLARE _ParameterWID bigint;
DECLARE _ProcessWID bigint;
DECLARE _StateWID bigint;
DECLARE _ReactionWID bigint;
DECLARE _MoleculeWID bigint;
DECLARE _UnitsWID bigint;
DECLARE _idx smallint;
DECLARE _iterMax smallint;
DECLARE _ReactionXID varchar(255);
DECLARE _MoleculeXID varchar(255);

#units
CALL set_units(_KnowledgeBaseWID, _UnitsWID, _Units);

#parameter
SELECT WID INTO _ParameterWID FROM Parameter WHERE WID=_WID;
IF _ParameterWID IS NULL THEN
    INSERT INTO Parameter(WID,Name,Identifier,DefaultValue,UnitsWID,ExperimentallyConstrained,DataSetWID)
    VALUES(_WID,_Name,_Index,_Value,_UnitsWID,_ExperimentallyConstrained,_KnowledgeBaseWID);
ELSE
    UPDATE Parameter
    SET
        Name=_Name,
        Identifier=_Index,
        DefaultValue=_Value,
        UnitsWID=_UnitsWID,
		ExperimentallyConstrained=_ExperimentallyConstrained
    WHERE WID=_WID;
END IF;

DELETE FROM ParameterWIDOtherWID WHERE ParameterWID=_WID;

#process
SELECT WID INTO _ProcessWID
FROM `Process`
JOIN DBID ON DBID.OtherWID=`Process`.WID
WHERE DataSetWID=_KnowledgeBaseWID && DBID.XID=_Process;

IF _ProcessWID IS NOT NULL THEN
	INSERT INTO ParameterWIDOtherWID(ParameterWID, OtherWID, Type) VALUES(_WID, _ProcessWID, 'Process');
END IF;

#state
SELECT WID INTO _StateWID
FROM `State`
JOIN DBID ON DBID.OtherWID=`State`.WID
WHERE DataSetWID=_KnowledgeBaseWID && DBID.XID=_State;

IF _StateWID IS NOT NULL THEN
	INSERT INTO ParameterWIDOtherWID(ParameterWID, OtherWID, Type) VALUES(_WID, _StateWID, 'State');
END IF;

#reaction
SET _iterMax=(LENGTH(_Reactions)-LENGTH(REPLACE(_Reactions, ';', ''))+1);
SET _idx=1;
WHILE _idx<=_iterMax DO
	SET _ReactionXID=SUBSTRING_INDEX(SUBSTRING_INDEX(_Reactions,';',_idx),';',-1);
	
	SELECT WID INTO _ReactionWID
	FROM Reaction
	JOIN DBID ON DBID.OtherWID=Reaction.WID
	WHERE DataSetWID=_KnowledgeBaseWID && DBID.XID=_ReactionXID;

	IF _ReactionWID IS NOT NULL THEN
		INSERT INTO ParameterWIDOtherWID(ParameterWID, OtherWID, Type) VALUES(_WID, _ReactionWID, 'Reaction');
	END IF;
  
	SET _idx=_idx+1;
END WHILE;

#molecule
SET _iterMax=(LENGTH(_Molecules)-LENGTH(REPLACE(_Molecules, ';', ''))+1);
SET _idx=1;
WHILE _idx<=_iterMax DO
	SET _MoleculeXID=SUBSTRING_INDEX(SUBSTRING_INDEX(_Molecules,';',_idx),';',-1);

	SELECT Entry.OtherWID INTO _MoleculeWID
	FROM Entry
	JOIN DBID ON DBID.OtherWID=Entry.OtherWID
	WHERE DataSetWID=_KnowledgeBaseWID && DBID.XID=_MoleculeXID;
	
	IF _MoleculeWID IS NOT NULL THEN
		INSERT INTO ParameterWIDOtherWID(ParameterWID, OtherWID, Type) VALUES(_WID, _MoleculeWID, 'Molecule');
	END IF;
  
	SET _idx=_idx+1;
END WHILE;

CALL set_textsearch(_WID, _Process, 'process');
CALL set_textsearch(_WID, _State, 'state');
CALL set_textsearch(_WID, _Name,   'name');
CALL set_textsearch(_WID, _Index,  'index');
CALL set_textsearch(_WID, _Units,  'units');

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_parameter` $$
CREATE PROCEDURE `delete_parameter` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

#parameter
DELETE FROM Parameter WHERE WID=_WID;
DELETE FROM ParameterWIDOtherWID WHERE ParameterWID=_WID;

#experiment
DELETE FROM ExperimentData WHERE MageData=_WID;

#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `get_parameters` $$
CREATE PROCEDURE `get_parameters` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Parameter.WID, DBID.XID WholeCellModelID,
  Parameter.Name, Parameter.Identifier `Index`,
  Parameter.DefaultValue,
  Term.Name Units,
  Parameter.ExperimentallyConstrained,
  ProcessDBID.XID `Process`,
  StateDBID.XID `State`,
  GROUP_CONCAT(DISTINCT ReactionDBID.XID ORDER BY ReactionDBID.XID SEPARATOR ';') Reactions,
  GROUP_CONCAT(DISTINCT MoleculeDBID.XID ORDER BY MoleculeDBID.XID SEPARATOR ';') Molecules
FROM Parameter
JOIN DBID ON Parameter.WID=DBID.OtherWID

#process
LEFT JOIN (SELECT * FROM ParameterWIDOtherWID WHERE Type='Process') AS ProcessParameter ON Parameter.WID=ProcessParameter.ParameterWID
LEFT JOIN DBID ProcessDBID ON ProcessDBID.OtherWID=ProcessParameter.OtherWID

#state
LEFT JOIN (SELECT * FROM ParameterWIDOtherWID WHERE Type='State') AS StateParameter ON Parameter.WID=StateParameter.ParameterWID
LEFT JOIN DBID StateDBID ON StateDBID.OtherWID=StateParameter.OtherWID

#reaction
LEFT JOIN (SELECT * FROM ParameterWIDOtherWID WHERE Type='Reaction') AS ParameterReaction ON Parameter.WID=ParameterReaction.ParameterWID
LEFT JOIN DBID ReactionDBID ON ReactionDBID.OtherWID=ParameterReaction.OtherWID

#molecule
LEFT JOIN (SELECT * FROM ParameterWIDOtherWID WHERE Type='Molecule') AS  MoleculeReaction ON Parameter.WID=MoleculeReaction.ParameterWID
LEFT JOIN DBID MoleculeDBID ON MoleculeDBID.OtherWID=MoleculeReaction.OtherWID

#units
JOIN Term ON Term.WID=Parameter.UnitsWID

WHERE 
	Parameter.DataSetWID=_KnowledgeBaseWID && 
	(_WID IS NULL || Parameter.WID=_WID)
GROUP BY Parameter.WID
ORDER BY DBID.XID;

END $$

DROP PROCEDURE IF EXISTS `get_processs_parameters` $$
CREATE PROCEDURE `get_processs_parameters` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @processIdx:=0;
SET @parameterIdx:=0;

SELECT
  Process.Idx ProcessIdx,
  Process.WID ProcessWID,
  Process.XID Process,  
  Parameter.Idx ParameterIdx,
  Parameter.WID ParameterWID,
  Parameter.XID Parameter
FROM

(SELECT @parameterIdx:=@parameterIdx+1 AS Idx,Parameter.WID, DBID.XID
 FROM Parameter
 JOIN DBID ON DBID.OtherWID=Parameter.WID
 WHERE Parameter.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Parameter

JOIN ParameterWIDOtherWID ON Parameter.WID=ParameterWIDOtherWID.ParameterWID

JOIN (
 SELECT @processIdx:=@processIdx+1 AS Idx,Process.WID, DBID.XID
 FROM Process
 JOIN DBID ON DBID.OtherWID=Process.WID
 WHERE Process.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Process ON ParameterWIDOtherWID.OtherWID=Process.WID

WHERE ParameterWIDOtherWID.Type='Process' && (_WID IS NULL || (Parameter.WID=_WID || Process.WID=_WID))
GROUP BY Process.Idx,Parameter.IDx
ORDER BY Process.Idx,Parameter.IDx;

END $$

DROP PROCEDURE IF EXISTS `get_states_parameters` $$
CREATE PROCEDURE `get_states_parameters` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @stateIdx:=0;
SET @parameterIdx:=0;

SELECT
  State.Idx StateIdx,
  State.WID StateWID,
  State.XID State,
  Parameter.Idx ParameterIdx,
  Parameter.WID ParameterWID,
  Parameter.XID Parameter
FROM

(SELECT @parameterIdx:=@parameterIdx+1 AS Idx,Parameter.WID, DBID.XID
 FROM Parameter
 JOIN DBID ON DBID.OtherWID=Parameter.WID
 WHERE Parameter.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Parameter

JOIN ParameterWIDOtherWID ON Parameter.WID=ParameterWIDOtherWID.ParameterWID

JOIN (
 SELECT @stateIdx:=@stateIdx+1 AS Idx,State.WID, DBID.XID
 FROM State
 JOIN DBID ON DBID.OtherWID=State.WID
 WHERE State.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS State ON ParameterWIDOtherWID.OtherWID=State.WID

WHERE ParameterWIDOtherWID.Type='State' && (_WID IS NULL || (Parameter.WID=_WID || State.WID=_WID))
GROUP BY State.Idx,Parameter.IDx
ORDER BY State.Idx,Parameter.IDx;

END $$

DROP PROCEDURE IF EXISTS `get_reactions_parameters` $$
CREATE PROCEDURE `get_reactions_parameters` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @reactionIdx:=0;
SET @parameterIdx:=0;

SELECT
  Reaction.Idx ReactionIdx,
  Reaction.WID ReactionWID,
  Reaction.XID Reaction,  
  Parameter.Idx ParameterIdx,
  Parameter.WID ParameterWID,
  Parameter.XID Parameter
FROM

(SELECT @parameterIdx:=@parameterIdx+1 AS Idx,Parameter.WID, DBID.XID
 FROM Parameter
 JOIN DBID ON DBID.OtherWID = Parameter.WID
 WHERE Parameter.DataSetWID = _KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Parameter

JOIN ParameterWIDOtherWID ON Parameter.WID=ParameterWIDOtherWID.ParameterWID

JOIN (SELECT @reactionIdx:=@reactionIdx+1 AS Idx,Reaction.WID, DBID.XID
 FROM Reaction
 JOIN DBID ON Reaction.WID=DBID.OtherWID
 JOIN ReactionWIDOtherWID ON Reaction.WID=ReactionWIDOtherWID.ReactionWID
 WHERE Reaction.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Reaction ON ParameterWIDOtherWID.OtherWID=Reaction.WID

WHERE ParameterWIDOtherWID.Type = 'Reaction' && (_WID IS NULL || (Parameter.WID=_WID || Reaction.WID=_WID))
GROUP BY Reaction.Idx, Parameter.IDx
ORDER BY Reaction.Idx, Parameter.IDx;

END $$

DROP PROCEDURE IF EXISTS `get_proteinmonomers_parameters` $$
CREATE PROCEDURE `get_proteinmonomers_parameters` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinMonomerIdx:=0;
SET @parameterIdx:=0;

SELECT
  ProteinMonomer.Idx ProteinMonomerIdx,
  ProteinMonomer.WID ProteinMonomerWID,
  ProteinMonomer.XID ProteinMonomer,  
  Parameter.Idx ParameterIdx,
  Parameter.WID ParameterWID,
  Parameter.XID Parameter
FROM

(SELECT @parameterIdx:=@parameterIdx+1 AS Idx,Parameter.WID, DBID.XID
 FROM Parameter
 JOIN DBID ON DBID.OtherWID=Parameter.WID
 WHERE Parameter.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Parameter

JOIN ParameterWIDOtherWID ON Parameter.WID=ParameterWIDOtherWID.ParameterWID

JOIN (SELECT @proteinMonomerIdx:=@proteinMonomerIdx+1 AS Idx,GeneWIDProteinWID.ProteinWID WID, DBID.XID
 FROM GeneWIDProteinWID
 JOIN Gene ON GeneWIDProteinWID.GeneWID=Gene.WID
 JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS ProteinMonomer ON ParameterWIDOtherWID.OtherWID=ProteinMonomer.WID

WHERE ParameterWIDOtherWID.Type='Molecule' && (_WID IS NULL || (Parameter.WID=_WID || ProteinMonomer.WID=_WID))
GROUP BY ProteinMonomer.Idx,Parameter.IDx
ORDER BY ProteinMonomer.Idx,Parameter.IDx;

END $$

DROP PROCEDURE IF EXISTS `get_proteincomplexs_parameters` $$
CREATE PROCEDURE `get_proteincomplexs_parameters` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinComplexIdx:=0;
SET @parameterIdx:=0;

SELECT
  ProteinComplex.Idx ProteinComplexIdx,
  ProteinComplex.WID ProteinComplexWID,
  ProteinComplex.XID ProteinComplex,  
  Parameter.Idx ParameterIdx,
  Parameter.WID ParameterWID,
  Parameter.XID Parameter
FROM

(SELECT @parameterIdx:=@parameterIdx+1 AS Idx,Parameter.WID, DBID.XID
 FROM Parameter
 JOIN DBID ON DBID.OtherWID=Parameter.WID
 WHERE Parameter.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Parameter

JOIN ParameterWIDOtherWID ON Parameter.WID=ParameterWIDOtherWID.ParameterWID

JOIN (SELECT @proteinComplexIdx:=@proteinComplexIdx+1 AS Idx,Protein.WID,Protein.CompartmentWID, DBID.XID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS ProteinComplex ON ParameterWIDOtherWID.OtherWID=ProteinComplex.WID

WHERE ParameterWIDOtherWID.Type='Molecule' && (_WID IS NULL || (Parameter.WID=_WID || ProteinComplex.WID=_WID))
GROUP BY ProteinComplex.Idx,Parameter.IDx
ORDER BY ProteinComplex.Idx,Parameter.IDx;

END $$
-- ---------------------------------------------------------
-- compartments
-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS `set_compartment` $$
CREATE PROCEDURE `set_compartment` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _Name varchar(255))
BEGIN

DECLARE _CompartmentWID bigint;

SELECT WID INTO _CompartmentWID From Compartment WHERE WID=_WID;
IF _CompartmentWID IS NULL THEN
	INSERT INTO Compartment(WID,Name,DataSetWID) VALUES(_WID,_Name,_KnowledgeBaseWID);
ELSE
	UPDATE Compartment
	SET Name=_Name
	WHERE WID=_WID;
END IF;

CALL set_textsearch(_WID, _Name, 'name');

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_compartment` $$
CREATE PROCEDURE `delete_compartment` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

DECLARE _ForeignWID bigint;
DECLARE done INT DEFAULT 0;
DECLARE cur1 CURSOR FOR SELECT WID FROM Gene WHERE CompartmentWID=_WID;
DECLARE cur2 CURSOR FOR SELECT WID FROM TranscriptionUnit WHERE CompartmentWID=_WID;
DECLARE cur3 CURSOR FOR SELECT WID FROM Protein JOIN Subunit ON ComplexWID=WID WHERE Protein.CompartmentWID=_WID;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

#compartment
DELETE FROM Compartment WHERE WID=_WID;

SET done=0;
OPEN cur1;
REPEAT
    FETCH cur1 INTO _ForeignWID;
    IF NOT done THEN
		    CALL delete_gene(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur1;

SET done=0;
OPEN cur2;
REPEAT
    FETCH cur2 INTO _ForeignWID;
    IF NOT done THEN
		    CALL delete_transcriptionunit(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur2;

SET done=0;
OPEN cur3;
REPEAT
    FETCH cur3 INTO _ForeignWID;
    IF NOT done THEN
        CALL delete_proteincomplex(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur3;

#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `get_compartments` $$
CREATE PROCEDURE `get_compartments` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Compartment.WID, DBID.XID WholeCellModelID,
  Compartment.Name

FROM Compartment
JOIN DBID ON Compartment.WID=DBID.OtherWID

WHERE Compartment.DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || Compartment.WID=_WID)
GROUP BY Compartment.WID
ORDER BY DBID.XID;

END $$

DROP PROCEDURE IF EXISTS `get_genes_compartments` $$
CREATE PROCEDURE `get_genes_compartments` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @geneIdx:=0;
SET @compartmentIdx:=0;

SELECT
  Gene.Idx GeneIdx,
  Gene.WID GeneWID,
  Gene.XID Gene,
  Compartment.Idx CompartmentIdx,
  Compartment.WID CompartmentWID,
  Compartment.XID Compartment
FROM

(SELECT @geneIdx:=@geneIdx+1 AS Idx,Gene.WID,Gene.CompartmentWID, DBID.XID
 FROM Gene
 JOIN DBID ON DBID.OtherWID=Gene.WID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS Gene

JOIN
(SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
  FROM Compartment
  JOIN DBID ON DBID.OtherWID=Compartment.WID
  WHERE Compartment.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Compartment
ON Gene.CompartmentWID=Compartment.WID

WHERE _WID IS NULL || (Gene.WID=_WID || Compartment.WID=_WID)
GROUP BY Gene.Idx,Compartment.Idx
ORDER BY Gene.Idx,Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_transcriptionunits_compartments` $$
CREATE PROCEDURE `get_transcriptionunits_compartments` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @transcriptionUnitIdx:=0;
SET @compartmentIdx:=0;

SELECT
  TranscriptionUnit.Idx TranscriptionUnitIdx,
  TranscriptionUnit.WID TranscriptionUnitWID,
  TranscriptionUnit.XID TranscriptionUnit,
  Compartment.Idx CompartmentIdx,
  Compartment.WID CompartmentWID,
  Compartment.XID Compartment
FROM

(SELECT @transcriptionUnitIdx:=@transcriptionUnitIdx+1 AS Idx,TranscriptionUnit.WID,TranscriptionUnit.CompartmentWID, DBID.XID
 FROM TranscriptionUnitComponent
 JOIN Gene ON TranscriptionUnitComponent.OtherWID=Gene.WID
 JOIN TranscriptionUnit ON TranscriptionUnit.WID=TranscriptionUnitComponent.TranscriptionUnitWID
 JOIN DBID ON DBID.OtherWID=TranscriptionUnit.WID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 GROUP BY TranscriptionUnit.WID
 ORDER BY MIN(Gene.CodingRegionStart)
) AS TranscriptionUnit

JOIN
(SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
  FROM Compartment
  JOIN DBID ON DBID.OtherWID=Compartment.WID
  WHERE Compartment.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Compartment
ON TranscriptionUnit.CompartmentWID=Compartment.WID

WHERE _WID IS NULL || (TranscriptionUnit.WID=_WID || Compartment.WID=_WID)
GROUP BY TranscriptionUnit.Idx,Compartment.Idx
ORDER BY TranscriptionUnit.Idx,Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteinmonomers_compartments` $$
CREATE PROCEDURE `get_proteinmonomers_compartments` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinMonomerIdx:=0;
SET @compartmentIdx:=0;

SELECT
  ProteinMonomer.Idx ProteinMonomerIdx,
  ProteinMonomer.WID ProteinMonomerWID,
  ProteinMonomer.XID ProteinMonomer,
  Compartment.Idx CompartmentIdx,
  Compartment.WID CompartmentWID,
  Compartment.XID Compartment
FROM

(SELECT @proteinMonomerIdx:=@proteinMonomerIdx+1 AS Idx,GeneWIDProteinWID.ProteinWID WID,Protein.CompartmentWID,DBID.XID
 FROM GeneWIDProteinWID
 JOIN Protein ON GeneWIDProteinWID.ProteinWID=Protein.WID
 JOIN Gene ON GeneWIDProteinWID.GeneWID=Gene.WID
 JOIN DBID ON DBID.OtherWID=Protein.WID
 WHERE Protein.DataSetWID=_KnowledgeBaseWID
 GROUP BY Protein.WID
 ORDER BY MIN(Gene.CodingRegionStart)
) AS ProteinMonomer

JOIN
(SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID,DBID.XID
  FROM Compartment
  JOIN DBID ON DBID.OtherWID=Compartment.WID
  WHERE Compartment.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Compartment
ON ProteinMonomer.CompartmentWID=Compartment.WID

WHERE _WID IS NULL || (ProteinMonomer.WID=_WID || Compartment.WID=_WID)
GROUP BY ProteinMonomer.Idx,Compartment.Idx
ORDER BY ProteinMonomer.Idx,Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteincomplexs_compartments` $$
CREATE PROCEDURE `get_proteincomplexs_compartments` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinComplexIdx:=0;
SET @compartmentIdx:=0;

SELECT
  ProteinComplex.Idx ProteinComplexIdx,
  ProteinComplex.WID ProteinComplexWID,
  ProteinComplex.XID ProteinComplex,
  Compartment.Idx CompartmentIdx,
  Compartment.WID CompartmentWID,
  Compartment.XID Compartment
FROM

(SELECT @proteinComplexIdx:=@proteinComplexIdx+1 AS Idx,Protein.WID,Protein.CompartmentWID, DBID.XID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS ProteinComplex

JOIN
(SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
  FROM Compartment
  JOIN DBID ON DBID.OtherWID=Compartment.WID
  WHERE Compartment.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Compartment
ON ProteinComplex.CompartmentWID=Compartment.WID

WHERE _WID IS NULL || (ProteinComplex.WID=_WID || Compartment.WID=_WID)
GROUP BY ProteinComplex.Idx,Compartment.Idx
ORDER BY ProteinComplex.Idx,Compartment.Idx;

END $$

-- ---------------------------------------------------------
-- pathways
-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS `set_pathway` $$
CREATE PROCEDURE `set_pathway` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _Name varchar(255))
BEGIN

DECLARE _PathwayWID bigint;

SELECT WID INTO _PathwayWID FROM Pathway WHERE WID=_WID;
IF _PathwayWID IS NULL THEN
	INSERT INTO Pathway(WID,Name,Type,DataSetWID) VALUES(_WID,_Name,'O',_KnowledgeBaseWID);
ELSE
	UPDATE Pathway
	SET Name=_Name
	WHERE WID=_WID;
END IF;

CALL set_textsearch(_WID, _Name, 'name');

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_pathway` $$
CREATE PROCEDURE `delete_pathway` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

#pathway
DELETE Pathway, PathwayReaction
FROM Pathway
JOIN PathwayReaction ON Pathway.WID=PathwayReaction.PathwayWId
WHERE Pathway.WID=_WID;

#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `get_pathways` $$
CREATE PROCEDURE `get_pathways` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Pathway.WID, DBID.XID WholeCellModelID,
  Pathway.Name,
  GROUP_CONCAT(DISTINCT ReactionDBID.XID ORDER BY ReactionDBID.XID SEPARATOR ';') Reactions

FROM Pathway
JOIN DBID ON Pathway.WID=DBID.OtherWID

#reactions
LEFT JOIN PathwayReaction ON PathwayReaction.PathwayWID=Pathway.WID
LEFT JOIN DBID ReactionDBID ON ReactionDBID.OtherWID=PathwayReaction.ReactionWID

WHERE Pathway.DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || Pathway.WID=_WID)
GROUP BY Pathway.WID
ORDER BY DBID.XID;

END $$

DROP PROCEDURE IF EXISTS `get_reactions_pathways` $$
CREATE PROCEDURE `get_reactions_pathways` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @reactionIdx:=0;
SET @pathwayIdx:=0;

SELECT
  Reaction.Idx ReactionIdx,
  Reaction.WID ReactionWID,
  Reaction.XID Reaction,
  Pathway.Idx PathwayIdx,
  Pathway.WID PathwayWID,
  Pathway.XID Pathway
FROM

(SELECT @reactionIdx:=@reactionIdx+1 AS Idx,Reaction.WID, DBID.XID
 FROM Reaction
 JOIN DBID ON Reaction.WID=DBID.OtherWID
 JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
 WHERE Reaction.DataSetWID=_KnowledgeBaseWID
 GROUP BY Reaction.WID
 ORDER BY DBID.XID
) AS Reaction

JOIN PathwayReaction ON Reaction.WID=PathwayReaction.ReactionWID

JOIN
(SELECT @pathwayIdx:=@pathwayIdx+1 AS Idx,Pathway.WID, DBID.XID
  FROM Pathway
  JOIN DBID ON Pathway.WID=DBID.OtherWID
  WHERE Pathway.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Pathway
ON PathwayReaction.PathwayWID=Pathway.WID

WHERE _WID IS NULL || (Reaction.WID=_WID || Pathway.WID=_WID)
GROUP BY Reaction.Idx,Pathway.Idx
ORDER BY Reaction.Idx,Pathway.Idx;

END $$


-- ---------------------------------------------------------
-- genes
-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS `set_gene` $$
CREATE PROCEDURE `set_gene` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _Symbol varchar(255), IN _Synonyms text, IN _Name varchar(255),IN _Type varchar(100),IN _StartCodon char(1), IN _Codons varchar(255),IN _AminoAcid varchar(255), IN _Coordinate int,IN _Length int,IN _Direction varchar(25),IN _MolecularWeightCalc float,
  IN _Essential char(1),IN _Expression float,IN _ExpressionColdShock float,IN _ExpressionHeatShock float,IN _HalfLifeExp float,IN _PICalc float,IN _Compartment varchar(255))
BEGIN

DECLARE _GeneWID bigint;
DECLARE _maxIdx smallint;
DECLARE _idx smallint default 1;
DECLARE _synonym varchar(255);
DECLARE _CompartmentWID bigint;
DECLARE _AminoAcidWID bigint;

SELECT WID INTO _CompartmentWID FROM Compartment JOIN DBID ON DBID.OtherWID=Compartment.WID WHERE Compartment.DataSetWID=_KnowledgeBaseWID && DBID.XID=_Compartment;
SELECT WID INTO _AminoAcidWID FROM Chemical JOIN DBID ON DBID.OtherWID=Chemical.WID WHERE Chemical.DataSetWID=_KnowledgeBaseWID && DBID.XID=_AminoAcid;

SELECT WID INTO _GeneWID FROM Gene WHERE WID=_WID;
IF _GeneWID IS NULL THEN
	INSERT INTO Gene (WID,Symbol,Name,Type,CodingRegionStart,CodingRegionEnd,Length,Direction,MolecularWeightCalc,Essential,StartCodon,Codons,AminoAcidWID,Expression,ExpressionColdShock,ExpressionHeatShock,HalfLifeExp,PICalc,CompartmentWID,DataSetWID)
	VALUES (_WID,_Symbol,_Name,_Type,_Coordinate,_Coordinate+_Length-1,_Length,_Direction,_MolecularWeightCalc,_Essential,_StartCodon,_Codons,_AminoAcidWID,_Expression,_ExpressionColdShock,_ExpressionHeatShock,_HalfLifeExp,_PICalc,_CompartmentWID,_KnowledgeBaseWID);
ELSE
	UPDATE Gene
	SET 
		Symbol=_Symbol,
		Name=_Name,
		Type=_Type,
		CodingRegionStart=_Coordinate,
		CodingRegionEnd=_Coordinate+_Length-1,
		Length=_Length,
		Direction=_Direction,
		MolecularWeightCalc=_MolecularWeightCalc,
		Essential=_Essential,
		StartCodon=_StartCodon,
		Codons=_Codons,
		AminoAcidWID=_AminoAcidWID,
		Expression=_Expression,
		ExpressionColdShock=_ExpressionColdShock,
		ExpressionHeatShock=_ExpressionHeatShock,
		HalfLifeExp=_HalfLifeExp,
		PICalc=_PICalc,
		CompartmentWID=_CompartmentWID
	WHERE WID=_WID;
END IF;

#synonyms
CALL set_synonyms(_WID,_Synonyms);

CALL set_textsearch(_WID, _Symbol, 'symbol');
CALL set_textsearch(_WID, _Name, 'name');
CALL set_textsearch(_WID, _Type, 'type');
CALL set_textsearch(_WID, _StartCodon, 'start codon');
CALL set_textsearch(_WID, _Codons, 'codons');
CALL set_textsearch(_WID, _AminoAcid, 'amino acid');

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `set_gene_sequence` $$
CREATE PROCEDURE `set_gene_sequence` (IN _KnowledgeBaseWID bigint,
  IN _WholeCellModelID varchar(255), IN _NTSequence text)
BEGIN

UPDATE Gene,DBID
SET
  NTSequence=_NTSequence,
  Length=LENGTH(_NTSequence),
  GCContent=(1-LENGTH(REPLACE(REPLACE(_NTSequence,'A',''),'T',''))/Length(_NTSequence))
WHERE
  Gene.WID=DBID.OtherWID &&
  DBID.XID=_WholeCellModelID &&
  Gene.DataSetWID=_KnowledgeBaseWID;

SELECT WID FROM Gene JOIN DBID ON Gene.WID=DBID.OtherWID WHERE DBID.XID=_WholeCellModelID && Gene.DataSetWID=_KnowledgeBaseWID;

END $$

DROP PROCEDURE IF EXISTS `delete_gene` $$
CREATE PROCEDURE `delete_gene` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

DECLARE _ForeignWID bigint;
DECLARE done INT DEFAULT 0;
DECLARE cur1 CURSOR FOR SELECT WID FROM Protein JOIN GeneWIDProteinWID ON ProteinWID=WID WHERE GeneWIDProteinWID.GeneWID=_WID;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

#gene
DELETE Gene, TranscriptionUnitComponent, Reactant, Product, ModificationReaction, EnzymaticReaction, EnzReactionCofactor
FROM Gene
JOIN TranscriptionUnitComponent ON TranscriptionUnitComponent.OtherWID=Gene.WID
LEFT JOIN Reactant ON Reactant.OtherWID=Gene.WID
LEFT JOIN Product ON Product.OtherWID=Gene.WID
LEFT JOIN ModificationReaction ON ModificationReaction.OtherWID=Gene.WID
LEFT JOIN EnzymaticReaction ON EnzymaticReaction.ProteinWID=Gene.WID
LEFT JOIN EnzReactionCofactor ON EnzReactionCofactor.EnzymaticReactionWID=EnzymaticReaction.WID
WHERE Gene.WID=_WID;

SET done=0;
OPEN cur1;
REPEAT
    FETCH cur1 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_proteinmonomer(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur1;

#gene->protein
DELETE FROM GeneWIDProteinWID WHERE GeneWID=_WID;

#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `get_genes` $$
CREATE PROCEDURE `get_genes` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

DECLARE _TotalSynthesisRate float;
DECLARE _GenomeSequence longtext;
SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT SUM(LN(2)/Gene.HalfLifeCalc*Gene.Expression) INTO _TotalSynthesisRate
FROM Gene
WHERE DataSetWID=_KnowledgeBaseWID;

SELECT Sequence INTO _GenomeSequence
FROM NucleicAcid
WHERE NucleicAcid.DataSetWID=_KnowledgeBaseWID && Class='Chromosome';

SELECT
	@Idx:=@Idx+1 AS Idx,
	Gene.WID, DBID.XID WholeCellModelID,
	Gene.Symbol, GROUP_CONCAT(DISTINCT SynonymTable.Syn ORDER BY SynonymTable.Syn SEPARATOR ';') Synonyms, Gene.Name, Gene.Type,
	Gene.StartCodon, Gene.Codons, Gene.AminoAcid,
	Gene.CodingRegionStart Coordinate, Gene.Length, Gene.Direction,
	MID(_GenomeSequence,Gene.CodingRegionStart,Gene.Length) Sequence,
	Gene.MolecularWeightCalc, Gene.GCContent,
	Gene.Essential, Gene.Expression, Gene.ExpressionColdShock, Gene.ExpressionHeatShock, Gene.HalfLifeExp, Gene.HalfLifeCalc,
	LN(2)/Gene.HalfLifeCalc HalfLifeTimeConstant, LN(2)/Gene.HalfLifeCalc*Gene.Expression SynthesisRate, LN(2)/Gene.HalfLifeCalc*Gene.Expression/_TotalSynthesisRate ProbRNAPolBinding,
	Gene.PICalc,
	TranscriptionUnitDBID.XID TranscriptionUnit,
	Gene.Reactions,
	CompartmentDBID.XID Compartment

FROM (
  SELECT
    Gene.*,
    DBID.XID AminoAcid,
    NULL Reactions
  FROM Gene
  LEFT JOIN DBID ON Gene.AminoAcidWID=DBID.OtherWID
  WHERE Gene.Type!='mRNA'  && Gene.DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || Gene.WID=_WID)

  UNION

  SELECT
    Gene.*,
    NULL AminoAcid,
    GROUP_CONCAT(DISTINCT ReactionDBID.XID ORDER BY ReactionDBID.XID SEPARATOR ';') Reactions
  FROM Gene

  #protein monomer
  JOIN GeneWIDProteinWID ON GeneWIDProteinWID.GeneWID=Gene.WID
  LEFT JOIN Subunit ON Subunit.SubunitWID=GeneWIDProteinWID.ProteinWID
  LEFT JOIN EnzymaticReaction ON EnzymaticReaction.ProteinWID=GeneWIDProteinWID.ProteinWID || EnzymaticReaction.ProteinWID=Subunit.ComplexWID
  LEFT JOIN DBID ReactionDBID ON ReactionDBID.OtherWID=EnzymaticReaction.ReactionWID

  WHERE Gene.Type='mRNA' && Gene.DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || Gene.WID=_WID)
  GROUP BY Gene.WID
  ) AS Gene

#whole cell model id
JOIN DBID ON Gene.WID=DBID.OtherWID

#transcription unit
JOIN TranscriptionUnitComponent ON Gene.WID=TranscriptionUnitComponent.OtherWID && Gene.CompartmentWID=TranscriptionUnitComponent.CompartmentWID
JOIN DBID TranscriptionUnitDBID ON TranscriptionUnitDBID.OtherWID=TranscriptionUnitComponent.TranscriptionUnitWID

#compartment
JOIN DBID CompartmentDBID ON CompartmentDBID.OtherWID=Gene.CompartmentWID

#synonyms
LEFT JOIN SynonymTable ON SynonymTable.OtherWID=Gene.WID

WHERE Gene.DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || Gene.WID=_WID)
GROUP BY Gene.WID
ORDER BY Gene.CodingRegionStart;

END $$

DROP PROCEDURE IF EXISTS `get_genesequences` $$
CREATE PROCEDURE `get_genesequences` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Gene.WID,DBID.XID WholeCellModelID,Gene.Name,CodingRegionStart,CodingRegionEnd,Direction,Length,GCContent,NTSequence
FROM Gene
JOIN DBID ON DBID.OtherWID=Gene.WID
WHERE Gene.DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || Gene.WID=_WID);

END $$


DROP PROCEDURE IF EXISTS `get_genes_aminoacids` $$
CREATE PROCEDURE `get_genes_aminoacids` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @geneIdx:=0;
SET @metaboliteIdx:=0;

SELECT
  Gene.Idx GeneIdx,
  Gene.WID GeneWID,
  Gene.XID Gene,
  Metabolite.Idx MetaboliteIdx,
  Metabolite.WID MetaboliteWID,
  Metabolite.XID Metabolite
FROM

(SELECT @geneIdx:=@geneIdx+1 AS Idx,Gene.WID,Gene.AminoAcidWID, DBID.XID
 FROM Gene
 JOIN DBID ON DBID.OtherWID=Gene.WID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS Gene

JOIN (

 SELECT @metaboliteIdx:=@metaboliteIdx+1 AS Idx,Chemical.WID, DBID.XID
 FROM Chemical
 JOIN DBID ON DBID.OtherWID=Chemical.WID
 WHERE Chemical.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Metabolite ON Metabolite.WID=Gene.AminoAcidWID

WHERE _WID IS NULL || (Gene.WID=_WID || Metabolite.WID=_WID)
GROUP BY Gene.Idx,Metabolite.Idx
ORDER BY Gene.Idx,Metabolite.Idx;

END $$




DROP PROCEDURE IF EXISTS `get_geneannotations` $$
CREATE PROCEDURE `get_geneannotations` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Gene.WID, DBID.XID WholeCellModelID,
 	Gene.Symbol, GROUP_CONCAT(DISTINCT SynonymTable.Syn ORDER BY SynonymTable.Syn SEPARATOR ';') Synonyms, Gene.Name, Gene.Type,
 	Gene.StartCodon, Gene.Codons, Gene.AminoAcid,
 	Gene.CodingRegionStart Coordinate, Gene.Length, Gene.Direction,
 	Gene.Essential,
 	TranscriptionUnitDBID.XID TranscriptionUnit,
  Gene.Reactions,  
  GeneCommentTable.Comm GeneComments,
  TUCommentTable.Comm TranscriptionUnitComments,
  Gene.ProteinMonomerComments,
  Gene.ProteinComplexComments,
  Gene.ReactionComments

FROM (
  SELECT
    Gene.*,
    DBID.XID AminoAcid,
    GROUP_CONCAT(DISTINCT ComplexDBID.XID ORDER BY ComplexDBID.XID SEPARATOR ';') Complexs,
    GROUP_CONCAT(DISTINCT ReactionDBID.XID ORDER BY ReactionDBID.XID SEPARATOR ';') Reactions,
    NULL ProteinMonomerComments,
    GROUP_CONCAT(DISTINCT ComplexCommentTable.Comm ORDER BY ComplexDBID.XID SEPARATOR '. ') ProteinComplexComments,
    GROUP_CONCAT(DISTINCT ReactionCommentTable.Comm  ORDER BY ReactionDBID.XID SEPARATOR '. ') ReactionComments
  FROM Gene
  
  LEFT JOIN DBID ON Gene.AminoAcidWID = DBID.OtherWID
  
  #protein complex
  LEFT JOIN Subunit ON Subunit.SubunitWID = Gene.WID
  LEFT JOIN EnzymaticReaction ON EnzymaticReaction.ProteinWID = EnzymaticReaction.ProteinWID = Subunit.ComplexWID  
  LEFT JOIN DBID ComplexDBID ON ComplexDBID.OtherWID = Subunit.ComplexWID
  LEFT JOIN DBID ReactionDBID ON ReactionDBID.OtherWID = EnzymaticReaction.ReactionWID  
  
  #comments
  LEFT JOIN CommentTable ComplexCommentTable ON ComplexCommentTable.OtherWID = Subunit.ComplexWID
  LEFT JOIN CommentTable ReactionCommentTable ON ReactionCommentTable.OtherWID = EnzymaticReaction.ReactionWID
  
  WHERE Gene.Type != 'mRNA' && Gene.DataSetWID = _KnowledgeBaseWID && (_WID IS NULL || Gene.WID=_WID)
  GROUP BY Gene.WID

  UNION

  SELECT
    Gene.*,
    NULL AminoAcid,    
    GROUP_CONCAT(DISTINCT ComplexDBID.XID ORDER BY ComplexDBID.XID SEPARATOR ';') Complexs,
    GROUP_CONCAT(DISTINCT ReactionDBID.XID ORDER BY ReactionDBID.XID SEPARATOR ';') Reactions,
    MonomerCommentTable.Comm ProteinMonomerComments,
    GROUP_CONCAT(DISTINCT ComplexCommentTable.Comm ORDER BY ComplexDBID.XID SEPARATOR '. ') ProteinComplexComments,
    GROUP_CONCAT(DISTINCT ReactionCommentTable.Comm  ORDER BY ReactionDBID.XID SEPARATOR '. ') ReactionComments
  FROM Gene

  #protein monomer
  JOIN GeneWIDProteinWID ON GeneWIDProteinWID.GeneWID = Gene.WID
  LEFT JOIN Subunit ON Subunit.SubunitWID = GeneWIDProteinWID.ProteinWID
  LEFT JOIN (
     SELECT EnzymaticReaction.ProteinWID, EnzymaticReaction.ReactionWID
     FROM EnzymaticReaction
     WHERE EnzymaticReaction.DataSetWID = _KnowledgeBaseWID

     UNION     
     
     SELECT Protein.WID ProteinWID, Reactant.ReactionWID
     FROM Protein 
     JOIN Reactant ON Protein.WID = Reactant.OtherWID
     WHERE Protein.DataSetWID = _KnowledgeBaseWID
     
     UNION
     
     SELECT Protein.WID ProteinWID, Product.ReactionWID
     FROM Protein 
     JOIN Product ON Protein.WID = Product.OtherWID
     WHERE Protein.DataSetWID = _KnowledgeBaseWID
     ) AS ProteinReaction ON ProteinReaction.ProteinWID = GeneWIDProteinWID.ProteinWID || ProteinReaction.ProteinWID = Subunit.ComplexWID     
  LEFT JOIN DBID ComplexDBID ON ComplexDBID.OtherWID = Subunit.ComplexWID
  LEFT JOIN DBID ReactionDBID ON ReactionDBID.OtherWID = ProteinReaction.ReactionWID
  
  #comments
  LEFT JOIN CommentTable MonomerCommentTable ON MonomerCommentTable.OtherWID = GeneWIDProteinWID.ProteinWID
  LEFT JOIN CommentTable ComplexCommentTable ON ComplexCommentTable.OtherWID = Subunit.ComplexWID
  LEFT JOIN CommentTable ReactionCommentTable ON ReactionCommentTable.OtherWID = ProteinReaction.ReactionWID

  WHERE Gene.Type = 'mRNA' && Gene.DataSetWID = _KnowledgeBaseWID && (_WID IS NULL || Gene.WID=_WID)
  GROUP BY Gene.WID
  ) AS Gene

#whole cell model id
JOIN DBID ON Gene.WID = DBID.OtherWID

#synonyms
LEFT JOIN SynonymTable ON SynonymTable.OtherWID=Gene.WID

#transcription unit
JOIN TranscriptionUnitComponent ON Gene.WID = TranscriptionUnitComponent.OtherWID && Gene.CompartmentWID = TranscriptionUnitComponent.CompartmentWID
JOIN DBID TranscriptionUnitDBID ON TranscriptionUnitDBID.OtherWID = TranscriptionUnitComponent.TranscriptionUnitWID

#comments
LEFT JOIN CommentTable GeneCommentTable ON GeneCommentTable.OtherWID = Gene.WID
LEFT JOIN CommentTable TUCommentTable ON TUCommentTable.OtherWID = TranscriptionUnitComponent.TranscriptionUnitWID

WHERE Gene.DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || Gene.WID=_WID)
GROUP BY Gene.WID
ORDER BY Gene.CodingRegionStart;

END $$

-- ---------------------------------------------------------
-- transcription units
-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS `set_transcriptionunit` $$
CREATE PROCEDURE `set_transcriptionunit` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _Name varchar(255),IN _Genes text,
  IN _Promoter35Coordinate int, IN _Promoter35Length int, IN _Promoter10Coordinate int, IN _Promoter10Length int, IN _TSSCoordinate int,
  IN _Compartment varchar(255))
BEGIN

DECLARE _TranscriptionUnitWID bigint;
DECLARE _GeneWID bigint;
DECLARE _GeneXID varchar(255);
DECLARE _nGenes smallint;
DECLARE _idx smallint default 1;
DECLARE _SynthesisRateTemp float;
DECLARE _SynthesisRate float default 0;
DECLARE _NSynthesisRates smallint default 0;
DECLARE _CompartmentWID bigint;
DECLARE _GeneCompartmentWID bigint;
DECLARE _Coefficient smallint;
DECLARE _FeatureWID bigint;
DECLARE _NucleicAcidWID bigint;

SELECT WID INTO _CompartmentWID
FROM Compartment
JOIN DBID ON DBID.OtherWID=Compartment.WID
WHERE Compartment.DataSetWID=_KnowledgeBaseWID && DBID.XID=_Compartment;

#entry
SELECT WID INTO _TranscriptionUnitWID FROM TranscriptionUnit WHERE WID=_WID;
IF _TranscriptionUnitWID IS NULL THEN
	INSERT INTO TranscriptionUnit(WID,Name,CompartmentWID,DataSetWID) VALUES(_WID,_Name,_CompartmentWID,_KnowledgeBaseWID);
ELSE
	UPDATE TranscriptionUnit 
	SET Name=_Name, CompartmentWID=_CompartmentWID
	WHERE WID=_WID;
END IF;

#genes
DELETE FROM TranscriptionUnitComponent WHERE TranscriptionUnitWID=_WID && Type='gene';

SET _nGenes=(LENGTH(_Genes)-LENGTH(REPLACE(_Genes, ';', ''))+1);
WHILE _idx<=_nGenes DO
  CALL parseStoichiometry(_KnowledgeBaseWID,_Genes,';',NULL,NULL,_idx,_GeneWID,_GeneCompartmentWID,_Coefficient);

  INSERT INTO TranscriptionUnitComponent(Type,TranscriptionUnitWID,OtherWID,CompartmentWID) VALUES('gene',_WID,_GeneWID,_GeneCompartmentWID);
  SELECT LN(2)/Gene.HalfLifeExp*Gene.Expression INTO _SynthesisRateTemp FROM Gene WHERE WID=_GeneWID && HalfLifeExp IS NOT NULL && Expression IS NOT NULL;
  IF _SynthesisRateTemp IS NOT NULL THEN
    SET _SynthesisRate=_SynthesisRate+_SynthesisRateTemp;
    SET _NSynthesisRates=_NSynthesisRates+1;
  END IF;

  SET _idx=_idx+1;
END WHILE;

#promoter, TSS
DELETE TranscriptionUnitComponent, Feature
FROM TranscriptionUnitComponent
JOIN Feature ON TranscriptionUnitComponent.OtherWID=Feature.WID
WHERE TranscriptionUnitComponent.TranscriptionUnitWID=_WID && TranscriptionUnitComponent.Type='promoter';

SELECT WID INTO _NucleicAcidWID FROM NucleicAcid WHERE DataSetWID=_KnowledgeBaseWID;

IF _Promoter35Coordinate IS NOT NULL THEN
	SET _FeatureWID=NULL;
	CALL set_entry('F',_KnowledgeBaseWID,_FeatureWID,NULL);
	INSERT INTO Feature(WID,Type,Class,SequenceType,RegionOrPoint,StartPosition,EndPosition,DataSetWID) VALUES(_FeatureWID,'-35 promoter box','promoter','N','region',_Promoter35Coordinate,_Promoter35Length,_KnowledgeBaseWID);
	INSERT INTO TranscriptionUnitComponent(Type,TranscriptionUnitWID,OtherWID) VALUES('promoter',_WID,_FeatureWID);
END IF;

IF _Promoter10Coordinate IS NOT NULL THEN
	SET _FeatureWID=NULL;
	CALL set_entry('F',_KnowledgeBaseWID,_FeatureWID,NULL);
	INSERT INTO Feature(WID,Type,Class,SequenceType,RegionOrPoint,StartPosition,EndPosition,DataSetWID) VALUES(_FeatureWID,'-10 promoter box','promoter','N','region',_Promoter10Coordinate,_Promoter10Length,_KnowledgeBaseWID);
	INSERT INTO TranscriptionUnitComponent(Type,TranscriptionUnitWID,OtherWID) VALUES('promoter',_WID,_FeatureWID);
END IF;

IF _TSSCoordinate IS NOT NULL THEN
	SET _FeatureWID=NULL;
	CALL set_entry('F',_KnowledgeBaseWID,_FeatureWID,NULL);
	INSERT INTO Feature(WID,Type,Class,SequenceType,RegionOrPoint,StartPosition,EndPosition,DataSetWID) VALUES(_FeatureWID,'transcription start site','promoter','N','point',_TSSCoordinate,1,_KnowledgeBaseWID);
	INSERT INTO TranscriptionUnitComponent(Type,TranscriptionUnitWID,OtherWID) VALUES('promoter',_WID,_FeatureWID);
END IF;

#synthesis rate
IF _NSynthesisRates>0 THEN
  SET _SynthesisRate=_SynthesisRate/_NSynthesisRates;
ELSE
  SELECT AVG(LN(2)/Gene.HalfLifeExp*Gene.Expression) INTO _SynthesisRate FROM Gene WHERE DataSetWID=_KnowledgeBaseWID && HalfLifeExp IS NOT NULL && Expression IS NOT NULL;
END IF;

UPDATE Gene,TranscriptionUnitComponent
SET
  HalfLifeCalc=LN(2)/_SynthesisRate*Expression
WHERE
  Gene.DataSetWID=_KnowledgeBaseWID &&
  Gene.WID=TranscriptionUnitComponent.OtherWID &&
  TranscriptionUnitComponent.TranscriptionUnitWID=_WID;

CALL set_textsearch(_WID, _Name, 'name');
CALL set_textsearch(_WID, _Genes, 'genes');

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_transcriptionunit` $$
CREATE PROCEDURE `delete_transcriptionunit` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

DECLARE _ForeignWID bigint;
DECLARE done INT DEFAULT 0;
DECLARE cur1 CURSOR FOR SELECT WID FROM Gene JOIN TranscriptionUnitComponent ON OtherWID=WID WHERE TranscriptionUnitWID=_WID;
DECLARE cur2 CURSOR FOR 
	SELECT Interaction.WID 
	FROM Interaction
	JOIN InteractionParticipant ON Interaction.WID=InteractionParticipant.InteractionWID 
	WHERE 
		Interaction.Type='transcriptional regulation' &&
		InteractionParticipant.OtherWID=_WID && 
		InteractionParticipant.Role='transcription unit';
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

#Transcription Unit
DELETE FROM TranscriptionUnit WHERE WID=_WID;

SET done=0;
OPEN cur1;
REPEAT
    FETCH cur1 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_gene(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur1;

SET done=0;
OPEN cur2;
REPEAT
    FETCH cur2 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_transcriptionalregulation(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur2;

#transcription unit->gene
DELETE FROM TranscriptionUnitComponent WHERE TranscriptionUnitWID=_WID;

#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `get_transcriptionunits` $$
CREATE PROCEDURE `get_transcriptionunits` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

DECLARE _TotalSynthesisRate float;
DECLARE _GenomeSequence longtext;
SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  SUM(TranscriptionUnit.SynthesisRate) INTO _TotalSynthesisRate FROM (
  SELECT AVG(LN(2)/Gene.HalfLifeCalc*Gene.Expression) SynthesisRate
  FROM TranscriptionUnitComponent
  JOIN Gene ON Gene.WID=TranscriptionUnitComponent.OtherWID
  WHERE Gene.DataSetWID=_KnowledgeBaseWID
  GROUP BY TranscriptionUnitComponent.TranscriptionUnitWID
) AS TranscriptionUnit;

SELECT Sequence INTO _GenomeSequence
FROM NucleicAcid
WHERE NucleicAcid.DataSetWID=_KnowledgeBaseWID && Class='Chromosome';

SELECT
  @Idx:=@Idx+1 AS Idx,
  TranscriptionUnit.WID, DBID.XID WholeCellModelID,TranscriptionUnit.Name,

  Gene.Type,
  GROUP_CONCAT(
      DISTINCT composeStoichiometry(GeneDBID.XID, GeneCompartmentDBID.XID, 1)
      ORDER BY Gene.CodingRegionStart
      SEPARATOR ';') Genes,
  MIN(Gene.CodingRegionStart) Coordinate,
  MAX(Gene.CodingRegionEnd)-MIN(Gene.CodingRegionStart) Length,
  Gene.Direction,

  CAST(GROUP_CONCAT(DISTINCT IF(Feature.Type='-35 promoter box',Feature.StartPosition,NULL)) AS SIGNED) Promoter35Coordinate,
  CAST(GROUP_CONCAT(DISTINCT IF(Feature.Type='-35 promoter box',Feature.EndPosition,  NULL)) AS SIGNED) Promoter35Length,
  CAST(GROUP_CONCAT(DISTINCT IF(Feature.Type='-10 promoter box',Feature.StartPosition,NULL)) AS SIGNED) Promoter10Coordinate,
  CAST(GROUP_CONCAT(DISTINCT IF(Feature.Type='-10 promoter box',Feature.EndPosition,  NULL)) AS SIGNED) Promoter10Length,
  CAST(GROUP_CONCAT(DISTINCT IF(Feature.Type='transcription start site',Feature.StartPosition,NULL)) AS SIGNED) TSSCoordinate,

  MID(_GenomeSequence,MIN(Gene.CodingRegionStart),MAX(Gene.CodingRegionEnd)-MIN(Gene.CodingRegionStart)) Sequence,

  AVG(LN(2)/Gene.HalfLifeCalc*Gene.Expression) SynthesisRate,
  AVG(LN(2)/Gene.HalfLifeCalc*Gene.Expression)/_TotalSynthesisRate ProbRNAPolBinding,

  CompartmentDBID.XID Compartment

FROM TranscriptionUnit

JOIN DBID ON TranscriptionUnit.WID=DBID.OtherWID

#genes
LEFT JOIN TranscriptionUnitComponent ON TranscriptionUnitComponent.TranscriptionUnitWID=TranscriptionUnit.WID
LEFT JOIN Gene ON TranscriptionUnitComponent.OtherWID=Gene.WID
LEFT JOIN DBID GeneDBID ON GeneDBID.OtherWID=Gene.WID
LEFT JOIN DBID GeneCompartmentDBID ON GeneCompartmentDBID.OtherWID=TranscriptionUnitComponent.CompartmentWID

#promoter
LEFT JOIN TranscriptionUnitComponent Promoter ON Promoter.TranscriptionUnitWID=TranscriptionUnit.WID
LEFT JOIN Feature ON Feature.WID=Promoter.OtherWID

#compartment
JOIN DBID CompartmentDBID ON CompartmentDBID.OtherWID=TranscriptionUnit.CompartmentWID

WHERE
  TranscriptionUnit.DataSetWID=_KnowledgeBaseWID &&
  (_WID IS NULL || TranscriptionUnit.WID=_WID)
GROUP BY TranscriptionUnit.WID
ORDER BY MIN(Gene.CodingRegionStart);

END $$


DROP PROCEDURE IF EXISTS `get_transcriptionunitsequences` $$
CREATE PROCEDURE `get_transcriptionunitsequences` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

DECLARE _GenomeSequence longtext;
SET @Idx:=0;

SELECT Sequence INTO _GenomeSequence
FROM NucleicAcid
WHERE NucleicAcid.DataSetWID=_KnowledgeBaseWID && Class='Chromosome';

SELECT
  @Idx:=@Idx+1 AS Idx,
  TranscriptionUnit.WID, DBID.XID WholeCellModelID,TranscriptionUnit.Name,
  TranscriptionUnitComponent.Genes,TranscriptionUnitComponent.Coordinate,TranscriptionUnitComponent.Length,TranscriptionUnitComponent.Direction,
  MID(_GenomeSequence,TranscriptionUnitComponent.Coordinate,TranscriptionUnitComponent.Length) Sequence

FROM TranscriptionUnit

JOIN DBID ON TranscriptionUnit.WID=DBID.OtherWID

LEFT JOIN (
  SELECT TranscriptionUnitComponent.TranscriptionUnitWID,
    GROUP_CONCAT(DISTINCT DBID.XID ORDER BY Gene.CodingRegionStart SEPARATOR ';') Genes,
    MIN(Gene.CodingRegionStart) Coordinate,MAX(Gene.CodingRegionEnd)-MIN(Gene.CodingRegionStart) Length, Gene.Direction
  FROM TranscriptionUnitComponent
  JOIN Gene ON Gene.WID=TranscriptionUnitComponent.OtherWID
  JOIN DBID ON Gene.WID=DBID.OtherWID
  WHERE Gene.DataSetWID=_KnowledgeBaseWID
  GROUP BY TranscriptionUnitComponent.TranscriptionUnitWID
) AS TranscriptionUnitComponent ON TranscriptionUnitComponent.TranscriptionUnitWID=TranscriptionUnit.WID

WHERE TranscriptionUnit.DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || TranscriptionUnit.WID=_WID);

END $$


DROP PROCEDURE IF EXISTS `get_genes_transcriptionunits` $$
CREATE PROCEDURE `get_genes_transcriptionunits` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @geneIdx:=0;
SET @transcriptionUnitIdx:=0;
SET @compartmentIdx:=0;

SELECT
  Gene.Idx GeneIdx,
  Gene.WID GeneWID,
  Gene.XID Gene,
  TranscriptionUnit.Idx TranscriptionUnitIdx,
  TranscriptionUnit.WID TranscriptionUnitWID,
  TranscriptionUnit.XID TranscriptionUnit,
  Compartment.Idx GeneCompartmentIdx,
  Compartment.WID CompartmentWID,
  Compartment.XID Compartment
FROM

(SELECT @geneIdx:=@geneIdx+1 AS Idx,Gene.WID, DBID.XID
 FROM Gene
 JOIN DBID ON DBID.OtherWID=Gene.WID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS Gene

JOIN TranscriptionUnitComponent ON Gene.WID=TranscriptionUnitComponent.OtherWID

JOIN
(SELECT @transcriptionUnitIdx:=@transcriptionUnitIdx+1 AS Idx,TranscriptionUnitComponent.TranscriptionUnitWID WID, DBID.XID
  FROM TranscriptionUnitComponent
  JOIN Gene ON Gene.WID=TranscriptionUnitComponent.OtherWID
  JOIN DBID ON DBID.OtherWID=TranscriptionUnitComponent.TranscriptionUnitWID
  WHERE Gene.DataSetWID=_KnowledgeBaseWID
  GROUP BY TranscriptionUnitComponent.TranscriptionUnitWID
  ORDER BY MIN(Gene.CodingRegionStart)
) AS TranscriptionUnit
ON TranscriptionUnitComponent.TranscriptionUnitWID=TranscriptionUnit.WID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON Compartment.WID=TranscriptionUnitComponent.CompartmentWID

WHERE _WID IS NULL || (Gene.WID=_WID || TranscriptionUnit.WID=_WID || Compartment.WID=_WID)
GROUP BY Gene.Idx,TranscriptionUnit.Idx,Compartment.Idx
ORDER BY Gene.Idx,TranscriptionUnit.Idx,Compartment.Idx;

END $$

-- ---------------------------------------------------------
-- DNA Features (other than genes and transcription units)
-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS `set_genomefeature` $$
CREATE PROCEDURE `set_genomefeature` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
IN _Name varchar(255),IN _Type varchar(50),IN _Subtype varchar(50),
IN _Coordinate bigint,IN _Length bigint,IN _Direction varchar(25))
BEGIN

DECLARE _GenomeFeatureWID bigint;
DECLARE _NucleicAcidWID bigint;

SELECT WID INTO _NucleicAcidWID FROM NucleicAcid WHERE DataSetWID=_KnowledgeBaseWID;

SELECT WID INTO _GenomeFeatureWID FROM Feature WHERE WID=_WID;
IF _GenomeFeatureWID IS NULL THEN
	INSERT INTO Feature(WID,Description,Type,Class,SequenceType,SequenceWID,StartPosition,EndPosition,Direction,DataSetWID)
	VALUES(_WID,_Name,_Type,_Subtype,'N',_NucleicAcidWID,_Coordinate,_Coordinate+_Length-1,_Direction,_KnowledgeBaseWID);
ELSE
	UPDATE Feature
	SET
		Description=_Name,
		Type=_Type,
		Class=_Subtype,
		SequenceType='N',
		SequenceWID=_NucleicAcidWID,
		StartPosition=_Coordinate,
		EndPosition=_Coordinate+_Length-1,
		Direction=_Direction
	WHERE WID=_WID;
END IF;

CALL set_textsearch(_WID, _Name, 'name');
CALL set_textsearch(_WID, _Type, 'type');
CALL set_textsearch(_WID, _Subtype, 'subtype');

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_genomefeature` $$
CREATE PROCEDURE `delete_genomefeature` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `get_genomefeatures` $$
CREATE PROCEDURE `get_genomefeatures` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Feature.WID, DBID.XID WholeCellModelID,
  Feature.Description Name, Feature.Type, Feature.Class Subtype,
  Feature.StartPosition Coordinate, Feature.EndPosition-Feature.StartPosition+1 Length, Feature.Direction,
  dnaSequenceReverseComplement(MID(NucleicAcid.Sequence, Feature.StartPosition, Feature.EndPosition-Feature.StartPosition+1),Feature.Direction) Sequence,
  GROUP_CONCAT(DISTINCT Gene.XID ORDER BY Gene.CodingRegionStart SEPARATOR ';') Genes,
  GROUP_CONCAT(DISTINCT TranscriptionUnit.XID ORDER BY TranscriptionUnit.CodingRegionStart SEPARATOR ';') TranscriptionUnits

FROM Feature

JOIN DBID ON Feature.WID=DBID.OtherWID

JOIN NucleicAcid ON Feature.SequenceWID=NucleicAcid.WID

LEFT JOIN (
    SELECT Gene.WID, DBID.XID, Gene.CodingRegionStart, Gene.CodingRegionEnd
    FROM Gene
    JOIN DBID ON DBID.OtherWID=Gene.WID
    WHERE DataSetWID=_KnowledgeBaseWID
  ) AS Gene ON
  (Feature.StartPosition > Gene.CodingRegionStart && Feature.StartPosition < Gene.CodingRegionEnd) ||
  (Feature.EndPosition > Gene.CodingRegionStart && Feature.EndPosition < Gene.CodingRegionEnd) ||
  (Feature.StartPosition < Gene.CodingRegionStart && Feature.EndPosition > Gene.CodingRegionEnd)

LEFT JOIN (
  SELECT
    TranscriptionUnitComponent.TranscriptionUnitWID WID,
    DBID.XID,
    MIN(Gene.CodingRegionStart) CodingRegionStart,
    Max(Gene.CodingRegionEnd) CodingRegionEnd
  FROM Gene
  JOIN TranscriptionUnitComponent ON Gene.WID=TranscriptionUnitComponent.OtherWID
  JOIN DBID ON DBID.OtherWID=TranscriptionUnitComponent.TranscriptionUnitWID
  WHERE Gene.DataSetWID=_KnowledgeBaseWID
  GROUP BY TranscriptionUnitComponent.TranscriptionUnitWID
) AS TranscriptionUnit ON
  (Feature.StartPosition > TranscriptionUnit.CodingRegionStart && Feature.StartPosition < TranscriptionUnit.CodingRegionEnd) ||
  (Feature.EndPosition > TranscriptionUnit.CodingRegionStart && Feature.EndPosition < TranscriptionUnit.CodingRegionEnd) ||
  (Feature.StartPosition < TranscriptionUnit.CodingRegionStart && Feature.EndPosition > TranscriptionUnit.CodingRegionEnd)

WHERE Feature.DataSetWID=_KnowledgeBaseWID && Feature.SequenceType='N' && (_WID IS NULL || Feature.WID=_WID)
GROUP BY Feature.WID
ORDER BY Feature.StartPosition;

END $$


-- ---------------------------------------------------------
-- protein monomers
-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS `set_proteinmonomer` $$
CREATE PROCEDURE `set_proteinmonomer` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _GeneXID varchar(150),
  IN _MolecularWeightCalc float, IN _Atoms smallint, IN _Formula varchar(255),
  IN _PICalc float, IN _HalfLifeCalc varchar(255), IN _Instability float, IN _Stability varchar(255), IN _Aliphatic float, IN _GRAVY float, IN _ExtinctionCoefficient float, IN _Absorption float,
  IN _Topology tinytext, IN _ActiveSite varchar(255), IN _MetalBindingSite varchar(255), 
  IN _DNAFootprint int, IN _DNAFootprintBindingStrandedness ENUM('ssDNA','dsDNA'), IN _DNAFootprintRegionStrandedness ENUM('ssDNA','dsDNA','Either'),
  IN _MolecularInteraction tinytext,IN _ChemicalRegulation tinytext,
  IN _Subsystem tinytext,IN _GeneralClassification tinytext,IN _ProteaseClassification tinytext,IN _TransporterClassification tinytext,
  IN _Compartment varchar(255),
  IN _NTerminalMethionineCleavage char(1), IN _SignalSequenceType varchar(50), IN _SignalSequenceLocation char(1), IN _SignalSequenceLength bigint,
  IN _ProstheticGroups text,IN _Chaperones text)
BEGIN

DECLARE _ProteinWID bigint;
DECLARE _GeneWID bigint;
DECLARE _GeneName varchar(255);
DECLARE _CompartmentWID bigint;
DECLARE _ProstheticGroupXID varchar(255);
DECLARE _ProstheticGroupCoefficient smallint;
DECLARE _ProstheticGroupWID bigint;
DECLARE _FeatureWID bigint;
DECLARE _InteractionWID bigint;
DECLARE _maxIdx smallint;
DECLARE _idx smallint default 1;
DECLARE _GeneCompartmentWID bigint;
DECLARE _Coefficient smallint;
DECLARE _ChaperoneWID bigint;
DECLARE _ChaperoneCompartmentWID bigint;

CALL parseStoichiometry(_KnowledgeBaseWID,_GeneXID,';',NULL,NULL,1,_GeneWID,_GeneCompartmentWID,_Coefficient);
SELECT Gene.Name INTO _GeneName FROM Gene WHERE Gene.WID=_GeneWID;
SELECT WID INTO _CompartmentWID FROM Compartment JOIN DBID ON DBID.OtherWID=Compartment.WID && Compartment.DataSetWID=_KnowledgeBaseWID && DBID.XID=_Compartment;

#new protein
SELECT WID INTO _ProteinWID FROM Protein WHERE WID=_WID;
IF _ProteinWID IS NULL THEN
	INSERT INTO Protein(WID, Name, 
	  MolecularWeightCalc, Atoms, Formula, PICalc, HalfLifeCalc, 
	  Instability, Stability, Aliphatic, GRAVY, ExtinctionCoefficient, Absorption,
	  Topology,ActiveSite, MetalBindingSite, 
	  DNAFootprint, DNAFootprintBindingStrandedness, DNAFootprintRegionStrandedness, 
	  CompartmentWID, 
	  MolecularInteraction, ChemicalRegulation, Subsystem, GeneralClassification, ProteaseClassification, TransporterClassification, 
	  DataSetWID)
	VALUES (_WID, _GeneName, 
	_MolecularWeightCalc, _Atoms, _Formula, _PICalc, 
	IF(_HalfLifeCalc='>10 hours', 'S', 'U'), _Instability, IF(_Stability='stable', 'S', 'U'), _Aliphatic, _GRAVY, _ExtinctionCoefficient, _Absorption, 
	_Topology, _ActiveSite, _MetalBindingSite,  
	_DNAFootprint,  _DNAFootprintBindingStrandedness,  _DNAFootprintRegionStrandedness,
	_CompartmentWID, _MolecularInteraction, _ChemicalRegulation, _Subsystem, _GeneralClassification, _ProteaseClassification, _TransporterClassification, 
	_KnowledgeBaseWID);
ELSE
	UPDATE Protein
	SET
		Name=_GeneName,
		MolecularWeightCalc=_MolecularWeightCalc,
		Atoms=_Atoms,
		Formula=_Formula,
		PICalc=_PICalc,
		HalfLifeCalc=IF(_HalfLifeCalc='>10 hours','S','U'),
		Instability=_Instability,
		Stability=IF(_Stability='stable','S','U'),
		Aliphatic=_Aliphatic,
		GRAVY=_GRAVY,
		ExtinctionCoefficient=_ExtinctionCoefficient,
		Absorption=_Absorption,
		Topology=_Topology,
		ActiveSite=_ActiveSite,
		MetalBindingSite=_MetalBindingSite,
		DNAFootprint = _DNAFootprint,
		DNAFootprintBindingStrandedness = _DNAFootprintBindingStrandedness,
		DNAFootprintRegionStrandedness = _DNAFootprintRegionStrandedness,
		CompartmentWID=_CompartmentWID,
		MolecularInteraction=_MolecularInteraction,
		ChemicalRegulation=_ChemicalRegulation,
		Subsystem=_Subsystem,
		GeneralClassification=_GeneralClassification,
		ProteaseClassification=_ProteaseClassification,
		TransporterClassification=_TransporterClassification
	WHERE WID=_WID;
END IF;

#connection to gene
DELETE FROM GeneWIDProteinWID WHERE ProteinWID=_WID;
INSERT INTO GeneWIDProteinWID(GeneWID,ProteinWID,CompartmentWID) VALUES(_GeneWID,_WID,_GeneCompartmentWID);

#N Terminal Methionine Cleavage
DELETE FROM Feature WHERE SequenceWID=_WID;
IF _NTerminalMethionineCleavage='Y' THEN
	SET _FeatureWID=NULL;
	CALL set_entry('F',_KnowledgeBaseWID,_FeatureWID,NULL);
	INSERT INTO Feature(WID,Type,SequenceType,SequenceWID,StartPosition,EndPosition,DataSetWID)
	VALUES(_FeatureWID,'n terminal methionine cleavage','P',_WID,1,1,_KnowledgeBaseWID);
END IF;

#signal sequence
IF _SignalSequenceType IS NOT NULL && _SignalSequenceType!='' THEN
	SET _FeatureWID=NULL;
	CALL set_entry('F',_KnowledgeBaseWID,_FeatureWID,NULL);
	INSERT INTO Feature(WID,Type,Class,SequenceType,SequenceWID,StartPosition,EndPosition,DataSetWID)
	VALUES(_FeatureWID,'signal sequence',_SignalSequenceType,'P',_WID,IF(_SignalSequenceLocation='N',1,NULL),_SignalSequenceLength,_KnowledgeBaseWID);
END IF;

#prosthetic groups
DELETE Interaction, Protein, ProstheticGroup
FROM InteractionParticipant Protein
JOIN Interaction ON Interaction.WID=Protein.InteractionWID
JOIN InteractionParticipant ProstheticGroup ON ProstheticGroup.InteractionWID=Interaction.WID
WHERE Protein.OtherWID=_WID && Interaction.Type='prosthetic group';

SET _maxIdx=(LENGTH(_ProstheticGroups)-LENGTH(REPLACE(_ProstheticGroups,';',''))+1);
SET _idx=1;
WHILE _idx<=_maxIdx DO
  CALL parseStoichiometry(_KnowledgeBaseWID, _ProstheticGroups,';',NULL,NULL,_idx,_ProstheticGroupWID,_CompartmentWID,_ProstheticGroupCoefficient);

  SET _InteractionWID=NULL;
  CALL set_entry('F',_KnowledgeBaseWID,_InteractionWID,NULL);
  INSERT INTO Interaction(WID,Type,DataSetWID)
  VALUES(_InteractionWID,'prosthetic group',_KnowledgeBaseWID);

  INSERT INTO InteractionParticipant(InteractionWID,OtherWID,Coefficient) VALUES(_InteractionWID,_WID,1);
  INSERT INTO InteractionParticipant(InteractionWID,OtherWID,CompartmentWID,Coefficient) VALUES(_InteractionWID,_ProstheticGroupWID,_CompartmentWID,_ProstheticGroupCoefficient);

  SET _idx=_idx+1;
END WHILE;

#chaperones
SET _maxIdx=(LENGTH(_Chaperones)-LENGTH(REPLACE(_Chaperones,';',''))+1);
SET _idx=1;
WHILE _idx<=_maxIdx DO
  CALL parseStoichiometry(_KnowledgeBaseWID, _Chaperones,';',NULL,NULL,_idx,_ChaperoneWID,_ChaperoneCompartmentWID,_Coefficient);

  SET _InteractionWID=NULL;
  CALL set_entry('F',_KnowledgeBaseWID,_InteractionWID,NULL);
  INSERT INTO Interaction(WID,Type,DataSetWID)
  VALUES(_InteractionWID,'chaperone',_KnowledgeBaseWID);

  INSERT INTO InteractionParticipant(InteractionWID,OtherWID,CompartmentWID,Coefficient,Role)
  VALUES(_InteractionWID,_ChaperoneWID,_ChaperoneCompartmentWID,_Coefficient,'chaperone');

  INSERT INTO InteractionParticipant(InteractionWID,OtherWID,CompartmentWID,Coefficient,Role)
  VALUES(_InteractionWID,_WID,_CompartmentWID,1,'folding protein');

  SET _idx=_idx+1;
END WHILE;

CALL set_textsearch(_WID, _GeneXID, 'gene');
CALL set_textsearch(_WID, _Topology, 'topology');
CALL set_textsearch(_WID, _ActiveSite, 'active site');
CALL set_textsearch(_WID, _MetalBindingSite, 'metal binding site');
CALL set_textsearch(_WID, _MolecularInteraction, 'molecular interaction');
CALL set_textsearch(_WID, _ChemicalRegulation, 'chemical regulation');
CALL set_textsearch(_WID, _Subsystem, 'subsystem');
CALL set_textsearch(_WID, _GeneralClassification, 'general classification');
CALL set_textsearch(_WID, _ProteaseClassification, 'protease classification');
CALL set_textsearch(_WID, _TransporterClassification, 'transporter classification');
CALL set_textsearch(_WID, _Compartment, 'compartment');
CALL set_textsearch(_WID, _ProstheticGroups, 'prosthetic groups');

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `set_proteinmonomer_sequence` $$
CREATE PROCEDURE `set_proteinmonomer_sequence` (IN _KnowledgeBaseWID bigint,
  IN _WholeCellModelID varchar(255), IN _AASequence text)
BEGIN

UPDATE Protein,DBID
SET
  AASequence=_AASequence,
  Length=LENGTH(_AASequence),
  NegAA=2*LENGTH(_AASequence)-LENGTH(REPLACE(_AASequence,"D",""))-LENGTH(REPLACE(_AASequence,"E","")),
  PosAA=3*LENGTH(_AASequence)-LENGTH(REPLACE(_AASequence,"R",""))-LENGTH(REPLACE(_AASequence,"H",""))-LENGTH(REPLACE(_AASequence,"K",""))
WHERE
  Protein.WID=DBID.OtherWID &&
  DBID.XID=_WholeCellModelID &&
  Protein.DataSetWID=_KnowledgeBaseWID;

SELECT WID FROM Protein JOIN DBID ON DBID.OtherWID=Protein.WID WHERE DBID.XID=_WholeCellModelID && Protein.DataSetWID=_KnowledgeBaseWID;

END $$

DROP PROCEDURE IF EXISTS `delete_proteinmonomer` $$
CREATE PROCEDURE `delete_proteinmonomer` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

DECLARE _ForeignWID bigint;
DECLARE done INT DEFAULT 0;
DECLARE cur1 CURSOR FOR SELECT WID FROM Gene JOIN GeneWIDProteinWID ON WID=GeneWID WHERE ProteinWID=_WID;
DECLARE cur3 CURSOR FOR SELECT WID FROM Reaction JOIN ModificationReaction ON ReactionWID=WID WHERE OtherWID=_WID;
DECLARE cur4 CURSOR FOR 
	SELECT Interaction.WID
	FROM Interaction
	JOIN InteractionParticipant ON Interaction.WID=InteractionParticipant.InteractionWID
	WHERE 
		Interaction.Type='transcriptional regulation' &&
		InteractionParticipant.Role='transcription factor' &&
		InteractionParticipant.OtherWID=_WID;
DECLARE cur5 CURSOR FOR 
	SELECT Interaction.WID
	FROM Interaction
	JOIN InteractionParticipant ON Interaction.WID=InteractionParticipant.InteractionWID
	WHERE 
		Interaction.Type='activation' &&
		InteractionParticipant.Role='protein' &&
		InteractionParticipant.OtherWID=_WID;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

#protein monomer
DELETE Protein, Subunit, EnzymaticReaction, EnzReactionCofactor, ModificationReaction, Reactant, Product
FROM Protein
LEFT JOIN Subunit ON Subunit.SubunitWID=Protein.WID
LEFT JOIN EnzymaticReaction ON EnzymaticReaction.ProteinWID=Protein.WID
LEFT JOIN EnzReactionCofactor ON EnzymaticReaction.ReactionWID=EnzReactionCofactor.EnzymaticReactionWID
LEFT JOIN ModificationReaction ON ModificationReaction.OtherWID=Protein.WID
LEFT JOIN Reactant ON Reactant.OtherWID=Protein.WID
LEFT JOIN Product ON Product.OtherWID=Protein.WID
WHERE Protein.WID=_WID;

SET done=0;
OPEN cur1;
REPEAT
    FETCH cur1 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_gene(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur1;

SET done=0;
OPEN cur3;
REPEAT
    FETCH cur3 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_reaction(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur3;

SET done=0;
OPEN cur4;
REPEAT
    FETCH cur4 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_transcriptionalregulation(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur4;

SET done=0;
OPEN cur5;
REPEAT
    FETCH cur5 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_proteinactivation(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur5;

#links
DELETE FROM GeneWIDProteinWID WHERE ProteinWID=_WID;
DELETE FROM ModificationReaction WHERE OtherWID=_WID;
DELETE FROM Reactant WHERE OtherWID=_WID;
DELETE FROM Product WHERE OtherWID=_WID;

#entry
CALL delete_entry(_WID);

END $$


DROP PROCEDURE IF EXISTS `get_proteinmonomers` $$
CREATE PROCEDURE `get_proteinmonomers` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Protein.WID, DBID.XID WholeCellModelID, composeStoichiometry(GeneDBID.XID,GeneCompartmentDBID.XID,1) Gene, Gene.Symbol, Gene.Name,
  Protein.Length, Protein.NegAA, Protein.PosAA, Protein.AASequence Sequence,
  Protein.MolecularWeightCalc,Protein.Atoms,Protein.Formula,LEFT(Protein.AASequence,1) NTerminalAA,
  Protein.PICalc, IF(Protein.HalfLifeCalc='S','>10 hours','2 min') HalfLifeCalc, Protein.Instability, IF(Protein.Stability='S','stable','unstable') Stability, Protein.Aliphatic, Protein.GRAVY, Protein.ExtinctionCoefficient, Protein.Absorption,
  GROUP_CONCAT(DISTINCT ComplexDBID.XID ORDER BY ComplexDBID.XID SEPARATOR ';') Complex,
  Protein.Topology, Protein.ActiveSite, Protein.MetalBindingSite, Protein.DNAFootprint, Protein.DNAFootprintBindingStrandedness, Protein.DNAFootprintRegionStrandedness,
  Protein.MolecularInteraction,Protein.ChemicalRegulation,Protein.Subsystem,Protein.GeneralClassification,Protein.ProteaseClassification,Protein.TransporterClassification,
  CompartmentDBID.XID Compartment,

  GROUP_CONCAT(DISTINCT IF(Feature.Type='n terminal methionine cleavage','Y','N')) NTerminalMethionineCleavage,
  GROUP_CONCAT(DISTINCT IF(Feature.Type='signal sequence',Feature.Class,NULL)) SignalSequenceType,
  GROUP_CONCAT(DISTINCT IF(Feature.Type='signal sequence',IF(Feature.StartPosition=1,'N','C'),NULL)) SignalSequenceLocation,
  CAST(GROUP_CONCAT(DISTINCT IF(Feature.Type='signal sequence',Feature.EndPosition,NULL)) AS DECIMAL) SignalSequenceLength,

  CONCAT("",GROUP_CONCAT(DISTINCT ProstheticGroup.ProstheticGroups)) ProstheticGroups,
  CONCAT("",GROUP_CONCAT(DISTINCT Chaperone.Chaperones)) Chaperones,
  ActivationInteraction.ActivationRule,
  GROUP_CONCAT(DISTINCT ReactionDBID.XID ORDER BY ReactionDBID.XID SEPARATOR ';') Reactions,
  GROUP_CONCAT(DISTINCT Reaction.ECNumber ORDER BY Reaction.ECNumber SEPARATOR ';') ECNumbers

FROM Protein
JOIN DBID ON DBID.OtherWID=Protein.WID

#gene
JOIN GeneWIDProteinWID ON GeneWIDProteinWID.ProteinWID=Protein.WID
JOIN Gene ON Gene.WID=GeneWIDProteinWID.GeneWID
JOIN DBID GeneDBID ON GeneDBID.OtherWID=GeneWIDProteinWID.GeneWID
JOIN DBID GeneCompartmentDBID ON GeneCompartmentDBID.OtherWID=GeneWIDProteinWID.CompartmentWID

#complex
LEFT JOIN Subunit ON Subunit.SubunitWID=Protein.WID
LEFT JOIN DBID ComplexDBID ON ComplexDBID.OtherWID=Subunit.ComplexWID

#compartment
LEFT JOIN DBID CompartmentDBID ON CompartmentDBID.OtherWID=Protein.CompartmentWID

#n terminal methionine cleavage, signal sequence
LEFT JOIN Feature ON Feature.SequenceWID=Protein.WID

#prosthetic group
LEFT JOIN (
  SELECT
    Protein.WID ProteinWID,
    GROUP_CONCAT(
      DISTINCT
      composeStoichiometry(ProstheticGroupDBID.XID,CompartmentDBID.XID,InteractionProstheticGroup.Coefficient)
      ORDER BY ProstheticGroupDBID.XID SEPARATOR ';'
    ) ProstheticGroups
  FROM Interaction

  JOIN InteractionParticipant InteractionProtein ON InteractionProtein.InteractionWID=Interaction.WID
  JOIN (SELECT WID FROM Protein WHERE DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || Protein.WID=_WID)) AS Protein ON Protein.WID=InteractionProtein.OtherWID

  JOIN InteractionParticipant InteractionProstheticGroup ON InteractionProstheticGroup.InteractionWID=Interaction.WID
  JOIN (SELECT WID FROM Chemical WHERE DataSetWID=_KnowledgeBaseWID) AS Chemical ON Chemical.WID=InteractionProstheticGroup.OtherWID
  JOIN DBID ProstheticGroupDBID ON ProstheticGroupDBID.OtherWID=Chemical.WID
  JOIN DBID CompartmentDBID ON CompartmentDBID.OtherWID=InteractionProstheticGroup.CompartmentWID

  WHERE
    Interaction.Type='prosthetic group' && 
    Interaction.DataSetWID=_KnowledgeBaseWID &&
	(_WID IS NULL || InteractionProtein.OtherWID=_WID)
  GROUP BY Protein.WID
) AS ProstheticGroup ON Protein.WID=ProstheticGroup.ProteinWID

#chaperone
LEFT JOIN (
  SELECT
    Protein.WID ProteinWID,
    GROUP_CONCAT(
      DISTINCT
        composeStoichiometry(ChaperoneDBID.XID,CompartmentDBID.XID,InteractionChaperone.Coefficient)
        ORDER BY ChaperoneDBID.XID
        SEPARATOR ';') Chaperones
  FROM Interaction

  JOIN InteractionParticipant InteractionProtein ON InteractionProtein.InteractionWID=Interaction.WID
  JOIN (SELECT WID FROM Protein WHERE DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || Protein.WID=_WID)) AS Protein ON Protein.WID=InteractionProtein.OtherWID

  JOIN InteractionParticipant InteractionChaperone ON InteractionChaperone.InteractionWID=Interaction.WID
  JOIN (SELECT WID FROM Protein WHERE DataSetWID=_KnowledgeBaseWID) AS Chaperone ON Chaperone.WID=InteractionChaperone.OtherWID
  JOIN DBID ChaperoneDBID ON ChaperoneDBID.OtherWID=Chaperone.WID
  JOIN DBID CompartmentDBID ON CompartmentDBID.OtherWID=InteractionChaperone.CompartmentWID

  WHERE 
	Interaction.Type='chaperone' && 
	InteractionProtein.Role='folding protein' && 
	InteractionChaperone.Role='chaperone' && 
	Interaction.DataSetWID=_KnowledgeBaseWID &&
	(_WID IS NULL || InteractionProtein.OtherWID=_WID)
  GROUP BY Protein.WID
) AS Chaperone ON Protein.WID=Chaperone.ProteinWID

LEFT JOIN (
  SELECT Interaction.Rule ActivationRule, InteractionParticipant.OtherWID ProteinWID
  FROM Interaction
  JOIN InteractionParticipant ON Interaction.WID=InteractionParticipant.InteractionWID
  WHERE
    Interaction.DataSetWID=_KnowledgeBaseWID &&
	Interaction.Type='activation' &&
	InteractionParticipant.Role='protein' &&
	(_WID IS NULL || InteractionParticipant.OtherWID=_WID)
) ActivationInteraction ON Protein.WID=ActivationInteraction.ProteinWID

#reactions
LEFT JOIN EnzymaticReaction ON EnzymaticReaction.ProteinWID=Protein.WID || EnzymaticReaction.ProteinWID=Subunit.ComplexWID
LEFT JOIN Reaction ON Reaction.WID=EnzymaticReaction.ReactionWID
LEFT JOIN DBID ReactionDBID ON EnzymaticReaction.ReactionWID=ReactionDBID.OtherWID

WHERE
	Protein.DataSetWID=_KnowledgeBaseWID &&
	(_WID IS NULL || Protein.WID=_WID)
GROUP BY Protein.WID
ORDER BY Gene.CodingRegionStart;

END $$

DROP PROCEDURE IF EXISTS `get_proteinmonomersequences` $$
CREATE PROCEDURE `get_proteinmonomersequences` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Protein.WID, DBID.XID WholeCellModelID, GeneDBID.XID Gene, Gene.Name,
  Protein.Length,Protein.NegAA,Protein.PosAA,Protein.MolecularWeightCalc,Protein.Atoms,Protein.Formula,LEFT(Protein.AASequence,1) NTerminalAA,
  Protein.AASequence

FROM Protein
JOIN DBID ON DBID.OtherWID=Protein.WID

#gene
JOIN GeneWIDProteinWID ON GeneWIDProteinWID.ProteinWID=Protein.WID
JOIN Gene ON Gene.WID=GeneWIDProteinWID.GeneWID
JOIN DBID GeneDBID ON GeneDBID.OtherWID=GeneWIDProteinWID.GeneWID

WHERE Protein.DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || Protein.WID=_WID)
GROUP BY Protein.WID
ORDER BY Gene.CodingRegionStart;

END $$

DROP PROCEDURE IF EXISTS `get_genes_proteinmonomers` $$
CREATE PROCEDURE `get_genes_proteinmonomers` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @geneIdx:=0;
SET @proteinMonomerIdx:=0;
SET @compartmentIdx:=0;

SELECT
  Gene.Idx GeneIdx,
  Gene.WID GeneWID,
  Gene.XID Gene,
  ProteinMonomer.Idx ProteinMonomerIdx,
  ProteinMonomer.WID ProteinMonomerWID,
  ProteinMonomer.XID ProteinMonomer,
  Compartment.Idx GeneCompartmentIdx,
  Compartment.WID CompartmentWID,
  Compartment.XID Compartment
FROM

(SELECT @geneIdx:=@geneIdx+1 AS Idx,Gene.WID, DBID.XID
 FROM Gene
 JOIN DBID ON DBID.OtherWID=Gene.WID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS Gene

JOIN GeneWIDProteinWID ON Gene.WID=GeneWIDProteinWID.GeneWID

JOIN
(SELECT @proteinMonomerIdx:=@proteinMonomerIdx+1 AS Idx,GeneWIDProteinWID.ProteinWID WID, DBID.XID
  FROM GeneWIDProteinWID
  JOIN Gene ON GeneWIDProteinWID.GeneWID=Gene.WID
  JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
  WHERE Gene.DataSetWID=_KnowledgeBaseWID
  ORDER BY Gene.CodingRegionStart
) AS ProteinMonomer
ON GeneWIDProteinWID.ProteinWID=ProteinMonomer.WID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON Compartment.WID=GeneWIDProteinWID.CompartmentWID

WHERE _WID IS NULL || (Gene.WID=_WID || ProteinMonomer.WID=_WID || Compartment.WID=_WID)
GROUP BY Gene.Idx,ProteinMonomer.Idx,Compartment.Idx
ORDER BY Gene.Idx,ProteinMonomer.Idx,Compartment.Idx;

END $$


-- ---------------------------------------------------------
-- protein complexes
-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS `set_proteincomplex` $$
CREATE PROCEDURE `set_proteincomplex` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _Name text, IN _Biosynthesis text,
  IN _HalfLifeCalc varchar(255), 
  IN _DNAFootprint int, IN _DNAFootprintBindingStrandedness ENUM('ssDNA','dsDNA'), IN _DNAFootprintRegionStrandedness ENUM('ssDNA','dsDNA','Either'), 
  IN _MolecularInteraction tinytext,IN _ChemicalRegulation tinytext,IN _Subsystem tinytext,
  IN _GeneralClassification tinytext,IN _ProteaseClassification tinytext, IN _TransporterClassification tinytext,
  IN _Compartment varchar(255),
  IN _DisulfideBonds text,
  IN _ProstheticGroups text, IN _Chaperones text, IN _ComplexFormationProcess varchar(255))
BEGIN

DECLARE _ProteinComplexWID bigint;
DECLARE _maxIdx smallint;
DECLARE _idx smallint default 1;
DECLARE _CompartmentWID bigint;
DECLARE _SubunitWID bigint;
DECLARE _SubunitCompartmentWID bigint;
DECLARE _SubunitMW float;
DECLARE _Coefficient float;
DECLARE _ProstheticGroupXID varchar(255);
DECLARE _ProstheticGroupCoefficient smallint;
DECLARE _ProstheticGroupWID bigint;
DECLARE _ProstheticGroupCompartmentWID bigint;
DECLARE _InteractionWID bigint;
DECLARE _ChaperoneWID bigint;
DECLARE _ChaperoneCompartmentWID bigint;
DECLARE _ComplexFormationProcessWID bigint;
DECLARE _Subunits text;
DECLARE _MonomerXID varchar(255);
DECLARE _MonomerWID bigint;
DECLARE _DisulfideBond text;
DECLARE _Sulfur1 bigint;
DECLARE _Sulfur2 bigint;
DECLARE _FeatureWID bigint;

SELECT WID INTO _CompartmentWID
FROM Compartment
JOIN DBID ON DBID.OtherWID=Compartment.WID && Compartment.DataSetWID=_KnowledgeBaseWID && DBID.XID=_Compartment;

SELECT WID INTO _ComplexFormationProcessWID
FROM Process
JOIN DBID ON DBID.OtherWID=Process.WID && Process.DataSetWID=_KnowledgeBaseWID && DBID.XID=_ComplexFormationProcess;

#new complex
SELECT WID INTO _ProteinComplexWID FROM Protein WHERE WID=_WID;
IF _ProteinComplexWID IS NULL THEN
    INSERT INTO Protein(WID, Name, HalfLifeCalc, CompartmentWID, DNAFootprint, DNAFootprintBindingStrandedness, DNAFootprintRegionStrandedness, MolecularInteraction, ChemicalRegulation, Subsystem, GeneralClassification,ProteaseClassification, TransporterClassification, ComplexFormationProcessWID, DataSetWID)
    VALUES(_WID,_Name,IF(_HalfLifeCalc='>10 hours','S','U'),_CompartmentWID,_DNAFootprint, _DNAFootprintBindingStrandedness, _DNAFootprintRegionStrandedness, _MolecularInteraction,_ChemicalRegulation,_Subsystem,_GeneralClassification,_ProteaseClassification,_TransporterClassification,_ComplexFormationProcessWID,_KnowledgeBaseWID);
ELSE
    UPDATE Protein
    SET
        Name=_Name,
        HalfLifeCalc=IF(_HalfLifeCalc='>10 hours','S','U'),
        CompartmentWID=_CompartmentWID,
        DNAFootprint = _DNAFootprint,
        DNAFootprintBindingStrandedness = _DNAFootprintBindingStrandedness,
		DNAFootprintRegionStrandedness = _DNAFootprintRegionStrandedness,
        MolecularInteraction=_MolecularInteraction,
        ChemicalRegulation=_ChemicalRegulation,
        Subsystem=_Subsystem,
        GeneralClassification=_GeneralClassification,
        ProteaseClassification=_ProteaseClassification,
        TransporterClassification=_TransporterClassification,
        ComplexFormationProcessWID=_ComplexFormationProcessWID
    WHERE WID=_WID;
END IF;

#biosynthesis
DELETE FROM Subunit WHERE ComplexWID=_WID;

SET _Subunits=SUBSTRING_INDEX(_Biosynthesis,' ==> ', 1);
SET _maxIdx=((LENGTH(_Subunits)-LENGTH(REPLACE(_Subunits,' + ','')))/3+1);
SET _idx=1;
WHILE _idx<=_maxIdx DO
    CALL parseStoichiometry(_KnowledgeBaseWID,_Biosynthesis,' + ','F',-1,_idx,_SubunitWID,_SubunitCompartmentWID,_Coefficient);

    IF _SubunitWID IS NOT NULL THEN
        INSERT INTO Subunit(ComplexWID,SubunitWID,CompartmentWID, Coefficient)
        VALUES(_WID,_SubunitWID,_SubunitCompartmentWID, _Coefficient);
    END IF;

    SET _idx=_idx+1;
END WHILE;

SET _Subunits =SUBSTRING_INDEX(_Biosynthesis,' ==> ',-1);
SET _maxIdx=((LENGTH(_Subunits)-LENGTH(REPLACE(_Subunits,' + ','')))/3+1);
SET _idx=1;
WHILE _idx<=_maxIdx DO
    CALL parseStoichiometry(_KnowledgeBaseWID,_Biosynthesis,' + ','F',1,_idx,_SubunitWID,_SubunitCompartmentWID,_Coefficient);

    IF _SubunitWID!=_WID && _SubunitWID IS NOT NULL THEN
        INSERT INTO Subunit(ComplexWID,SubunitWID,CompartmentWID, Coefficient)
        VALUES(_WID,_SubunitWID,_SubunitCompartmentWID, -1*_Coefficient);
    END IF;

    SET _idx=_idx+1;
END WHILE;

#disulfide bonds
DELETE FROM Feature 
WHERE SequenceWID=_WID && 
Type='disulfide bond';

SET _maxIdx=(LENGTH(_DisulfideBonds)-LENGTH(REPLACE(_DisulfideBonds,';',''))+1);
SET _idx=1;
WHILE _idx<=_maxIdx DO
  SET _DisulfideBond =  SUBSTRING_INDEX(SUBSTRING_INDEX(_DisulfideBonds,';',_idx),';',-1);
   
  SET _MonomerXID = SUBSTRING_INDEX(_DisulfideBond,': ',1);
  SELECT Entry.OtherWID INTO _MonomerWID 
  FROM Entry
  JOIN DBID ON DBID.OtherWID=Entry.OtherWID
  WHERE Entry.DataSetWID=_KnowledgeBaseWID && DBID.XID=_MonomerXID;
  
  SET _Sulfur1 = substr(SUBSTRING_INDEX(SUBSTRING_INDEX(_DisulfideBond,': ',-1),'-', 1),2);  
  SET _Sulfur2 = substr(SUBSTRING_INDEX(SUBSTRING_INDEX(_DisulfideBond,': ',-1),'-',-1),2);

  SET _FeatureWID=NULL;
  CALL set_entry('F',_KnowledgeBaseWID,_FeatureWID,NULL);
  INSERT INTO Feature(WID,Type,SequenceType,SequenceWID,SubSequenceWID,StartPosition,EndPosition,DataSetWID)
  VALUES(_FeatureWID,'disulfide bond','P',_WID,_MonomerWID, _Sulfur1,_Sulfur2,_KnowledgeBaseWID);

  SET _idx=_idx+1;
END WHILE;

#prosthetic groups
DELETE Interaction, Protein, ProstheticGroup
FROM InteractionParticipant Protein
JOIN Interaction ON Interaction.WID=Protein.InteractionWID
JOIN InteractionParticipant ProstheticGroup ON ProstheticGroup.InteractionWID=Interaction.WID
WHERE Protein.OtherWID=_WID && Interaction.Type='prosthetic group';

SET _maxIdx=(LENGTH(_ProstheticGroups)-LENGTH(REPLACE(_ProstheticGroups,';',''))+1);
SET _idx=1;
WHILE _idx<=_maxIdx DO
  CALL parseStoichiometry(_KnowledgeBaseWID, _ProstheticGroups,';',NULL,NULL,_idx,_ProstheticGroupWID,_ProstheticGroupCompartmentWID,_ProstheticGroupCoefficient);

  SET _InteractionWID=NULL;
  CALL set_entry('F',_KnowledgeBaseWID,_InteractionWID,NULL);
  INSERT INTO Interaction(WID,Type,DataSetWID)
  VALUES(_InteractionWID,'prosthetic group',_KnowledgeBaseWID);

  INSERT INTO InteractionParticipant(InteractionWID,OtherWID,Coefficient) VALUES(_InteractionWID,_WID,1);
  INSERT INTO InteractionParticipant(InteractionWID,OtherWID,CompartmentWID,Coefficient) VALUES(_InteractionWID,_ProstheticGroupWID,_ProstheticGroupCompartmentWID,_ProstheticGroupCoefficient);

  SET _idx=_idx+1;
END WHILE;

#chaperones
SET _maxIdx=(LENGTH(_Chaperones)-LENGTH(REPLACE(_Chaperones,';',''))+1);
SET _idx=1;
WHILE _idx<=_maxIdx DO
  CALL parseStoichiometry(_KnowledgeBaseWID, _Chaperones,';',NULL,NULL,_idx,_ChaperoneWID,_ChaperoneCompartmentWID,_Coefficient);

  SET _InteractionWID=NULL;
  CALL set_entry('F',_KnowledgeBaseWID,_InteractionWID,NULL);
  INSERT INTO Interaction(WID,Type,DataSetWID)
  VALUES(_InteractionWID,'chaperone',_KnowledgeBaseWID);

  INSERT INTO InteractionParticipant(InteractionWID,OtherWID,CompartmentWID,Coefficient,Role)
  VALUES(_InteractionWID,_ChaperoneWID,_ChaperoneCompartmentWID,_Coefficient,'chaperone');

  INSERT INTO InteractionParticipant(InteractionWID,OtherWID,CompartmentWID,Coefficient,Role)
  VALUES(_InteractionWID,_WID,_CompartmentWID,1,'folding protein');

  SET _idx=_idx+1;
END WHILE;

CALL set_textsearch(_WID, _Name, 'name');
CALL set_textsearch(_WID, _MolecularInteraction, 'molecular interaction');
CALL set_textsearch(_WID, _ChemicalRegulation, 'chemical regulation');
CALL set_textsearch(_WID, _Subsystem, 'subsystem');
CALL set_textsearch(_WID, _GeneralClassification, 'general classification');
CALL set_textsearch(_WID, _ProteaseClassification, 'protease classification');
CALL set_textsearch(_WID, _TransporterClassification, 'transporter classification');
CALL set_textsearch(_WID, _Compartment, 'compartment');
CALL set_textsearch(_WID, _ProstheticGroups, 'prosthetic groups');

SELECT _WID WID;

END $$


DROP PROCEDURE IF EXISTS `delete_proteincomplex` $$
CREATE PROCEDURE `delete_proteincomplex` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

DECLARE _ForeignWID bigint;
DECLARE done INT DEFAULT 0;
DECLARE cur1 CURSOR FOR SELECT WID FROM Reaction JOIN ModificationReaction ON ReactionWID=WID WHERE OtherWID=_WID;
DECLARE cur2 CURSOR FOR
	SELECT Interaction.WID
	FROM Interaction
	JOIN InteractionParticipant ON Interaction.WID=InteractionParticipant.InteractionWID
	WHERE 
		Interaction.Type='transcriptional regulation' &&
		InteractionParticipant.Role='transcription factor' &&
		InteractionParticipant.OtherWID=_WID;
DECLARE cur3 CURSOR FOR 
	SELECT Interaction.WID
	FROM Interaction
	JOIN InteractionParticipant ON Interaction.WID=InteractionParticipant.InteractionWID
	WHERE 
		Interaction.Type='activation' &&
		InteractionParticipant.Role='protein' &&
		InteractionParticipant.OtherWID=_WID;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

#protein complex
DELETE Protein, Subunit, EnzymaticReaction, EnzReactionCofactor, ModificationReaction, Reactant, Product
FROM Protein
JOIN Subunit ON Subunit.ComplexWID=Protein.WID
LEFT JOIN EnzymaticReaction ON EnzymaticReaction.ProteinWID=Protein.WID
LEFT JOIN EnzReactionCofactor ON EnzymaticReaction.ReactionWID=EnzReactionCofactor.EnzymaticReactionWID
LEFT JOIN ModificationReaction ON ModificationReaction.OtherWID=Protein.WID
LEFT JOIN Reactant ON Reactant.OtherWID=Protein.WID
LEFT JOIN Product ON Product.OtherWID=Protein.WID
WHERE Protein.WID=_WID; 

SET done=0;
OPEN cur1;
REPEAT
    FETCH cur1 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_reaction(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur1;

SET done=0;
OPEN cur2;
REPEAT
    FETCH cur2 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_transcriptionalregulation(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur2;

SET done=0;
OPEN cur3;
REPEAT
    FETCH cur3 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_proteinactivation(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur3;


#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `get_proteincomplexs` $$
CREATE PROCEDURE `get_proteincomplexs` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Protein.WID, DBID.XID WholeCellModelID, Protein.Name,
  
  IF(!(COUNT(DISTINCT Reactant.CompartmentWID)>1 ||
    COUNT(DISTINCT Product.CompartmentWID)>1 ||
    (Reactant.CompartmentWID IS NULL && Product.CompartmentWID IS NULL) ||
    (Reactant.CompartmentWID IS NOT NULL && Product.CompartmentWID IS NOT NULL && Reactant.CompartmentWID!=Product.CompartmentWID)),
		CONCAT(
			'[', IF(ReactantCompartmentDBID.XID IS NOT NULL,ReactantCompartmentDBID.XID,ProductCompartmentDBID.XID),']: ',
			CAST(IF(Reactant.Coefficient IS NOT NULL,GROUP_CONCAT(
			  DISTINCT
			  composeStoichiometry(ReactantDBID.XID,NULL,Reactant.Coefficient)
			  ORDER BY ReactantDBID.XID
			  SEPARATOR ' + '),'') AS CHAR),
			' ==> ',
			IF(Product.Coefficient IS NOT NULL,CONCAT(GROUP_CONCAT(
			  DISTINCT
			  composeStoichiometry(ProductDBID.XID, NULL, -1*Product.Coefficient)
			  ORDER BY ProductDBID.XID
			  SEPARATOR ' + '),' + '),''),
			composeStoichiometry(DBID.XID, NULL, 1)
		),
		CONCAT(
			IF(Reactant.Coefficient IS NOT NULL,GROUP_CONCAT(
			  DISTINCT
			  composeStoichiometry(ReactantDBID.XID,ReactantCompartmentDBID.XID,Reactant.Coefficient)
			  ORDER BY ReactantDBID.XID
			  SEPARATOR ' + '),''),
			' ==> ',
			IF(Product.Coefficient IS NOT NULL,CONCAT(GROUP_CONCAT(
			  DISTINCT
			  composeStoichiometry(ProductDBID.XID, ProductCompartmentDBID.XID, -1*Product.Coefficient)
			  ORDER BY ProductDBID.XID
			  SEPARATOR ' + '),' + '),''),
			composeStoichiometry(DBID.XID, CompartmentDBID.XID, 1)
		)
	) Biosynthesis,	
	
  IF(Protein.HalfLifeCalc='S','>10 hours','2 min') HalfLifeCalc, Protein.MolecularWeightCalc,
  EnzymaticReaction.ReactionXID Reactions, EnzymaticReaction.ECNumber ECNumbers,
  Protein.DNAFootprint, Protein.DNAFootprintBindingStrandedness, Protein.DNAFootprintRegionStrandedness, Protein.MolecularInteraction, Protein.ChemicalRegulation, Protein.Subsystem,
  Protein.GeneralClassification,Protein.ProteaseClassification,Protein.TransporterClassification,
  CompartmentDBID.XID Compartment,
  CAST(GROUP_CONCAT(
      DISTINCT
      CONCAT(MonomerDBID.XID, ': ', MID(Monomer.AASequence,Feature.StartPosition,1), Feature.StartPosition, '-', MID(Monomer.AASequence,Feature.EndPosition,1), Feature.EndPosition)
      ORDER BY MonomerDBID.XID, Feature.StartPosition, Feature.EndPosition
	  SEPARATOR ';'
    ) AS CHAR) DisulfideBonds,
  CONCAT("",GROUP_CONCAT(DISTINCT ProstheticGroup.ProstheticGroups)) ProstheticGroups,
  CONCAT("",GROUP_CONCAT(DISTINCT Chaperone.Chaperones)) Chaperones,
  ComplexFormationProcessDBID.XID ComplexFormationProcess,
  ActivationInteraction.ActivationRule
FROM Protein
JOIN DBID ON DBID.OtherWID=Protein.WID

#biosynthesis
JOIN (
  SELECT * 
  FROM Subunit 
  WHERE Coefficient>0
  ) AS Reactant ON Reactant.ComplexWID=Protein.WID
JOIN DBID ReactantDBID ON ReactantDBID.OtherWID=Reactant.SubunitWID
JOIN DBID ReactantCompartmentDBID ON ReactantCompartmentDBID.OtherWID=Reactant.CompartmentWID

LEFT JOIN (
  SELECT *
  FROM Subunit 
  WHERE Coefficient<0
  ) AS Product ON Product.ComplexWID=Protein.WID
LEFT JOIN DBID ProductDBID ON ProductDBID.OtherWID=Product.SubunitWID
LEFT JOIN DBID ProductCompartmentDBID ON ProductCompartmentDBID.OtherWID=Product.CompartmentWID

#catalyzed reactions 
LEFT JOIN (
  SELECT EnzymaticReaction.ProteinWID,
    GROUP_CONCAT(DISTINCT ReactionDBID.XID ORDER BY ReactionDBID.XID SEPARATOR ';') ReactionXID,
    GROUP_CONCAT(DISTINCT Reaction.ECNumber ORDER BY Reaction.ECNumber SEPARATOR ';') ECNumber
  FROM EnzymaticReaction
  JOIN Reaction ON EnzymaticReaction.ReactionWID=Reaction.WID
  JOIN DBID ReactionDBID ON ReactionDBID.OtherWID=EnzymaticReaction.ReactionWID
  WHERE EnzymaticReaction.DataSetWID=_KnowledgeBaseWID && Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY EnzymaticReaction.ProteinWID
) AS EnzymaticReaction ON EnzymaticReaction.ProteinWID=Protein.WID

#compartment
LEFT JOIN DBID CompartmentDBID ON CompartmentDBID.OtherWID=Protein.CompartmentWID

#disulfide bonds
LEFT JOIN Feature ON Feature.SequenceWID=Protein.WID
LEFT JOIN Protein Monomer ON Feature.SubSequenceWID=Monomer.WID
LEFT JOIN DBID MonomerDBID ON Feature.SubSequenceWID=MonomerDBID.OtherWID

#prosthetic group
LEFT JOIN (
  SELECT
    Protein.WID ProteinWID,
    GROUP_CONCAT(
      DISTINCT
      composeStoichiometry(ProstheticGroupDBID.XID,CompartmentDBID.XID,InteractionProstheticGroup.Coefficient)
      ORDER BY ProstheticGroupDBID.XID
      SEPARATOR ';') ProstheticGroups
  FROM Interaction

  JOIN InteractionParticipant InteractionProtein ON InteractionProtein.InteractionWID=Interaction.WID
  JOIN (SELECT WID FROM Protein WHERE DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || Protein.WID=_WID)) AS Protein ON Protein.WID=InteractionProtein.OtherWID

  JOIN InteractionParticipant InteractionProstheticGroup ON InteractionProstheticGroup.InteractionWID=Interaction.WID
  JOIN (SELECT WID FROM Chemical WHERE DataSetWID=_KnowledgeBaseWID) AS Chemical ON Chemical.WID=InteractionProstheticGroup.OtherWID
  JOIN DBID ProstheticGroupDBID ON ProstheticGroupDBID.OtherWID=Chemical.WID
  JOIN DBID CompartmentDBID ON CompartmentDBID.OtherWID=InteractionProstheticGroup.CompartmentWID

  WHERE 
    Interaction.Type='prosthetic group' && 
    Interaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
) AS ProstheticGroup ON Protein.WID=ProstheticGroup.ProteinWID

#chaperone
LEFT JOIN (
  SELECT
    Protein.WID ProteinWID,
    GROUP_CONCAT(
      DISTINCT
      composeStoichiometry(ChaperoneDBID.XID,CompartmentDBID.XID,InteractionChaperone.Coefficient)
      ORDER BY ChaperoneDBID.XID
      SEPARATOR ';') Chaperones
  FROM Interaction

  JOIN InteractionParticipant InteractionProtein ON InteractionProtein.InteractionWID=Interaction.WID
  JOIN (SELECT WID FROM Protein WHERE DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || Protein.WID=_WID)) AS Protein ON Protein.WID=InteractionProtein.OtherWID

  JOIN InteractionParticipant InteractionChaperone ON InteractionChaperone.InteractionWID=Interaction.WID
  JOIN (SELECT WID FROM Protein WHERE DataSetWID=_KnowledgeBaseWID) AS Chaperone ON Chaperone.WID=InteractionChaperone.OtherWID
  JOIN DBID ChaperoneDBID ON ChaperoneDBID.OtherWID=Chaperone.WID
  JOIN DBID CompartmentDBID ON CompartmentDBID.OtherWID=InteractionChaperone.CompartmentWID

  WHERE 
    Interaction.Type='chaperone' && 
    InteractionProtein.Role='folding protein' && 
    InteractionChaperone.Role='chaperone' && 
    Interaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
) AS Chaperone ON Protein.WID=Chaperone.ProteinWID

#process of formation
JOIN DBID ComplexFormationProcessDBID ON Protein.ComplexFormationProcessWID = ComplexFormationProcessDBID.OtherWID

#activation
LEFT JOIN (
  SELECT Interaction.Rule ActivationRule, InteractionParticipant.OtherWID ProteinWID
  FROM Interaction
  JOIN InteractionParticipant ON Interaction.WID=InteractionParticipant.InteractionWID
  WHERE
    Interaction.DataSetWID=_KnowledgeBaseWID &&
	Interaction.Type='activation' &&
	InteractionParticipant.Role='protein'
) ActivationInteraction ON Protein.WID=ActivationInteraction.ProteinWID

WHERE Protein.DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || Protein.WID=_WID)
GROUP BY Protein.WID
ORDER BY DBID.XID;

END $$

DROP PROCEDURE IF EXISTS `get_metabolites_proteincomplexs` $$
CREATE PROCEDURE `get_metabolites_proteincomplexs` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @complexIdx:=0;
SET @metaboliteIdx:=0;
SET @compartmentIdx:=0;

SELECT
  Metabolite.Idx MetaboliteIdx,
  Metabolite.WID MetaboliteWID,
  Metabolite.XID Metabolite,
  ProteinComplex.Idx ProteinComplexIdx,
  ProteinComplex.WID ProteinComplexWID,
  ProteinComplex.XID ProteinComplex,
  Compartment.Idx MetaboliteCompartmentIdx,
  Compartment.WID MetaboliteCompartmentWID,
  Compartment.XID MetaboliteCompartment,
  Subunit.Coefficient
FROM

(SELECT @metaboliteIdx:=@metaboliteIdx+1 AS Idx,Chemical.WID, DBID.XID
 FROM Chemical
 JOIN DBID ON DBID.OtherWID=Chemical.WID
 WHERE Chemical.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Metabolite

JOIN Subunit ON Metabolite.WID=Subunit.SubunitWID

JOIN
(SELECT @complexIdx:=@complexIdx+1 AS Idx,Protein.WID, DBID.XID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS ProteinComplex
ON Subunit.ComplexWID=ProteinComplex.WID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON Compartment.WID=Subunit.CompartmentWID

WHERE Subunit.Coefficient!=0 && (_WID IS NULL || (Metabolite.WID=_WID || ProteinComplex.WID=_WID || Compartment.WID=_WID))
GROUP BY Metabolite.Idx,ProteinComplex.Idx,Compartment.Idx
ORDER BY Metabolite.Idx,ProteinComplex.Idx,Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_rnasubunits_proteincomplexs` $$
CREATE PROCEDURE `get_rnasubunits_proteincomplexs` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @complexIdx:=0;
SET @subunitIdx:=0;
SET @compartmentIdx:=0;

SELECT
  RNASubunit.Idx RNASubunitIdx,
  RNASubunit.WID RNASubunitWID,
  RNASubunit.XID RNASubunit,
  ProteinComplex.Idx ProteinComplexIdx,
  ProteinComplex.WID ProteinComplexWID,
  ProteinComplex.XID ProteinComplex,
  Compartment.Idx RNASubunitCompartmentIdx,
  Compartment.WID RNASubunitCompartmentWID,
  Compartment.XID RNASubunitCompartment,
  Subunit.Coefficient
FROM

(SELECT @subunitIdx:=@subunitIdx+1 AS Idx,Gene.WID, DBID.XID
 FROM Gene
 JOIN DBID ON DBID.OtherWID=Gene.WID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS RNASubunit

JOIN Subunit ON RNASubunit.WID=Subunit.SubunitWID

JOIN
(SELECT @complexIdx:=@complexIdx+1 AS Idx,Protein.WID, DBID.XID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS ProteinComplex
ON Subunit.ComplexWID=ProteinComplex.WID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON Compartment.WID=Subunit.CompartmentWID

WHERE Subunit.Coefficient!=0 && (_WID IS NULL || (RNASubunit.WID=_WID || ProteinComplex.WID=_WID || Compartment.WID=_WID))
GROUP BY RNASubunit.Idx,ProteinComplex.Idx,Compartment.Idx
ORDER BY RNASubunit.Idx,ProteinComplex.Idx,Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteinmonomersubunits_proteincomplexs` $$
CREATE PROCEDURE `get_proteinmonomersubunits_proteincomplexs` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @complexIdx:=0;
SET @subunitIdx:=0;
SET @compartmentIdx:=0;

SELECT
  ProteinMonomer.Idx ProteinMonomerIdx,
  ProteinMonomer.WID ProteinMonomerWID,
  ProteinMonomer.XID ProteinMonomer,
  ProteinComplex.Idx ProteinComplexIdx,
  ProteinComplex.WID ProteinComplexWID,
  ProteinComplex.XID ProteinComplex,
  Compartment.Idx ProteinMonomerCompartmentIdx,
  Compartment.WID ProteinMonomerCompartmentWID,
  Compartment.XID ProteinMonomerCompartment,
  Subunit.Coefficient
FROM

(SELECT @subunitIdx:=@subunitIdx+1 AS Idx,GeneWIDProteinWID.ProteinWID WID, DBID.XID
 FROM Gene
 JOIN GeneWIDProteinWID ON GeneWIDProteinWID.GeneWID=Gene.WID
 JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS ProteinMonomer

JOIN Subunit ON ProteinMonomer.WID=Subunit.SubunitWID

JOIN
(SELECT @complexIdx:=@complexIdx+1 AS Idx,Protein.WID, DBID.XID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS ProteinComplex
ON Subunit.ComplexWID=ProteinComplex.WID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON Compartment.WID=Subunit.CompartmentWID

WHERE Subunit.Coefficient!=0 && (_WID IS NULL || (ProteinMonomer.WID=_WID || ProteinComplex.WID=_WID || Compartment.WID=_WID))
GROUP BY ProteinMonomer.Idx,ProteinComplex.Idx,Compartment.Idx
ORDER BY ProteinMonomer.Idx,ProteinComplex.Idx,Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteincomplexsubunits_proteincomplexs` $$
CREATE PROCEDURE `get_proteincomplexsubunits_proteincomplexs` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @complexIdx:=0;
SET @subunitIdx:=0;
SET @compartmentIdx:=0;

SELECT
  ProteinComplexSubunit.Idx ProteinComplexSubunitIdx,
  ProteinComplexSubunit.WID ProteinComplexSubunitWID,
  ProteinComplexSubunit.XID ProteinComplexSubunit,
  ProteinComplex.Idx ProteinComplexIdx,
  ProteinComplex.WID ProteinComplexWID,
  ProteinComplex.XID ProteinComplex,
  Compartment.Idx ProteinComplexSubunitCompartmentIdx,
  Compartment.WID ProteinComplexSubunitCompartmentWID,
  Compartment.XID ProteinComplexSubunitCompartment,
  Subunit.Coefficient
FROM

(SELECT @subunitIdx:=@subunitIdx+1 AS Idx,Protein.WID, DBID.XID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS ProteinComplexSubunit

JOIN Subunit ON ProteinComplexSubunit.WID=Subunit.SubunitWID

JOIN
(SELECT @complexIdx:=@complexIdx+1 AS Idx,Protein.WID, DBID.XID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS ProteinComplex
ON Subunit.ComplexWID=ProteinComplex.WID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON Compartment.WID=Subunit.CompartmentWID

WHERE Subunit.Coefficient!=0 && (_WID IS NULL || (ProteinComplexSubunit.WID=_WID || ProteinComplex.WID=_WID || Compartment.WID=_WID))
GROUP BY ProteinComplexSubunit.Idx,ProteinComplex.Idx,Compartment.Idx
ORDER BY ProteinComplexSubunit.Idx,ProteinComplex.Idx,Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteinmonomers_proteinmonomerchaperones` $$
CREATE PROCEDURE `get_proteinmonomers_proteinmonomerchaperones` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinMonomerIdx:=0;
SET @proteinMonomerChaperoneIdx:=0;
SET @compartmentIdx:=0;

SELECT
  ProteinMonomer.Idx ProteinMonomerIdx,
  ProteinMonomer.WID ProteinMonomerWID,
  ProteinMonomer.XID ProteinMonomer,
  ProteinMonomerChaperone.Idx ProteinMonomerChaperoneIdx,
  ProteinMonomerChaperone.WID ProteinMonomerChaperoneWID,
  ProteinMonomerChaperone.XID ProteinMonomerChaperone,
  Compartment.Idx ProteinMonomerChaperoneCompartmentIdx,
  Compartment.WID ProteinMonomerChaperoneCompartmentWID,
  Compartment.XID ProteinMonomerChaperoneCompartment,
  InteractionChaperone.Coefficient
FROM

(SELECT @proteinMonomerIdx:=@proteinMonomerIdx+1 AS Idx,GeneWIDProteinWID.ProteinWID WID, DBID.XID
 FROM GeneWIDProteinWID
 JOIN Gene ON GeneWIDProteinWID.GeneWID=Gene.WID
 JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS ProteinMonomer

JOIN Interaction
JOIN InteractionParticipant InteractionProtein ON InteractionProtein.InteractionWID=Interaction.WID && ProteinMonomer.WID=InteractionProtein.OtherWID
JOIN InteractionParticipant InteractionChaperone ON InteractionChaperone.InteractionWID=Interaction.WID

JOIN (
 SELECT @proteinMonomerChaperoneIdx:=@proteinMonomerChaperoneIdx+1 AS Idx,GeneWIDProteinWID.ProteinWID WID, DBID.XID
 FROM GeneWIDProteinWID
 JOIN Gene ON GeneWIDProteinWID.GeneWID=Gene.WID
 JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS ProteinMonomerChaperone ON ProteinMonomerChaperone.WID=InteractionChaperone.OtherWID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON InteractionChaperone.CompartmentWID=Compartment.WID

WHERE 
	Interaction.Type='chaperone' && 
	Interaction.DataSetWID=_KnowledgeBaseWID && 
	InteractionChaperone.Role='chaperone' && 
	InteractionProtein.Role='folding protein' &&
	(_WID IS NULL || (ProteinMonomer.WID=_WID || ProteinMonomerChaperone.WID=_WID || Compartment.WID=_WID))
GROUP BY ProteinMonomer.Idx,ProteinMonomerChaperone.Idx,Compartment.Idx
ORDER BY ProteinMonomer.Idx,ProteinMonomerChaperone.Idx,Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteincomplexs_proteinmonomerchaperones` $$
CREATE PROCEDURE `get_proteincomplexs_proteinmonomerchaperones` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinComplexIdx:=0;
SET @proteinMonomerChaperoneIdx:=0;
SET @compartmentIdx:=0;

SELECT
  ProteinComplex.Idx ProteinComplexIdx,
  ProteinComplex.WID ProteinComplexWID,
  ProteinComplex.XID ProteinComplex,
  ProteinMonomerChaperone.Idx ProteinMonomerChaperoneIdx,
  ProteinMonomerChaperone.WID ProteinNonomerChaperoneWID,
  ProteinMonomerChaperone.XID ProteinMonomerChaperone,
  Compartment.Idx ProteinMonomerChaperoneCompartmentIdx,
  Compartment.WID ProteinMonomerChaperoneCompartmentWID,
  Compartment.XID ProteinMonomerChaperoneCompartment,
  InteractionChaperone.Coefficient
FROM

(SELECT @proteinComplexIdx:=@proteinComplexIdx+1 AS Idx,Protein.WID, DBID.XID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS ProteinComplex

JOIN Interaction
JOIN InteractionParticipant InteractionProtein ON InteractionProtein.InteractionWID=Interaction.WID && ProteinComplex.WID=InteractionProtein.OtherWID
JOIN InteractionParticipant InteractionChaperone ON InteractionChaperone.InteractionWID=Interaction.WID

JOIN (
 SELECT @proteinMonomerChaperoneIdx:=@proteinMonomerChaperoneIdx+1 AS Idx,GeneWIDProteinWID.ProteinWID WID, DBID.XID
 FROM GeneWIDProteinWID
 JOIN Gene ON GeneWIDProteinWID.GeneWID=Gene.WID
 JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS ProteinMonomerChaperone
ON ProteinMonomerChaperone.WID=InteractionChaperone.OtherWID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON InteractionChaperone.CompartmentWID=Compartment.WID

WHERE 
	Interaction.Type='chaperone' && 
	Interaction.DataSetWID=_KnowledgeBaseWID && 
	InteractionChaperone.Role='chaperone' && 
	InteractionProtein.Role='folding protein' &&
	(_WID IS NULL || (ProteinComplex.WID=_WID || ProteinMonomerChaperone.WID=_WID || Compartment.WID=_WID))
GROUP BY ProteinComplex.Idx,ProteinMonomerChaperone.Idx,Compartment.Idx
ORDER BY ProteinComplex.Idx,ProteinMonomerChaperone.Idx,Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteinmonomers_proteincomplexchaperones` $$
CREATE PROCEDURE `get_proteinmonomers_proteincomplexchaperones` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinMonomerIdx:=0;
SET @proteinComplexChaperoneIdx:=0;
SET @compartmentIdx:=0;

SELECT
  ProteinMonomer.Idx ProteinMonomerIdx,
  ProteinMonomer.WID ProteinMonomerWID,
  ProteinMonomer.XID ProteinMonomer,
  ProteinComplexChaperone.Idx ProteinComplexChaperoneIdx,
  ProteinComplexChaperone.WID ProteinComplexChaperoneWID,
  ProteinComplexChaperone.XID ProteinComplexChaperone,
  Compartment.Idx ProteinComplexChaperoneCompartmentIdx,
  Compartment.WID ProteinComplexChaperoneCompartmentWID,
  Compartment.XID ProteinComplexChaperoneCompartment,
  InteractionChaperone.Coefficient
FROM

(SELECT @proteinMonomerIdx:=@proteinMonomerIdx+1 AS Idx,GeneWIDProteinWID.ProteinWID WID, DBID.XID
 FROM GeneWIDProteinWID
 JOIN Gene ON GeneWIDProteinWID.GeneWID=Gene.WID
 JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS ProteinMonomer

JOIN Interaction
JOIN InteractionParticipant InteractionProtein ON InteractionProtein.InteractionWID=Interaction.WID && ProteinMonomer.WID=InteractionProtein.OtherWID
JOIN InteractionParticipant InteractionChaperone ON InteractionChaperone.InteractionWID=Interaction.WID

JOIN (
  SELECT @proteinComplexChaperoneIdx:=@proteinComplexChaperoneIdx+1 AS Idx,Protein.WID, DBID.XID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS ProteinComplexChaperone
ON ProteinComplexChaperone.WID=InteractionChaperone.OtherWID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON InteractionChaperone.CompartmentWID=Compartment.WID

WHERE 
	Interaction.Type='chaperone' && 
	Interaction.DataSetWID=_KnowledgeBaseWID && 
	InteractionChaperone.Role='chaperone' && 
	InteractionProtein.Role='folding protein' &&
	(_WID IS NULL || (ProteinMonomer.WID=_WID || ProteinComplexChaperone.WID=_WID || Compartment.WID=_WID))
GROUP BY ProteinMonomer.Idx,ProteinComplexChaperone.Idx,Compartment.Idx
ORDER BY ProteinMonomer.Idx,ProteinComplexChaperone.Idx,Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteincomplexs_proteincomplexchaperones` $$
CREATE PROCEDURE `get_proteincomplexs_proteincomplexchaperones` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinComplexIdx:=0;
SET @proteinComplexChaperoneIdx:=0;
SET @compartmentIdx:=0;

SELECT
  ProteinComplex.Idx ProteinComplexIdx,
  ProteinComplex.WID ProteinComplexWID,
  ProteinComplex.XID ProteinComplex,
  ProteinComplexChaperone.Idx ProteinComplexChaperoneIdx,
  ProteinComplexChaperone.WID ProteinComplexChaperoneWID,
  ProteinComplexChaperone.XID ProteinComplexChaperone,
  Compartment.Idx ProteinComplexChaperoneCompartmentIdx,
  Compartment.WID ProteinComplexChaperoneCompartmentWID,
  Compartment.XID ProteinComplexChaperoneCompartment,
  InteractionChaperone.Coefficient
FROM

(SELECT @proteinComplexIdx:=@proteinComplexIdx+1 AS Idx,Protein.WID, DBID.XID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS ProteinComplex

JOIN Interaction
JOIN InteractionParticipant InteractionProtein ON InteractionProtein.InteractionWID=Interaction.WID && ProteinComplex.WID=InteractionProtein.OtherWID
JOIN InteractionParticipant InteractionChaperone ON InteractionChaperone.InteractionWID=Interaction.WID

JOIN (
  SELECT @proteinComplexChaperoneIdx:=@proteinComplexChaperoneIdx+1 AS Idx,Protein.WID, DBID.XID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS ProteinComplexChaperone
ON ProteinComplexChaperone.WID=InteractionChaperone.OtherWID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON InteractionChaperone.CompartmentWID=Compartment.WID

WHERE 
	Interaction.Type='chaperone' && 
	Interaction.DataSetWID=_KnowledgeBaseWID && 
	InteractionChaperone.Role='chaperone' && 
	InteractionProtein.Role='folding protein' &&
	(_WID IS NULL || (ProteinComplex.WID=_WID || ProteinComplexChaperone.WID=_WID || Compartment.WID=_WID))
GROUP BY ProteinComplex.Idx,ProteinComplexChaperone.Idx,Compartment.Idx
ORDER BY ProteinComplex.Idx,ProteinComplexChaperone.Idx,Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteincomplexs_processs` $$
CREATE PROCEDURE `get_proteincomplexs_processs` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @complexIdx:=0;
SET @processIdx:=0;

SELECT
  ProteinComplex.Idx ProteinComplexIdx,
  ProteinComplex.WID ProteinComplexWID,
  ProteinComplex.XID ProteinComplex,
  Process.Idx ProcessIdx,
  Process.WID ProcessWID,
  Process.XID Process
FROM

(SELECT @complexIdx:=@complexIdx+1 AS Idx, Protein.WID, DBID.XID, Protein.ComplexFormationProcessWID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS ProteinComplex

JOIN (
 SELECT @processIdx:=@processIdx+1 AS Idx,Process.WID, DBID.XID
 FROM Process
 JOIN DBID ON DBID.OtherWID=Process.WID
 WHERE Process.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Process ON Process.WID=ProteinComplex.ComplexFormationProcessWID

WHERE _WID IS NULL || (ProteinComplex.WID=_WID || Process.WID=_WID)
GROUP BY ProteinComplex.Idx, Process.Idx
ORDER BY ProteinComplex.Idx, Process.Idx;

END $$


-- ---------------------------------------------------------
-- metabolites
-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS `set_metabolite` $$
CREATE PROCEDURE `set_metabolite` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _CASID varchar(255),
  IN _Name varchar(255), IN _TraditionalName varchar(255), IN _IUPACName varchar(255), 
  IN _Category varchar(255), IN _Subcategory varchar(255), 
  IN _Charge smallint,IN _Hydrophobic char(1),
  IN _pKa1 float,IN _pKa2 float,IN _pKa3 float,
  IN _pI float, IN _logP float, IN _logD float, IN _Volume float,IN _MolecularWeightCalc float,
  IN _EmpiricalFormula varchar(255),IN _Smiles text, IN _ExchangeLowerBound float, IN _ExchangeUpperBound float)
BEGIN

DECLARE _MetaboliteWID bigint;
DECLARE _ReactionWID bigint;
DECLARE _BoundUnitsWID bigint;

SELECT WID INTO _MetaboliteWID FROM Chemical WHERE WID=_WID;

IF _MetaboliteWID IS NULL THEN
	INSERT INTO Chemical(WID,CAS,Name,SystematicName,TraditionalName,Category,Subcategory,Charge,WaterSolubility,EmpiricalFormula,MolecularWeightCalc,PKA1,PKA2,PKA3,pI,OctH2OPartitionCoeff,OctH2ODistributionCoeff,Volume,Smiles,DataSetWID)
	VALUES (_WID,_CASID,_Name,_IUPACName,_TraditionalName,_Category,_Subcategory,_Charge,IF(_Hydrophobic='Y','F','T'),_EmpiricalFormula,_MolecularWeightCalc,_pKa1,_pKa2,_pKa3,_pI,_logP,_logD,_Volume,_Smiles,_KnowledgeBaseWID);
ELSE 
	UPDATE Chemical
	SET
		CAS=_CASID,
		Name=_Name,
		SystematicName=_IUPACName,
		TraditionalName=_TraditionalName,
		Category=_Category,
		Subcategory=_Subcategory,
		Charge=_Charge,
		WaterSolubility=IF(_Hydrophobic='Y','F','T'),
		EmpiricalFormula=_EmpiricalFormula,
		MolecularWeightCalc=_MolecularWeightCalc,
		PKA1=_pKa1,
		PKA2=_pKa2,
		PKA3=_pKa3,
		pI=_pI,
		OctH2OPartitionCoeff=_logP,
		OctH2ODistributionCoeff=_logD,
		Volume=_Volume,
		Smiles=_Smiles
	WHERE WID=_WID;
END IF;

SELECT Reaction.WID INTO _ReactionWID
FROM Reaction
JOIN Product on Product.ReactionWID=Reaction.WID
WHERE
  Product.OtherWID=_WID &&
  Reaction.Type='metabolite exchange'
GROUP BY Reaction.WID;

IF _ReactionWID IS NULL THEN
	CALL set_units(_KnowledgeBaseWID, _BoundUnitsWID, 'mmol/gDCW/h');
  CALL set_entry('F',_KnowledgeBaseWID, _ReactionWID,NULL);
	INSERT INTO Reaction (WID, Type, Spontaneous, LowerBound, UpperBound, BoundUnitsWID, DataSetWID) 
	VALUES(_ReactionWID, 'metabolite exchange', 'Y', _ExchangeLowerBound, _ExchangeUpperBound, _BoundUnitsWID, _KnowledgeBaseWID);
ELSE
	UPDATE Reaction 
	SET LowerBound=_ExchangeLowerBound, UpperBound=_ExchangeUpperBound
	WHERE WID=_ReactionWID;
END IF;

DELETE FROM Product WHERE ReactionWID = _ReactionWID;
INSERT INTO Product (OtherWID, ReactionWID, Coefficient) VALUES(_WID, _ReactionWID, 1);

CALL set_textsearch(_WID, _Name, 'name');
CALL set_textsearch(_WID, _IUPACName, 'IUPAC name');
CALL set_textsearch(_WID, _TraditionalName, 'traditional name');
CALL set_textsearch(_WID, _EmpiricalFormula, 'empirical formula');
CALL set_textsearch(_WID, _Smiles, 'SMILES');

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_metabolite` $$
CREATE PROCEDURE `delete_metabolite` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

DECLARE _ForeignWID1 bigint;
DECLARE _ForeignWID2 bigint;
DECLARE _ForeignWID3 bigint;
DECLARE done INT DEFAULT 0;
DECLARE cur1 CURSOR FOR 
	SELECT BiomassComposition.WID, MediaComposition.WID, Illustration.WID
	FROM Chemical 
	LEFT JOIN BiomassComposition ON Chemical.WID=BiomassComposition.OtherWID
	LEFT JOIN MediaComposition ON Chemical.WID=MediaComposition.OtherWID
	LEFT JOIN Illustration ON Chemical.WID=Illustration.OtherWID
	WHERE Chemical.WID=_WID;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

#metabolite
DELETE FROM Chemical WHERE WID=_WID;

SET done=0;
OPEN cur1;
REPEAT
    FETCH cur1 INTO _ForeignWID1, _ForeignWID2, _ForeignWID3;
    IF NOT done THEN
		CALL delete_biomasscomposition(_KnowledgeBaseWID, _ForeignWID1);
		CALL delete_mediacomponent(_KnowledgeBaseWID, _ForeignWID2);
		CALL delete_metabolicmapmetabolite(_KnowledgeBaseWID, _ForeignWID3);
    END IF;
UNTIL done END REPEAT;
CLOSE cur1;

#metabolite
DELETE Reaction
FROM Reaction
JOIN Product ON Product.ReactionWID=Reaction.WID
WHERE
  Product.OtherWID=_WID &&
  Reaction.Type='metabolite exchange';
DELETE FROM Reactant WHERE Reactant.OtherWID=_WID;
DELETE FROM Product WHERE Product.OtherWID=_WID;

#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `get_metabolites` $$
CREATE PROCEDURE `get_metabolites` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Chemical.WID, DBID.XID WholeCellModelID,
  Chemical.CAS CASID,
  Chemical.Name, Chemical.TraditionalName, Chemical.SystematicName IUPACName,
  Chemical.Category,
  Chemical.Subcategory,
  Chemical.Charge, IF(Chemical.WaterSolubility='F','Y','N') Hydrophobic,
  CONCAT('',CONCAT_WS(', ',Chemical.PKA1,Chemical.PKA2,Chemical.PKA3)) pKa,Chemical.PKA1 pKa1,Chemical.PKA2 pKa2,Chemical.PKA3 pKa3,
  Chemical.pI, Chemical.OctH2OPartitionCoeff+0 logP, Chemical.OctH2ODistributionCoeff+0 logD, Chemical.Volume,
  Chemical.MolecularWeightCalc,Chemical.EmpiricalFormula,Chemical.Smiles,
  Reaction.LowerBound ExchangeLowerBound, Reaction.UpperBound ExchangeUpperBound,
  GROUP_CONCAT(DISTINCT ReactionDBID.XID ORDER BY ReactionDBID.XID SEPARATOR ';') Reactions

FROM Chemical
JOIN DBID ON DBID.OtherWID=Chemical.WID

#reactions
JOIN (
  SELECT * FROM Reactant
  UNION
  SELECT * FROM Product
) AS ProductORReactant ON ProductORReactant.OtherWID=Chemical.WID
LEFT JOIN DBID ReactionDBID ON ReactionDBID.OtherWID=ProductORReactant.ReactionWID

#exchange bounds
LEFT JOIN (
  SELECT Product.OtherWID, Reaction.LowerBound, Reaction.UpperBound
  FROM Reaction
  JOIN Product ON Product.ReactionWID=Reaction.WID
  WHERE
     Reaction.DataSetWID=_KnowledgeBaseWID &&
     Reaction.Type='metabolite exchange'
) AS Reaction ON Reaction.OtherWID=Chemical.WID

WHERE
	Chemical.DataSetWID=_KnowledgeBaseWID &&
	(_WID IS NULL || Chemical.WID=_WID)
GROUP BY Chemical.WID
ORDER BY DBID.XID;

END $$

DROP PROCEDURE IF EXISTS `get_metaboliteempiricalformulas` $$
CREATE PROCEDURE `get_metaboliteempiricalformulas` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @Idx:=0;

SELECT 
	@Idx:=@Idx+1 AS Idx, 
	Chemical.WID, 
	DBID.XID WholeCellModelID, 
	Chemical.EmpiricalFormula
FROM Chemical
JOIN DBID ON Chemical.WID=DBID.OtherWID
WHERE DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || Chemical.WID=_WID)
ORDER BY DBID.XID;

END $$

DROP PROCEDURE IF EXISTS `get_proteinmonomers_prostheticgroups` $$
CREATE PROCEDURE `get_proteinmonomers_prostheticgroups` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinMonomerIdx:=0;
SET @prostheticGroupIdx:=0;
SET @compartmentIdx:=0;

SELECT
  ProteinMonomer.Idx ProteinMonomerIdx,
  ProteinMonomer.WID ProteinMonomerWID,
  ProteinMonomer.XID ProteinMonomer,
  ProstheticGroup.Idx MetaboliteIdx,
  ProstheticGroup.WID MetaboliteWID,
  ProstheticGroup.XID Metabolite,
  Compartment.Idx MetaboliteCompartmentIdx,
  Compartment.WID MetaboliteCompartmentWID,
  Compartment.XID MetaboliteCompartment,
  InteractionMetabolite.Coefficient
FROM

(SELECT @proteinMonomerIdx:=@proteinMonomerIdx+1 AS Idx,GeneWIDProteinWID.ProteinWID WID, DBID.XID
 FROM GeneWIDProteinWID
 JOIN Gene ON GeneWIDProteinWID.GeneWID=Gene.WID
 JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS ProteinMonomer

JOIN Interaction
JOIN InteractionParticipant InteractionProtein ON InteractionProtein.InteractionWID=Interaction.WID && ProteinMonomer.WID=InteractionProtein.OtherWID
JOIN InteractionParticipant InteractionMetabolite ON InteractionMetabolite.InteractionWID=Interaction.WID

JOIN (
 SELECT @prostheticGroupIdx:=@prostheticGroupIdx+1 AS Idx,Chemical.WID, DBID.XID
 FROM Chemical
 JOIN DBID ON DBID.OtherWID=Chemical.WID
 WHERE Chemical.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS ProstheticGroup
ON ProstheticGroup.WID=InteractionMetabolite.OtherWID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON InteractionMetabolite.CompartmentWID=Compartment.WID

WHERE 
	Interaction.Type='prosthetic group' && 
	Interaction.DataSetWID=_KnowledgeBaseWID &&
	(_WID IS NULL || (ProteinMonomer.WID=_WID || ProstheticGroup.WID=_WID || Compartment.WID=_WID))
GROUP BY ProteinMonomer.Idx,ProstheticGroup.Idx,Compartment.Idx
ORDER BY ProteinMonomer.Idx,ProstheticGroup.Idx,Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteincomplexs_prostheticgroups` $$
CREATE PROCEDURE `get_proteincomplexs_prostheticgroups` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinComplexIdx:=0;
SET @prostheticGroupIdx:=0;
SET @compartmentIdx:=0;

SELECT
  ProteinComplex.Idx ProteinComplexIdx,
  ProteinComplex.WID ProteinComplexWID,
  ProteinComplex.XID ProteinComplex,
  ProstheticGroup.Idx MetaboliteIdx,
  ProstheticGroup.WID MetaboliteWID,
  ProstheticGroup.XID Metabolite,
  Compartment.Idx MetaboliteCompartmentIdx,
  Compartment.WID MetaboliteCompartmentWID,
  Compartment.XID MetaboliteCompartment,
  InteractionMetabolite.Coefficient
FROM

(SELECT @proteinComplexIdx:=@proteinComplexIdx+1 AS Idx,Protein.WID, DBID.XID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS ProteinComplex

JOIN Interaction
JOIN InteractionParticipant InteractionProtein ON InteractionProtein.InteractionWID=Interaction.WID && ProteinComplex.WID=InteractionProtein.OtherWID
JOIN InteractionParticipant InteractionMetabolite ON InteractionMetabolite.InteractionWID=Interaction.WID

JOIN (
 SELECT @prostheticGroupIdx:=@prostheticGroupIdx+1 AS Idx,Chemical.WID, DBID.XID
 FROM Chemical
 JOIN DBID ON DBID.OtherWID=Chemical.WID
 WHERE Chemical.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS ProstheticGroup
ON ProstheticGroup.WID=InteractionMetabolite.OtherWID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON InteractionMetabolite.CompartmentWID=Compartment.WID

WHERE 
	Interaction.Type='prosthetic group' && 
	Interaction.DataSetWID=_KnowledgeBaseWID &&
	(_WID IS NULL || (ProteinComplex.WID=_WID || ProstheticGroup.WID=_WID || Compartment.WID=_WID))
GROUP BY ProteinComplex.Idx,ProstheticGroup.Idx,Compartment.Idx
ORDER BY ProteinComplex.Idx,ProstheticGroup.Idx,Compartment.Idx;

END $$

-- ---------------------------------------------------------
-- biomass composition
-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS `set_biomasscomposition` $$
CREATE PROCEDURE `set_biomasscomposition` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _Metabolite varchar(150),
  IN _Compartment varchar(150), IN _BiomassCompositionCoefficient float)
BEGIN

DECLARE _BiomassCompositionWID bigint;
DECLARE _ChemicalWID bigint;
DECLARE _CompartmentWID bigint;
SELECT WID INTO _ChemicalWID FROM Chemical JOIN DBID ON DBID.OtherWID=Chemical.WID WHERE DBID.XID=_Metabolite && Chemical.DataSetWID=_KnowledgeBaseWID;
SELECT WID INTO _CompartmentWID FROM Compartment JOIN DBID ON DBID.OtherWID=Compartment.WID WHERE DBID.XID=_Compartment && Compartment.DataSetWID=_KnowledgeBaseWID;

SELECT WID INTO _BiomassCompositionWID FROM BiomassComposition WHERE WID=_WID;
IF _BiomassCompositionWID IS NULL THEN
	INSERT INTO BiomassComposition(WID,OtherWID,CompartmentWID,Coefficient,DataSetWID) 
	VALUES(_WID,_ChemicalWID,_CompartmentWID,_BiomassCompositionCoefficient,_KnowledgeBaseWID);
ELSE 
	UPDATE BiomassComposition
	SET 
		OtherWID=_ChemicalWID,
		CompartmentWID=_CompartmentWID,
		Coefficient=_BiomassCompositionCoefficient
	WHERE WID=_WID;
END IF;

CALL set_textsearch(_ChemicalWID, _Compartment, 'compartment');

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_biomasscomposition` $$
CREATE PROCEDURE `delete_biomasscomposition` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

#biomass composition
DELETE FROM BiomassComposition WHERE BiomassComposition.WID=_WID;

#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `get_biomasscompositions` $$
CREATE PROCEDURE `get_biomasscompositions` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  BiomassComposition.WID, DBID.XID WholeCellModelID, 
  ChemicalDBID.XID Metabolite, Chemical.Name,
  CompartmentDBID.XID Compartment,
  BiomassComposition.Coefficient BiomassCompositionCoefficient

FROM BiomassComposition
JOIN DBID ON DBID.OtherWID=BiomassComposition.WID

JOIN Chemical ON BiomassComposition.OtherWID=Chemical.WID
JOIN DBID ChemicalDBID ON ChemicalDBID.OtherWID=BiomassComposition.OtherWID
JOIN DBID CompartmentDBID ON CompartmentDBID.OtherWID=BiomassComposition.CompartmentWID

WHERE BiomassComposition.DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || BiomassComposition.WID=_WID)
ORDER BY DBID.XID;

END $$

DROP PROCEDURE IF EXISTS `get_metabolites_biomasscompositions` $$
CREATE PROCEDURE `get_metabolites_biomasscompositions` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinComplexIdx:=0;
SET @metaboliteIdx:=0;
SET @compartmentIdx:=0;

SELECT
  Metabolite.Idx MetaboliteIdx,
  Metabolite.WID MetaboliteWID,
  Metabolite.XID Metabolite,
  Compartment.Idx CompartmentIdx,
  Compartment.WID CompartmentWID,
  Compartment.XID Compartment,
  BiomassComposition.Coefficient
FROM (
 SELECT @metaboliteIdx:=@metaboliteIdx+1 AS Idx,Chemical.WID, DBID.XID
 FROM Chemical
 JOIN DBID ON DBID.OtherWID=Chemical.WID
 WHERE Chemical.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Metabolite

JOIN BiomassComposition ON BiomassComposition.OtherWID=Metabolite.WID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON Compartment.WID=BiomassComposition.CompartmentWID

WHERE (_WID IS NULL || (Metabolite.WID=_WID || Compartment.WID=_WID))
GROUP BY Metabolite.Idx, Compartment.Idx
ORDER BY Metabolite.Idx, Compartment.Idx;

END $$


-- ---------------------------------------------------------
-- reactions
-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS `set_reaction` $$
CREATE PROCEDURE `set_reaction` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _Name varchar(250),IN _Module varchar(255),IN _State varchar(255),IN _Type varchar(255),
  IN _ECNumber varchar(50), IN _Enzyme varchar(255), IN _EnzymeCompartment varchar(255),
  IN _Pathways tinytext,IN _Spontaneous char(1), IN _Stoichiometry text,
  IN _ModificationReactant varchar(150), IN _ModificationCompartment varchar(150), IN _ModificationPosition bigint,
  IN _DeltaGExp float, IN _DeltaGCalc float,
  IN _RateLawForward varchar(255),IN _KmForward varchar(255),IN _VmaxExpForward float,IN _VmaxExpUnitForward varchar(255),
  IN _RateLawBackward varchar(255),IN _KmBackward varchar(255),IN _VmaxExpBackward float,IN _VmaxExpUnitBackward varchar(255),
  IN _OptimalpH float,IN _OptimalTemp float,
  IN _Coenzymes tinytext,IN _Activators tinytext,IN _Inhibitors tinytext,
  IN _LowerBound float, IN _UpperBound float, IN _BoundUnits varchar(255))
BEGIN

CALL set_reaction_helper(_KnowledgeBaseWID,_WID,
  _Name,_Module,_State, _Type,
  _ECNumber,_Enzyme,_EnzymeCompartment,
  _Pathways,_Spontaneous,_Stoichiometry,
  _ModificationReactant, _ModificationCompartment, _ModificationPosition,
  _DeltaGExp,_DeltaGCalc,
  _RateLawForward,_KmForward,_VmaxExpForward,_VmaxExpUnitForward,
  _RateLawBackward,_KmBackward,_VmaxExpBackward,_VmaxExpUnitBackward,
  _OptimalpH,_OptimalTemp,
  _Coenzymes,_Activators,_Inhibitors,
  _LowerBound,_UpperBound,_BoundUnits,
  true);

END $$

DROP PROCEDURE IF EXISTS `set_reaction_helper` $$
CREATE PROCEDURE `set_reaction_helper` (IN _KnowledgeBaseWID bigint, INOUT _WID bigint,
  IN _Name varchar(250),IN _Module varchar(255),IN _State varchar(255), IN _Type varchar(255),
  IN _ECNumber varchar(50), IN _Enzyme varchar(255), IN _EnzymeCompartment varchar(255),
  IN _Pathways tinytext,IN _Spontaneous char(1), IN _Stoichiometry text,
  IN _ModificationReactant varchar(150), IN _ModificationCompartment varchar(150), IN _ModificationPosition bigint,
  IN _DeltaGExp float, IN _DeltaGCalc float,
  IN _RateLawForward varchar(255),IN _KmForward varchar(255),IN _VmaxExpForward float,IN _VmaxExpUnitForward varchar(255),
  IN _RateLawBackward varchar(255),IN _KmBackward varchar(255),IN _VmaxExpBackward float,IN _VmaxExpUnitBackward varchar(255),
  IN _OptimalpH float,IN _OptimalTemp float,
  IN _Coenzymes tinytext,IN _Activators tinytext,IN _Inhibitors tinytext,
  IN _LowerBound float, IN _UpperBound float, IN _BoundUnits varchar(255),
  IN _SelectWID bool)
BEGIN

DECLARE _ReactionWID bigint;
DECLARE _EnzymaticReactionWID bigint;
DECLARE _EnzymeWID bigint;
DECLARE _EnzymeCompartmentWID bigint;
DECLARE _Coefficient float;
DECLARE _CompartmentWID bigint;
DECLARE _ChemicalWID bigint;
DECLARE _idx smallint;
DECLARE _nIter smallint;
DECLARE _MolecularWeightCalc float;
DECLARE _VmaxCalcForward float;
DECLARE _VmaxCalcBackward float;
DECLARE _PathwayWID bigint;
DECLARE _PathwayXID varchar(255);
DECLARE _Reactants tinytext;
DECLARE _Products tinytext;
DECLARE _Direction char(1);
DECLARE _ModificationCompartmentWID bigint;
DECLARE _ModificationReactantWID bigint;
DECLARE _ModuleWID bigint;
DECLARE _StateWID bigint;
DECLARE _BoundUnitsWID bigint;

#determine direction
IF LOCATE(' <==> ',_Stoichiometry)>0 THEN
    SET _Direction='R';
    IF _LowerBound IS NULL THEN
        SET _LowerBound='-1000';
    END IF;
    IF _UpperBound IS NULL THEN
        SET _UpperBound='1000';
    END IF;
ELSEIF LOCATE(' ==> ',_Stoichiometry)>0 THEN
    SET _Direction='F';
    IF _LowerBound IS NULL THEN
        SET _LowerBound='0';
    END IF;
    IF _UpperBound IS NULL THEN
        SET _UpperBound='1000';
    END IF;
ELSE
    SET _Direction='B';
    IF _LowerBound IS NULL THEN
        SET _LowerBound='-1000';
    END IF;
    IF _UpperBound IS NULL THEN
        SET _UpperBound='0';
    END IF;
END IF;

IF _BoundUnits IS NULL THEN
	SET _BoundUnits='mmol/gDCW/h';
END IF;

#bound units
CALL set_units(_KnowledgeBaseWID, _BoundUnitsWID, _BoundUnits);

#create reaction
SELECT WID INTO _ReactionWID FROM Reaction WHERE WID=_WID;
IF _ReactionWID IS NULL THEN
    INSERT INTO Reaction(WID,Name,Type,DeltaGExp,DeltaGCalc,Direction,ECNumber,Spontaneous,LowerBound,UpperBound,BoundUnitsWID, DataSetWID)
    VALUES(_WID,_Name,_Type,_DeltaGExp,_DeltaGCalc,_Direction,_ECNumber,_Spontaneous,_LowerBound,_UpperBound,_BoundUnitsWID, _KnowledgeBaseWID);
ELSE 
    UPDATE Reaction
    SET
        Name=_Name,
        Type=_Type,
        DeltaGExp=_DeltaGExp,
        DeltaGCalc=_DeltaGCalc,
        Direction=_Direction,
        ECNumber=_ECNumber,
        Spontaneous=_Spontaneous,
        LowerBound=_LowerBound,
        UpperBound=_UpperBound,
		BoundUnitsWID=_BoundUnitsWID
    WHERE WID=_WID;
END IF;


#process
DELETE FROM ReactionWIDOtherWID WHERE ReactionWID = _WID && `Type`='Process';

SELECT Entry.OtherWID INTO _ModuleWID
FROM Entry
JOIN DBID ON DBID.OtherWID=Entry.OtherWID
WHERE DBID.XID=_Module && Entry.DataSetWID = _KnowledgeBaseWID;

IF _ModuleWID IS NOT NULL THEN
    INSERT INTO ReactionWIDOtherWID(ReactionWID, OtherWID, `Type`) VALUES(_WID, _ModuleWID, 'Process');
END IF;

#state
DELETE FROM ReactionWIDOtherWID WHERE ReactionWID = _WID && `Type`='State';

SELECT Entry.OtherWID INTO _StateWID
FROM Entry
JOIN DBID ON DBID.OtherWID=Entry.OtherWID
WHERE DBID.XID=_State && Entry.DataSetWID = _KnowledgeBaseWID;

IF _StateWID IS NOT NULL THEN
    INSERT INTO ReactionWIDOtherWID(ReactionWID, OtherWID, `Type`) VALUES(_WID, _StateWID, 'State');
END IF;

#stoichiometry
DELETE FROM Reactant WHERE ReactionWID=_WID;
SET _Reactants=SUBSTRING_INDEX(_Stoichiometry,CONCAT(' ',IF(_Direction='R','<==>',IF(_Direction='F','==>','<==')),' '),1);
SET _nIter=((LENGTH(_Reactants)-LENGTH(REPLACE(_Reactants,' + ','')))/3+1);
SET _idx=1;
WHILE _idx<=_nIter DO
    CALL parseStoichiometry(_KnowledgeBaseWID,_Stoichiometry,' + ',_Direction,-1,_idx,_ChemicalWID,_CompartmentWID,_Coefficient);

    IF _ChemicalWID IS NOT NULL THEN
        INSERT INTO Reactant(ReactionWID,OtherWID,Coefficient,CompartmentWID)
        VALUES(_WID,_ChemicalWID,_Coefficient,_CompartmentWID);
    END IF;

    SET _idx=_idx+1;
END WHILE;

DELETE FROM Product WHERE ReactionWID=_WID;
SET _Products=SUBSTRING_INDEX(_Stoichiometry,CONCAT(' ',IF(_Direction='R','<==>',IF(_Direction='F','==>','<==')),' '),-1);
SET _nIter=((LENGTH(_Products)-LENGTH(REPLACE(_Products,' + ','')))/3+1);
SET _idx=1;
WHILE _idx<=_nIter DO
    CALL parseStoichiometry(_KnowledgeBaseWID,_Stoichiometry,' + ',_Direction,1,_idx,_ChemicalWID,_CompartmentWID,_Coefficient);

    IF _ChemicalWID IS NOT NULL THEN
        INSERT INTO Product(ReactionWID,OtherWID,Coefficient,CompartmentWID)
        VALUES(_WID,_ChemicalWID,_Coefficient,_CompartmentWID);
    END IF;

    SET _idx=_idx+1;
END WHILE;

#Modification
DELETE FROM ModificationReaction WHERE ReactionWID=_WID;
IF _ModificationReactant IS NOT NULL THEN
    SELECT WID INTO _ModificationCompartmentWID
    FROM Compartment
    JOIN DBID ON DBID.OtherWID=Compartment.WID
    WHERE Compartment.DataSetWID=_KnowledgeBaseWID && DBID.XID=_ModificationCompartment;

    SELECT WID INTO _ModificationReactantWID
    FROM Gene
    JOIN DBID ON DBID.OtherWID=Gene.WID
    WHERE Gene.DataSetWID=_KnowledgeBaseWID && DBID.XID=_ModificationReactant;

    IF _ModificationReactantWID IS NULL THEN
        SELECT WID INTO _ModificationReactantWID
        FROM Protein
        JOIN DBID ON DBID.OtherWID=Protein.WID
        WHERE Protein.DataSetWID=_KnowledgeBaseWID && DBID.XID=_ModificationReactant;
    END IF;

    INSERT INTO ModificationReaction(ReactionWID,OtherWID,CompartmentWID,Position) VALUES(_WID,_ModificationReactantWID,_ModificationCompartmentWID,_ModificationPosition);
END IF;

#enzymatic reaction
DELETE EnzymaticReaction, EnzReactionCofactor, Entry
FROM EnzymaticReaction
LEFT JOIN EnzReactionCofactor ON EnzReactionCofactor.EnzymaticReactionWID=EnzymaticReaction.WID
JOIN Entry ON Entry.OtherWID=EnzymaticReaction.WID
WHERE EnzymaticReaction.ReactionWID=_WID;

SELECT WID,MolecularWeightCalc INTO _EnzymeWID,_MolecularWeightCalc
From Protein
JOIN DBID ON DBID.OtherWID=Protein.WID
WHERE DBID.XID=_Enzyme && Protein.DataSetWID=_KnowledgeBaseWID;

SELECT WID INTO _EnzymeCompartmentWID
FROM Compartment
JOIN DBID ON DBID.OtherWID=Compartment.WID
WHERE Compartment.DataSetWID=_KnowledgeBaseWID && DBID.XID=_EnzymeCompartment;

IF _EnzymeWID IS NOT NULL THEN
    CALL set_entry('F',_KnowledgeBaseWID,_EnzymaticReactionWID,NULL);

    IF _VmaxExpUnitForward='1/min' THEN
        SET _VmaxCalcForward=_VmaxExpForward;
    ELSEIF _MolecularWeightCalc IS NOT NULL THEN
        SET _VmaxCalcForward=_VmaxExpForward*_MolecularWeightCalc*1e-3;
    END IF;

    IF _VmaxExpUnitBackward='1/min' THEN
        SET _VmaxCalcBackward=_VmaxExpBackward;
    ELSEIF _MolecularWeightCalc IS NOT NULL THEN
        SET _VmaxCalcBackward=_VmaxExpBackward*_MolecularWeightCalc*1e-3;
    END IF;

    INSERT INTO EnzymaticReaction
    (WID,ReactionWID,ProteinWID,CompartmentWID,ReactionDirection,RateLawForward,RateLawBackward,KmForward,KmBackward,VmaxExpForward,VmaxExpBackward,VmaxExpUnitForward,VmaxExpUnitBackward,VmaxCalcForward,VmaxCalcBackward,OptimalpH,OptimalTemp,Activators,Inhibitors,DataSetWID)
    VALUES
    (_EnzymaticReactionWID,_WID,_EnzymeWID,_EnzymeCompartmentWID,_Direction,_RateLawForward,_RateLawBackward,_KmForward,_KmBackward,_VmaxExpForward,_VmaxExpBackward,_VmaxExpUnitForward,_VmaxExpUnitBackward,_VmaxCalcForward,_VmaxCalcBackward,_OptimalpH,_OptimalTemp,_Activators,_Inhibitors,_KnowledgeBaseWID);

    #coenzymes
    SET _nIter=(LENGTH(_Coenzymes)-LENGTH(REPLACE(_Coenzymes,';',''))+1);
    SET _idx=1;
    WHILE _idx<=_nIter DO
        CALL parseStoichiometry(_KnowledgeBaseWID, _Coenzymes,';',NULL,NULL,_idx,_ChemicalWID,_CompartmentWID,_Coefficient);

        IF _ChemicalWID IS NOT NULL THEN
            INSERT INTO EnzReactionCofactor(EnzymaticReactionWID,ChemicalWID,CompartmentWID,Prosthetic,Coefficient) VALUES(_EnzymaticReactionWID,_ChemicalWID,_CompartmentWID,'F',_Coefficient);
        END IF;
        SET _idx=_idx+1;
    END WHILE;
END IF;

#pathways
DELETE FROM PathwayReaction WHERE ReactionWID=_WID;
SET _nIter=(LENGTH(_Pathways)-LENGTH(REPLACE(_Pathways,';',''))+1);
SET _idx=1;
WHILE _idx<=_nIter DO
    SET _PathwayXID=SUBSTRING_INDEX(SUBSTRING_INDEX(_Pathways,';',_idx),';',-1);

    SELECT WID INTO _PathwayWID
    FROM Pathway JOIN DBID ON DBID.OtherWID=Pathway.WID
    WHERE DBID.XID=_PathwayXID && Pathway.DataSetWID=_KnowledgeBaseWID;

    IF _PathwayWID IS NOT NULL THEN
        INSERT INTO PathwayReaction(PathwayWID,ReactionWID) VALUES(_PathwayWID,_WID);
    END IF;

    SET _idx=_idx+1;
END WHILE;

CALL set_textsearch(_WID, _Name, 'name');
CALL set_textsearch(_WID, _Module, 'module');
CALL set_textsearch(_WID, _State, 'state');
CALL set_textsearch(_WID, _Type, 'type');
CALL set_textsearch(_WID, _ECNumber, 'EC number');
CALL set_textsearch(_WID, _Enzyme, 'enzyme');
CALL set_textsearch(_WID, _Pathways, 'pathways');
CALL set_textsearch(_WID, _ModificationReactant, 'modification reactants');
CALL set_textsearch(_WID, _Coenzymes, 'coenzymes');
CALL set_textsearch(_WID, _Activators, 'activators');
CALL set_textsearch(_WID, _Inhibitors, 'inhibitors');

IF _SelectWID THEN
    SELECT _WID WID;
END IF;

END $$


DROP PROCEDURE IF EXISTS `delete_reaction` $$
CREATE PROCEDURE `delete_reaction` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

DECLARE _ForeignWID bigint;
DECLARE done INT DEFAULT 0;
DECLARE cur1 CURSOR FOR SELECT WID FROM Illustration WHERE OtherWID=_WID;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

#reaction
DELETE FROM Reaction WHERE WID=_WID;

SET done=0;
OPEN cur1;
REPEAT
    FETCH cur1 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_metabolicmapreaction(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur1;

#reaction
DELETE FROM Reactant WHERE Reactant.ReactionWID=_WID;
DELETE FROM Product WHERE Product.ReactionWID=_WID;
DELETE FROM ModificationReaction WHERE ModificationReaction.ReactionWID=_WID;
DELETE FROM PathwayReaction WHERE PathwayReaction.ReactionWID=_WID;
DELETE FROM ReactionWIDOtherWID WHERE ReactionWIDOtherWID.ReactionWID=_WID;

DELETE EnzymaticReaction, EnzReactionCofactor
FROM EnzymaticReaction
JOIN EnzReactionCofactor ON EnzReactionCofactor.EnzymaticReactionWID=EnzymaticReaction.WID
WHERE EnzymaticReaction.ReactionWID=_WID;

#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `get_reactions` $$
CREATE PROCEDURE `get_reactions` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

CALL get_reactions_bytype(_KnowledgeBaseWID,_WID,NULL,NULL,NULL,true,303);

END $$

DROP PROCEDURE IF EXISTS `get_reactions_bytype` $$
CREATE PROCEDURE `get_reactions_bytype` (IN _KnowledgeBaseWID bigint,IN _WID bigint,IN _Process text,IN _State text, IN _Type text,IN _TypeInclusive boolean, IN _Temperature float)
BEGIN

SET SESSION group_concat_max_len = 65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Reaction.WID, DBID.XID WholeCellModelID,
  Reaction.Name, 
  IF(ReactionWIDOtherWID.`Type`='Process', ModuleDBID.XID, NULL) Process,
  IF(ReactionWIDOtherWID.`Type`='State', ModuleDBID.XID, NULL) State,
  Reaction.Type, Reaction.ECNumber,
  EnzymeDBID.XID Enzyme, EnzymeCompartmentDBID.XID EnzymeCompartment,
  PathwayDBID.XID Pathways,
  Reaction.Spontaneous,
  IF(!(COUNT(DISTINCT Reactant.CompartmentWID)>1 ||
    COUNT(DISTINCT Product.CompartmentWID)>1 ||
    (Reactant.CompartmentWID IS NULL && Product.CompartmentWID IS NULL) ||
    (Reactant.CompartmentWID IS NOT NULL && Product.CompartmentWID IS NOT NULL && Reactant.CompartmentWID!=Product.CompartmentWID)),
		CONCAT(
			'[', IF(ReactantCompartmentDBID.XID IS NOT NULL,ReactantCompartmentDBID.XID,ProductCompartmentDBID.XID),']: ',
			CAST(IF(Reactant.Coefficient IS NOT NULL,GROUP_CONCAT(
			  DISTINCT
			  composeStoichiometry(ReactantDBID.XID,NULL,Reactant.Coefficient)
			  ORDER BY ReactantDBID.XID
			  SEPARATOR ' + '),'') AS CHAR),
			' ',
			IF(Reaction.Direction='R','<==>',IF(Reaction.Direction='B','<==','==>')),
			' ',
			IF(Product.Coefficient IS NOT NULL,GROUP_CONCAT(
			  DISTINCT
			  composeStoichiometry(ProductDBID.XID, NULL, Product.Coefficient)
			  ORDER BY ProductDBID.XID
			  SEPARATOR ' + '),'')
		),
		CONCAT(
			IF(Reactant.Coefficient IS NOT NULL,GROUP_CONCAT(
			  DISTINCT
			  composeStoichiometry(ReactantDBID.XID,ReactantCompartmentDBID.XID,Reactant.Coefficient)
			  ORDER BY ReactantDBID.XID
			  SEPARATOR ' + '),''),
			' ',
			IF(Reaction.Direction='R','<==>',IF(Reaction.Direction='B','<==','==>')),
			' ',
			IF(Product.Coefficient IS NOT NULL,GROUP_CONCAT(
			  DISTINCT
			  composeStoichiometry(ProductDBID.XID, ProductCompartmentDBID.XID, Product.Coefficient)
			  ORDER BY ProductDBID.XID
			  SEPARATOR ' + '),'')
		)
	) Stoichiometry,
  ModificationReactantDBID.XID ModificationReactant, ModificationReactantCompartmentDBID.XID ModificationCompartment, ModificationReaction.Position ModificationPosition,
  Reaction.Direction,Reaction.DeltaGExp,Reaction.DeltaGCalc,Reaction.DeltaGCalc DeltaG, EXP(-Reaction.DeltaGCalc/(1.987/1000*_Temperature)) Keq,
  EnzymaticReaction.RateLawForward,EnzymaticReaction.KmForward,EnzymaticReaction.VmaxExpForward,EnzymaticReaction.VmaxExpUnitForward,EnzymaticReaction.VmaxCalcForward,
  EnzymaticReaction.RateLawBackward,EnzymaticReaction.KmBackward,EnzymaticReaction.VmaxExpBackward,EnzymaticReaction.VmaxExpUnitBackward,EnzymaticReaction.VmaxCalcBackward,
  EnzymaticReaction.OptimalpH,EnzymaticReaction.OptimalTemp,
  GROUP_CONCAT(
    DISTINCT
    composeStoichiometry(CofactorDBID.XID,CofactorCompartmentDBID.XID,EnzReactionCofactor.Coefficient)
    ORDER BY CofactorDBID.XID
    SEPARATOR ';') Coenzymes,
  EnzymaticReaction.Activators,EnzymaticReaction.Inhibitors,
  Reaction.LowerBound,Reaction.UpperBound, BoundUnits.Name BoundUnits

FROM Reaction
JOIN DBID ON DBID.OtherWID=Reaction.WID

#reactants,products
LEFT JOIN Reactant ON Reactant.ReactionWID=Reaction.WID
LEFT JOIN DBID ReactantDBID ON ReactantDBID.OtherWID=Reactant.OtherWID
LEFT JOIN DBID ReactantCompartmentDBID ON ReactantCompartmentDBID.OtherWID=Reactant.CompartmentWID

LEFT JOIN Product ON Product.ReactionWID=Reaction.WID
LEFT JOIN DBID ProductDBID ON ProductDBID.OtherWID=Product.OtherWID
LEFT JOIN DBID ProductCompartmentDBID ON ProductCompartmentDBID.OtherWID=Product.CompartmentWID

#modification
LEFT JOIN ModificationReaction ON ModificationReaction.ReactionWID=Reaction.WID
LEFT JOIN DBID ModificationReactantDBID ON ModificationReactantDBID.OtherWID=ModificationReaction.OtherWID
LEFT JOIN DBID ModificationReactantCompartmentDBID ON ModificationReactantCompartmentDBID.OtherWID=ModificationReaction.CompartmentWID

#process, state
JOIN ReactionWIDOtherWID ON Reaction.WID = ReactionWIDOtherWID.ReactionWID
JOIN DBID ModuleDBID ON ModuleDBID.OtherWID = ReactionWIDOtherWID.OtherWID

#pathways
LEFT JOIN PathwayReaction ON PathwayReaction.ReactionWID=Reaction.WID
LEFT JOIN DBID PathwayDBID ON PathwayDBID.OtherWID=PathwayReaction.PathwayWID

#enzymes
LEFT JOIN EnzymaticReaction ON EnzymaticReaction.ReactionWID=Reaction.WID
LEFT JOIN DBID EnzymeDBID ON EnzymeDBID.OtherWID=EnzymaticReaction.ProteinWID
LEFT JOIN DBID EnzymeCompartmentDBID ON EnzymeCompartmentDBID.OtherWID=EnzymaticReaction.CompartmentWID
LEFT JOIN EnzReactionCofactor ON EnzReactionCofactor.EnzymaticReactionWID=EnzymaticReaction.WID
LEFT JOIN DBID CofactorDBID ON CofactorDBID.OtherWID=EnzReactionCofactor.ChemicalWID
LEFT JOIN DBID CofactorCompartmentDBID ON CofactorCompartmentDBID.OtherWID=EnzReactionCofactor.CompartmentWID

#bound units
LEFT JOIN Term BoundUnits ON BoundUnits.WID=Reaction.BoundUnitsWID

WHERE
  Reaction.DataSetWID=_KnowledgeBaseWID &&
  (_Type IS NULL || ((_TypeInclusive && FIND_IN_SET(Reaction.Type,_Type)) || (!_TypeInclusive && !FIND_IN_SET(Reaction.Type,_Type)))) &&
  (_Process IS NULL || ((_TypeInclusive && FIND_IN_SET(ModuleDBID.XID,_Process)) || (!_TypeInclusive && !FIND_IN_SET(ModuleDBID.XID,_Process)))) &&
  (_State IS NULL || ((_TypeInclusive && FIND_IN_SET(ModuleDBID.XID,_State)) || (!_TypeInclusive && !FIND_IN_SET(ModuleDBID.XID,_State)))) &&
  (_WID IS NULL || Reaction.WID=_WID)
GROUP BY Reaction.WID
ORDER BY DBID.XID;

END $$

DROP PROCEDURE IF EXISTS `get_stimulireactantproducts_reactions` $$
CREATE PROCEDURE `get_stimulireactantproducts_reactions` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @reactionIdx1:=0;
SET @reactionIdx2:=0;
SET @stimulusIdx:=0;
SET @compartmentIdx:=0;

SELECT
  Stimulus.Idx StimulusIdx,
  Stimulus.WID StimulusWID,
  Stimulus.XID Stimulus,
  Reaction.Idx ReactionIdx,
  Reaction.WID ReactionWID,
  Reaction.XID Reaction,
  Compartment.Idx StimulusCompartmentIdx,
  Compartment.WID StimulusCompartmentWID,
  Compartment.XID StimulusCompartment,
  SUM(Reaction.Coefficient) Coefficient
FROM

(SELECT @stimulusIdx:=@stimulusIdx+1 AS Idx,Stimulus.WID, DBID.XID
 FROM Stimulus
 JOIN DBID ON DBID.OtherWID=Stimulus.WID
 WHERE Stimulus.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Stimulus

JOIN
(SELECT Idx,Reactant.OtherWID,-1*Reactant.Coefficient Coefficient, Reactant.CompartmentWID, Reaction.WID, Reaction.XID
 FROM
 (SELECT @reactionIdx1:=@reactionIdx1+1 AS Idx,Reaction.WID, DBID.XID
  FROM Reaction
  JOIN DBID ON DBID.OtherWID=Reaction.WID
  JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
  ORDER BY DBID.XID
 ) AS Reaction
 JOIN Reactant ON Reactant.ReactionWID=Reaction.WID
 WHERE Reactant.Coefficient!=0

 UNION

 SELECT Idx,Product.OtherWID,Product.Coefficient, Product.CompartmentWID, Reaction.WID, Reaction.XID
 FROM
 (SELECT @reactionIdx2:=@reactionIdx2+1 AS Idx,Reaction.WID, DBID.XID
  FROM Reaction
  JOIN DBID ON DBID.OtherWID=Reaction.WID
  JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
  ORDER BY DBID.XID
 ) AS Reaction
 JOIN Product ON Product.ReactionWID=Reaction.WID
 WHERE Product.Coefficient!=0

) AS Reaction ON Reaction.OtherWID=Stimulus.WID

JOIN (SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON Reaction.CompartmentWID=Compartment.WID

WHERE (_WID IS NULL || (Stimulus.WID=_WID || Reaction.WID=_WID || Compartment.WID=_WID))
GROUP BY Stimulus.Idx,Reaction.Idx,Compartment.Idx
ORDER BY Stimulus.Idx,Reaction.Idx,Compartment.Idx;

END $$


DROP PROCEDURE IF EXISTS `get_metabolitereactantproducts_reactions` $$
CREATE PROCEDURE `get_metabolitereactantproducts_reactions` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @reactionIdx1:=0;
SET @reactionIdx2:=0;
SET @metaboliteIdx:=0;
SET @compartmentIdx:=0;

SELECT
  Metabolite.Idx MetaboliteIdx,
  Metabolite.WID MetaboliteWID,
  Metabolite.XID Metabolite,
  Reaction.Idx ReactionIdx,
  Reaction.WID ReactionWID,
  Reaction.XID Reaction,
  Compartment.Idx MetaboliteCompartmentIdx,
  Compartment.WID MetaboliteCompartmentWID,
  Compartment.XID MetaboliteCompartment,
  SUM(Reaction.Coefficient) Coefficient
FROM

(SELECT @metaboliteIdx:=@metaboliteIdx+1 AS Idx,Chemical.WID, DBID.XID
 FROM Chemical
 JOIN DBID ON DBID.OtherWID=Chemical.WID
 WHERE Chemical.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Metabolite

JOIN
(SELECT Idx,Reactant.OtherWID,-1*Reactant.Coefficient Coefficient, Reactant.CompartmentWID, Reaction.WID, Reaction.XID
 FROM
 (SELECT @reactionIdx1:=@reactionIdx1+1 AS Idx,Reaction.WID, DBID.XID
  FROM Reaction
  JOIN DBID ON DBID.OtherWID=Reaction.WID
  JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
  ORDER BY DBID.XID
 ) AS Reaction
 JOIN Reactant ON Reactant.ReactionWID=Reaction.WID
 WHERE Reactant.Coefficient!=0

 UNION

 SELECT Idx,Product.OtherWID,Product.Coefficient, Product.CompartmentWID, Reaction.WID, Reaction.XID
 FROM
 (SELECT @reactionIdx2:=@reactionIdx2+1 AS Idx,Reaction.WID, DBID.XID
  FROM Reaction
  JOIN DBID ON DBID.OtherWID=Reaction.WID
  JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
  ORDER BY DBID.XID
 ) AS Reaction
 JOIN Product ON Product.ReactionWID=Reaction.WID
 WHERE Product.Coefficient!=0

) AS Reaction ON Reaction.OtherWID=Metabolite.WID

JOIN (SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON Reaction.CompartmentWID=Compartment.WID

WHERE (_WID IS NULL || (Metabolite.WID=_WID || Reaction.WID=_WID || Compartment.WID=_WID))
GROUP BY Metabolite.Idx,Reaction.Idx,Compartment.Idx
ORDER BY Metabolite.Idx,Reaction.Idx,Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_transcriptionunitreactantproducts_reactions` $$
CREATE PROCEDURE `get_transcriptionunitreactantproducts_reactions` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @reactionIdx1:=0;
SET @reactionIdx2:=0;
SET @transcriptionUnitIdx:=0;
SET @compartmentIdx:=0;

SELECT
  TranscriptionUnit.Idx TranscriptionUnitIdx,
  TranscriptionUnit.WID TranscriptionUnitWID,
  TranscriptionUnit.XID TranscriptionUnit,
  Reaction.Idx ReactionIdx,
  Reaction.WID ReactionWID,
  Reaction.XID Reaction,
  Compartment.Idx CompartmentIdx,
  Compartment.WID CompartmentWID,
  Compartment.XID Compartment,
  Reaction.Coefficient
FROM (SELECT @transcriptionUnitIdx:=@transcriptionUnitIdx+1 AS Idx, TranscriptionUnitComponent.TranscriptionUnitWID WID, DBID.XID
  FROM TranscriptionUnitComponent
  JOIN Gene ON Gene.WID=TranscriptionUnitComponent.OtherWID
  JOIN DBID ON DBID.OtherWID=TranscriptionUnitComponent.TranscriptionUnitWID
  WHERE Gene.DataSetWID=_KnowledgeBaseWID
  GROUP BY TranscriptionUnitComponent.TranscriptionUnitWID
  ORDER BY MIN(Gene.CodingRegionStart)
) AS TranscriptionUnit

JOIN
(SELECT Idx,Reactant.OtherWID,-1*Reactant.Coefficient Coefficient, Reactant.CompartmentWID,Reaction.WID, Reaction.XID
 FROM
 (SELECT @reactionIdx1:=@reactionIdx1+1 AS Idx,Reaction.WID, DBID.XID
  FROM Reaction
  JOIN DBID ON DBID.OtherWID=Reaction.WID
  JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
  ORDER BY DBID.XID
 ) AS Reaction
 JOIN Reactant ON Reactant.ReactionWID=Reaction.WID
 WHERE Reactant.Coefficient!=0

 UNION

 SELECT Idx,Product.OtherWID,Product.Coefficient, Product.CompartmentWID,Reaction.WID, Reaction.XID
 FROM
 (SELECT @reactionIdx2:=@reactionIdx2+1 AS Idx,Reaction.WID, DBID.XID
  FROM Reaction
  JOIN DBID ON DBID.OtherWID=Reaction.WID
  JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
  ORDER BY DBID.XID
 ) AS Reaction
 JOIN Product ON Product.ReactionWID=Reaction.WID
 WHERE Product.Coefficient!=0

) AS Reaction ON Reaction.OtherWID=TranscriptionUnit.WID

JOIN (SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON Reaction.CompartmentWID=Compartment.WID

WHERE (_WID IS NULL || (TranscriptionUnit.WID=_WID || Reaction.WID=_WID || Compartment.WID=_WID))
GROUP BY TranscriptionUnit.Idx, Reaction.Idx, Compartment.Idx
ORDER BY TranscriptionUnit.Idx, Reaction.Idx, Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteinmonomerreactantproducts_reactions` $$
CREATE PROCEDURE `get_proteinmonomerreactantproducts_reactions` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @reactionIdx1:=0;
SET @reactionIdx2:=0;
SET @monomerIdx:=0;
SET @compartmentIdx:=0;

SELECT
  Monomer.Idx MonomerIdx,
  Monomer.WID MonomerWID,
  Monomer.XID Monomer,
  Reaction.Idx ReactionIdx,
  Reaction.WID ReactionWID,
  Reaction.XID Reaction,
  Compartment.Idx CompartmentIdx,
  Compartment.WID CompartmentWID,
  Compartment.XID Compartment,
  Reaction.Coefficient
FROM (
  SELECT @monomerIdx:=@monomerIdx+1 AS Idx, Protein.WID, DBID.XID
  FROM GeneWIDProteinWID
  JOIN Protein ON GeneWIDProteinWID.ProteinWID=Protein.WID
  JOIN Gene ON GeneWIDProteinWID.GeneWID=Gene.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY MIN(Gene.CodingRegionStart)
) AS Monomer

JOIN
(SELECT Idx,Reactant.OtherWID,-1*Reactant.Coefficient Coefficient, Reactant.CompartmentWID,Reaction.WID, Reaction.XID
 FROM
 (SELECT @reactionIdx1:=@reactionIdx1+1 AS Idx,Reaction.WID, DBID.XID
  FROM Reaction
  JOIN DBID ON DBID.OtherWID=Reaction.WID
  JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
  ORDER BY DBID.XID
 ) AS Reaction
 JOIN Reactant ON Reactant.ReactionWID=Reaction.WID
 WHERE Reactant.Coefficient!=0

 UNION

 SELECT Idx,Product.OtherWID,Product.Coefficient, Product.CompartmentWID,Reaction.WID, Reaction.XID
 FROM
 (SELECT @reactionIdx2:=@reactionIdx2+1 AS Idx,Reaction.WID, DBID.XID
  FROM Reaction
  JOIN DBID ON DBID.OtherWID=Reaction.WID
  JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
  ORDER BY DBID.XID
 ) AS Reaction
 JOIN Product ON Product.ReactionWID=Reaction.WID
 WHERE Product.Coefficient!=0

) AS Reaction ON Reaction.OtherWID=Monomer.WID

JOIN (SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON Reaction.CompartmentWID=Compartment.WID

WHERE (_WID IS NULL || (Monomer.WID=_WID || Reaction.WID=_WID || Compartment.WID=_WID))
GROUP BY Monomer.Idx, Reaction.Idx, Compartment.Idx
ORDER BY Monomer.Idx, Reaction.Idx, Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteincomplexreactantproducts_reactions` $$
CREATE PROCEDURE `get_proteincomplexreactantproducts_reactions` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @reactionIdx1:=0;
SET @reactionIdx2:=0;
SET @complexIdx:=0;
SET @compartmentIdx:=0;

SELECT
  Complex.Idx ComplexIdx,
  Complex.WID ComplexWID,
  Complex.XID Complex,
  Reaction.Idx ReactionIdx,
  Reaction.WID ReactionWID,
  Reaction.XID Reaction,
  Compartment.Idx CompartmentIdx,
  Compartment.WID CompartmentWID,
  Compartment.XID Compartment,
  Reaction.Coefficient
FROM (SELECT @complexIdx:=@complexIdx+1 AS Idx, Protein.WID, DBID.XID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS Complex

JOIN
(SELECT Idx,Reactant.OtherWID,-1*Reactant.Coefficient Coefficient, Reactant.CompartmentWID,Reaction.WID, Reaction.XID
 FROM
 (SELECT @reactionIdx1:=@reactionIdx1+1 AS Idx,Reaction.WID, DBID.XID
  FROM Reaction
  JOIN DBID ON DBID.OtherWID=Reaction.WID
  JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
  ORDER BY DBID.XID
 ) AS Reaction
 JOIN Reactant ON Reactant.ReactionWID=Reaction.WID
 WHERE Reactant.Coefficient!=0

 UNION

 SELECT Idx,Product.OtherWID,Product.Coefficient, Product.CompartmentWID,Reaction.WID, Reaction.XID
 FROM
 (SELECT @reactionIdx2:=@reactionIdx2+1 AS Idx,Reaction.WID, DBID.XID
  FROM Reaction
  JOIN DBID ON DBID.OtherWID=Reaction.WID
  JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
  ORDER BY DBID.XID
 ) AS Reaction
 JOIN Product ON Product.ReactionWID=Reaction.WID
 WHERE Product.Coefficient!=0

) AS Reaction ON Reaction.OtherWID=Complex.WID

JOIN (SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON Reaction.CompartmentWID=Compartment.WID

WHERE (_WID IS NULL || (Complex.WID=_WID || Reaction.WID=_WID || Compartment.WID=_WID))
GROUP BY Complex.Idx, Reaction.Idx, Compartment.Idx
ORDER BY Complex.Idx, Reaction.Idx, Compartment.Idx;

END $$


DROP PROCEDURE IF EXISTS `get_proteinmonomers_reactions` $$
CREATE PROCEDURE `get_proteinmonomers_reactions` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinMonomerIdx:=0;
SET @reactionIdx:=0;
SET @compartmentIdx:=0;

SELECT
  ProteinMonomer.Idx ProteinMonomerIdx,
  ProteinMonomer.WID ProteinMonomerWID,
  ProteinMonomer.XID ProteinMonomer,
  Reaction.Idx ReactionIdx,
  Reaction.WID ReactionWID,
  Reaction.XID Reaction,
  Compartment.Idx ProteinMonomerCompartmentIdx,
  Compartment.WID ProteinMonomerCompartmentWID,
  Compartment.XID ProteinMonomerCompartment
FROM

(SELECT @proteinMonomerIdx:=@proteinMonomerIdx+1 AS Idx,GeneWIDProteinWID.ProteinWID WID, DBID.XID
 FROM Gene
 JOIN GeneWIDProteinWID ON GeneWIDProteinWID.GeneWID=Gene.WID
 JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS ProteinMonomer

JOIN EnzymaticReaction ON EnzymaticReaction.ProteinWID=ProteinMonomer.WID

JOIN (SELECT @reactionIdx:=@reactionIdx+1 AS Idx,Reaction.WID, DBID.XID
 FROM Reaction
 JOIN DBID ON DBID.OtherWID=Reaction.WID
 JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
 ORDER BY DBID.XID
) AS Reaction ON EnzymaticReaction.ReactionWID=Reaction.WID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON Compartment.WID=EnzymaticReaction.CompartmentWID

WHERE (_WID IS NULL || (ProteinMonomer.WID=_WID || Reaction.WID=_WID || Compartment.WID=_WID))
GROUP BY ProteinMonomer.Idx,Reaction.Idx,Compartment.Idx
ORDER BY ProteinMonomer.Idx,Reaction.Idx,Compartment.Idx;

END $$


DROP PROCEDURE IF EXISTS `get_proteincomplexs_reactions` $$
CREATE PROCEDURE `get_proteincomplexs_reactions` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinComplexIdx:=0;
SET @reactionIdx:=0;
SET @compartmentIdx:=0;

SELECT
  ProteinComplex.Idx ProteinComplexIdx,
  ProteinComplex.WID ProteinComplexWID,
  ProteinComplex.XID ProteinComplex,
  Reaction.Idx ReactionIdx,
  Reaction.WID ReactionWID,
  Reaction.XID Reaction,
  Compartment.Idx ProteinComplexCompartmentIdx,
  Compartment.WID ProteinComplexCompartmentWID,
  Compartment.XID ProteinComplexCompartment
FROM

(SELECT @proteinComplexIdx:=@proteinComplexIdx+1 AS Idx,Protein.WID, DBID.XID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS ProteinComplex

JOIN EnzymaticReaction ON EnzymaticReaction.ProteinWID=ProteinComplex.WID

JOIN (SELECT @reactionIdx:=@reactionIdx+1 AS Idx,Reaction.WID, DBID.XID
 FROM Reaction
 JOIN DBID ON DBID.OtherWID=Reaction.WID
 JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
 ORDER BY DBID.XID
) AS Reaction ON EnzymaticReaction.ReactionWID=Reaction.WID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON Compartment.WID=EnzymaticReaction.CompartmentWID

WHERE (_WID IS NULL || (ProteinComplex.WID=_WID || Reaction.WID=_WID || Compartment.WID=_WID))
GROUP BY ProteinComplex.Idx,Reaction.Idx,Compartment.Idx
ORDER BY ProteinComplex.Idx,Reaction.Idx,Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_reactions_coenzymes` $$
CREATE PROCEDURE `get_reactions_coenzymes` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @reactionIdx:=0;
SET @metaboliteIdx:=0;
SET @compartmentIdx:=0;

SELECT
  Coenzyme.Idx MetaboliteIdx,
  Coenzyme.WID MetaboliteWID,
  Coenzyme.XID Metabolite,
  Reaction.Idx ReactionIdx,
  Reaction.WID ReactionWID,
  Reaction.XID Reaction,
  Compartment.Idx MetaboliteCompartmentIdx,
  Compartment.WID MetaboliteCompartmentWID,
  Compartment.XID MetaboliteCompartment,
  EnzReactionCofactor.Coefficient
FROM

(SELECT @metaboliteIdx:=@metaboliteIdx+1 AS Idx,Chemical.WID, DBID.XID
 FROM Chemical
 JOIN DBID ON DBID.OtherWID=Chemical.WID
 WHERE Chemical.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Coenzyme

JOIN EnzReactionCofactor ON EnzReactionCofactor.ChemicalWID=Coenzyme.WID
JOIN EnzymaticReaction ON EnzymaticReaction.WID=EnzReactionCofactor.EnzymaticReactionWID

JOIN (
  SELECT @reactionIdx:=@reactionIdx+1 AS Idx,Reaction.WID, DBID.XID
  FROM Reaction
  JOIN DBID ON DBID.OtherWID=Reaction.WID
  JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
  ORDER BY DBID.XID
) AS Reaction ON EnzymaticReaction.ReactionWID=Reaction.WID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON EnzReactionCofactor.CompartmentWID=Compartment.WID

WHERE EnzReactionCofactor.Prosthetic='F' && (_WID IS NULL || (Coenzyme.WID=_WID || Reaction.WID=_WID || Compartment.WID=_WID))
GROUP BY Coenzyme.Idx,Reaction.Idx,Compartment.Idx
ORDER BY Coenzyme.Idx,Reaction.Idx,Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_reactions_stablernamodifications` $$
CREATE PROCEDURE `get_reactions_stablernamodifications` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @reactionIdx:=0;
SET @geneIdx:=0;
SET @compartmentIdx:=0;

SELECT
  Gene.Idx GeneIdx,
  Gene.WID GeneWID,
  Gene.XID Gene,
  Reaction.Idx ReactionIdx,
  Reaction.WID ReactionWID,
  Reaction.XID Reaction,
  Compartment.Idx GeneCompartmentIdx,
  Compartment.WID GeneCompartmentWID,
  Compartment.XID GeneCompartment,
  ModificationReaction.Position
FROM

(SELECT @geneIdx:=@geneIdx+1 AS Idx,Gene.WID, DBID.XID
  FROM Gene
  JOIN DBID ON DBID.OtherWID=Gene.WID
  WHERE Gene.DataSetWID=_KnowledgeBaseWID
  ORDER BY Gene.CodingRegionStart
) AS Gene

JOIN ModificationReaction ON ModificationReaction.OtherWID=Gene.WID

JOIN (
  SELECT @reactionIdx:=@reactionIdx+1 AS Idx, Reaction.WID, Reaction.Type, DBID.XID
  FROM Reaction
  JOIN DBID ON DBID.OtherWID=Reaction.WID
  JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
  ORDER BY DBID.XID
) AS Reaction ON ModificationReaction.ReactionWID=Reaction.WID

JOIN (
  SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx, Compartment.WID, DBID.XID
  FROM Compartment
  JOIN DBID ON DBID.OtherWID=Compartment.WID
  WHERE Compartment.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Compartment ON ModificationReaction.CompartmentWID=Compartment.WID

WHERE _WID IS NULL || (Gene.WID=_WID || Reaction.WID=_WID || Compartment.WID=_WID)
GROUP BY Gene.Idx,Reaction.Idx,Compartment.Idx
ORDER BY Gene.Idx,Reaction.Idx,Compartment.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_reactions_stableproteinmonomermodifications` $$
CREATE PROCEDURE `get_reactions_stableproteinmonomermodifications` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @reactionIdx:=0;
SET @proteinMonomerIdx:=0;
SET @compartmentIdx:=0;

SELECT
  ProteinMonomer.Idx ProteinMonomerIdx,
  ProteinMonomer.WID ProteinMonomerWID,
  ProteinMonomer.XID ProteinMonomer,
  Reaction.Idx ReactionIdx,
  Reaction.WID ReactionWID,
  Reaction.XID Reaction,
  Compartment.Idx ProteinMonomerCompartmentIdx,
  Compartment.WID ProteinMonomerCompartmentWID,
  Compartment.XID ProteinMonomerCompartment,
  ModificationReaction.Position
FROM

(SELECT @proteinMonomerIdx:=@proteinMonomerIdx+1 AS Idx, GeneWIDProteinWID.ProteinWID WID, DBID.XID
  FROM GeneWIDProteinWID
  JOIN Gene ON GeneWIDProteinWID.GeneWID=Gene.WID
  JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
  WHERE Gene.DataSetWID=_KnowledgeBaseWID
  ORDER BY Gene.CodingRegionStart
) AS ProteinMonomer

JOIN ModificationReaction ON ModificationReaction.OtherWID=ProteinMonomer.WID

JOIN (
  SELECT @reactionIdx:=@reactionIdx+1 AS Idx, Reaction.WID, Reaction.Type, DBID.XID
  FROM Reaction
  JOIN DBID ON DBID.OtherWID=Reaction.WID
  JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
  ORDER BY DBID.XID
) AS Reaction ON ModificationReaction.ReactionWID=Reaction.WID

JOIN (
  SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
  FROM Compartment
  JOIN DBID ON DBID.OtherWID=Compartment.WID
  WHERE Compartment.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Compartment ON ModificationReaction.CompartmentWID=Compartment.WID

WHERE _WID IS NULL || (ProteinMonomer.WID=_WID || Reaction.WID=_WID || Compartment.WID=_WID)
GROUP BY ProteinMonomer.Idx,Reaction.Idx,Compartment.Idx
ORDER BY ProteinMonomer.Idx,Reaction.Idx,Compartment.Idx;

END $$


DROP PROCEDURE IF EXISTS `get_reactions_processs` $$
CREATE PROCEDURE `get_reactions_processs` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @reactionIdx:=0;
SET @processIdx:=0;

SELECT
  Process.Idx ProcessIdx,
  Process.WID ProcessWID,
  Process.XID Process,
  Reaction.Idx ReactionIdx,
  Reaction.WID ReactionWID,
  Reaction.XID Reaction
FROM

(SELECT @processIdx:=@processIdx+1 AS Idx, Process.WID, DBID.XID
  FROM Process
  JOIN DBID ON DBID.OtherWID=Process.WID
  WHERE Process.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Process

JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.OtherWID=Process.WID

JOIN (
  SELECT @reactionIdx:=@reactionIdx+1 AS Idx,Reaction.WID, DBID.XID
  FROM Reaction
  JOIN DBID ON DBID.OtherWID=Reaction.WID
  JOIN ReactionWIDOtherWID ON Reaction.WID=ReactionWIDOtherWID.ReactionWID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
  ORDER BY DBID.XID
) AS Reaction ON ReactionWIDOtherWID.ReactionWID = Reaction.WID

WHERE _WID IS NULL || (Process.WID=_WID || Reaction.WID=_WID) && ReactionWIDOtherWID.`Type`='Process'
GROUP BY Process.Idx,Reaction.Idx
ORDER BY Process.Idx,Reaction.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_reactions_states` $$
CREATE PROCEDURE `get_reactions_states` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @reactionIdx:=0;
SET @stateIdx:=0;

SELECT
  State.Idx StateIdx,
  State.WID StateWID,
  State.XID State,
  Reaction.Idx ReactionIdx,
  Reaction.WID ReactionWID,
  Reaction.XID Reaction
FROM

(SELECT @stateIdx:=@stateIdx+1 AS Idx, State.WID, DBID.XID
  FROM State
  JOIN DBID ON DBID.OtherWID=State.WID
  WHERE State.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS State

JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.OtherWID=State.WID

JOIN (
  SELECT @reactionIdx:=@reactionIdx+1 AS Idx,Reaction.WID, DBID.XID
  FROM Reaction
  JOIN DBID ON DBID.OtherWID=Reaction.WID
  JOIN ReactionWIDOtherWID ON Reaction.WID=ReactionWIDOtherWID.ReactionWID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
  ORDER BY DBID.XID
) AS Reaction ON ReactionWIDOtherWID.ReactionWID = Reaction.WID

WHERE _WID IS NULL || (State.WID=_WID || Reaction.WID=_WID) && ReactionWIDOtherWID.`Type`='State'
GROUP BY State.Idx,Reaction.Idx
ORDER BY State.Idx,Reaction.Idx;

END $$

-- ---------------------------------------------------------
-- transcriptional regulation
-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS `set_transcriptionalregulation` $$
CREATE PROCEDURE `set_transcriptionalregulation` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _TranscriptionUnit varchar(255), IN _TranscriptionFactor varchar(255), IN _TranscriptionFactorCompartment varchar(255),
  IN _BindingSiteCoordinate int, IN _BindingSiteLength int, IN _BindingSiteDirection ENUM('forward','reverse'),
  IN _Affinity float, IN _Activity float, IN _Element varchar(255), IN _Condition varchar(255))
BEGIN

DECLARE _TranscriptionalRegulationWID bigint;
DECLARE _TranscriptionFactorWID bigint;
DECLARE _TranscriptionUnitWID bigint;
DECLARE _TranscriptionFactorCompartmentWID bigint;
DECLARE _GenomeWID bigint;
DECLARE _TranscriptionFactorBindingSiteWID bigint;

#transcription factor, unit, genome
SELECT Protein.WID INTO _TranscriptionFactorWID
FROM Protein
JOIN DBID ON DBID.OtherWID=Protein.WID
WHERE Protein.DataSetWID=_KnowledgeBaseWID && DBID.XID=_TranscriptionFactor;

SELECT TranscriptionUnit.WID INTO _TranscriptionUnitWID
FROM TranscriptionUnit
JOIN DBID ON DBID.OtherWID=TranscriptionUnit.WID
WHERE TranscriptionUnit.DataSetWID=_KnowledgeBaseWID && DBID.XID=_TranscriptionUnit;

SELECT Compartment.WID INTO _TranscriptionFactorCompartmentWID
FROM Compartment
JOIN DBID ON DBID.OtherWID=Compartment.WID
WHERE Compartment.DataSetWID=_KnowledgeBaseWID && DBID.XID=_TranscriptionFactorCompartment;

SELECT NucleicAcid.WID INTO _GenomeWID
FROM NucleicAcid
WHERE NucleicAcid.DataSetWID=_KnowledgeBaseWID;

#interaction
SELECT WID INTO _TranscriptionalRegulationWID FROM Interaction WHERE WID=_WID;
IF _TranscriptionalRegulationWID IS NULL THEN
	INSERT INTO Interaction(WID, Type, Affinity, Activity, Element, `Condition`, DataSetWID)
	VALUES(_WID, 'transcriptional regulation', _Affinity, _Activity, _Element, _Condition, _KnowledgeBaseWID);
	
	INSERT INTO InteractionParticipant (InteractionWID, OtherWID, CompartmentWID, Role) 
	VALUES(_WID, _TranscriptionFactorWID, _TranscriptionFactorCompartmentWID, 'transcription factor');

	INSERT INTO InteractionParticipant(InteractionWID, OtherWID, Role)
	VALUES(_WID, _TranscriptionUnitWID, 'transcription unit');
ELSE
	UPDATE Interaction
	SET
		Type='transcriptional regulation',
		Affinity=_Affinity,
		Activity=_Activity,
		Element=_Element,
		`Condition`=_Condition
	WHERE WID=_WID;
	
	UPDATE InteractionParticipant
	SET OtherWID=_TranscriptionFactorWID, CompartmentWID=_TranscriptionFactorCompartmentWID
	WHERE InteractionWID = _WID && Role = 'transcription factor';

	UPDATE InteractionParticipant
	SET OtherWID = _TranscriptionUnitWID
	WHERE InteractionWID=_WID && Role='transcription unit';
END IF;

#binding site
SELECT OtherWID INTO _TranscriptionFactorBindingSiteWID
FROM InteractionParticipant
WHERE InteractionWID=_WID && Role='transcription factor binding site';

IF _TranscriptionFactorBindingSiteWID IS NOT NULL THEN
	DELETE FROM Entry WHERE OtherWID = _TranscriptionFactorBindingSiteWID;
	DELETE FROM Feature WHERE WID = _TranscriptionFactorBindingSiteWID;
	DELETE FROM InteractionParticipant WHERE OtherWID = _TranscriptionFactorBindingSiteWID;
END IF;

CALL set_entry('F', _KnowledgeBaseWID, _TranscriptionFactorBindingSiteWID, NULL);
INSERT INTO Feature(WID, Class, SequenceType, SequenceWID, RegionOrPoint, StartPosition, EndPosition, Direction, DataSetWID)
VALUES(_TranscriptionFactorBindingSiteWID, 'binding site', 'N', _GenomeWID, 'region',
	_BindingSiteCoordinate, _BindingSiteCoordinate + _BindingSiteLength - 1, _BindingSiteDirection,
	_KnowledgeBaseWID);

INSERT INTO InteractionParticipant(InteractionWID, OtherWID, Role)
VALUES (_WID, _TranscriptionFactorBindingSiteWID, 'transcription factor binding site');

#text search
CALL set_textsearch(_WID, _TranscriptionUnit, 'transcription unit');
CALL set_textsearch(_WID, _TranscriptionFactor, 'transcription factor');
CALL set_textsearch(_WID, _Element, 'element');
CALL set_textsearch(_WID, _Condition, 'condition');

CALL set_textsearch(_TranscriptionFactorWID, _TranscriptionUnit, 'transcription unit');
CALL set_textsearch(_TranscriptionUnitWID, _TranscriptionFactor, 'transcription factor');
CALL set_textsearch(_TranscriptionFactorWID, _Element, 'element');
CALL set_textsearch(_TranscriptionFactorWID, _Condition, 'condition');
CALL set_textsearch(_TranscriptionUnitWID, _Element, 'element');
CALL set_textsearch(_TranscriptionUnitWID, _Condition, 'condition');

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_transcriptionalregulation` $$
CREATE PROCEDURE `delete_transcriptionalregulation` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

DECLARE _TranscriptionFactorBindingSiteWID bigint;

#transcription factor binding site
SELECT OtherWID INTO _TranscriptionFactorBindingSiteWID
FROM InteractionParticipant
WHERE InteractionWID = _WID && Role ='transcription factor binding site';
IF _TranscriptionFactorBindingSiteWID IS NOT NULL THEN
	CALL delete_entry(_TranscriptionFactorBindingSiteWID);
END IF;

#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `get_transcriptionalregulations` $$
CREATE PROCEDURE `get_transcriptionalregulations` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Interaction.WID,
  DBID.XID WholeCellModelID,
  CONCAT_WS(' - ',TranscriptionFactorDBID.XID,TranscriptionUnitDBID.XID) Name,
  TranscriptionUnitDBID.XID TranscriptionUnit,
  GROUP_CONCAT(
      DISTINCT composeStoichiometry(GeneDBID.XID, GeneCompartmentDBID.XID, 1)
      ORDER BY Gene.CodingRegionStart
      SEPARATOR ';') Genes,
  TranscriptionFactorDBID.XID TranscriptionFactor,
  TranscriptionFactorCompartmentDBID.XID TranscriptionFactorCompartment,
  Feature.StartPosition BindingSiteCoordinate, 
  Feature.EndPosition - Feature.StartPosition + 1 BindingSiteLength, 
  Feature.Direction BindingSiteDirection,
  dnaSequenceReverseComplement(MID(NucleicAcid.Sequence, Feature.StartPosition, Feature.EndPosition-Feature.StartPosition+1),Feature.Direction) BindingSiteSequence,
  Interaction.Affinity,Interaction.Activity,Interaction.Element,Interaction.`Condition`

FROM Interaction
JOIN DBID ON DBID.OtherWID=Interaction.WID

#transcription unit
JOIN InteractionParticipant TranscriptionUnit ON Interaction.WID=TranscriptionUnit.InteractionWID
JOIN DBID TranscriptionUnitDBID ON TranscriptionUnit.OtherWID=TranscriptionUnitDBID.OtherWID

#genes
LEFT JOIN TranscriptionUnitComponent ON TranscriptionUnitComponent.TranscriptionUnitWID=TranscriptionUnit.OtherWID
LEFT JOIN Gene ON Gene.WID=TranscriptionUnitComponent.OtherWID
LEFT JOIN DBID GeneDBID ON GeneDBID.OtherWID=Gene.WID
LEFT JOIN DBID GeneCompartmentDBID ON GeneCompartmentDBID.OtherWID=TranscriptionUnitComponent.CompartmentWID

#transcriptional factor
JOIN InteractionParticipant TranscriptionFactor ON Interaction.WID=TranscriptionFactor.InteractionWID
JOIN DBID TranscriptionFactorDBID ON TranscriptionFactor.OtherWID=TranscriptionFactorDBID.OtherWID
JOIN DBID TranscriptionFactorCompartmentDBID ON TranscriptionFactor.CompartmentWID=TranscriptionFactorCompartmentDBID.OtherWID

#transcription factor binding site
LEFT JOIN (SELECT * FROM InteractionParticipant WHERE Role='transcription factor binding site')
  AS TranscriptionFactorBindingSite ON Interaction.WID=TranscriptionFactorBindingSite.InteractionWID
LEFT JOIN Feature ON Feature.WID=TranscriptionFactorBindingSite.OtherWID
LEFT JOIN NucleicAcid ON Feature.SequenceWID = NucleicAcid.WID

WHERE
  Interaction.DataSetWID=_KnowledgeBaseWID &&
  Interaction.Type='transcriptional regulation' &&
  TranscriptionUnit.Role='transcription unit' &&
  TranscriptionFactor.Role='transcription factor' &&
  (_WID IS NULL || Interaction.WID=_WID)
GROUP BY Interaction.WID
ORDER BY DBID.XID;

END $$

DROP PROCEDURE IF EXISTS `get_transcriptionunits_transcriptionfactorproteinmonomers` $$
CREATE PROCEDURE `get_transcriptionunits_transcriptionfactorproteinmonomers` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @transcriptionUnitIdx:=0;
SET @proteinMonomerIdx:=0;
SET @compartmentIdx:=0;

SELECT
  TranscriptionUnit.Idx TranscriptionUnitIdx,
  TranscriptionUnit.WID TranscriptionUnitWID,
  TranscriptionUnit.XID TranscriptionUnit,
  ProteinMonomer.Idx ProteinMonomerIdx,
  ProteinMonomer.WID ProteinMonomerWID,
  ProteinMonomer.XID ProteinMonomer,
  ProteinMonomerCompartment.Idx ProteinMonomerCompartmentIdx,
  ProteinMonomerCompartment.WID ProteinMonomerCompartmentWID,
  ProteinMonomerCompartment.XID ProteinMonomerCompartment,
  Feature.StartPosition BindingSiteStartCoordinate, Feature.EndPosition-Feature.StartPosition+1 BindingSiteLength, IF(Feature.Direction='forward',1,0) BindingSiteDirection, 
  Interaction.Affinity, Interaction.Activity, Interaction.`Condition`
FROM

(SELECT @transcriptionUnitIdx:=@transcriptionUnitIdx+1 AS Idx,TranscriptionUnit.WID, DBID.XID
 FROM TranscriptionUnit
 JOIN TranscriptionUnitComponent ON TranscriptionUnit.WID=TranscriptionUnitComponent.TranscriptionUnitWID
 JOIN Gene ON TranscriptionUnitComponent.OtherWID=Gene.WID
 JOIN DBID ON TranscriptionUnit.WID=DBID.OtherWID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 GROUP BY TranscriptionUnit.WID
 ORDER BY Gene.CodingRegionStart
) AS TranscriptionUnit

JOIN InteractionParticipant InteractionTranscriptionUnit ON InteractionTranscriptionUnit.OtherWID=TranscriptionUnit.WID
JOIN Interaction ON Interaction.WID=InteractionTranscriptionUnit.InteractionWID
JOIN InteractionParticipant InteractionTranscriptionFactor ON InteractionTranscriptionFactor.InteractionWID=Interaction.WID

#transcription factor binding site
LEFT JOIN (SELECT * FROM InteractionParticipant WHERE Role='transcription factor binding site')
  AS TranscriptionFactorBindingSite ON Interaction.WID=TranscriptionFactorBindingSite.InteractionWID
LEFT JOIN Feature ON Feature.WID=TranscriptionFactorBindingSite.OtherWID

JOIN (SELECT @proteinMonomerIdx:=@proteinMonomerIdx+1 AS Idx,GeneWIDProteinWID.ProteinWID WID, DBID.XID
 FROM Gene
 JOIN GeneWIDProteinWID ON GeneWIDProteinWID.GeneWID=Gene.WID
 JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS ProteinMonomer ON ProteinMonomer.WID=InteractionTranscriptionFactor.OtherWID

JOIN
(SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
  FROM Compartment
  JOIN DBID ON DBID.OtherWID=Compartment.WID
  WHERE Compartment.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS ProteinMonomerCompartment
ON InteractionTranscriptionFactor.CompartmentWID=ProteinMonomerCompartment.WID

WHERE
  InteractionTranscriptionUnit.Role='transcription unit' &&
  InteractionTranscriptionFactor.Role='transcription factor' &&
  (_WID IS NULL || (TranscriptionUnit.WID=_WID || ProteinMonomer.WID=_WID || ProteinMonomerCompartment.WID=_WID))
GROUP BY TranscriptionUnit.Idx, ProteinMonomer.Idx, ProteinMonomerCompartment.Idx
ORDER BY TranscriptionUnit.Idx, ProteinMonomer.Idx, ProteinMonomerCompartment.Idx;

END $$


DROP PROCEDURE IF EXISTS `get_transcriptionunits_transcriptionfactorproteincomplexs` $$
CREATE PROCEDURE `get_transcriptionunits_transcriptionfactorproteincomplexs` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @transcriptionUnitIdx:=0;
SET @proteinComplexIdx:=0;
SET @compartmentIdx:=0;

SELECT
  TranscriptionUnit.Idx TranscriptionUnitIdx,
  TranscriptionUnit.WID TranscriptionUnitWID,
  TranscriptionUnit.XID TranscriptinUnit,
  ProteinComplex.Idx ProteinComplexIdx,
  ProteinComplex.WID ProteinComplexWID,
  ProteinComplex.XID ProteinComplex,
  ProteinComplexCompartment.Idx ProteinComplexCompartmentIdx,
  ProteinComplexCompartment.WID ProteinComplexCompartmentWID,
  ProteinComplexCompartment.XID ProteinComlpexCompartment,
  Feature.StartPosition BindingSiteStartCoordinate, Feature.EndPosition-Feature.StartPosition+1 BindingSiteLength, IF(Feature.Direction='forward',1,0) BindingSiteDirection, 
  Interaction.Affinity, Interaction.Activity, Interaction.Condition
FROM

(SELECT @transcriptionUnitIdx:=@transcriptionUnitIdx+1 AS Idx,TranscriptionUnit.WID, DBID.XID
 FROM TranscriptionUnit
 JOIN TranscriptionUnitComponent ON TranscriptionUnit.WID=TranscriptionUnitComponent.TranscriptionUnitWID
 JOIN Gene ON TranscriptionUnitComponent.OtherWID=Gene.WID
 JOIN DBID ON TranscriptionUnit.WID=DBID.OtherWID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 GROUP BY TranscriptionUnit.WID
 ORDER BY Gene.CodingRegionStart
) AS TranscriptionUnit

JOIN InteractionParticipant InteractionTranscriptionUnit ON InteractionTranscriptionUnit.OtherWID=TranscriptionUnit.WID
JOIN Interaction ON Interaction.WID=InteractionTranscriptionUnit.InteractionWID
JOIN InteractionParticipant InteractionTranscriptionFactor ON InteractionTranscriptionFactor.InteractionWID=Interaction.WID

#transcription factor binding site
LEFT JOIN (SELECT * FROM InteractionParticipant WHERE Role='transcription factor binding site')
  AS TranscriptionFactorBindingSite ON Interaction.WID=TranscriptionFactorBindingSite.InteractionWID
LEFT JOIN Feature ON Feature.WID=TranscriptionFactorBindingSite.OtherWID

JOIN (SELECT @proteinComplexIdx:=@proteinComplexIdx+1 AS Idx,Protein.WID, DBID.XID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS ProteinComplex ON ProteinComplex.WID=InteractionTranscriptionFactor.OtherWID

JOIN
(SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
  FROM Compartment
  JOIN DBID ON DBID.OtherWID=Compartment.WID
  WHERE Compartment.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS ProteinComplexCompartment
ON InteractionTranscriptionFactor.CompartmentWID=ProteinComplexCompartment.WID

WHERE
  Interaction.Type='transcriptional regulation' &&
  InteractionTranscriptionUnit.Role='transcription unit' &&
  InteractionTranscriptionFactor.Role='transcription factor' &&
  (_WID IS NULL || (TranscriptionUnit.WID=_WID || ProteinComplex.WID=_WID || ProteinComplexCompartment.WID=_WID))
GROUP BY TranscriptionUnit.Idx, ProteinComplex.Idx, ProteinComplexCompartment.Idx
ORDER BY TranscriptionUnit.Idx, ProteinComplex.Idx, ProteinComplexCompartment.Idx;

END $$

-- ---------------------------------------------------------
-- media
-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS `set_mediacomponent` $$
CREATE PROCEDURE `set_mediacomponent` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _Metabolite varchar(150),
  IN _Compartment varchar(150), IN _Concentration float, IN _InitialTime float, IN _FinalTime float)
BEGIN

DECLARE _MediaComponentWID bigint;
DECLARE _ChemicalWID bigint;
DECLARE _CompartmentWID bigint;
SELECT WID INTO _ChemicalWID FROM Chemical JOIN DBID ON DBID.OtherWID=Chemical.WID WHERE DBID.XID=_Metabolite && Chemical.DataSetWID=_KnowledgeBaseWID;
SELECT WID INTO _CompartmentWID FROM Compartment JOIN DBID ON DBID.OtherWID=Compartment.WID WHERE DBID.XID=_Compartment && Compartment.DataSetWID=_KnowledgeBaseWID;

SELECT WID INTO _MediaComponentWID FROM MediaComposition WHERE WID=_WID;
IF _MediaComponentWID IS NULL THEN
	INSERT INTO MediaComposition(WID,OtherWID,CompartmentWID,Concentration,InitialTime,FinalTime,DataSetWID)
	VALUES(_WID,_ChemicalWID,_CompartmentWID,_Concentration,_InitialTime,_FinalTime,_KnowledgeBaseWID);
ELSE
	UPDATE MediaComposition
	SET
		OtherWID=_ChemicalWID,
		CompartmentWID=_CompartmentWID,
		Concentration=_Concentration,
		InitialTime=_InitialTime,
		FinalTime=_FinalTime
	WHERE WID=_WID;
END IF;

CALL set_textsearch(_ChemicalWID, _Compartment, 'compartment');

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_mediacomponent` $$
CREATE PROCEDURE `delete_mediacomponent` (IN _KnowledgeBaseWID bigint, IN _WID varchar(150))
BEGIN

#biomass composition
DELETE FROM MediaComposition WHERE MediaComposition.WID=_WID;

#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `get_mediacomponents` $$
CREATE PROCEDURE `get_mediacomponents` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  MediaComposition.WID, DBID.XID WholeCellModelID, 
  ChemicalDBID.XID Metabolite, Chemical.Name,
  CompartmentDBID.XID Compartment,
  MediaComposition.Concentration,
  MediaComposition.InitialTime,
  MediaComposition.FinalTime

FROM MediaComposition
JOIN DBID ON DBID.OtherWID=MediaComposition.WID

JOIN Chemical ON MediaComposition.OtherWID=Chemical.WID
JOIN DBID ChemicalDBID ON ChemicalDBID.OtherWID=MediaComposition.OtherWID
JOIN DBID CompartmentDBID ON CompartmentDBID.OtherWID=MediaComposition.CompartmentWID

WHERE MediaComposition.DataSetWID=_KnowledgeBaseWID &&  (_WID IS NULL || MediaComposition.WID=_WID)
ORDER BY DBID.XID;

END $$

DROP PROCEDURE IF EXISTS `get_metabolites_mediacomponents` $$
CREATE PROCEDURE `get_metabolites_mediacomponents` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @metaboliteIdx:=0;
SET @compartmentIdx:=0;

SELECT
  Metabolite.Idx MetaboliteIdx,
  Metabolite.WID MetaboliteWID,
  Metabolite.XID Metabolite,
  Compartment.Idx CompartmentIdx,
  Compartment.WID CompartmentWID,
  Compartment.XID Compartment,
  MediaComposition.Concentration,
  MediaComposition.InitialTime,
  MediaComposition.FinalTime
FROM (
 SELECT @metaboliteIdx:=@metaboliteIdx+1 AS Idx,Chemical.WID, DBID.XID
 FROM Chemical
 JOIN DBID ON DBID.OtherWID=Chemical.WID
 WHERE Chemical.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Metabolite

JOIN MediaComposition ON MediaComposition.OtherWID=Metabolite.WID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON Compartment.WID=MediaComposition.CompartmentWID

WHERE _WID IS NULL || (Metabolite.WID=_WID || Compartment.WID=_WID)
GROUP BY Metabolite.Idx, Compartment.Idx
ORDER BY Metabolite.Idx, Compartment.Idx;

END $$

-- ---------------------------------------------------------
-- stmuli
-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS `set_stimuli` $$
CREATE PROCEDURE `set_stimuli` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _Name varchar(255))
BEGIN

DECLARE _StimulusWID bigint;

SELECT WID INTO _StimulusWID FROM Stimulus WHERE WID=_WID;
IF _StimulusWID IS NULL THEN
	INSERT INTO Stimulus(WID,Name,DataSetWID) VALUES(_WID,_Name,_KnowledgeBaseWID);
ELSE
	UPDATE Stimulus
	SET
		Name=_Name
	WHERE WID=_WID;
END IF;

CALL set_textsearch(_WID, _Name, 'name');

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_stimuli` $$
CREATE PROCEDURE `delete_stimuli` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

DECLARE _ForeignWID bigint;
DECLARE done INT DEFAULT 0;
DECLARE cur1 CURSOR FOR SELECT WID FROM StimulusValue WHERE StimulusWID=_WID;
DECLARE cur2 CURSOR FOR
	SELECT Interaction.WID
	FROM Interaction
	JOIN InteractionParticipant ON Interaction.WID=InteractionParticipant.InteractionWID
	WHERE
		Interaction.Type='activation' &&
		InteractionParticipant.Role='regulator' &&
		InteractionParticipant.OtherWID=_WID;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

#simulus
DELETE FROM Stimulus WHERE Stimulus.WID=_WID;

SET done=0;
OPEN cur1;
REPEAT
    FETCH cur1 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_stimulivalue(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur1;

SET done=0;
OPEN cur2;
REPEAT
    FETCH cur2 INTO _ForeignWID;
    IF NOT done THEN
		CALL delete_proteinactivation(_KnowledgeBaseWID, _ForeignWID);
    END IF;
UNTIL done END REPEAT;
CLOSE cur2;

#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `get_stimulis` $$
CREATE PROCEDURE `get_stimulis` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Stimulus.WID,
  DBID.XID WholeCellModelID,
  Stimulus.Name,
  GROUP_CONCAT(DISTINCT StimulusValueDBID.XID ORDER BY StimulusValueDBID.XID SEPARATOR ';') `Values`
FROM Stimulus
JOIN DBID ON DBID.OtherWID=Stimulus.WID

#values
LEFT JOIN StimulusValue ON StimulusValue.StimulusWID=Stimulus.WID
LEFT JOIN DBID StimulusValueDBID ON StimulusValueDBID.OtherWID=StimulusValue.WID

WHERE Stimulus.DataSetWID=_KnowledgeBaseWID &&  (_WID IS NULL || Stimulus.WID=_WID)
GROUP BY Stimulus.WID
ORDER BY DBID.XID;

END $$

-- ---------------------------------------------------------
-- stmuli values
-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS `set_stimulivalue` $$
CREATE PROCEDURE `set_stimulivalue` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _Stimulus varchar(150), IN _Compartment varchar(150), IN _Value float, IN _Units varchar(255), IN _InitialTime float, IN _FinalTime float)
BEGIN

DECLARE _StimulusValueWID bigint;
DECLARE _StimulusWID bigint;
DECLARE _CompartmentWID bigint;
DECLARE _UnitsWID bigint;

#units
CALL set_units(_KnowledgeBaseWID, _UnitsWID, _Units);

SELECT WID INTO _StimulusWID FROM Stimulus JOIN DBID ON DBID.OtherWID=Stimulus.WID WHERE DBID.XID=_Stimulus && Stimulus.DataSetWID=_KnowledgeBaseWID;
SELECT WID INTO _CompartmentWID FROM Compartment JOIN DBID ON DBID.OtherWID=Compartment.WID WHERE DBID.XID=_Compartment && Compartment.DataSetWID=_KnowledgeBaseWID;

SELECT WID INTO _StimulusValueWID FROM StimulusValue WHERE WID=_WID;
IF _StimulusValueWID IS NULL THEN
	INSERT INTO StimulusValue(WID,StimulusWID,CompartmentWID,Value,UnitsWID,InitialTime,FinalTime,DataSetWID)
	VALUES(_WID,_StimulusWID,_CompartmentWID,_Value,_UnitsWID,_InitialTime,_FinalTime,_KnowledgeBaseWID);
ELSE 
	UPDATE StimulusValue
	SET
		StimulusWID=_StimulusWID,
		CompartmentWID=_CompartmentWID,
		Value=_Value,
		UnitsWID=_UnitsWID,
		InitialTime=_InitialTime,
		FinalTime=_FinalTime
	WHERE WID=_WID;
END IF;

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_stimulivalue` $$
CREATE PROCEDURE `delete_stimulivalue` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

#simulus
DELETE FROM StimulusValue WHERE StimulusValue.WID=_WID;

#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `get_stimulivalues` $$
CREATE PROCEDURE `get_stimulivalues` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
	@Idx:=@Idx+1 AS Idx,
	StimulusValue.WID,
	DBID.XID WholeCellModelID,
	StimulusDBID.XID Stimulus, 
	Stimulus.Name,
	CompartmentDBID.XID Compartment,
	StimulusValue.Value,
	Units.Name Units,
	StimulusValue.InitialTime,
	StimulusValue.FinalTime
FROM StimulusValue
JOIN DBID ON DBID.OtherWID=StimulusValue.WID
LEFT JOIN Stimulus ON Stimulus.WID=StimulusValue.StimulusWID
LEFT JOIN DBID StimulusDBID ON StimulusDBID.OtherWID=StimulusValue.StimulusWID
LEFT JOIN DBID CompartmentDBID ON CompartmentDBID.OtherWID=StimulusValue.CompartmentWID
LEFT JOIN Term Units ON Units.WID=StimulusValue.UnitsWID
WHERE StimulusValue.DataSetWID=_KnowledgeBaseWID && (_WID IS NULL || StimulusValue.WID=_WID)
ORDER BY DBID.XID;

END $$

DROP PROCEDURE IF EXISTS `get_stimulis_values` $$
CREATE PROCEDURE `get_stimulis_values` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @stimulusIdx:=0;
SET @compartmentIdx:=0;

SELECT
  Stimulus.Idx StimuliIdx,
  Stimulus.WID StimulusWID,
  Stimulus.XID Stimulus,
  Compartment.Idx CompartmentIdx,
  Compartment.WID CompartmentWID,
  Compartment.XID Compartment,
  StimulusValue.Value,
  StimulusValue.InitialTime,
  StimulusValue.FinalTime
FROM (
 SELECT @stimulusIdx:=@stimulusIdx+1 AS Idx,Stimulus.WID, DBID.XID
 FROM Stimulus
 JOIN DBID ON DBID.OtherWID=Stimulus.WID
 WHERE Stimulus.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Stimulus

JOIN StimulusValue ON StimulusValue.StimulusWID=Stimulus.WID

JOIN (
 SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment ON Compartment.WID=StimulusValue.CompartmentWID

WHERE _WID IS NULL || (Stimulus.WID=_WID || Compartment.WID=_WID)
ORDER BY Stimulus.Idx, Compartment.Idx;

END $$

-- ---------------------------------------------------------
-- protein activation
-- ---------------------------------------------------------
DROP PROCEDURE IF EXISTS `set_proteinactivation` $$
CREATE PROCEDURE `set_proteinactivation` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _Protein varchar(150),
  IN _ActivationRule text, IN _Regulators text)
BEGIN

DECLARE _ProteinActivationWID bigint;
DECLARE _ProteinWID bigint;
DECLARE _RegulatorXID varchar(255);
DECLARE _RegulatorWID bigint;
DECLARE _idx smallint default 1;
DECLARE _maxIdx smallint;

SELECT WID INTO _ProteinWID
FROM Protein
JOIN DBID ON DBID.OtherWID=Protein.WID
WHERE DBID.XID=_Protein && Protein.DataSetWID=_KnowledgeBaseWID;

SELECT WID INTO _ProteinActivationWID FROM Interaction WHERE WID=_WID;
IF _ProteinActivationWID IS NULL THEN
    INSERT INTO Interaction(WID,Type,Rule,DataSetWID) VALUES(_WID, 'activation', _ActivationRule, _KnowledgeBaseWID);
ELSE
    UPDATE Interaction
    SET
        Type='activation',
        Rule=_ActivationRule
    WHERE WID=_WID;
END IF;

DELETE FROM InteractionParticipant WHERE InteractionWID=_WID;
INSERT INTO InteractionParticipant(InteractionWID, OtherWID, Role) VALUES(_WID, _ProteinWID, 'protein');

#stimuli
SET _maxIdx=(LENGTH(_Regulators)-LENGTH(REPLACE(_Regulators, ';', ''))+1);

WHILE _idx<=_maxIdx DO
    SET _RegulatorXID=SUBSTRING_INDEX(SUBSTRING_INDEX(_Regulators,";",_idx),";",-1);

    SELECT Entry.OtherWID INTO _RegulatorWID
    FROM Entry
    JOIN DBID ON DBID.OtherWID=Entry.OtherWID
    WHERE Entry.DataSetWID=_KnowledgeBaseWID && DBID.XID=_RegulatorXID;

    IF _RegulatorWID IS NOT NULL THEN
        INSERT INTO InteractionParticipant(InteractionWID, OtherWID, Role) VALUES(_WID, _RegulatorWID, 'regulator');
    END IF;

    SET _idx=_idx+1;
END WHILE;

CALL set_textsearch(_ProteinWID, _ActivationRule, 'activation rule');
CALL set_textsearch(_WID, _ActivationRule, 'activation rule');

SELECT _WID WID;

END $$


DROP PROCEDURE IF EXISTS `delete_proteinactivation` $$
CREATE PROCEDURE `delete_proteinactivation` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `get_proteinactivations` $$
CREATE PROCEDURE `get_proteinactivations` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Interaction.WID,
  DBID.XID WholeCellModelID,
  ProteinDBID.XID Protein,
  Protein.Name,
  Interaction.Rule ActivationRule,
  GROUP_CONCAT(DISTINCT RegulatorDBID.XID ORDER BY RegulatorDBID.XID SEPARATOR ';') Regulators
FROM Interaction
JOIN DBID ON DBID.OtherWID=Interaction.WID

#activation rule
JOIN InteractionParticipant ProteinInteractionParticipant ON ProteinInteractionParticipant.InteractionWID=Interaction.WID
JOIN Protein ON Protein.WID=ProteinInteractionParticipant.OtherWID
JOIN DBID ProteinDBID ON ProteinDBID.OtherWID=Protein.WID

#regulators
JOIN InteractionParticipant RegulatorInteractionParticipant ON RegulatorInteractionParticipant.InteractionWID=Interaction.WID
JOIN DBID RegulatorDBID ON RegulatorDBID.OtherWID=RegulatorInteractionParticipant.OtherWID

WHERE
  Interaction.DataSetWID=_KnowledgeBaseWID &&
  ProteinInteractionParticipant.Role='protein' &&
  RegulatorInteractionParticipant.Role='regulator' &&
  Interaction.Type='activation' &&
  (_WID IS NULL || Interaction.WID=_WID)
GROUP BY Interaction.WID
ORDER BY DBID.XID;

END $$

DROP PROCEDURE IF EXISTS `get_proteinactivations_proteinmonomers_stimulis` $$
CREATE PROCEDURE `get_proteinactivations_proteinmonomers_stimulis` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinMonomerIdx:=0;
SET @regulatorIdx:=0;

SELECT
	ProteinMonomer.Idx ProteinMonomerIdx,
	ProteinMonomer.WID ProteinMonomerWID,
	ProteinMonomer.XID ProteinMonomer,
	StimulusRegulator.Idx StimulusRegulatorIdx,
	StimulusRegulator.WID StimulusRegulatorWID,
	StimulusRegulator.XID StimulusRegulator
FROM

(SELECT @proteinMonomerIdx:=@proteinMonomerIdx+1 AS Idx,GeneWIDProteinWID.ProteinWID WID, DBID.XID
	FROM Gene
	JOIN GeneWIDProteinWID ON GeneWIDProteinWID.GeneWID=Gene.WID
	JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
	WHERE Gene.DataSetWID=_KnowledgeBaseWID
	ORDER BY Gene.CodingRegionStart
) AS ProteinMonomer

JOIN InteractionParticipant ProteinInteractionParticipant ON ProteinInteractionParticipant.OtherWID=ProteinMonomer.WID
JOIN InteractionParticipant RegulatorInteractionParticipant ON RegulatorInteractionParticipant.InteractionWID=ProteinInteractionParticipant.InteractionWID

JOIN (SELECT @regulatorIdx:=@regulatorIdx+1 AS Idx,Stimulus.WID, DBID.XID
	FROM Stimulus
	JOIN DBID ON Stimulus.WID=DBID.OtherWID
	WHERE Stimulus.DataSetWID=_KnowledgeBaseWID
	ORDER BY DBID.XID
) AS StimulusRegulator ON RegulatorInteractionParticipant.OtherWID=StimulusRegulator.WID

WHERE
	ProteinInteractionParticipant.Role='protein' &&
	RegulatorInteractionParticipant.Role='regulator' &&
	(_WID IS NULL || (ProteinMonomer.WID=_WID || StimulusRegulator.WID=_WID))
GROUP BY ProteinMonomer.Idx, StimulusRegulator.Idx
ORDER BY ProteinMonomer.Idx, StimulusRegulator.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteinactivations_proteincomplexs_stimulis` $$
CREATE PROCEDURE `get_proteinactivations_proteincomplexs_stimulis` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinComplexIdx:=0;
SET @regulatorIdx:=0;

SELECT
	ProteinComplex.Idx ProteinComplexIdx,
	ProteinComplex.WID ProteinComplexWID,
	ProteinComplex.XID ProteinComplex,
	StimulusRegulator.Idx StimulusRegulatorIdx,
	StimulusRegulator.WID StimulusRegulatorWID, 
	StimulusRegulator.XID StimulusRegulator
FROM

(SELECT @proteinComplexIdx:=@proteinComplexIdx+1 AS Idx,Protein.WID, DBID.XID
	FROM Protein
	JOIN Subunit ON Subunit.ComplexWID=Protein.WID
	JOIN DBID ON DBID.OtherWID=Protein.WID
	WHERE Protein.DataSetWID=_KnowledgeBaseWID
	GROUP BY Protein.WID
	ORDER BY DBID.XID
) AS ProteinComplex

JOIN InteractionParticipant ProteinInteractionParticipant ON ProteinInteractionParticipant.OtherWID=ProteinComplex.WID
JOIN InteractionParticipant RegulatorInteractionParticipant ON RegulatorInteractionParticipant.InteractionWID=ProteinInteractionParticipant.InteractionWID

JOIN (SELECT @regulatorIdx:=@regulatorIdx+1 AS Idx,Stimulus.WID, DBID.XID
	FROM Stimulus
	JOIN DBID ON Stimulus.WID=DBID.OtherWID
	WHERE Stimulus.DataSetWID=_KnowledgeBaseWID
	ORDER BY DBID.XID
) AS StimulusRegulator ON RegulatorInteractionParticipant.OtherWID=StimulusRegulator.WID

WHERE
	ProteinInteractionParticipant.Role='protein' &&
	RegulatorInteractionParticipant.Role='regulator' &&
	(_WID IS NULL || (ProteinComplex.WID=_WID || StimulusRegulator.WID=_WID))
GROUP BY ProteinComplex.Idx, StimulusRegulator.Idx
ORDER BY ProteinComplex.Idx, StimulusRegulator.Idx;


END $$


DROP PROCEDURE IF EXISTS `get_proteinactivations_proteinmonomers_metabolites` $$
CREATE PROCEDURE `get_proteinactivations_proteinmonomers_metabolites` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinMonomerIdx:=0;
SET @regulatorIdx:=0;

SELECT
	ProteinMonomer.Idx ProteinMonomerIdx,
	ProteinMonomer.WID ProteinMonomerWID,
	ProteinMonomer.XID ProteinMonomer,
	Metabolite.Idx MetaboliteRegulatorIdx,
	Metabolite.WID MetaboliteRegulatorWID,
	Metabolite.XID MetaboliteRegulator
FROM

(SELECT @proteinMonomerIdx:=@proteinMonomerIdx+1 AS Idx,GeneWIDProteinWID.ProteinWID WID, DBID.XID
	FROM Gene
	JOIN GeneWIDProteinWID ON GeneWIDProteinWID.GeneWID=Gene.WID
	JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
	WHERE Gene.DataSetWID=_KnowledgeBaseWID
	ORDER BY Gene.CodingRegionStart
) AS ProteinMonomer

JOIN InteractionParticipant ProteinInteractionParticipant ON ProteinInteractionParticipant.OtherWID=ProteinMonomer.WID
JOIN InteractionParticipant RegulatorInteractionParticipant ON RegulatorInteractionParticipant.InteractionWID=ProteinInteractionParticipant.InteractionWID

JOIN (SELECT @regulatorIdx:=@regulatorIdx+1 AS Idx,Chemical.WID, DBID.XID
	FROM Chemical
	JOIN DBID ON Chemical.WID=DBID.OtherWID
	WHERE Chemical.DataSetWID=_KnowledgeBaseWID
	ORDER BY DBID.XID
) AS Metabolite ON RegulatorInteractionParticipant.OtherWID=Metabolite.WID

WHERE
	ProteinInteractionParticipant.Role='protein' &&
	RegulatorInteractionParticipant.Role='regulator' &&
	(_WID IS NULL || (ProteinMonomer.WID=_WID || Metabolite.WID=_WID))
GROUP BY ProteinMonomer.Idx, Metabolite.Idx
ORDER BY ProteinMonomer.Idx, Metabolite.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteinactivations_proteincomplexs_metabolites` $$
CREATE PROCEDURE `get_proteinactivations_proteincomplexs_metabolites` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinComplexIdx:=0;
SET @regulatorIdx:=0;

SELECT
	ProteinComplex.Idx ProteinComplexIdx,
	ProteinComplex.WID ProteinComplexWID,
	ProteinComplex.XID ProteinComplex,
	Metabolite.Idx MetaboliteRegulatorIdx,
	Metabolite.WID MetaboliteRegulatorWID, 
	Metabolite.XID MetaboliteRegulator
FROM

(SELECT @proteinComplexIdx:=@proteinComplexIdx+1 AS Idx,Protein.WID, DBID.XID
	FROM Protein
	JOIN Subunit ON Subunit.ComplexWID=Protein.WID
	JOIN DBID ON DBID.OtherWID=Protein.WID
	WHERE Protein.DataSetWID=_KnowledgeBaseWID
	GROUP BY Protein.WID
	ORDER BY DBID.XID
) AS ProteinComplex

JOIN InteractionParticipant ProteinInteractionParticipant ON ProteinInteractionParticipant.OtherWID=ProteinComplex.WID
JOIN InteractionParticipant RegulatorInteractionParticipant ON RegulatorInteractionParticipant.InteractionWID=ProteinInteractionParticipant.InteractionWID

JOIN (SELECT @regulatorIdx:=@regulatorIdx+1 AS Idx,Chemical.WID, DBID.XID
	FROM Chemical
	JOIN DBID ON Chemical.WID=DBID.OtherWID
	WHERE Chemical.DataSetWID=_KnowledgeBaseWID
	ORDER BY DBID.XID
) AS Metabolite ON RegulatorInteractionParticipant.OtherWID=Metabolite.WID

WHERE
	ProteinInteractionParticipant.Role='protein' &&
	RegulatorInteractionParticipant.Role='regulator' &&
	(_WID IS NULL || (ProteinComplex.WID=_WID || Metabolite.WID=_WID))
GROUP BY ProteinComplex.Idx, Metabolite.Idx
ORDER BY ProteinComplex.Idx, Metabolite.Idx;


END $$

DROP PROCEDURE IF EXISTS `get_proteinactivations_proteinmonomers_proteinmonomers` $$
CREATE PROCEDURE `get_proteinactivations_proteinmonomers_proteinmonomers` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinMonomerIdx:=0;
SET @regulatorIdx:=0;

SELECT
	ProteinMonomer.Idx ProteinMonomerIdx,
	ProteinMonomer.WID ProteinMonomerWID,
	ProteinMonomer.XID ProteinMonomer,
	ProteinMonomerRegulator.Idx ProteinMonomerRegulatorIdx,
	ProteinMonomerRegulator.WID ProteinMonomerRegulatorWID,
	ProteinMonomerRegulator.XID ProteinMonomerRegulator
FROM

(SELECT @proteinMonomerIdx:=@proteinMonomerIdx+1 AS Idx,GeneWIDProteinWID.ProteinWID WID, DBID.XID
	FROM Gene
	JOIN GeneWIDProteinWID ON GeneWIDProteinWID.GeneWID=Gene.WID
	JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
	WHERE Gene.DataSetWID=_KnowledgeBaseWID
	ORDER BY Gene.CodingRegionStart
) AS ProteinMonomer

JOIN InteractionParticipant ProteinInteractionParticipant ON ProteinInteractionParticipant.OtherWID=ProteinMonomer.WID
JOIN InteractionParticipant RegulatorInteractionParticipant ON RegulatorInteractionParticipant.InteractionWID=ProteinInteractionParticipant.InteractionWID

JOIN (SELECT @regulatorIdx:=@regulatorIdx+1 AS Idx, GeneWIDProteinWID.ProteinWID WID, DBID.XID
	FROM Gene
	JOIN GeneWIDProteinWID ON GeneWIDProteinWID.GeneWID=Gene.WID
	JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
	WHERE Gene.DataSetWID=_KnowledgeBaseWID
	ORDER BY Gene.CodingRegionStart
) AS ProteinMonomerRegulator ON RegulatorInteractionParticipant.OtherWID=ProteinMonomerRegulator.WID

WHERE
	ProteinInteractionParticipant.Role='protein' &&
	RegulatorInteractionParticipant.Role='regulator' &&
	(_WID IS NULL || (ProteinMonomer.WID=_WID || ProteinMonomerRegulator.WID=_WID))
GROUP BY ProteinMonomer.Idx, ProteinMonomerRegulator.Idx
ORDER BY ProteinMonomer.Idx, ProteinMonomerRegulator.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteinactivations_proteincomplexs_proteinmonomers` $$
CREATE PROCEDURE `get_proteinactivations_proteincomplexs_proteinmonomers` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinComplexIdx:=0;
SET @regulatorIdx:=0;

SELECT
	ProteinComplex.Idx ProteinComplexIdx,
	ProteinComplex.WID ProteinComplexWID,
	ProteinComplex.XID ProteinComplex,
	ProteinMonomerRegulator.Idx ProteinMonomerRegulatorIdx,
	ProteinMonomerRegulator.WID ProteinMonomerRegulatorWID,
	ProteinMonomerRegulator.XID ProteinMonomerRegulator
FROM

(SELECT @proteinComplexIdx:=@proteinComplexIdx+1 AS Idx,Protein.WID, DBID.XID
	FROM Protein
	JOIN Subunit ON Subunit.ComplexWID=Protein.WID
	JOIN DBID ON DBID.OtherWID=Protein.WID
	WHERE Protein.DataSetWID=_KnowledgeBaseWID
	GROUP BY Protein.WID
	ORDER BY DBID.XID
) AS ProteinComplex

JOIN InteractionParticipant ProteinInteractionParticipant ON ProteinInteractionParticipant.OtherWID=ProteinComplex.WID
JOIN InteractionParticipant RegulatorInteractionParticipant ON RegulatorInteractionParticipant.InteractionWID=ProteinInteractionParticipant.InteractionWID

JOIN (SELECT @regulatorIdx:=@regulatorIdx+1 AS Idx, GeneWIDProteinWID.ProteinWID WID, DBID.XID
	FROM Gene
	JOIN GeneWIDProteinWID ON GeneWIDProteinWID.GeneWID=Gene.WID
	JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
	WHERE Gene.DataSetWID=_KnowledgeBaseWID
	ORDER BY Gene.CodingRegionStart
) AS ProteinMonomerRegulator ON RegulatorInteractionParticipant.OtherWID=ProteinMonomerRegulator.WID

WHERE
	ProteinInteractionParticipant.Role='protein' &&
	RegulatorInteractionParticipant.Role='regulator' &&
	(_WID IS NULL || (ProteinComplex.WID=_WID || ProteinMonomerRegulator.WID=_WID))
GROUP BY ProteinComplex.Idx, ProteinMonomerRegulator.Idx
ORDER BY ProteinComplex.Idx, ProteinMonomerRegulator.Idx;


END $$

DROP PROCEDURE IF EXISTS `get_proteinactivations_proteinmonomers_proteincomplexs` $$
CREATE PROCEDURE `get_proteinactivations_proteinmonomers_proteincomplexs` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinMonomerIdx:=0;
SET @regulatorIdx:=0;

SELECT
	ProteinMonomer.Idx ProteinMonomerIdx,
	ProteinMonomer.WID ProteinMonomerWID,
	ProteinMonomer.XID ProteinMonomer,
	ProteinComplexRegulator.Idx ProteinComplexRegulatorIdx,
	ProteinComplexRegulator.WID ProteinComplexRegulatorWID,
	ProteinComplexRegulator.XID ProteinComplexRegulator
FROM

(SELECT @proteinMonomerIdx:=@proteinMonomerIdx+1 AS Idx,GeneWIDProteinWID.ProteinWID WID, DBID.XID
	FROM Gene
	JOIN GeneWIDProteinWID ON GeneWIDProteinWID.GeneWID=Gene.WID
	JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
	WHERE Gene.DataSetWID=_KnowledgeBaseWID
	ORDER BY Gene.CodingRegionStart
) AS ProteinMonomer

JOIN InteractionParticipant ProteinInteractionParticipant ON ProteinInteractionParticipant.OtherWID=ProteinMonomer.WID
JOIN InteractionParticipant RegulatorInteractionParticipant ON RegulatorInteractionParticipant.InteractionWID=ProteinInteractionParticipant.InteractionWID

JOIN (SELECT @regulatorIdx:=@regulatorIdx+1 AS Idx,Protein.WID, DBID.XID
	FROM Protein
	JOIN Subunit ON Subunit.ComplexWID=Protein.WID
	JOIN DBID ON DBID.OtherWID=Protein.WID
	WHERE Protein.DataSetWID=_KnowledgeBaseWID
	GROUP BY Protein.WID
	ORDER BY DBID.XID
) AS ProteinComplexRegulator ON RegulatorInteractionParticipant.OtherWID=ProteinComplexRegulator.WID

WHERE
	ProteinInteractionParticipant.Role='protein' &&
	RegulatorInteractionParticipant.Role='regulator' &&
	(_WID IS NULL || (ProteinMonomer.WID=_WID || ProteinComplexRegulator.WID=_WID))
GROUP BY ProteinMonomer.Idx, ProteinComplexRegulator.Idx
ORDER BY ProteinMonomer.Idx, ProteinComplexRegulator.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteinactivations_proteincomplexs_proteincomplexs` $$
CREATE PROCEDURE `get_proteinactivations_proteincomplexs_proteincomplexs` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinComplexIdx:=0;
SET @regulatorIdx:=0;

SELECT
	ProteinComplex.Idx ProteinComplexIdx,
	ProteinComplex.WID ProteinComplexWID,
	ProteinComplex.XID ProteinComplex,
	ProteinComplexRegulator.Idx ProteinComplexRegulatorIdx,
	ProteinComplexRegulator.WID ProteinComplexRegulatorWID,
	ProteinComplexRegulator.XID ProteinComplexRegulator
FROM

(SELECT @proteinComplexIdx:=@proteinComplexIdx+1 AS Idx,Protein.WID, DBID.XID
	FROM Protein
	JOIN Subunit ON Subunit.ComplexWID=Protein.WID
	JOIN DBID ON DBID.OtherWID=Protein.WID
	WHERE Protein.DataSetWID=_KnowledgeBaseWID
	GROUP BY Protein.WID
	ORDER BY DBID.XID
) AS ProteinComplex

JOIN InteractionParticipant ProteinInteractionParticipant ON ProteinInteractionParticipant.OtherWID=ProteinComplex.WID
JOIN InteractionParticipant RegulatorInteractionParticipant ON RegulatorInteractionParticipant.InteractionWID=ProteinInteractionParticipant.InteractionWID

JOIN (SELECT @regulatorIdx:=@regulatorIdx+1 AS Idx, Protein.WID, DBID.XID
	FROM Protein
	JOIN Subunit ON Subunit.ComplexWID=Protein.WID
	JOIN DBID ON DBID.OtherWID=Protein.WID
	WHERE Protein.DataSetWID=_KnowledgeBaseWID
	GROUP BY Protein.WID
	ORDER BY DBID.XID
) AS ProteinComplexRegulator ON RegulatorInteractionParticipant.OtherWID=ProteinComplexRegulator.WID

WHERE
	ProteinInteractionParticipant.Role='protein' &&
	RegulatorInteractionParticipant.Role='regulator' &&
	(_WID IS NULL || (ProteinComplex.WID=_WID || ProteinComplexRegulator.WID=_WID))
GROUP BY ProteinComplex.Idx, ProteinComplexRegulator.Idx
ORDER BY ProteinComplex.Idx, ProteinComplexRegulator.Idx;


END $$

-- ---------------------------------------------------------
-- metabolic map
-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS `set_metabolicmapmetabolite` $$
CREATE PROCEDURE `set_metabolicmapmetabolite` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _Metabolite varchar(150),IN _CompartmentXID varchar(255),IN _X float,IN _Y float)
BEGIN

DECLARE _IllustrationWID bigint;
DECLARE _MetaboliteWID bigint;
DECLARE _CompartmentWID bigint;
SELECT WID INTO _MetaboliteWID FROM Chemical JOIN DBID ON DBID.OtherWID=Chemical.WID WHERE DBID.XID=_Metabolite && Chemical.DataSetWID=_KnowledgeBaseWID;
SELECT WID INTO _CompartmentWID FROM Compartment JOIN DBID ON DBID.OtherWID=Compartment.WID WHERE DBID.XID=_CompartmentXID && Compartment.DataSetWID=_KnowledgeBaseWID;

SELECT WID INTO _IllustrationWID FROM Illustration WHERE WID=_WID;
IF _IllustrationWID IS NULL THEN
	INSERT INTO Illustration(WID,OtherWID,CompartmentWID,Illustration,Value,DataSetWID) 
	VALUES(_WID,_MetaboliteWID,_CompartmentWID,'MetabolicMap',CONCAT_WS(';',_X,_Y),_KnowledgeBaseWID);
ELSE
	UPDATE Illustration
	SET 
		OtherWID=_MetaboliteWID,
		CompartmentWID=_CompartmentWID,
		Illustration='MetabolicMap',
		Value=CONCAT_WS(';',_X,_Y)
	WHERE WID=_WID;
END IF;

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `set_metabolicmapreaction` $$
CREATE PROCEDURE `set_metabolicmapreaction` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _Reaction varchar(150),IN _Path varchar(255),IN _LabelX float,IN _LabelY float,IN _ValueX float,IN _ValueY float)
BEGIN

DECLARE _IllustrationWID bigint;
DECLARE _ReactionWID bigint;

SELECT WID INTO _ReactionWID FROM Reaction JOIN DBID ON DBID.OtherWID=Reaction.WID WHERE DBID.XID=_Reaction && Reaction.DataSetWID=_KnowledgeBaseWID;

SELECT WID INTO _IllustrationWID FROM Illustration WHERE WID=_WID;
IF _IllustrationWID IS NULL THEN
	INSERT INTO Illustration(WID,OtherWID,Illustration,Value,DataSetWID) 
	VALUES(_WID,_ReactionWID,'MetabolicMap',CONCAT_WS(';',_Path,_LabelX,_LabelY,_ValueX,_ValueY),_KnowledgeBaseWID);
ELSE
	UPDATE Illustration
	SET
		OtherWID=_ReactionWID,
		Illustration='MetabolicMap',
		Value=CONCAT_WS(';',_Path,_LabelX,_LabelY,_ValueX,_ValueY)
	WHERE WID=_WID;
END IF;

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_metabolicmapmetabolite` $$
CREATE PROCEDURE `delete_metabolicmapmetabolite` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

#illustration
DELETE FROM Illustration WHERE WID=_WID;

#entry
CALL delete_entry(_WID);

END $$

DROP PROCEDURE IF EXISTS `delete_metabolicmapreaction` $$
CREATE PROCEDURE `delete_metabolicmapreaction` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

#illustration
DELETE FROM Illustration WHERE WID=_WID;

#entry
CALL delete_entry(_WID);

END $$


DROP PROCEDURE IF EXISTS `get_metabolicmapmetabolites` $$
CREATE PROCEDURE `get_metabolicmapmetabolites` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Illustration.WID, DBID.XID WholeCellModelID,
  ChemicalDBID.XID Metabolite,
  Chemical.Name, CompartmentDBID.XID Compartment,
  SUBSTRING_INDEX(Illustration.Value,';',1)+0 X,SUBSTRING_INDEX(Illustration.Value,';',-1) Y
FROM Illustration
JOIN DBID ON DBID.OtherWID=Illustration.WID
JOIN Chemical ON Illustration.OtherWID=Chemical.WID
JOIN DBID ChemicalDBID ON ChemicalDBID.OtherWID=Chemical.WID
JOIN DBID CompartmentDBID ON CompartmentDBID.OtherWID=Illustration.CompartmentWID
WHERE
  Illustration.DataSetWID=_KnowledgeBaseWID &&
  Illustration.Illustration='MetabolicMap' &&
  (_WID IS NULL || Illustration.WID=_WID)
ORDER BY DBID.XID;

END $$

DROP PROCEDURE IF EXISTS `get_metabolicmapreactions` $$
CREATE PROCEDURE `get_metabolicmapreactions` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Illustration.WID, DBID.XID WholeCellModelID, 
  ReactionDBID.XID Reaction, Reaction.Name,
  SUBSTRING_INDEX(SUBSTRING_INDEX(Illustration.Value,';',1),';',-1) Path,
  SUBSTRING_INDEX(SUBSTRING_INDEX(Illustration.Value,';',2),';',-1)+0 LabelX,
  SUBSTRING_INDEX(SUBSTRING_INDEX(Illustration.Value,';',3),';',-1)+0 LabelY,
  SUBSTRING_INDEX(SUBSTRING_INDEX(Illustration.Value,';',4),';',-1)+0 ValueX,
  SUBSTRING_INDEX(SUBSTRING_INDEX(Illustration.Value,';',5),';',-1)+0 ValueY
FROM Illustration
JOIN DBID ON DBID.OtherWID=Illustration.WID
JOIN Reaction ON Illustration.OtherWID=Reaction.WID
JOIN DBID ReactionDBID ON ReactionDBID.OtherWID=Illustration.OtherWID
WHERE 
	Illustration.DataSetWID=_KnowledgeBaseWID && 
	Illustration.Illustration='MetabolicMap' &&  
	(_WID IS NULL || Illustration.WID=_WID)
ORDER BY DBID.XID;

END $$

-- ---------------------------------------------------------
-- references
-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS `set_reference` $$
CREATE PROCEDURE `set_reference` (IN _KnowledgeBaseWID bigint, IN _WID bigint,
  IN _Type ENUM('article','book', 'misc','thesis'),
  IN _PMID bigint, IN _ISBN bigint, IN _Authors text, IN _Editors text,IN _Year smallint, IN _Title text, IN _Publication varchar(255),
  IN _Volume varchar(255),IN _Issue varchar(255),IN _Pages varchar(255),  IN _Publisher varchar(255), IN _URL varchar(255))
BEGIN

DECLARE _ReferenceWID bigint;

SELECT WID INTO _ReferenceWID FROM Citation WHERE WID=_WID;
IF _ReferenceWID IS NULL THEN
	INSERT INTO Citation(WID, `Type`, PMID,ISBN,Title,Authors,Editor,Publication,Publisher,Year,Volume,Issue,Pages,URI,DataSetWID)
	VALUES (_WID, _Type, _PMID, _ISBN, _Title,_Authors,_Editors,_Publication,_Publisher,_Year,_Volume,_Issue,_Pages,_URL,_KnowledgeBaseWID);
ELSE
	UPDATE Citation
	SET
    `Type`=_Type,
		PMID=_PMID,
		ISBN=_ISBN,
		Title=_Title,
		Authors=_Authors,
		Editor=_Editors,
		Publication=_Publication,
		Publisher=_Publisher,
		Year=_Year,
		Volume=_Volume,
		Issue=_Issue,
		Pages=_Pages,
		URI=_URL
	WHERE WID=_WID;
END IF;

CALL set_textsearch(_WID, _PMID, 'cross reference - PubMed ID');
CALL set_textsearch(_WID, _ISBN, 'cross reference - ISBN');
CALL set_textsearch(_WID, _Authors, 'authors');
CALL set_textsearch(_WID, _Editors, 'editors');
CALL set_textsearch(_WID, _Title, 'title');
CALL set_textsearch(_WID, _Publication, 'publication');
CALL set_textsearch(_WID, _Publisher, 'publisher');
CALL set_textsearch(_WID, _URL, 'URL');

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `update_entry_references` $$
CREATE PROCEDURE `update_entry_references` (IN _KnowledgeBaseWID bigint, IN _EntryWID bigint, IN _References text)
BEGIN

DECLARE _ReferenceWID bigint;
DECLARE _Reference varchar(150);
DECLARE _idx smallint default 1;
DECLARE _maxIdx smallint;
DECLARE _count smallint;

DELETE FROM CitationWIDOtherWID WHERE OtherWID=_EntryWID;

SET _maxIdx=(LENGTH(_References)-LENGTH(REPLACE(_References, ';', ''))+1);

WHILE _idx<=_maxIdx DO
    SET _Reference=SUBSTRING_INDEX(SUBSTRING_INDEX(_References,";",_idx),";",-1);

    SELECT Entry.OtherWID INTO _ReferenceWID
    FROM Entry
    JOIN DBID ON DBID.OtherWID=Entry.OtherWID
    WHERE Entry.DataSetWID=_KnowledgeBaseWID && DBID.XID=_Reference;

    IF _ReferenceWID IS NOT NULL && _EntryWID IS NOT NULL THEN
        INSERT INTO CitationWIDOtherWID(CitationWID,OtherWID) VALUES(_ReferenceWID,_EntryWID);
    END IF;
    SET _idx=_idx+1;
END WHILE;

SELECT _EntryWID;

END $$

DROP PROCEDURE IF EXISTS `delete_reference` $$
CREATE PROCEDURE `delete_reference` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

#reference
DELETE Citation, CitationWIDOtherWID
FROM Citation
JOIN CitationWIDOtherWID ON Citation.WID=CitationWIDOtherWID.CitationWID
WHERE Citation.WID=_WID;

#entry
CALL delete_entry(_WID);

END $$


DROP PROCEDURE IF EXISTS `get_references` $$
CREATE PROCEDURE `get_references` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Citation.WID, 
  DBID.XID WholeCellModelID,
  Citation.Type,
  Citation.PMID, Citation.ISBN, 
  Citation.Authors, Citation.Editor Editors, 
  Citation.Year+0 Year, 
  Citation.Title, Citation.Publication, 
  Citation.Volume, Citation.Issue, Citation.Pages, 
  Citation.Publisher, Citation.URI URL,
  GROUP_CONCAT(DISTINCT EntryDBID.XID ORDER BY EntryDBID.XID SEPARATOR ';') Citations

FROM Citation
JOIN DBID ON DBID.OtherWID=Citation.WID

#entry
LEFT JOIN CitationWIDOtherWID ON CitationWIDOtherWID.CitationWID=Citation.WID
LEFT JOIN DBID EntryDBID ON EntryDBID.OtherWID=CitationWIDOtherWID.OtherWID

WHERE Citation.DataSetWID=_KnowledgeBaseWID &&  (_WID IS NULL || Citation.WID=_WID)
GROUP BY Citation.WID
ORDER BY DBID.XID;

END $$

DROP PROCEDURE IF EXISTS `get_processs_references` $$
CREATE PROCEDURE `get_processs_references` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @processIdx:=0;
SET @referenceIdx:=0;

SELECT
  Process.Idx ProcessIdx,
  Process.WID ProcessWID,
  Process.XID Process,
  Reference.Idx ReferenceIdx,
  Reference.WID ReferenceWID,
  Reference.XID Reference
FROM

(SELECT @processIdx:=@processIdx+1 AS Idx,Process.WID, DBID.XID
 FROM Process
 JOIN DBID ON DBID.OtherWID=Process.WID
 WHERE Process.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Process

JOIN CitationWIDOtherWID ON Process.WID=CitationWIDOtherWID.OtherWID

JOIN
(SELECT @referenceIdx:=@referenceIdx+1 AS Idx,Citation.WID, DBID.XID
  FROM Citation
  JOIN DBID ON Citation.WID=DBID.OtherWID
  WHERE Citation.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Reference
ON CitationWIDOtherWID.CitationWID=Reference.WID

WHERE (_WID IS NULL || (Process.WID=_WID || Reference.WID=_WID))
GROUP BY Process.Idx,Reference.Idx
ORDER BY Process.Idx,Reference.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_states_references` $$
CREATE PROCEDURE `get_states_references` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @stateIdx:=0;
SET @referenceIdx:=0;

SELECT
  State.Idx StateIdx,
  State.WID StateWID,
  State.XID State,
  Reference.Idx ReferenceIdx,
  Reference.WID ReferenceWID,
  Reference.XID Reference
FROM

(SELECT @stateIdx:=@stateIdx+1 AS Idx,State.WID, DBID.XID
 FROM State
 JOIN DBID ON DBID.OtherWID=State.WID
 WHERE State.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS State

JOIN CitationWIDOtherWID ON State.WID=CitationWIDOtherWID.OtherWID

JOIN
(SELECT @referenceIdx:=@referenceIdx+1 AS Idx,Citation.WID, DBID.XID
  FROM Citation
  JOIN DBID ON Citation.WID=DBID.OtherWID
  WHERE Citation.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Reference
ON CitationWIDOtherWID.CitationWID=Reference.WID

WHERE (_WID IS NULL || (State.WID=_WID || Reference.WID=_WID))
GROUP BY State.Idx,Reference.Idx
ORDER BY State.Idx,Reference.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_parameters_references` $$
CREATE PROCEDURE `get_parameters_references` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @parameterIdx:=0;
SET @referenceIdx:=0;

SELECT
  Parameter.Idx ParameterIdx,
  Parameter.WID ParameterWID,
  Parameter.XID Parameter,
  Reference.Idx ReferenceIdx,
  Reference.WID ReferenceWID,
  Reference.XID Reference
FROM

(SELECT @parameterIdx:=@parameterIdx+1 AS Idx,Parameter.WID, DBID.XID
 FROM Parameter
 JOIN DBID ON DBID.OtherWID=Parameter.WID
 WHERE Parameter.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Parameter

JOIN CitationWIDOtherWID ON Parameter.WID=CitationWIDOtherWID.OtherWID

JOIN
(SELECT @referenceIdx:=@referenceIdx+1 AS Idx,Citation.WID, DBID.XID
  FROM Citation
  JOIN DBID ON Citation.WID=DBID.OtherWID
  WHERE Citation.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Reference
ON CitationWIDOtherWID.CitationWID=Reference.WID

WHERE (_WID IS NULL || (Parameter.WID=_WID || Reference.WID=_WID))
GROUP BY Parameter.Idx,Reference.Idx
ORDER BY Parameter.Idx,Reference.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_compartments_references` $$
CREATE PROCEDURE `get_compartments_references` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @compartmentIdx:=0;
SET @referenceIdx:=0;

SELECT
  Compartment.Idx CompartmentIdx,
  Compartment.WID CompartmentWID,
  Compartment.XID Compartment,
  Reference.Idx ReferenceIdx,
  Reference.WID ReferenceWID,
  Reference.XID Reference
FROM

(SELECT @compartmentIdx:=@compartmentIdx+1 AS Idx,Compartment.WID, DBID.XID
 FROM Compartment
 JOIN DBID ON DBID.OtherWID=Compartment.WID
 WHERE Compartment.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Compartment

JOIN CitationWIDOtherWID ON Compartment.WID=CitationWIDOtherWID.OtherWID

JOIN
(SELECT @referenceIdx:=@referenceIdx+1 AS Idx,Citation.WID, DBID.XID
  FROM Citation
  JOIN DBID ON Citation.WID=DBID.OtherWID
  WHERE Citation.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Reference
ON CitationWIDOtherWID.CitationWID=Reference.WID

WHERE (_WID IS NULL || (Compartment.WID=_WID || Reference.WID=_WID))
GROUP BY Compartment.Idx,Reference.Idx
ORDER BY Compartment.Idx,Reference.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_metabolites_references` $$
CREATE PROCEDURE `get_metabolites_references` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @metaboliteIdx:=0;
SET @referenceIdx:=0;

SELECT
  Metabolite.Idx MetaboliteIdx,
  Metabolite.WID MetaboliteWID,
  Metabolite.XID Metabolite,
  Reference.Idx ReferenceIdx,
  Reference.WID ReferenceWID,
  Reference.XID Reference
FROM

(SELECT @metaboliteIdx:=@metaboliteIdx+1 AS Idx,Chemical.WID, DBID.XID
 FROM Chemical
 JOIN DBID ON DBID.OtherWID=Chemical.WID
 WHERE Chemical.DataSetWID=_KnowledgeBaseWID
 ORDER BY DBID.XID
) AS Metabolite

JOIN CitationWIDOtherWID ON Metabolite.WID=CitationWIDOtherWID.OtherWID

JOIN
(SELECT @referenceIdx:=@referenceIdx+1 AS Idx,Citation.WID, DBID.XID
  FROM Citation
  JOIN DBID ON Citation.WID=DBID.OtherWID
  WHERE Citation.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Reference
ON CitationWIDOtherWID.CitationWID=Reference.WID

WHERE (_WID IS NULL || (Metabolite.WID=_WID || Reference.WID=_WID))
GROUP BY Metabolite.Idx,Reference.Idx
ORDER BY Metabolite.Idx,Reference.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_genes_references` $$
CREATE PROCEDURE `get_genes_references` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @geneIdx:=0;
SET @referenceIdx:=0;

SELECT
  Gene.Idx GeneIdx,
  Gene.WID GeneWID,
  Gene.XID Gene,
  Reference.Idx ReferenceIdx,
  Reference.WID ReferenceWID,
  Reference.XID Reference
FROM

(SELECT @geneIdx:=@geneIdx+1 AS Idx,Gene.WID, DBID.XID
 FROM Gene
 JOIN DBID ON Gene.WID=DBID.OtherWID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS Gene

JOIN CitationWIDOtherWID ON Gene.WID=CitationWIDOtherWID.OtherWID

JOIN
(SELECT @referenceIdx:=@referenceIdx+1 AS Idx,Citation.WID, DBID.XID
  FROM Citation
  JOIN DBID ON Citation.WID=DBID.OtherWID
  WHERE Citation.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Reference
ON CitationWIDOtherWID.CitationWID=Reference.WID

WHERE (_WID IS NULL || (Gene.WID=_WID || Reference.WID=_WID))
GROUP BY Gene.Idx,Reference.Idx
ORDER BY Gene.Idx,Reference.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_transcriptionunits_references` $$
CREATE PROCEDURE `get_transcriptionunits_references` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @transcriptionUnitIdx:=0;
SET @referenceIdx:=0;

SELECT
  TranscriptionUnit.Idx TranscriptionUnitIdx,
  TranscriptionUnit.WID TranscriptionUnitWID,
  TranscriptionUnit.XID TranscriptionUnit,
  Reference.Idx ReferenceIdx,
  Reference.WID ReferenceWID,
  Reference.XID Reference
FROM

(SELECT @transcriptionUnitIdx:=@transcriptionUnitIdx+1 AS Idx,TranscriptionUnitComponent.TranscriptionUnitWID WID, DBID.XID
 FROM TranscriptionUnitComponent
 JOIN Gene ON TranscriptionUnitComponent.OtherWID=Gene.WID
 JOIN DBID ON DBID.OtherWID=TranscriptionUnitComponent.TranscriptionUnitWID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS TranscriptionUnit

JOIN CitationWIDOtherWID ON TranscriptionUnit.WID=CitationWIDOtherWID.OtherWID

JOIN
(SELECT @referenceIdx:=@referenceIdx+1 AS Idx,Citation.WID, DBID.XID
  FROM Citation
  JOIN DBID ON Citation.WID=DBID.OtherWID
  WHERE Citation.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Reference
ON CitationWIDOtherWID.CitationWID=Reference.WID

WHERE (_WID IS NULL || (TranscriptionUnit.WID=_WID || Reference.WID=_WID))
GROUP BY TranscriptionUnit.Idx,Reference.Idx
ORDER BY TranscriptionUnit.Idx,Reference.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_genomefeatures_references` $$
CREATE PROCEDURE `get_genomefeatures_references` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @genomeFeatureIdx:=0;
SET @referenceIdx:=0;

SELECT
  GenomeFeature.Idx GenomeFeatureIdx,
  GenomeFeature.WID GenomeFeatureWID,
  GenomeFeature.XID GenomeFeature,
  Reference.Idx ReferenceIdx,
  Reference.WID ReferenceWID,
  Reference.XID Reference
FROM

(SELECT @genomeFeatureIdx:=@genomeFeatureIdx+1 AS Idx,Feature.WID, DBID.XID
 FROM Feature
 JOIN NucleicAcid ON Feature.SequenceWID=NucleicAcid.WID
 JOIN DBID ON DBID.OtherWID=Feature.WID
 WHERE Feature.DataSetWID=_KnowledgeBaseWID && NucleicAcid.DataSetWID=_KnowledgeBaseWID && Feature.SequenceType='N'
 ORDER BY Feature.StartPosition
) AS GenomeFeature

JOIN CitationWIDOtherWID ON GenomeFeature.WID=CitationWIDOtherWID.OtherWID

JOIN
(SELECT @referenceIdx:=@referenceIdx+1 AS Idx,Citation.WID, DBID.XID
  FROM Citation
  JOIN DBID ON Citation.WID=DBID.OtherWID
  WHERE Citation.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Reference
ON CitationWIDOtherWID.CitationWID=Reference.WID

WHERE (_WID IS NULL || (GenomeFeature.WID=_WID || Reference.WID=_WID))
GROUP BY GenomeFeature.Idx,Reference.Idx
ORDER BY GenomeFeature.Idx,Reference.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteinmonomers_references` $$
CREATE PROCEDURE `get_proteinmonomers_references` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinMonomerIdx:=0;
SET @referenceIdx:=0;

SELECT
  ProteinMonomer.Idx ProteinMonomerIdx,
  ProteinMonomer.WID ProteinMonomerWID,
  ProteinMonomer.XID ProteinMonomer,
  Reference.Idx ReferenceIdx,
  Reference.WID ReferenceWID,
  Reference.XID Reference
FROM

(SELECT @proteinMonomerIdx:=@proteinMonomerIdx+1 AS Idx,GeneWIDProteinWID.ProteinWID WID, DBID.XID
 FROM GeneWIDProteinWID
 JOIN Gene ON GeneWIDProteinWID.GeneWID=Gene.WID
 JOIN DBID ON DBID.OtherWID=GeneWIDProteinWID.ProteinWID
 WHERE Gene.DataSetWID=_KnowledgeBaseWID
 ORDER BY Gene.CodingRegionStart
) AS ProteinMonomer

JOIN CitationWIDOtherWID ON ProteinMonomer.WID=CitationWIDOtherWID.OtherWID

JOIN
(SELECT @referenceIdx:=@referenceIdx+1 AS Idx,Citation.WID, DBID.XID
  FROM Citation
  JOIN DBID ON Citation.WID=DBID.OtherWID
  WHERE Citation.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Reference
ON CitationWIDOtherWID.CitationWID=Reference.WID

WHERE (_WID IS NULL || (ProteinMonomer.WID=_WID || Reference.WID=_WID))
GROUP BY ProteinMonomer.Idx,Reference.Idx
ORDER BY ProteinMonomer.Idx,Reference.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_proteincomplexs_references` $$
CREATE PROCEDURE `get_proteincomplexs_references` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @proteinComplexIdx:=0;
SET @referenceIdx:=0;

SELECT
  ProteinComplex.Idx ProteinComplexIdx,
  ProteinComplex.WID ProteinComplexWID,
  ProteinComplex.XID ProteinComplex,
  Reference.Idx ReferenceIdx,
  Reference.WID ReferenceWID,
  Reference.XID Reference
FROM

(SELECT @proteinComplexIdx:=@proteinComplexIdx+1 AS Idx,Protein.WID, DBID.XID
  FROM Protein
  JOIN Subunit ON Subunit.ComplexWID=Protein.WID
  JOIN DBID ON DBID.OtherWID=Protein.WID
  WHERE Protein.DataSetWID=_KnowledgeBaseWID
  GROUP BY Protein.WID
  ORDER BY DBID.XID
) AS ProteinComplex

JOIN CitationWIDOtherWID ON ProteinComplex.WID=CitationWIDOtherWID.OtherWID

JOIN
(SELECT @referenceIdx:=@referenceIdx+1 AS Idx,Citation.WID, DBID.XID
  FROM Citation
  JOIN DBID ON Citation.WID=DBID.OtherWID
  WHERE Citation.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Reference
ON CitationWIDOtherWID.CitationWID=Reference.WID

WHERE (_WID IS NULL || (ProteinComplex.WID=_WID || Reference.WID=_WID))
GROUP BY ProteinComplex.Idx,Reference.Idx
ORDER BY ProteinComplex.Idx,Reference.Idx;

END $$




DROP PROCEDURE IF EXISTS `get_reactions_references` $$
CREATE PROCEDURE `get_reactions_references` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @reactionIdx:=0;
SET @referenceIdx:=0;

SELECT
  Reaction.Idx ReactionIdx,
  Reaction.WID ReactionWID,
  Reaction.XID Reaction,
  Reference.Idx ReferenceIdx,
  Reference.WID ReferenceWID,
  Reference.XID Reference
FROM

(SELECT @reactionIdx:=@reactionIdx+1 AS Idx,Reaction.WID, DBID.XID
 FROM Reaction
JOIN ReactionWIDOtherWID ON ReactionWIDOtherWID.ReactionWID=Reaction.WID
 JOIN DBID ON DBID.OtherWID=Reaction.WID
  WHERE Reaction.DataSetWID=_KnowledgeBaseWID
  GROUP BY Reaction.WID
 ORDER BY DBID.XID
) AS Reaction

JOIN CitationWIDOtherWID ON Reaction.WID=CitationWIDOtherWID.OtherWID

JOIN
(SELECT @referenceIdx:=@referenceIdx+1 AS Idx,Citation.WID, DBID.XID
  FROM Citation
  JOIN DBID ON Citation.WID=DBID.OtherWID
  WHERE Citation.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Reference
ON CitationWIDOtherWID.CitationWID=Reference.WID

WHERE (_WID IS NULL || (Reaction.WID=_WID || Reference.WID=_WID))
GROUP BY Reaction.Idx,Reference.Idx
ORDER BY Reaction.Idx,Reference.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_pathways_references` $$
CREATE PROCEDURE `get_pathways_references` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @pathwayIdx:=0;
SET @referenceIdx:=0;

SELECT
  Pathway.Idx PathwayIdx,
  Pathway.WID PathwayWID,
  Pathway.XID Pathway,
  Reference.Idx ReferenceIdx,
  Reference.WID ReferenceWID,
  Reference.XID Reference
FROM

(SELECT @pathwayIdx:=@pathwayIdx+1 AS Idx,Pathway.WID, DBID.XID
  FROM Pathway
  JOIN DBID ON Pathway.WID=DBID.OtherWID
  WHERE Pathway.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Pathway

JOIN CitationWIDOtherWID ON Pathway.WID=CitationWIDOtherWID.OtherWID

JOIN
(SELECT @referenceIdx:=@referenceIdx+1 AS Idx,Citation.WID, DBID.XID
  FROM Citation
  JOIN DBID ON Citation.WID=DBID.OtherWID
  WHERE Citation.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Reference
ON CitationWIDOtherWID.CitationWID=Reference.WID

WHERE (_WID IS NULL || (Pathway.WID=_WID || Reference.WID=_WID))
GROUP BY Pathway.Idx,Reference.Idx
ORDER BY Pathway.Idx,Reference.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_stimulis_references` $$
CREATE PROCEDURE `get_stimulis_references` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @stimulusIdx:=0;
SET @referenceIdx:=0;

SELECT
  Stimulus.Idx StimuliIdx,
  Stimulus.WID StimulusWId,
  Stimulus.XID Stimulus,
  Reference.Idx ReferenceIdx,
  Reference.WID ReferenceWID,
  Reference.XID Reference
FROM

(SELECT @stimulusIdx:=@stimulusIdx+1 AS Idx,Stimulus.WID, DBID.XID
  FROM Stimulus
  JOIN DBID ON Stimulus.WID=DBID.OtherWID
  WHERE Stimulus.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Stimulus

JOIN CitationWIDOtherWID ON Stimulus.WID=CitationWIDOtherWID.OtherWID

JOIN
(SELECT @referenceIdx:=@referenceIdx+1 AS Idx,Citation.WID, DBID.XID
  FROM Citation
  JOIN DBID ON Citation.WID=DBID.OtherWID
  WHERE Citation.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID) AS Reference
ON CitationWIDOtherWID.CitationWID=Reference.WID

WHERE (_WID IS NULL || (Stimulus.WID=_WID || Reference.WID=_WID))
GROUP BY Stimulus.Idx,Reference.Idx
ORDER BY Stimulus.Idx,Reference.Idx;

END $$

DROP PROCEDURE IF EXISTS `get_notes_references` $$
CREATE PROCEDURE `get_notes_references` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET @noteIdx:=0;
SET @referenceIdx:=0;

SELECT
  Note.Idx NoteIdx,
  Note.WID NoteWID,
  Note.XID Note,
  Reference.Idx ReferenceIdx,
  Reference.WID ReferenceWID,
  Reference.XID Reference
FROM

(SELECT @noteIdx:=@noteIdx+1 AS Idx, Description.OtherWID WID, DBID.XID
  FROM Entry
  JOIN Description ON Entry.OtherWID=Description.OtherWID
  JOIN DBID ON Description.OtherWID=DBID.OtherWID
  WHERE Entry.DataSetWID=_KnowledgeBaseWID && Description.TableName='DataSet'
  GROUP BY Entry.OtherWID
  ORDER BY DBID.XID
) AS Note

JOIN CitationWIDOtherWID ON Note.WID=CitationWIDOtherWID.OtherWID

JOIN
(SELECT @referenceIdx:=@referenceIdx+1 AS Idx,Citation.WID, DBID.XID
  FROM Citation
  JOIN DBID ON Citation.WID=DBID.OtherWID
  WHERE Citation.DataSetWID=_KnowledgeBaseWID
  ORDER BY DBID.XID
) AS Reference
ON CitationWIDOtherWID.CitationWID=Reference.WID

WHERE (_WID IS NULL || (Note.WID=_WID || Reference.WID=_WID))
GROUP BY Note.Idx,Reference.Idx
ORDER BY Note.Idx,Reference.Idx;

END $$


-- ---------------------------------------------------------
-- notes
-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS `set_note` $$
CREATE PROCEDURE `set_note` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

DECLARE _NoteWID bigint;
DECLARE _ContactWID bigint;

SELECT OtherWID INTO _NoteWID FROM Description WHERE OtherWID=_WID;
IF _NoteWID IS NULL THEN
    INSERT INTO Description (OtherWID, TableName)
    VALUES (_WID, 'DataSet');
ELSE
    UPDATE Description
    SET
        TableName='DataSet'
    WHERE OtherWID=_WID;
END IF;

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_note` $$
CREATE PROCEDURE `delete_note` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

DELETE FROM Description WHERE OtherWID=_WID;

call delete_entry(_WID);

END $$


DROP PROCEDURE IF EXISTS `get_notes` $$
CREATE PROCEDURE `get_notes` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SET SESSION group_concat_max_len=65536;
SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Entry.OtherWID WID,
  DBID.XID WholeCellModelID

FROM Entry
JOIN Description ON Entry.OtherWID=Description.OtherWID
JOIN DBID ON Description.OtherWID=DBID.OtherWID
WHERE
  Entry.DataSetWID=_KnowledgeBaseWID &&
  Description.TableName='DataSet' &&
  (_WID IS NULL || Description.OtherWID=_WID)
GROUP BY Entry.OtherWID
ORDER BY DBID.XID;

END $$

#############################################################
## simulation
#############################################################

/*
BioWarehouse Schema Details
- SaveExperiment creates a 'Experiment' entry in BioWarehouse
  - shortDescription->Experiment.Type
  - longDescription->Experiment.Description
- parameters,timeCourses represented as 'ExperimentData' entry
  - field name->DBID.BioCycID
  - Description->ExperimentData.Role (<=50 characters)
  - Value->ExperimentData.Data
  - Units->RelatedTerm
- First Name, Last Name, Email represented in Contact Table
  - First Name->Contact.FirstName
  - Last Name->Contact.LastName
  - Email->Contact.Email
- Code represented as entry in 'Archive' Table
  - Code->Archive.Content (zip archive of files)
*/

-- ---------------------------------------------------------
-- save
-- ---------------------------------------------------------

## create simulation
DROP PROCEDURE IF EXISTS `set_simulation` $$
CREATE PROCEDURE `set_simulation` (IN _ShortDescription varchar(50), IN _LongDescription text,IN _ContactWID bigint,
  IN _Revision bigint, IN _DifferencesFromRevision longtext, IN _UserName varchar(255),IN _HostName varchar(255),IN _IPAddress varchar(255),IN _OutputDirectory text,
  IN _Length float, IN _SegmentStep float,IN _SampleStep float, 
  IN _StartDate datetime, IN _EndDate datetime, 
  IN _KnowledgeBaseWID bigint)
BEGIN

DECLARE _SimulationWID bigint;
DECLARE _ArchiveWID bigint;

CALL set_entry('T',_KnowledgeBaseWID,_SimulationWID,NULL);
CALL set_entry('F',_KnowledgeBaseWID,_ArchiveWID,NULL);

CALL set_dbid(_SimulationWID,CONCAT_WS('-','Simulation',_Revision,_StartDate,_IPAddress));
CALL set_dbid(_ArchiveWID,CONCAT_WS('-','Simulation-Archive',_Revision,_StartDate,_IPAddress));

INSERT INTO Archive(WID,OtherWID,Format,Contents,DataSetWID) VALUES(_ArchiveWID,_SimulationWID,'text',CAST(_DifferencesFromRevision AS BINARY),_KnowledgeBaseWID);

INSERT INTO Experiment(
  WID,ContactWID,ArchiveWID,Type,Description,UserName,
  HostName, IPAddress, OutputDirectory, Length, SegmentStep, SampleStep, StartDate, EndDate, DataSetWID)
VALUES(
  _SimulationWID,_ContactWID,_ArchiveWID,_ShortDescription,_LongDescription,_UserName,
  _HostName, _IPAddress, _OutputDirectory, _Length, _SegmentStep, _SampleStep, _StartDate, _EndDate, _KnowledgeBaseWID);

SELECT _SimulationWID WID;

END $$


## set simulation load error to false
DROP PROCEDURE IF EXISTS `set_simulation_success` $$
CREATE PROCEDURE `set_simulation_success` (IN _WID bigint)
BEGIN

CALL set_entry_success(_WID);
SELECT _WID WID;

END $$

## create parameter entry
DROP PROCEDURE IF EXISTS `set_simulation_option` $$
CREATE PROCEDURE `set_simulation_option` (IN _Module varchar(255),
  IN _Name varchar(150), IN _Description varchar(50), IN _Value longtext, 
  IN _SimulationWID bigint, IN _KnowledgeBaseWID bigint)
BEGIN

CALL set_simulation_data(_Module, _Name, 'Q', _Description, _Value, NULL, false, NULL, _SimulationWID, _KnowledgeBaseWID);

END $$

## create parameter entry
DROP PROCEDURE IF EXISTS `set_simulation_parameter` $$
CREATE PROCEDURE `set_simulation_parameter` (IN _Module varchar(255),
  IN _Name varchar(150), IN _Index varchar(50), IN _Value longtext, IN _SimulationWID bigint,
  IN _KnowledgeBaseWID bigint)
BEGIN

DECLARE _ParameterWID bigint;

IF _Module='' THEN
  SET _Module=NULL;
END IF;
IF _Index='' THEN
  SET _Index=NULL;
END IF;
IF _Value='' THEN
  SET _Value=NULL;
END IF;

SELECT Parameter.WID INTO _ParameterWID
FROM Parameter
LEFT JOIN (SELECT * FROM ParameterWIDOtherWID WHERE Type='Process' || Type='State') AS ParameterWIDOtherWID ON Parameter.WID=ParameterWIDOtherWID.ParameterWID
LEFT JOIN DBID ON ParameterWIDOtherWID.OtherWID=DBID.OtherWID
WHERE
  Parameter.Name=_Name &&
  (Parameter.Identifier=_Index || (Parameter.Identifier IS NULL && _Index IS NULL))&&
  Parameter.DataSetWID=_KnowledgeBaseWID &&
  (DBID.XID=_Module || (DBID.XID IS NULL && _Module IS NULL));

CALL set_simulation_data(_Module, NULL,'P',NULL,_Value,NULL,false,_ParameterWID,_SimulationWID,_KnowledgeBaseWID);

END $$

## create fitted constant entry
DROP PROCEDURE IF EXISTS `set_simulation_fittedconstant` $$
CREATE PROCEDURE `set_simulation_fittedconstant` (IN _Module varchar(255),
  IN _Name varchar(150), IN _Description varchar(50), IN _Value longtext, IN _Units varchar(255),
  IN _SimulationWID bigint, IN _KnowledgeBaseWID bigint)
BEGIN

CALL set_simulation_data(_Module,_Name,'C',_Description,_Value,_Units,true,NULL,_SimulationWID,_KnowledgeBaseWID);

END $$

## create fitted constant entry
DROP PROCEDURE IF EXISTS `set_simulation_randstreamstate` $$
CREATE PROCEDURE `set_simulation_randstreamstate` (IN _Module varchar(255),
  IN _Name varchar(150), IN _Description varchar(50), IN _Value longtext, IN _Units varchar(255),
  IN _SimulationWID bigint, IN _KnowledgeBaseWID bigint)
BEGIN

CALL set_simulation_data(_Module,_Name,'R',_Description,_Value,_Units,true,NULL,_SimulationWID,_KnowledgeBaseWID);

END $$

## create time course entry
DROP PROCEDURE IF EXISTS `set_simulation_timecourse` $$
CREATE PROCEDURE `set_simulation_timecourse` (IN _Module varchar(255),
  IN _Name varchar(150), IN _Description varchar(50), IN _Value longtext, IN _Units varchar(255),
  IN _SimulationWID bigint, IN _KnowledgeBaseWID bigint)
BEGIN

CALL set_simulation_data(_Module, _Name,'O',_Description,_Value,_Units,true,NULL,_SimulationWID,_KnowledgeBaseWID);

END $$

## create data entry
DROP PROCEDURE IF EXISTS `set_simulation_data` $$
CREATE PROCEDURE `set_simulation_data` (IN _Module varchar(255),
  IN _Name varchar(150), IN _Kind char(1), IN _Description varchar(50), IN _Value longtext, IN _Units varchar(255), IN _CompressValue bool,
  IN _ParameterWID bigint, IN _SimulationWID bigint, IN _KnowledgeBaseWID bigint)
BEGIN

DECLARE _DataWID bigint;
DECLARE _ModuleWID bigint;
DECLARE _UnitsWID bigint;

SELECT Entry.OtherWID INTO _ModuleWID FROM Entry JOIN DBID ON Entry.OtherWID=DBID.OtherWID WHERE Entry.DataSetWID=_KnowledgeBaseWID && DBID.XID=_Module;

CALL set_entry('T',_KnowledgeBaseWID,_DataWID,NULL);

INSERT INTO ExperimentData(WID,Kind,Role,Data,MageData,ModuleWID,ExperimentWID,DataSetWID)
  VALUES(_DataWID,_Kind,_Description,IF(_CompressValue,COMPRESS(_Value),_Value),_ParameterWID,_ModuleWID,_SimulationWID,_KnowledgeBaseWID);
IF _Name IS NOT NULL THEN
  INSERT INTO DBID(OtherWID,XID,Type)
  VALUES(_DataWID,_Name,'GUID');
END IF;

IF _Units IS NOT NULL THEN
  CALL set_units(_KnowledgeBaseWID, _UnitsWID, _Units);
ELSEIF _ParameterWID IS NOT NULL THEN
  SELECT Parameter.UnitsWID INTO _UnitsWID FROM Parameter WHERE WID=_ParameterWID;
END IF;

IF _UnitsWID IS NOT NULL THEN
  INSERT INTO RelatedTerm(OtherWID,TermWID,Relationship) VALUES(_DataWID,_UnitsWID,'units');
END IF;

CALL set_entry_success(_DataWID);

SELECT _DataWID WID;

END $$

-- ---------------------------------------------------------
-- retrieve
-- ---------------------------------------------------------

## get_simulation_list
DROP PROCEDURE IF EXISTS `get_simulations` $$
CREATE PROCEDURE `get_simulations` (IN _KnowledgeBaseWID bigint, IN _WholeCellModelID varchar(255))
BEGIN

SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Experiment.WID,
  Experiment.WID WholeCellModelID,
  Experiment.Type ShortDescription,
  Experiment.Description LongDescription,
  SUBSTRING_INDEX(SUBSTRING_INDEX(DBID.XID,'-',2),'-',-1)+0 Revision,
  CONCAT_WS(' ',Contact.FirstName,Contact.LastName) Investigator,
  Experiment.StartDate StartDate
FROM Experiment
JOIN Contact ON Experiment.ContactWID=Contact.WID
JOIN DBID ON Experiment.WID=DBID.OtherWID
WHERE Experiment.DataSetWID=_KnowledgeBaseWID && (_WholeCellModelID IS NULL || Experiment.WID=_WholeCellModelID)
ORDER BY Experiment.Type ASC,Experiment.StartDate DESC,Experiment.WID DESC;

END $$

## get latest simulation
DROP PROCEDURE IF EXISTS `get_latest_simulation` $$
CREATE PROCEDURE `get_latest_simulation` (IN _KnowledgeBaseWID bigint)
BEGIN

SELECT
  Experiment.WID,
  Experiment.WID WholeCellModelID,
  Experiment.Type ShortDescription,
  Experiment.Description LongDescription,
  SUBSTRING_INDEX(SUBSTRING_INDEX(DBID.XID,'-',2),'-',-1)+0 Revision,
  CONCAT_WS(' ',Contact.FirstName,Contact.LastName) Investigator,
  Experiment.StartDate StartDate
FROM Experiment
JOIN Contact ON Experiment.ContactWID=Contact.WID
JOIN DBID ON Experiment.WID=DBID.OtherWID
WHERE Experiment.DataSetWID=_KnowledgeBaseWID
ORDER BY Experiment.StartDate DESC
LIMIT 1;

END $$


## get_simulation_summary
DROP PROCEDURE IF EXISTS `get_simulation_summary` $$
CREATE PROCEDURE `get_simulation_summary` (IN _SimulationWID bigint)
BEGIN

SELECT
  Experiment.DataSetWID KnowledgeBaseWID,
  Experiment.WID,
  Experiment.Type ShortDescription,
  SUBSTRING_INDEX(SUBSTRING_INDEX(DBID.XID,'-',2),'-',-1)+0 Revision, CONVERT(Archive.Contents USING latin1) DifferencesFromRevision,
  CONCAT_WS(' ',Contact.FirstName,Contact.LastName) Investigator,
  Contact.FirstName, Contact.LastName, Contact.Email, Affiliation.Name Affiliation,
  Experiment.UserName,  Experiment.HostName, Experiment.IPAddress, Experiment.OutputDirectory, 
  Experiment.Length,
  Experiment.SegmentStep, Experiment.SampleStep,
  Experiment.StartDate,
  Experiment.EndDate,
  Experiment.Description LongDescription
FROM Experiment
JOIN Contact ON Experiment.ContactWID=Contact.WID
JOIN Contact Affiliation ON Contact.Affiliation=Affiliation.WID
JOIN Archive ON Experiment.ArchiveWID=Archive.WID
JOIN DBID ON Experiment.WID=DBID.OtherWID
WHERE Experiment.WID=_SimulationWID;

END $$

## get_simulaton_options
DROP PROCEDURE IF EXISTS `get_simulation_options` $$
CREATE PROCEDURE `get_simulation_options` (IN _SimulationWID bigint)
BEGIN

CALL get_simulation_data(_SimulationWID,'Q',false);

END $$

## get_simulaton_parameters
DROP PROCEDURE IF EXISTS `get_simulation_parameters` $$
CREATE PROCEDURE `get_simulation_parameters` (IN _SimulationWID bigint)
BEGIN

CALL get_simulation_data(_SimulationWID,'P',false);

END $$

## get_simulaton_parameters
DROP PROCEDURE IF EXISTS `get_simulation_fittedconstants` $$
CREATE PROCEDURE `get_simulation_fittedconstants` (IN _SimulationWID bigint)
BEGIN

CALL get_simulation_data(_SimulationWID,'C',true);

END $$

## get_simulaton_parameters
DROP PROCEDURE IF EXISTS `get_simulation_randstreamstates` $$
CREATE PROCEDURE `get_simulation_randstreamstates` (IN _SimulationWID bigint)
BEGIN

CALL get_simulation_data(_SimulationWID,'R',true);

END $$

## get_simulation_timecourses
DROP PROCEDURE IF EXISTS `get_simulation_timecourses` $$
CREATE PROCEDURE `get_simulation_timecourses` (IN _SimulationWID bigint)
BEGIN

CALL get_simulation_data(_SimulationWID,'O',true);

END $$

## get_simulation_data
DROP PROCEDURE IF EXISTS `get_simulation_data` $$
CREATE PROCEDURE `get_simulation_data` (IN _SimulationWID bigint, IN _Kind char(1), IN _UnCompressValue bool)
BEGIN

SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  ExperimentData.WID,
  ModuleDBID.XID Module,
  IF(Parameter.WID IS NOT NULL,Parameter.Name,DBID.XID) Name,
  Parameter.Identifier `Index`,
  IF(Parameter.WID IS NOT NULL,Parameter.Description,ExperimentData.Role) Description,
  IF(_UnCompressValue,UNCOMPRESS(ExperimentData.Data),ExperimentData.Data) Value,
  Parameter.DefaultValue, Term.Name Units
FROM ExperimentData

#name
LEFT JOIN DBID ON DBID.OtherWID=ExperimentData.WID

#parameter
LEFT JOIN Parameter ON Parameter.WID=ExperimentData.MageData

#process
LEFT JOIN DBID ModuleDBID ON ModuleDBID.OtherWID=ExperimentData.ModuleWID

#units
LEFT JOIN (SELECT * FROM RelatedTerm where Relationship='units') AS RelatedTerm ON RelatedTerm.OtherWID=ExperimentData.WID
LEFT JOIN Term ON Term.WID=RelatedTerm.TermWID

WHERE
  ExperimentData.Kind=_Kind &&
  ExperimentWID=_SimulationWID
ORDER BY DBID.XID ASC;

END $$


## get_simulation_archive
DROP PROCEDURE IF EXISTS `get_simulation_codearchive` $$
CREATE PROCEDURE `get_simulation_codearchive` (IN _SimulationWID bigint)
BEGIN

SELECT DBID.XID+0 Revision, Archive.Contents DifferencesFromRevision
FROM Archive
JOIN DBID ON Archive.WID = DBID.OtherWID
WHERE Archive.OtherWID = _SimulationWID;

END $$

-- ---------------------------------------------------------
-- delete
-- ---------------------------------------------------------

DROP PROCEDURE IF EXISTS `delete_simulation` $$
CREATE PROCEDURE `delete_simulation` (IN _SimulationWID bigint)
BEGIN

DELETE FROM Archive WHERE OtherWID=_SimulationWID;
DELETE FROM ExperimentData WHERE ExperimentWID=_SimulationWID;
DELETE FROM Experiment WHERE WID=_SimulationWID;

SELECT _SimulationWID WID;

END $$

DROP PROCEDURE IF EXISTS `delete_simulations` $$
CREATE PROCEDURE `delete_simulations` (IN _KnowledgeBaseWID bigint)
BEGIN

DELETE FROM Archive WHERE DataSetWID=_KnowledgeBaseWID;
DELETE FROM ExperimentData WHERE DataSetWID=_KnowledgeBaseWID;
DELETE FROM Experiment WHERE DataSetWID=_KnowledgeBaseWID;

SELECT _KnowledgeBaseWID WID;

END $$

#############################################################
## contacts
#############################################################

## create contact
DROP PROCEDURE IF EXISTS `set_contact` $$
CREATE PROCEDURE `set_contact` (IN _FirstName varchar(255),IN _LastName varchar(255),IN _Email varchar(255),IN _Affiliation varchar(255),IN _DataSetWID bigint)
BEGIN

DECLARE _ContactWID bigint;
DECLARE _AffiliationWID bigint;

SELECT WID INTO _AffiliationWID FROM Contact WHERE Name=_Affiliation && Email IS NULL && DataSetWID=_DataSetWID;
IF _AffiliationWID IS NULL THEN
  CALL set_entry('T',_DataSetWID,_AffiliationWID,NULL);
  INSERT INTO Contact(WID,Name,DataSetWID) VALUES(_AffiliationWID,_Affiliation,_DataSetWID);
END IF;

SELECT WID INTO _ContactWID FROM Contact WHERE Email=_Email && DataSetWID=_DataSetWID;
IF _ContactWID IS NULL THEN
  CALL set_entry('T',_DataSetWID,_ContactWID,NULL);
  INSERT INTO Contact(WID,FirstName,LastName,Email,Affiliation,DataSetWID) VALUES(_ContactWID,_FirstName,_LastName,_Email,_AffiliationWID,_DataSetWID);
END IF;

SELECT _ContactWID WID;

END $$

## get contacts
DROP PROCEDURE IF EXISTS `get_contacts` $$
CREATE PROCEDURE `get_contacts` (IN _DataSetWID bigint)
BEGIN

SET @Idx:=0;

SELECT
  @Idx:=@Idx+1 AS Idx,
  Contact.WID,Contact.LastName,Contact.FirstName,Contact.Email,Affiliation.Name Affiliation
FROM Contact
JOIN Contact Affiliation ON Contact.Affiliation=Affiliation.WID
WHERE
  Contact.DataSetWID=_DataSetWID && Contact.Email IS NOT NULL &&
  Affiliation.DataSetWID=_DataSetWID && Affiliation.Email IS NULL
ORDER BY LastName,FirstName;

END $$

## get contact wid
DROP PROCEDURE IF EXISTS `get_contact` $$
CREATE PROCEDURE `get_contact` (IN _Email varchar(255),IN _DataSetWID bigint)
BEGIN

SELECT Contact.WID,Contact.LastName,Contact.FirstName,Contact.Email,Affiliation.Name Affiliation
FROM Contact
JOIN Contact Affiliation ON Contact.Affiliation=Affiliation.WID
WHERE
  Contact.DataSetWID=_DataSetWID && Contact.Email=_Email &&
  Affiliation.DataSetWID=_DataSetWID && Affiliation.Email IS NULL
LIMIT 1;

END $$

#############################################################
## helper procedures
#############################################################

## create new special entry
DROP PROCEDURE IF EXISTS `set_dataset` $$
CREATE PROCEDURE `set_dataset` (IN _WID bigint, IN _Name varchar(255), IN _Version varchar(50),
  IN _HomeURL varchar(255), IN _QueryURL varchar(255), IN _LoadedBy varchar(255),
  IN _Application varchar(255), IN _ApplicationVersion varchar(255))
BEGIN

UPDATE DataSet
SET 
    Name=_Name,
    Version=_Version,
    HomeURL=_HomeURL,
    QueryURL=_QueryURL,
    LoadedBy=_LoadedBy,
    Application=_Application,
    ApplicationVersion=_ApplicationVersion
WHERE DataSet.WID=_WID;

END $$

## create new entry
DROP PROCEDURE IF EXISTS `set_knowledgebaseobject` $$
CREATE PROCEDURE `set_knowledgebaseobject` (
  IN _KnowledgeBaseWID bigint, IN _WID bigint, IN _WholeCellModelID varchar(150), IN _Comment longtext, IN _UserID bigint)
BEGIN

IF _KnowledgeBaseWID IS NULL THEN
    #create dataset
    SELECT PreviousWID INTO _KnowledgeBaseWID FROM SpecialWIDTable;
    UPDATE SpecialWIDTable SET PreviousWID=_KnowledgeBaseWID+1;

    INSERT INTO DataSet(WID, LoadDate)
    VALUES(_KnowledgeBaseWID, CURRENT_TIMESTAMP());
	
	INSERT INTO Entry(OtherWID,LoadError,InsertDate,ModifiedDate,InsertUserID,ModifiedUserID,DataSetWID)
    VALUES(_KnowledgeBaseWID,'F',CURRENT_TIMESTAMP(),CURRENT_TIMESTAMP(),_UserID,_UserID,_KnowledgeBaseWID);

    SET _WID=_KnowledgeBaseWID;
END IF;

CALL set_entry('F', _KnowledgeBaseWID, _WID, _UserID);
CALL set_dbid(_WID, _WholeCellModelID);
CALL set_comment(_WID, _Comment);

SELECT _WID WID;

END $$

DROP PROCEDURE IF EXISTS `get_knowledgebaseobjects` $$
CREATE PROCEDURE `get_knowledgebaseobjects` (
  IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SELECT 
  Entry.OtherWID WID, DBID.XID WholeCellModelID, 
  Entry.InsertDate, Entry.ModifiedDate,
  InsertUser.UserName InsertUser, ModifiedUser.UserName ModifiedUser
FROM Entry
JOIN DBID ON Entry.OtherWID=DBID.OtherWID
JOIN User InsertUser ON Entry.InsertUserID=InsertUser.ID
JOIN User ModifiedUser ON Entry.ModifiedUserID=ModifiedUser.ID
WHERE 
  Entry.DataSetWID=_KnowledgeBaseWID &&
  (_WID IS NULL || Entry.OtherWID=_WID);

END $$

## create new entry
DROP PROCEDURE IF EXISTS `set_entry` $$
CREATE PROCEDURE `set_entry` (IN _LoadError char(1), IN _DataSetWID bigint, INOUT _WID bigint, IN _UserID bigint)
BEGIN

IF _WID IS NULL THEN
    SELECT PreviousWID INTO _WID FROM WIDTable;
    SET _WID=_WID+1;
    UPDATE WIDTable SET PreviousWID=_WID;

    INSERT INTO Entry(OtherWID,LoadError,InsertDate,ModifiedDate,InsertUserID,ModifiedUserID,DataSetWID)
    VALUES(_WID,_LoadError,CURRENT_TIMESTAMP(),CURRENT_TIMESTAMP(),_UserID,_UserID,_DataSetWID);
ELSE
    UPDATE Entry
    SET 
		ModifiedDate=CURRENT_TIMESTAMP(),
		ModifiedUserID=_UserID
    WHERE Entry.OtherWID=_WID;
END IF;

END $$

#set entry load error to false
DROP PROCEDURE IF EXISTS `set_entry_success` $$
CREATE PROCEDURE `set_entry_success` (IN _WID bigint)
BEGIN

UPDATE Entry SET LoadError='F' WHERE OtherWID=_WID;

END $$

DROP PROCEDURE IF EXISTS `delete_entry` $$
CREATE PROCEDURE `delete_entry` (IN _WID bigint)
BEGIN

DELETE InteractionParticipant, Interaction
FROM InteractionParticipant
JOIN Interaction ON Interaction.WID=InteractionParticipant.InteractionWID
JOIN InteractionParticipant InteractionParticipant2 ON InteractionParticipant2.InteractionWID=InteractionParticipant.InteractionWID
WHERE InteractionParticipant.OtherWID=_WID || Interaction.WID=_WID;

DELETE FROM Feature WHERE SequenceWID=_WID || Feature.WID=_WID;

DELETE FROM DBID WHERE OtherWID=_WID;
DELETE FROM SynonymTable WHERE OtherWID=_WID;
DELETE FROM CrossReference WHERE OtherWID=_WID;
DELETE FROM CommentTable WHERE OtherWID=_WID;
DELETE FROM CitationWIDOtherWID WHERE OtherWID=_WID;
DELETE FROM TextSearch WHERE OtherWID=_WID;
DELETE FROM Entry WHERE OtherWID=_WID;

END $$

#new synonym
DROP PROCEDURE IF EXISTS `set_dbid` $$
CREATE PROCEDURE `set_dbid` (IN _WID bigint, IN _XID varchar(150))
BEGIN

DELETE FROM DBID WHERE OtherWID=_WID;
INSERT INTO DBID(OtherWID,XID,Type) Values(_WID,_XID,'GUID');
CALL set_textsearch(_WID, _XID, 'Whole Cell Model ID');

END $$

#new synonym
DROP PROCEDURE IF EXISTS `set_synonyms` $$
CREATE PROCEDURE `set_synonyms` (IN _WID bigint, IN _Synonyms text)
BEGIN

DECLARE _Synonym varchar(50);
DECLARE _idx smallint default 1;
DECLARE _maxIdx smallint;
DECLARE _count smallint;

DELETE FROM SynonymTable WHERE OtherWID=_WID;

SET _maxIdx=(LENGTH(_Synonyms)-LENGTH(REPLACE(_Synonyms, ';', ''))+1);

WHILE _idx<=_maxIdx DO
  SET _Synonym=SUBSTRING_INDEX(SUBSTRING_INDEX(_Synonyms,";",_idx),";",-1);
  IF _Synonym IS NOT NULL THEN
	INSERT INTO SynonymTable(OtherWID,Syn) Values(_WID,_Synonym);
  END IF;
  SET _idx=_idx+1;
END WHILE;

CALL set_textsearch(_WID, REPLACE(_Synonyms,';',' '), 'synonym');

END $$

#new crossreference
DROP PROCEDURE IF EXISTS `set_crossreference` $$
CREATE PROCEDURE `set_crossreference` (IN _WID bigint, IN _XIDs text,
  IN _DatabaseName varchar(255), IN _DatabaseRelationship varchar(50), IN _DatabaseType varchar(50))
BEGIN

DECLARE _XID varchar(50);
DECLARE _idx smallint default 1;
DECLARE _nXR smallint;
DECLARE _count smallint;

DELETE FROM CrossReference
WHERE
    OtherWID=_WID &&
    DatabaseName=_DatabaseName &&
    Relationship=_DatabaseRelationship;

SET _nXR=(LENGTH(_XIDs)-LENGTH(REPLACE(_XIDs, ';', ''))+1);

WHILE _idx<=_nXR DO
    SET _XID=SUBSTRING_INDEX(SUBSTRING_INDEX(_XIDs,";",_idx),";",-1);
    IF _XID IS NOT NULL THEN
        INSERT INTO CrossReference(OtherWID, XID, Type, Relationship, DatabaseName)
        Values(_WID, _XID, _DatabaseType, _DatabaseRelationship, _DatabaseName);
    END IF;
    SET _idx=_idx+1;
END WHILE;

CALL set_textsearch(_WID, REPLACE(_XIDs,';',' '), CONCAT_WS(' - ', 'cross reference', _DatabaseRelationship, _DatabaseName));

END $$

DROP PROCEDURE IF EXISTS `get_crossreferences` $$
CREATE PROCEDURE `get_crossreferences` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SELECT
    Entry.OtherWID WID,
    DBID.XID WholeCellModelID,
    GROUP_CONCAT(DISTINCT CrossReference.XID ORDER BY CrossReference.XID SEPARATOR ';') CrossReference,
    CrossReference.DatabaseName,
    CrossReference.Relationship DatabaseRelationship,
    CrossReference.Type DatabaseType
FROM (
  SELECT Entry.OtherWID, Entry.DataSetWID 
  FROM Entry 
  WHERE 
    DataSetWID=_KnowledgeBaseWID &&
    (_WID IS NULL || Entry.OtherWID=_WID)
  
  UNION
  
  SELECT DataSet.WID OtherWID, DataSet.WID DataSetWID 
  FROM DataSet 
  WHERE 
    WID=_KnowledgeBaseWID &&
    (_WID IS NULL || DataSet.WID=_WID)
  ) AS Entry
JOIN DBID ON Entry.OtherWID=DBID.OtherWID
JOIN CrossReference ON Entry.OtherWID=CrossReference.OtherWID
WHERE
    Entry.DataSetWID=_KnowledgeBaseWID &&
    (_WID IS NULL || Entry.OtherWID=_WID)
GROUP BY Entry.OtherWID, CrossReference.DatabaseName, CrossReference.Relationship
ORDER BY DBID.XID, CrossReference.DatabaseName, CrossReference.Relationship;

END $$

#new comment
DROP PROCEDURE IF EXISTS `set_comment` $$
CREATE PROCEDURE `set_comment` (IN _WID bigint, IN _Comment longtext)
BEGIN

DELETE FROM CommentTable WHERE OtherWID=_WID;

IF _Comment IS NOT NULL THEN
  INSERT INTO CommentTable(OtherWID,Comm) Values(_WID,_Comment);
  CALL set_textsearch(_WID, _Comment, 'comment');
END IF;

END $$

DROP PROCEDURE IF EXISTS `get_comments` $$
CREATE PROCEDURE `get_comments` (IN _KnowledgeBaseWID bigint, IN _WID bigint)
BEGIN

SELECT
    Entry.OtherWID WID,
    DBID.XID WholeCellModelID,
    CommentTable.Comm Comments
FROM (
  SELECT Entry.OtherWID, Entry.DataSetWID 
  FROM Entry 
  WHERE 
    DataSetWID=_KnowledgeBaseWID &&
    (_WID IS NULL || Entry.OtherWID=_WID)
    
  UNION
  
  SELECT DataSet.WID OtherWID, DataSet.WID DataSetWID 
  FROM DataSet 
  WHERE 
    WID=_KnowledgeBaseWID &&
    (_WID IS NULL || DataSet.WID=_WID)
  ) AS Entry
JOIN DBID ON Entry.OtherWID=DBID.OtherWID
JOIN CommentTable ON Entry.OtherWID=CommentTable.OtherWID
WHERE
    Entry.DataSetWID=_KnowledgeBaseWID &&
    (_WID IS NULL || Entry.OtherWID=_WID);

END $$

DROP PROCEDURE IF EXISTS `set_units` $$
CREATE PROCEDURE `set_units` (IN _KnowledgeBaseWID bigint, OUT _UnitsWID bigint, IN _Units varchar(255))
BEGIN

SELECT WID INTO _UnitsWID FROM Term WHERE DataSetWID=_KnowledgeBaseWID && Name=_Units;
IF _UnitsWID IS NULL THEN
  CALL set_entry('F',_KnowledgeBaseWID,_UnitsWID,NULL);
  INSERT INTO Term(WID,Name,DataSetWID) VALUES(_UnitsWID,_Units,_KnowledgeBaseWID);
END IF;

END $$

DROP PROCEDURE IF EXISTS `set_textsearch` $$
CREATE PROCEDURE `set_textsearch` (IN _WID bigint,IN _Text longtext, IN _Type varchar(255))
BEGIN

DELETE FROM TextSearch WHERE OtherWID=_WID && Type=_Type;
IF _Text IS NOT NULL THEN
	INSERT INTO TextSearch(OtherWID, Text, Type) VALUES(_WID, _Text, _Type);
END IF;

END $$

DROP PROCEDURE IF EXISTS `index_textsearch` $$
CREATE PROCEDURE `index_textsearch` (IN _KnowledgeBaseWID bigint)
BEGIN

DROP Table IF EXISTS TextSearch;
CREATE TABLE IF NOT EXISTS TextSearch (
	OtherWID bigint NOT NULL,
	Text longtext NOT NULL,
	Type varchar(255) NOT NULL,
	KEY `OtherWID` (`OtherWID`),
	KEY `Type` (`Type`)
) Engine=MyISAM AS
SELECT * FROM (
	SELECT Entry.OtherWID, DBID.XID Text, 'Whole Cell Model ID' Type
  FROM Entry JOIN DBID ON Entry.OtherWID=DBID.OtherWID
  WHERE (_KnowledgeBaseWID IS NULL || Entry.DataSetWID=_KnowledgeBaseWID)

  UNION
  
  SELECT Entry.OtherWID, SynonymTable.Syn Text, 'synonym' Type
  FROM Entry JOIN SynonymTable ON Entry.OtherWID=SynonymTable.OtherWID
  WHERE (_KnowledgeBaseWID IS NULL || Entry.DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Entry.OtherWID, CommentTable.Comm Text, 'comments'
  FROM Entry JOIN CommentTable ON CommentTable.OtherWID=Entry.OtherWID
  WHERE (_KnowledgeBaseWID IS NULL || Entry.DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Entry.OtherWID, CrossReference.XID Text, CONCAT_WS(' - ','cross reference',CrossReference.Type) Type
  FROM Entry JOIN CrossReference ON CrossReference.OtherWID=Entry.OtherWID
  WHERE (_KnowledgeBaseWID IS NULL || Entry.DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Process.WID OtherWID, Process.Name Text, 'name' Type FROM Process WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION
  
  SELECT State.WID OtherWID, State.Name Text, 'name' Type FROM State WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Compartment.WID OtherWID, Compartment.Name Text, 'name' Type FROM Compartment WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Pathway.WID OtherWID, Pathway.Name Text, 'name' Type FROM Pathway WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Gene.WID OtherWID, Gene.Name Text, 'name' Type FROM Gene WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT TranscriptionUnit.WID OtherWID, TranscriptionUnit.Name Text, 'name' Type FROM TranscriptionUnit WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Feature.WID OtherWID, Feature.Description Text, 'name' Type FROM Feature WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID) && SequenceWID IS NOT NULL

  UNION

  SELECT Protein.WID OtherWID, Protein.Name Text, 'name' Type FROM Protein WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Reaction.WID OtherWID, Reaction.Name Text, 'name' Type FROM Reaction WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Chemical.WID OtherWID, Chemical.Name Text, 'name' Type FROM Chemical WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Stimulus.WID OtherWID, Stimulus.Name Text, 'name' Type FROM Stimulus WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Citation.WID OtherWID, Citation.PMID Text, 'cross reference - PubMed ID' Type FROM Citation WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Citation.WID OtherWID, Citation.ISBN Text, 'cross reference - ISBN' Type FROM Citation WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Citation.WID OtherWID, Citation.Authors Text, 'authors' Type FROM Citation WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Citation.WID OtherWID, Citation.Editor Text, 'editor' Type FROM Citation WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Citation.WID OtherWID, Citation.Title Text, 'title' Type FROM Citation WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Citation.WID OtherWID, Citation.Publication Text, 'publication' Type FROM Citation WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Citation.WID OtherWID, Citation.Publisher Text, 'publisher' Type FROM Citation WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)

  UNION

  SELECT Citation.WID OtherWID, Citation.URI Text, 'URL' Type FROM Citation WHERE (_KnowledgeBaseWID IS NULL || DataSetWID=_KnowledgeBaseWID)
) AS TextSearch
WHERE TextSearch.Text IS NOT NULL;
CREATE FULLTEXT INDEX `Text` ON TextSearch (`Text`);

END $$

## create knowledgebase pathway
DROP PROCEDURE IF EXISTS `get_knowledgebase_biosourcewid` $$
CREATE PROCEDURE `get_knowledgebase_biosourcewid` (IN _KnowledgeBaseWID bigint,OUT _BioSourceWID bigint)
BEGIN

SELECT WID INTO _BioSourceWID FROM BioSource WHERE DataSetWID=_KnowledgeBaseWID;

END $$


## parse stoichiometry strings
DROP PROCEDURE IF EXISTS `parseStoichiometry` $$
CREATE PROCEDURE `parseStoichiometry` (IN _KnowledgeBaseWID bigint,
  IN _Stoichiometry text,IN _Delimeter varchar(255),IN _Direction char(1), IN _ReactantsOrProducts smallint, IN _Idx smallint,
  OUT _ObjectWID bigint, OUT _CompartmentWID bigint, OUT _Coefficient float)
BEGIN

DECLARE _ObjectXID varchar(255);
DECLARE _CompartmentXID varchar(255);

IF LOCATE(':',_Stoichiometry)>0 THEN
  SET _CompartmentXID = SUBSTRING_INDEX(SUBSTRING_INDEX(_Stoichiometry,'[',-1),']:',1);
  SET _Stoichiometry = RIGHT(_Stoichiometry, CHAR_LENGTH(_Stoichiometry)-CHAR_LENGTH(_CompartmentXID)-4);
END IF;

IF _ReactantsOrProducts IS NOT NULL THEN
  SET _Stoichiometry=SUBSTRING_INDEX(_Stoichiometry,CONCAT(' ',IF(_Direction='R','<==>',IF(_Direction='F','==>','<==')),' '),_ReactantsOrProducts*-1);
END IF;

SET _Stoichiometry = SUBSTRING_INDEX(SUBSTRING_INDEX(_Stoichiometry,_Delimeter,_Idx),_Delimeter,-1);

IF LOCATE(' ',_Stoichiometry)>0 THEN
  SET _Coefficient=SUBSTRING_INDEX(SUBSTRING_INDEX(_Stoichiometry,'(',-1),')',1);
  SET _Stoichiometry=SUBSTRING_INDEX(_Stoichiometry,' ',-1);
ELSE
  SET _Coefficient=1;
END IF;

IF LOCATE('[',_Stoichiometry)>0 THEN
  SET _CompartmentXID=SUBSTRING_INDEX(SUBSTRING_INDEX(_Stoichiometry,'[',-1),']',1);
  SET _ObjectXID=SUBSTRING_INDEX(_Stoichiometry,'[',1);
ELSE
  SET _ObjectXID=_Stoichiometry;
END IF;

SELECT Entry.OtherWID INTO _ObjectWID
FROM Entry
JOIN DBID ON DBID.OtherWID=Entry.OtherWID
WHERE Entry.DataSetWID=_KnowledgeBaseWID && DBID.XID=_ObjectXID;

SELECT Entry.OtherWID INTO _CompartmentWID
FROM Entry
JOIN DBID ON DBID.OtherWID=Entry.OtherWID
WHERE Entry.DataSetWID=_KnowledgeBaseWID && DBID.XID=_CompartmentXID;

END $$

#############################################################
## users
#############################################################

DROP PROCEDURE IF EXISTS `set_user` $$
CREATE PROCEDURE `set_user` (IN _UserName varchar(20), IN _Password varchar(20), 
	IN _FirstName varchar(255), IN _MiddleName varchar(255), IN _LastName varchar(255),
	IN _Affiliation varchar(255), IN _Email varchar(255))
BEGIN

DECLARE _ID bigint;

SELECT ID INTO _ID 
FROM User
WHERE UserName=_UserName;

IF _ID IS NULL THEN
	INSERT INTO User(UserName,Password, FirstName, MiddleName, LastName, Affiliation, Email) 
	VALUES(_UserName, _Password, _FirstName, _MiddleName, _LastName, _Affiliation, _Email);

	SELECT 1 Status, MAX(ID) ID FROM User;
ELSE
	SELECT 0 Status, NULL ID;
END IF;

END $$

DROP PROCEDURE IF EXISTS `delete_user` $$
CREATE PROCEDURE `delete_user` (IN _UserName varchar(20))
BEGIN

DELETE FROM User WHERE UserName=_UserName;

END $$

DROP PROCEDURE IF EXISTS `loginuser` $$
CREATE PROCEDURE `loginuser` (IN _UserName varchar(20), IN _Password varchar(20))
BEGIN

SELECT * 
FROM User
WHERE 
	UserName=_UserName &&
	Password=_Password
LIMIT 1;

END $$

#############################################################
## helper functions
#############################################################

DROP FUNCTION IF EXISTS `composeStoichiometry` $$
CREATE FUNCTION `composeStoichiometry`(_ObjectXID varchar(255),_CompartmentXID varchar(255),_Coefficient float)
	RETURNS varchar(255)
BEGIN

RETURN
  CONCAT(
    IF(_Coefficient!=1,
      CONCAT("(",_Coefficient,") "),
      ""),
    _ObjectXID,
    IF(_CompartmentXID IS NOT NULL,CONCAT("[",_CompartmentXID,"]"),""));

END $$

DROP FUNCTION IF EXISTS `dnaSequenceReverseComplement` $$
CREATE FUNCTION `dnaSequenceReverseComplement`(_sequence longtext, _direction varchar(25))
	RETURNS longtext
BEGIN

IF _direction='forward' THEN
  RETURN _sequence;
ELSE
  RETURN
    REPLACE(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(
              REPLACE(
                REVERSE(_sequence),
                'T','x'),
              'A','T'),
            'x','A'),
          'C','x'),
        'G','C'),
      'x','G');
END IF;

END $$