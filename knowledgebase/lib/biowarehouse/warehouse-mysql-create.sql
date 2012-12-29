CREATE TABLE Warehouse
(
  Version  DECIMAL(6,3)  NOT NULL,
  LoadDate  DATETIME  NOT NULL,
  MaxSpecialWID  BIGINT  NOT NULL,
  MaxReservedWID  BIGINT  NOT NULL,
  Description  TEXT
  --
) TYPE=INNODB;



INSERT INTO Warehouse (Version, LoadDate, MaxSpecialWID, MaxReservedWID)
        VALUES (4.1, now(), 999, 999999);
    

CREATE TABLE WIDTable
(
  PreviousWID  BIGINT  NOT NULL AUTO_INCREMENT,
  --
  CONSTRAINT PK_WIDTable PRIMARY KEY (PreviousWID)
) TYPE=INNODB;



INSERT INTO WIDTable (PreviousWID) values (999999);

CREATE TABLE SpecialWIDTable
(
  PreviousWID  BIGINT  NOT NULL AUTO_INCREMENT,
  --
  CONSTRAINT PK_SpecialWIDTable PRIMARY KEY (PreviousWID)
) TYPE=INNODB;



INSERT INTO SpecialWIDTable (PreviousWID) values (1);

CREATE TABLE Enumeration
(
  TableName  VARCHAR(50)  NOT NULL,
  ColumnName  VARCHAR(50)  NOT NULL,
  Value  VARCHAR(50)  NOT NULL,
  Meaning  TEXT
  --
) TYPE=INNODB;



CREATE TABLE DataSet
(
  WID  BIGINT  NOT NULL,
  Name  VARCHAR(255)  NOT NULL,
  Version  VARCHAR(50),
  ReleaseDate  VARCHAR(50),
  LoadDate  DATETIME  NOT NULL,
  ChangeDate  DATETIME,
  HomeURL  VARCHAR(255),
  QueryURL  VARCHAR(255),
  LoadedBy  VARCHAR(255),
  Application  VARCHAR(255),
  ApplicationVersion  VARCHAR(255),
  --
  CONSTRAINT PK_DataSet1 PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Entry
(
  OtherWID  BIGINT  NOT NULL,
  InsertDate  DATETIME  NOT NULL,
  CreationDate  DATETIME,
  ModifiedDate  DATETIME,
  LoadError  CHAR(1)  NOT NULL,
  LineNumber  INT,
  ErrorMessage  TEXT,
  DatasetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_Entry PRIMARY KEY (OtherWID)
) TYPE=INNODB;



CREATE TABLE GeneExpressionData
(
  B  SMALLINT  NOT NULL,
  D  SMALLINT  NOT NULL,
  Q  SMALLINT  NOT NULL,
  Value  VARCHAR(100)  NOT NULL,
  BioAssayValuesWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE Element
(
  WID  BIGINT  NOT NULL,
  Name  VARCHAR(15)  NOT NULL,
  ElementSymbol  VARCHAR(2)  NOT NULL,
  AtomicWeight  FLOAT  NOT NULL,
  AtomicNumber  SMALLINT  NOT NULL,
  --
  CONSTRAINT PK_Element PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Valence
(
  OtherWID  BIGINT  NOT NULL,
  Valence  SMALLINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE LightSource
(
  WID  BIGINT  NOT NULL,
  Wavelength  FLOAT,
  Type  VARCHAR(100),
  InstrumentWID  BIGINT,
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_LightSource1 PRIMARY KEY (WID)
) TYPE=INNODB;

CREATE INDEX LightSource_DWID ON LightSource(DataSetWID);

INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('LightSource', 'Type', 'arc-lamp', 'A type of light source');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('LightSource', 'Type', 'argon-laser', 'An ion laser that uses argon gas to produce light');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('LightSource', 'Type', 'krypton-laser', 'An ion laser that uses krypton gas to produce light');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('LightSource', 'Type', 'argon-krypton-laser', 'An ion laser that uses a combination of krypton and argon gases to produce light');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('LightSource', 'Type', 'helium-neon-laser', 'A laser that uses helium and neon gases to produce light');

CREATE TABLE FlowCytometrySample
(
  WID  BIGINT  NOT NULL,
  BioSourceWID  BIGINT,
  FlowCytometryProbeWID  BIGINT,
  MeasurementWID  BIGINT,
  ManufacturerWID  BIGINT,
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_FlowCytometrySample1 PRIMARY KEY (WID)
) TYPE=INNODB;

CREATE INDEX FlowCytometrySample_DWID ON FlowCytometrySample(DataSetWID);


CREATE TABLE FlowCytometryProbe
(
  WID  BIGINT  NOT NULL,
  Type  VARCHAR(100)  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_FlowCytometryProbe1 PRIMARY KEY (WID)
) TYPE=INNODB;

CREATE INDEX FlowCytometryProbe_DWID ON FlowCytometryProbe(DataSetWID);

INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('FlowCytometryProbe', 'Type', 'acid-dye', 'An acid dye probe');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('FlowCytometryProbe', 'Type', 'antibody', 'An antibody probe');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('FlowCytometryProbe', 'Type', 'reporter', 'A protein probe');

CREATE TABLE TranscriptionUnit
(
  WID  BIGINT  NOT NULL,
  Name  VARCHAR(255)  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_TranscriptionUnit1 PRIMARY KEY (WID)
) TYPE=INNODB;

CREATE INDEX TranscriptionUnit_DWID ON TranscriptionUnit(DataSetWID);


CREATE TABLE TranscriptionUnitComponent
(
  Type  VARCHAR(100)  NOT NULL,
  TranscriptionUnitWID  BIGINT  NOT NULL,
  OtherWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;


INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('TranscriptionUnitComponent', 'Type', 'gene', '');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('TranscriptionUnitComponent', 'Type', 'binding site', '');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('TranscriptionUnitComponent', 'Type', 'promoter', '');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('TranscriptionUnitComponent', 'Type', 'terminator', '');

CREATE TABLE Chemical
(
  WID  BIGINT  NOT NULL,
  Name  VARCHAR(255)  NOT NULL,
  Class  CHAR(1),
  BeilsteinName  VARCHAR(50),
  SystematicName  VARCHAR(255),
  CAS  VARCHAR(50),
  Charge  SMALLINT,
  EmpiricalFormula  VARCHAR(50),
  MolecularWeightCalc  FLOAT,
  MolecularWeightExp  FLOAT,
  OctH2OPartitionCoeff  VARCHAR(50),
  PKA1  FLOAT,
  PKA2  FLOAT,
  PKA3  FLOAT,
  WaterSolubility  CHAR(1),
  Smiles  VARCHAR(255),
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_Chemical1 PRIMARY KEY (WID)
) TYPE=INNODB;

CREATE INDEX CHEMICAL_DWID_NAME ON Chemical(DataSetWID, Name);
CREATE INDEX CHEMICAL_NAME ON Chemical(Name);


CREATE TABLE Reaction
(
  WID  BIGINT  NOT NULL,
  Name  VARCHAR(250),
  DeltaG  VARCHAR(50),
  ECNumber  VARCHAR(50),
  ECNumberProposed  VARCHAR(50),
  Spontaneous  CHAR(1),
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_Reaction PRIMARY KEY (WID)
) TYPE=INNODB;

CREATE INDEX REACTION_DWID ON Reaction(DataSetWID);


CREATE TABLE Interaction
(
  WID  BIGINT  NOT NULL,
  Type  VARCHAR(100),
  Name  VARCHAR(120),
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_Interaction PRIMARY KEY (WID)
) TYPE=INNODB;

CREATE INDEX INTERACTION_DWID ON Interaction(DataSetWID);


CREATE TABLE Protein
(
  WID  BIGINT  NOT NULL,
  Name  TEXT,
  AASequence  LONGTEXT,
  Length  INT,
  LengthApproximate  VARCHAR(10),
  Charge  SMALLINT,
  Fragment  CHAR(1),
  MolecularWeightCalc  FLOAT,
  MolecularWeightExp  FLOAT,
  PICalc  VARCHAR(50),
  PIExp  VARCHAR(50),
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_Protein PRIMARY KEY (WID)
) TYPE=INNODB;

CREATE INDEX PROTEIN_DWID ON Protein(DataSetWID);


CREATE TABLE Feature
(
  WID  BIGINT  NOT NULL,
  Description  VARCHAR(1300),
  Type  VARCHAR(50),
  Class  VARCHAR(50),
  SequenceType  CHAR(1)  NOT NULL,
  SequenceWID  BIGINT,
  RegionOrPoint  VARCHAR(10),
  PointType  VARCHAR(10),
  StartPosition  INT,
  EndPosition  INT,
  StartPositionApproximate  VARCHAR(10),
  EndPositionApproximate  VARCHAR(10),
  ExperimentalSupport  CHAR(1),
  ComputationalSupport  CHAR(1),
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_Feature PRIMARY KEY (WID)
) TYPE=INNODB;


INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'Class', 'binding site', 'Identifies the presence of a DNA binding site');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'Class', 'promoter', 'Identifies the presence of a promoter');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'Class', 'terminator', 'Identifies the presence of a terminator');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'Class', 'pseudogene', 'Identifies a pseudogene, whether non-transcribed or processed');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'Class', 'ORF', 'Identifies a truly unknown open reading frame according to warehouse definition (no strong evidence that a product is produced)');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'Class', 'partial', 'Qualifier: States that feature is not complete');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'Class', 'unknown product', 'Identifies an unspecified product is produced from this genomic location, as stated in dataset');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'Class', 'notable', 'Qualifier: Characterizes the feature value as notable (same as ''Exceptional'' in GB dataset)');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'Class', 'by similarity', 'Qualifier: states that feature was derived by similarity analysis');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'Class', 'potential', 'Qualifier: states that feature may be incorrect');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'Class', 'probably', 'Qualifier: states that feature is probably correct');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'SequenceType', 'P', 'Feature resides on a protein. Implies SequenceWID (if nonNULL) references a Protein');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'SequenceType', 'S', 'Feature resides on a nucleic acid. Implies SequenceWID is nonNULL and references a Subsequence');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'SequenceType', 'N', 'Feature resides on a nucleic acid. Implies SequenceWID (if nonNULL) references a NucleicAcid');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'RegionOrPoint', 'region', 'Feature is specified by a start point and an end point on the sequence');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'RegionOrPoint', 'point', 'Feature is specified by a single point on the sequence');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'PointType', 'center', 'Feature is centered at location.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'PointType', 'left', 'Feature extends to the left (decreasing position) of location.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'PointType', 'right', 'Feature extends to the right (increasing position) of location.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'StartPositionApproximate', 'gt', 'The start position of the feature is greater than the actual position specified.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'StartPositionApproximate', 'lt', 'The start position of the feature is less than the actual position specified.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'StartPositionApproximate', 'ne', 'The start position of the feature is less than or greater than the actual position. All we know is that its not the exact position.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'EndPositionApproximate', 'gt', 'The end position of the feature is greater than the actual position specified.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'EndPositionApproximate', 'lt', 'The end position of the feature is less than the actual position specified.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Feature', 'EndPositionApproximate', 'ne', 'The end position of the feature is less than or greater than the actual position. All we know is that its not the exact position.');

CREATE TABLE Function
(
  WID  BIGINT  NOT NULL,
  Name  VARCHAR(255),
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_Function PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE EnzymaticReaction
(
  WID  BIGINT  NOT NULL,
  ReactionWID  BIGINT  NOT NULL,
  ProteinWID  BIGINT  NOT NULL,
  ComplexWID  BIGINT,
  ReactionDirection  VARCHAR(30),
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_EnzymaticReaction PRIMARY KEY (WID)
) TYPE=INNODB;

CREATE INDEX ER_DATASETWID ON EnzymaticReaction(DataSetWID);

INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('EnzymaticReaction', 'ReactionDirection', 'reversible', 'Reaction occurs in both directions in physiological settings.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('EnzymaticReaction', 'ReactionDirection', 'physiol-left-to-right', 'Reaction occurs in the left-to-right direction in physiological settings.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('EnzymaticReaction', 'ReactionDirection', 'physiol-right-to-left', 'Reaction occurs in the right-to-left direction in physiological settings.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('EnzymaticReaction', 'ReactionDirection', 'irreversible-left-to-right', 'For all practical purposes, the reaction occurs only in the left-to-right direction in physiological settings, because of chemical properties of the reaction.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('EnzymaticReaction', 'ReactionDirection', 'irreversible-right-to-left', 'For all practical purposes, the reaction occurs only in the right-to-left direction in physiological settings, because of chemical properties of the reaction.');

CREATE TABLE GeneticCode
(
  WID  BIGINT  NOT NULL,
  NCBIID  VARCHAR(2),
  Name  VARCHAR(100),
  TranslationTable  VARCHAR(64),
  StartCodon  VARCHAR(64),
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_GeneticCode PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Division
(
  WID  BIGINT  NOT NULL,
  Code  VARCHAR(10),
  Name  VARCHAR(100),
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_Division PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Taxon
(
  WID  BIGINT  NOT NULL,
  ParentWID  BIGINT,
  Name  VARCHAR(100),
  Rank  VARCHAR(100),
  DivisionWID  BIGINT,
  InheritedDivision  CHAR(1),
  GencodeWID  BIGINT,
  InheritedGencode  CHAR(1),
  MCGencodeWID  BIGINT,
  InheritedMCGencode  CHAR(1),
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_Taxon PRIMARY KEY (WID)
) TYPE=INNODB;


INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'no rank', 'Origin:NCBI- Taxonomy databaseOrigin:NCBI- Taxonomy database. Parent: none');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'forma', 'Origin:NCBI- Taxonomy database.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'varietas', 'Origin:NCBI- Taxonomy database');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'subspecies', 'Origin:NCBI- Taxonomy database Parent: species');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'species', 'Origin:NCBI- Taxonomy database. Parent: species subgroup');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'species subgroup', 'Origin:NCBI- Taxonomy database. Parent: species group');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'species group', 'Origin:NCBI- Taxonomy database. Parent: subgenus');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'subgenus', 'Origin:NCBI- Taxonomy database. Parent: genus');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'genus', 'Origin:NCBI- Taxonomy database. Parent: subtribe');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'subtribe', 'Origin:NCBI- Taxonomy database. Parent: tribe');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'tribe', 'Origin:NCBI- Taxonomy database. Parent: subfamily');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'subfamily', 'Origin:NCBI- Taxonomy database. Parent: family');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'family', 'Origin:NCBI- Taxonomy database Parent:superfamily');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'superfamily', 'Origin:NCBI- Taxonomy database. Parent: infraorder');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'infraorder', 'Origin:NCBI- Taxonomy database. Parent: parvorder');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'parvorder', 'Origin:NCBI- Taxonomy database. Parent: suborder');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'suborder', 'Origin:NCBI- Taxonomy database. Parent:order');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'order', 'Origin:NCBI- Taxonomy database Parent:superorder');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'superorder', 'Origin:NCBI- Taxonomy database. Parent: infraclass');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'infraclass', 'Origin:NCBI- Taxonomy database. Parent: subclass');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'subclass', 'Origin:NCBI- Taxonomy database.Parent: class');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'class', 'Origin:NCBI- Taxonomy database. Parent:superclass');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'superclass', 'Origin:NCBI- Taxonomy database. Parent: subphylum');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'subphylum', 'Origin:NCBI- Taxonomy database. Parent: phylum.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'phylum', 'Origin:NCBI- Taxonomy database.Parent:superphylum');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'superphylum', 'Origin:NCBI- Taxonomy database. Parent:kingdom');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'kingdom', 'Origin:NCBI- Taxonomy database. Parent:superkingdom');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'superkingdom', 'Origin:NCBI- Taxonomy database. Parent: root');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Taxon', 'Rank', 'root', 'Origin:NCBI- Taxonomy database');

CREATE TABLE BioSource
(
  WID  BIGINT  NOT NULL,
  MAGEClass  VARCHAR(100),
  TaxonWID  BIGINT,
  Name  VARCHAR(200),
  Strain  VARCHAR(220),
  Organ  VARCHAR(50),
  Organelle  VARCHAR(50),
  Tissue  VARCHAR(100),
  CellType  VARCHAR(50),
  CellLine  VARCHAR(50),
  ATCCId  VARCHAR(50),
  Diseased  CHAR(1),
  Disease  VARCHAR(250),
  DevelopmentStage  VARCHAR(50),
  Sex  VARCHAR(15),
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_BioSource PRIMARY KEY (WID)
) TYPE=INNODB;


INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('BioSource', 'Sex', 'Male', 'Sex of organism is male');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('BioSource', 'Sex', 'Female', 'Sex of organism is female');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('BioSource', 'Sex', 'Hermaphrodite', 'Sex of organism is hermaphrodite');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('BioSource', 'Sex', 'DoesNotApply', 'The notion of a sex does not apply to this organism');

CREATE TABLE BioSubtype
(
  WID  BIGINT  NOT NULL,
  Type  VARCHAR(25),
  Value  VARCHAR(50)  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_BioSubtype PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE NucleicAcid
(
  WID  BIGINT  NOT NULL,
  Name  VARCHAR(200),
  Type  VARCHAR(30)  NOT NULL,
  Class  VARCHAR(30),
  Topology  VARCHAR(30),
  Strandedness  VARCHAR(30),
  SequenceDerivation  VARCHAR(30),
  Fragment  CHAR(1),
  FullySequenced  CHAR(1),
  MoleculeLength  INT,
  MoleculeLengthApproximate  VARCHAR(10),
  CumulativeLength  INT,
  CumulativeLengthApproximate  VARCHAR(10),
  GeneticCodeWID  BIGINT,
  BioSourceWID  BIGINT,
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_NucleicAcid PRIMARY KEY (WID)
) TYPE=INNODB;


INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Type', 'DNA', 'The molecule is composed of DNA');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Type', 'RNA', 'The molecule is composed of RNA');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Type', 'NA', 'The molecule is specified as a nucleic acid but whether of type DNA or RNA is not known');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Class', 'pre-RNA', 'As it exists within the organism, the molecule is a pre-RNA molecule. NCBI: used when there is no evidence that mature RNA is produced');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Class', 'mRNA', 'As it exists within the organism, the molecule is a mature mRNA. NCBI: used when there is evidence that mature mRNA is produced');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Class', 'rRNA', 'As it exists within the organism, the molecule is an rRNA; NCBI used when there is evidence that mature rRNA is produced');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Class', 'tRNA', 'As it exists within the organism, the molecule is a tRNA; NCBI: used when there is evidence that mature tRNA is produced');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Class', 'snRNA', 'As it exists within the organism, the molecule is a small nuclear RNA. NCBI: used when there is evidence that snRNA is produced');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Class', 'scRNA', 'As it exists within the organism, the molecule is an RNA which encodes small cytoplasmic ribonucleic proteins. NCBI: used when there is evidence that gene codes of small cytoplasmic (sc) ribonucleoproteins (RNP)s');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Class', 'snoRNA', 'As it exists within the organism, the molecule is a small nucleolar RNA. NCBI: used when there is evidence that transcript is a small nucleolar RNA');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Class', 'other', 'Check notes as to how we map this...');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Class', 'chromosome', 'As it exists within the organism, the molecule is a chromosome');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Class', 'plasmid', 'As it exists within the organism, the molecule is a plasmid');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Class', 'organelle-chromosome', 'As it exists within the organism, the molecule is the chromosome of an organelle');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Class', 'transposon', 'As it exists within the organism, the molecule is a transposon');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Class', 'virus', 'As it exists within the organism, the molecule is a virus');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Class', 'unknown', 'Used when the class is unknown');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Topology', 'linear', 'The topology of the molecule is Linear');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Topology', 'circular', 'The topology of the molecule is Circular');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Topology', 'other', 'The topology of the molecule is neither circular nor linear but is known');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Strandedness', 'ss', 'The molecule is single stranded');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Strandedness', 'ds', 'The molecule is double stranded');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'Strandedness', 'mixed', 'The molecule is composed of single and double stranded regions');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'SequenceDerivation', 'virtual', 'NCBI: The sequence of the molecule is NOT known. NOTE: this should map to null.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'SequenceDerivation', 'raw', 'POORLY DEFINED; seems to be used to indicate that the sequence of the molecule was actually generated from one single continuous molecule, as opposed to assembled together from sequences from different molecules (e.g., different clones)');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'SequenceDerivation', 'seg', 'NCBI: The sequence of the molecule is made up of collection of segments arranged according to specified coordinates, e.g., sequence was derived from assembling sequences from different clones');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'SequenceDerivation', 'reference', 'NCBI: The sequence of the molecule is constructed from existing Bioseqs;It behaves exactly like a segmented Bioseq in taking it''s data and character from the Bioseq to which it points.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'SequenceDerivation', 'constructed', 'NCBI: The sequence of the molecule is constructed by assembling other Bioseqs');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'SequenceDerivation', 'consensus', 'NCBI: The sequence of the molecule represents a pattern typical of a sequence region or family of sequences;'' it summarizes attributes of an aligned collection of real sequences. Note that this is NOT A REAL OBJECT');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'SequenceDerivation', 'map', 'NCBI: The molecule does not have a sequence describing it, but rather a set of coordinates (restriction fragment order, genetic markers, physical map, etc)');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'MoleculeLengthApproximate', 'gt', 'The length of the molecule''s sequence is greater than the actual length specified');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'MoleculeLengthApproximate', 'lt', 'The length of the molecule''s sequence is less than the actual length specified');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'MoleculeLengthApproximate', 'ne', 'The length of the molecule''s sequence is less than or greater than the actual length. All we know is that its not the exact length');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'CumulativeLengthApproximate', 'gt', 'The total length of the molecule''s sequence is greater than the actual length');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'CumulativeLengthApproximate', 'lt', 'The total length of the molecule''s sequence is less than the actual length');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('NucleicAcid', 'CumulativeLengthApproximate', 'ne', 'The total length of the molecule''s sequence is less than or greater than the actual length. All we know is that its not the exact length');

CREATE TABLE Subsequence
(
  WID  BIGINT  NOT NULL,
  NucleicAcidWID  BIGINT  NOT NULL,
  FullSequence  CHAR(1),
  Sequence  LONGTEXT,
  Length  INT,
  LengthApproximate  VARCHAR(10),
  PercentGC  FLOAT,
  Version  VARCHAR(30),
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_Subsequence PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Gene
(
  WID  BIGINT  NOT NULL,
  Name  VARCHAR(255),
  NucleicAcidWID  BIGINT,
  SubsequenceWID  BIGINT,
  Type  VARCHAR(100),
  GenomeID  VARCHAR(35),
  CodingRegionStart  INT,
  CodingRegionEnd  INT,
  CodingRegionStartApproximate  VARCHAR(10),
  CodingRegionEndApproximate  VARCHAR(10),
  Direction  VARCHAR(25),
  Interrupted  CHAR(1),
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_Gene PRIMARY KEY (WID)
) TYPE=INNODB;

CREATE INDEX GENE_DATASETWID ON Gene(DATASETWID);

INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Gene', 'Type', 'unknown', 'used when transcriptional status of gene is unknown');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Gene', 'Type', 'pre-RNA', 'used when there is no evidence that a mature RNA is ultimately produced by the gene');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Gene', 'Type', 'mRNA', 'used when there is evidence that a mature mRNA is ultimately produced by the gene');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Gene', 'Type', 'rRNA', 'used when there is evidence that a mature rRNA is ultimately produced by the gene');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Gene', 'Type', 'tRNA', 'used when there is evidence that a mature tRNA is ultimately produced by the gene');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Gene', 'Type', 'snRNA', 'used when there is evidence that an snRNA is ultimately produced by the gene');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Gene', 'Type', 'scRNA', '????');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Gene', 'Type', 'polypeptide', 'used when there is evidence that the ultimate product of this gene is proteinaceous');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Gene', 'Type', 'snoRNA', '???');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Gene', 'Type', 'other', 'catchall ?');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Gene', 'Direction', 'unknown', 'unknown the strand being transcribed is unknown');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Gene', 'Direction', 'forward', 'the plus strand is being transcribed');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Gene', 'Direction', 'reverse', 'the minus strand is being transcribed');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Gene', 'Direction', 'forward_and_reverse', 'both strands are being transcribed');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Gene', 'Direction', 'undefined_value', 'UNDEFINED; the NCBI documentation does not define this value');

CREATE TABLE Pathway
(
  WID  BIGINT  NOT NULL,
  Name  VARCHAR(255)  NOT NULL,
  Type  CHAR(1)  NOT NULL,
  BioSourceWID  BIGINT,
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_Pathway PRIMARY KEY (WID)
) TYPE=INNODB;

CREATE INDEX PATHWAY_BSWID_WID_DWID ON Pathway(BioSourceWID, WID, DataSetWID);
CREATE INDEX PATHWAY_TYPE_WID_DWID ON Pathway(TYPE, WID, DataSetWID);
CREATE INDEX PATHWAY_DWID ON Pathway(DataSetWID);

INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Pathway', 'Name', 'unknown', 'Name assigned when it is unknown or missing');

CREATE TABLE Term
(
  WID  BIGINT  NOT NULL,
  Name  VARCHAR(255)  NOT NULL,
  Definition  TEXT,
  Hierarchical  CHAR(1),
  Root  CHAR(1),
  Obsolete  CHAR(1),
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_Term PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Computation
(
  WID  BIGINT  NOT NULL,
  Name  VARCHAR(50)  NOT NULL,
  Description  TEXT,
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_Computation PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Citation
(
  WID  BIGINT  NOT NULL,
  Citation  TEXT,
  PMID  DECIMAL,
  Title  VARCHAR(255),
  Authors  VARCHAR(255),
  Publication  VARCHAR(255),
  Publisher  VARCHAR(255),
  Editor  VARCHAR(255),
  Year  VARCHAR(255),
  Volume  VARCHAR(255),
  Issue  VARCHAR(255),
  Pages  VARCHAR(255),
  URI  VARCHAR(255),
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_Citation PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Archive
(
  WID  BIGINT  NOT NULL,
  OtherWID  BIGINT  NOT NULL,
  Format  VARCHAR(10)  NOT NULL,
  Contents  LONGBLOB,
  URL  TEXT,
  ToolName  VARCHAR(50),
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_ARCHIVE PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Experiment
(
  WID  BIGINT  NOT NULL,
  Type  VARCHAR(50)  NOT NULL,
  ContactWID  BIGINT,
  ArchiveWID  BIGINT,
  StartDate  DATETIME,
  EndDate  DATETIME,
  Description  TEXT,
  GroupWID  BIGINT,
  GroupType  VARCHAR(50),
  GroupSize  INT  NOT NULL,
  GroupIndex  INT,
  TimePoint  INT,
  TimeUnit  VARCHAR(20),
  DataSetWID  BIGINT  NOT NULL,
  BioSourceWID  BIGINT,
  --
  CONSTRAINT PK_Experiment PRIMARY KEY (WID)
) TYPE=INNODB;


INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Experiment', 'GroupType', 'replicate', 'All subexperiments attempt to replicate identical experimental conditions and parameters');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Experiment', 'GroupType', 'variant', 'Subexperiments are variations upon an experimental procedure, technique, conditions, and/or parameters');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Experiment', 'GroupType', 'time-series', 'Subexperiments consist of observations according to a specific schedule');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Experiment', 'GroupType', 'step', 'Subexperiments comprise an experimental procedure and consist of an ordered sequence');

CREATE TABLE ExperimentData
(
  WID  BIGINT  NOT NULL,
  ExperimentWID  BIGINT  NOT NULL,
  Data  LONGTEXT,
  MageData  BIGINT,
  Role  VARCHAR(50)  NOT NULL,
  Kind  CHAR(1)  NOT NULL,
  DateProduced  DATETIME,
  OtherWID  BIGINT,
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_ExpData PRIMARY KEY (WID)
) TYPE=INNODB;


INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ExperimentData', 'Kind', 'O', 'Data is an observation');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ExperimentData', 'Kind', 'C', 'Data is computed from an observation');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ExperimentData', 'Kind', 'P', 'Data is a parameter to a procedure or compuatation');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ExperimentData', 'Kind', 'M', 'Data is metadata describing other data');

CREATE TABLE Support
(
  WID  BIGINT  NOT NULL,
  OtherWID  BIGINT  NOT NULL,
  Type  VARCHAR(100),
  Confidence  FLOAT,
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT CK_Support CHECK (Confidence > 0 AND Confidence <= 1),
  CONSTRAINT PK_Support PRIMARY KEY (WID)
) TYPE=INNODB;


INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Support', 'Type', 'computational', 'The warehouse fact is supported by a computational prediction (example: existence of a gene could be supported by a gene-finding program).');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('Support', 'Type', 'experimental', 'The warehouse fact is supported by data from a wet-lab experiment (example: existence of a gene could be supported observation of the gene''s mRNA product in a microarray experiment).');

CREATE TABLE ChemicalAtom
(
  ChemicalWID  BIGINT  NOT NULL,
  AtomIndex  SMALLINT  NOT NULL,
  Atom  VARCHAR(2)  NOT NULL,
  Charge  SMALLINT  NOT NULL,
  X  DECIMAL,
  Y  DECIMAL,
  Z  DECIMAL,
  StereoParity  DECIMAL,
  --
  CONSTRAINT UN_ChemicalAtom UNIQUE (ChemicalWID, AtomIndex)
) TYPE=INNODB;


INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalAtom', 'StereoParity', '0', 'Not stereo.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalAtom', 'StereoParity', '1', 'Odd parity.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalAtom', 'StereoParity', '2', 'Even parity.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalAtom', 'StereoParity', '3', 'Either or unmarked stereo center.');

CREATE TABLE ChemicalBond
(
  ChemicalWID  BIGINT  NOT NULL,
  Atom1Index  SMALLINT  NOT NULL,
  Atom2Index  SMALLINT  NOT NULL,
  BondType  SMALLINT  NOT NULL,
  BondStereo  DECIMAL
  --
) TYPE=INNODB;


INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalBond', 'BondType', '1', 'Single bond.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalBond', 'BondType', '2', 'Double bond.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalBond', 'BondType', '3', 'Triple bond.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalBond', 'BondType', '4', 'Aromatic bond.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalBond', 'BondType', '5', 'Single or double bond.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalBond', 'BondType', '6', 'Single or aromatic bond.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalBond', 'BondType', '7', 'Double or aromatic bond.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalBond', 'BondType', '8', 'Any bond.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalBond', 'BondStereo', '0', 'For single bonds, 0 = not stereo.   Four double bonds, 0 = use X,Y,Z coords to determine cis or trans.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalBond', 'BondStereo', '1', 'For single bonds, 1 = up.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalBond', 'BondStereo', '3', 'For double bonds, 3 = cis or trans (either) (presumably meaning unspecified or a mixture).');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalBond', 'BondStereo', '4', 'For single bonds, 4 = either.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('ChemicalBond', 'BondStereo', '6', 'For single bonds, 6 = down.');

CREATE TABLE EnzReactionCofactor
(
  EnzymaticReactionWID  BIGINT  NOT NULL,
  ChemicalWID  BIGINT  NOT NULL,
  Prosthetic  CHAR(1)
  --
) TYPE=INNODB;



CREATE TABLE EnzReactionAltCompound
(
  EnzymaticReactionWID  BIGINT  NOT NULL,
  PrimaryWID  BIGINT  NOT NULL,
  AlternativeWID  BIGINT  NOT NULL,
  Cofactor  CHAR(1)
  --
) TYPE=INNODB;



CREATE TABLE EnzReactionInhibitorActivator
(
  EnzymaticReactionWID  BIGINT  NOT NULL,
  CompoundWID  BIGINT  NOT NULL,
  InhibitOrActivate  CHAR(1),
  Mechanism  CHAR(1),
  PhysioRelevant  CHAR(1)
  --
) TYPE=INNODB;


INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('EnzReactionInhibitorActivator', 'InhibitOrActivate', 'I', 'Specifies a compound that inhibits an enzyme.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('EnzReactionInhibitorActivator', 'InhibitOrActivate', 'A', 'Specifies a compound that activates an enzyme.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('EnzReactionInhibitorActivator', 'Mechanism', 'A', 'The mechanism of inhibition or activation is allosteric.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('EnzReactionInhibitorActivator', 'Mechanism', 'I', 'The mechanism of inhibition or activation is irreversible.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('EnzReactionInhibitorActivator', 'Mechanism', 'C', 'The mechanism of inhibition or activation is competitive.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('EnzReactionInhibitorActivator', 'Mechanism', 'N', 'The mechanism of inhibition or activation is neither allosteric nor competitive.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('EnzReactionInhibitorActivator', 'Mechanism', 'U', 'The mechanism of inhibition or activation is unknown.');

CREATE TABLE Location
(
  ProteinWID  BIGINT  NOT NULL,
  Location  VARCHAR(100)  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE PathwayLink
(
  Pathway1WID  BIGINT  NOT NULL,
  Pathway2WID  BIGINT  NOT NULL,
  ChemicalWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE PathwayReaction
(
  PathwayWID  BIGINT  NOT NULL,
  ReactionWID  BIGINT  NOT NULL,
  PriorReactionWID  BIGINT,
  Hypothetical  CHAR(1)  NOT NULL
  --
) TYPE=INNODB;

CREATE INDEX PR_PATHWID_REACTIONWID ON PathwayReaction(PathwayWID, ReactionWID);


CREATE TABLE Product
(
  ReactionWID  BIGINT  NOT NULL,
  OtherWID  BIGINT  NOT NULL,
  Coefficient  SMALLINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE Reactant
(
  ReactionWID  BIGINT  NOT NULL,
  OtherWID  BIGINT  NOT NULL,
  Coefficient  SMALLINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE InteractionParticipant
(
  InteractionWID  BIGINT  NOT NULL,
  OtherWID  BIGINT  NOT NULL,
  Coefficient  SMALLINT
  --
) TYPE=INNODB;

CREATE INDEX PR_INTERACTIONWID_OTHERWID ON InteractionParticipant(InteractionWID, OtherWID);


CREATE TABLE SequenceMatch
(
  QueryWID  BIGINT  NOT NULL,
  MatchWID  BIGINT  NOT NULL,
  ComputationWID  BIGINT  NOT NULL,
  EValue  DOUBLE,
  PValue  DOUBLE,
  PercentIdentical  FLOAT,
  PercentSimilar  FLOAT,
  Rank  SMALLINT,
  Length  INT,
  QueryStart  INT,
  QueryEnd  INT,
  MatchStart  INT,
  MatchEnd  INT
  --
) TYPE=INNODB;



CREATE TABLE Subunit
(
  ComplexWID  BIGINT  NOT NULL,
  SubunitWID  BIGINT  NOT NULL,
  Coefficient  SMALLINT
  --
) TYPE=INNODB;



CREATE TABLE SuperPathway
(
  SubPathwayWID  BIGINT  NOT NULL,
  SuperPathwayWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE TermRelationship
(
  TermWID  BIGINT  NOT NULL,
  RelatedTermWID  BIGINT  NOT NULL,
  Relationship  VARCHAR(10)  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE RelatedTerm
(
  TermWID  BIGINT  NOT NULL,
  OtherWID  BIGINT  NOT NULL,
  Relationship  VARCHAR(50)
  --
) TYPE=INNODB;


INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('RelatedTerm', 'Relationship', 'keyword', 'The term is a keyword that characterizes the object.');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('RelatedTerm', 'Relationship', 'superclass', 'The term names a class, and the object is an instance or a subclass of that class.');

CREATE TABLE CitationWIDOtherWID
(
  OtherWID  BIGINT  NOT NULL,
  CitationWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE CommentTable
(
  OtherWID  BIGINT  NOT NULL,
  Comm  LONGTEXT
  --
) TYPE=INNODB;



CREATE TABLE CrossReference
(
  OtherWID  BIGINT  NOT NULL,
  CrossWID  BIGINT,
  XID  VARCHAR(50),
  Type  VARCHAR(20),
  Version  VARCHAR(10),
  Relationship  VARCHAR(50),
  DatabaseName  VARCHAR(255)
  --
) TYPE=INNODB;


INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('CrossReference', 'Type', 'Accession', 'Type of XID is an accession number (not guaranteed to be unique across datasets)');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('CrossReference', 'Type', 'GUID', 'Type of XID is a global unique identifier (guaranteed to be unique across datasets for a given database provider)');

CREATE TABLE Description
(
  OtherWID  BIGINT  NOT NULL,
  TableName  VARCHAR(30)  NOT NULL,
  Comm  TEXT
  --
) TYPE=INNODB;



CREATE TABLE DBID
(
  OtherWID  BIGINT  NOT NULL,
  XID  VARCHAR(150)  NOT NULL,
  Type  VARCHAR(20),
  Version  VARCHAR(10)
  --
) TYPE=INNODB;

CREATE INDEX DBID_XID_OTHERWID ON DBID(XID, OTHERWID);
CREATE INDEX DBID_OTHERWID ON DBID(OTHERWID);

INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('DBID', 'Type', 'Accession', 'Type of XID is an accession number (not guaranteed to be unique across datasets)');
INSERT INTO Enumeration (TableName, ColumnName, Value, Meaning) VALUES ('DBID', 'Type', 'GUID', 'Type of XID is a global unique identifier (guaranteed to be unique across datasets for a given database provider)');

CREATE TABLE SynonymTable
(
  OtherWID  BIGINT  NOT NULL,
  Syn  VARCHAR(255)  NOT NULL
  --
) TYPE=INNODB;

CREATE INDEX SYNONYM_OTHERWID_SYN ON SynonymTable(OTHERWID, SYN);


CREATE TABLE ToolAdvice
(
  OtherWID  BIGINT  NOT NULL,
  ToolName  VARCHAR(50)  NOT NULL,
  Advice  LONGTEXT
  --
) TYPE=INNODB;



CREATE TABLE BioSourceWIDBioSubtypeWID
(
  BioSourceWID  BIGINT  NOT NULL,
  BioSubtypeWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE BioSourceWIDGeneWID
(
  BioSourceWID  BIGINT  NOT NULL,
  GeneWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE BioSourceWIDProteinWID
(
  BioSourceWID  BIGINT  NOT NULL,
  ProteinWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE GeneWIDNucleicAcidWID
(
  GeneWID  BIGINT  NOT NULL,
  NucleicAcidWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE GeneWIDProteinWID
(
  GeneWID  BIGINT  NOT NULL,
  ProteinWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ProteinWIDFunctionWID
(
  ProteinWID  BIGINT  NOT NULL,
  FunctionWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ExperimentRelationship
(
  ExperimentWID  BIGINT  NOT NULL,
  RelatedExperimentWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE GelLocation
(
  WID  BIGINT  NOT NULL,
  SpotWID  BIGINT  NOT NULL,
  Xcoord  FLOAT,
  Ycoord  FLOAT,
  refGel  VARCHAR(1),
  ExperimentWID  BIGINT  NOT NULL,
  DatasetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_GelLocation PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE ProteinWIDSpotWID
(
  ProteinWID  BIGINT  NOT NULL,
  SpotWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE Spot
(
  WID  BIGINT  NOT NULL,
  SpotId  VARCHAR(25),
  MolecularWeightEst  FLOAT,
  PIEst  VARCHAR(50),
  DatasetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_Spot PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE SpotIdMethod
(
  WID  BIGINT  NOT NULL,
  MethodName  VARCHAR(100)  NOT NULL,
  MethodDesc  VARCHAR(500),
  MethodAbbrev  VARCHAR(10),
  DatasetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_SpotIdMethod PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE SpotWIDSpotIdMethodWID
(
  SpotWID  BIGINT  NOT NULL,
  SpotIdMethodWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE NameValueType
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Name  VARCHAR(255),
  Value  VARCHAR(255),
  Type_  VARCHAR(255),
  NameValueType_PropertySets  BIGINT,
  OtherWID  BIGINT,
  --
  CONSTRAINT PK_NameValueType PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Contact
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  MAGEClass  VARCHAR(100)  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  URI  VARCHAR(255),
  Address  VARCHAR(255),
  Phone  VARCHAR(255),
  TollFreePhone  VARCHAR(255),
  Email  VARCHAR(255),
  Fax  VARCHAR(255),
  Parent  BIGINT,
  LastName  VARCHAR(255),
  FirstName  VARCHAR(255),
  MidInitials  VARCHAR(255),
  Affiliation  BIGINT,
  --
  CONSTRAINT PK_Contact PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE ArrayDesign
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  MAGEClass  VARCHAR(100)  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  Version  VARCHAR(255),
  NumberOfFeatures  SMALLINT,
  SurfaceType  BIGINT,
  --
  CONSTRAINT PK_ArrayDesign PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE DesignElementGroup
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  MAGEClass  VARCHAR(100)  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  ArrayDesign_FeatureGroups  BIGINT,
  DesignElementGroup_Species  BIGINT,
  FeatureWidth  FLOAT,
  FeatureLength  FLOAT,
  FeatureHeight  FLOAT,
  FeatureGroup_TechnologyType  BIGINT,
  FeatureGroup_FeatureShape  BIGINT,
  FeatureGroup_DistanceUnit  BIGINT,
  --
  CONSTRAINT PK_DesignElementGroup PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Zone
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  Row_  SMALLINT,
  Column_  SMALLINT,
  UpperLeftX  FLOAT,
  UpperLeftY  FLOAT,
  LowerRightX  FLOAT,
  LowerRightY  FLOAT,
  Zone_DistanceUnit  BIGINT,
  ZoneGroup_ZoneLocations  BIGINT,
  --
  CONSTRAINT PK_Zone PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE ZoneGroup
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  PhysicalArrayDesign_ZoneGroups  BIGINT,
  SpacingsBetweenZonesX  FLOAT,
  SpacingsBetweenZonesY  FLOAT,
  ZonesPerX  SMALLINT,
  ZonesPerY  SMALLINT,
  ZoneGroup_DistanceUnit  BIGINT,
  ZoneGroup_ZoneLayout  BIGINT,
  --
  CONSTRAINT PK_ZoneGroup PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE ZoneLayout
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  NumFeaturesPerRow  SMALLINT,
  NumFeaturesPerCol  SMALLINT,
  SpacingBetweenRows  FLOAT,
  SpacingBetweenCols  FLOAT,
  ZoneLayout_DistanceUnit  BIGINT,
  --
  CONSTRAINT PK_ZoneLayout PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE ExperimentDesign
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Experiment_ExperimentDesigns  BIGINT,
  QualityControlDescription  BIGINT,
  NormalizationDescription  BIGINT,
  ReplicateDescription  BIGINT,
  --
  CONSTRAINT PK_ExperimentDesign PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE ExperimentalFactor
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  ExperimentDesign  BIGINT,
  ExperimentalFactor_Category  BIGINT,
  --
  CONSTRAINT PK_ExperimentalFactor PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE FactorValue
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  ExperimentalFactor  BIGINT,
  ExperimentalFactor2  BIGINT,
  FactorValue_Measurement  BIGINT,
  FactorValue_Value  BIGINT,
  --
  CONSTRAINT PK_FactorValue PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE QuantitationType
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  MAGEClass  VARCHAR(100)  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  IsBackground  CHAR(1),
  Channel  BIGINT,
  QuantitationType_Scale  BIGINT,
  QuantitationType_DataType  BIGINT,
  TargetQuantitationType  BIGINT,
  --
  CONSTRAINT PK_QuantitationType PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Database_
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  Version  VARCHAR(255),
  URI  VARCHAR(255),
  --
  CONSTRAINT PK_Database_ PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Array_
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  ArrayIdentifier  VARCHAR(255),
  ArrayXOrigin  FLOAT,
  ArrayYOrigin  FLOAT,
  OriginRelativeTo  VARCHAR(255),
  ArrayDesign  BIGINT,
  Information  BIGINT,
  ArrayGroup  BIGINT,
  --
  CONSTRAINT PK_Array_ PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE ArrayGroup
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  Barcode  VARCHAR(255),
  ArraySpacingX  FLOAT,
  ArraySpacingY  FLOAT,
  NumArrays  SMALLINT,
  OrientationMark  VARCHAR(255),
  OrientationMarkPosition  VARCHAR(25),
  Width  FLOAT,
  Length  FLOAT,
  ArrayGroup_SubstrateType  BIGINT,
  ArrayGroup_DistanceUnit  BIGINT,
  --
  CONSTRAINT PK_ArrayGroup PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE ArrayManufacture
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  ManufacturingDate  VARCHAR(255),
  Tolerance  FLOAT,
  --
  CONSTRAINT PK_ArrayManufacture PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE ArrayManufactureDeviation
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Array_  BIGINT,
  --
  CONSTRAINT PK_ArrayManufactureDeviation PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE FeatureDefect
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  ArrayManufactureDeviation  BIGINT,
  FeatureDefect_DefectType  BIGINT,
  FeatureDefect_PositionDelta  BIGINT,
  Feature  BIGINT,
  --
  CONSTRAINT PK_FeatureDefect PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Fiducial
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  ArrayGroup_Fiducials  BIGINT,
  Fiducial_FiducialType  BIGINT,
  Fiducial_DistanceUnit  BIGINT,
  Fiducial_Position  BIGINT,
  --
  CONSTRAINT PK_Fiducial PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE ManufactureLIMS
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  MAGEClass  VARCHAR(100)  NOT NULL,
  ArrayManufacture_FeatureLIMSs  BIGINT,
  Quality  VARCHAR(255),
  Feature  BIGINT,
  BioMaterial  BIGINT,
  ManufactureLIMS_IdentifierLIMS  BIGINT,
  BioMaterialPlateIdentifier  VARCHAR(255),
  BioMaterialPlateRow  VARCHAR(255),
  BioMaterialPlateCol  VARCHAR(255),
  --
  CONSTRAINT PK_ManufactureLIMS PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE PositionDelta
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  DeltaX  FLOAT,
  DeltaY  FLOAT,
  PositionDelta_DistanceUnit  BIGINT,
  --
  CONSTRAINT PK_PositionDelta PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE ZoneDefect
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  ArrayManufactureDeviation  BIGINT,
  ZoneDefect_DefectType  BIGINT,
  ZoneDefect_PositionDelta  BIGINT,
  Zone  BIGINT,
  --
  CONSTRAINT PK_ZoneDefect PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE SeqFeatureLocation
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  SeqFeature_Regions  BIGINT,
  StrandType  VARCHAR(255),
  SeqFeatureLocation_Subregions  BIGINT,
  SeqFeatureLocation_Coordinate  BIGINT,
  --
  CONSTRAINT PK_SeqFeatureLocation PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE SequencePosition
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  MAGEClass  VARCHAR(100)  NOT NULL,
  Start_  SMALLINT,
  End  SMALLINT,
  CompositeCompositeMap  BIGINT,
  Composite  BIGINT,
  ReporterCompositeMap  BIGINT,
  Reporter  BIGINT,
  --
  CONSTRAINT PK_SequencePosition PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE DesignElement
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  MAGEClass  VARCHAR(100)  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  FeatureGroup_Features  BIGINT,
  DesignElement_ControlType  BIGINT,
  Feature_Position  BIGINT,
  Zone  BIGINT,
  Feature_FeatureLocation  BIGINT,
  FeatureGroup  BIGINT,
  Reporter_WarningType  BIGINT,
  --
  CONSTRAINT PK_DesignElement PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE FeatureInformation
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Feature  BIGINT,
  FeatureReporterMap  BIGINT,
  --
  CONSTRAINT PK_FeatureInformation PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE FeatureLocation
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Row_  SMALLINT,
  Column_  SMALLINT,
  --
  CONSTRAINT PK_FeatureLocation PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE MismatchInformation
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  CompositePosition  BIGINT,
  FeatureInformation  BIGINT,
  StartCoord  SMALLINT,
  NewSequence  VARCHAR(255),
  ReplacedLength  SMALLINT,
  ReporterPosition  BIGINT,
  --
  CONSTRAINT PK_MismatchInformation PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Position_
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  X  FLOAT,
  Y  FLOAT,
  Position_DistanceUnit  BIGINT,
  --
  CONSTRAINT PK_Position_ PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE BioEvent
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  MAGEClass  VARCHAR(100)  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  CompositeSequence  BIGINT,
  Reporter  BIGINT,
  CompositeSequence2  BIGINT,
  BioAssayMapTarget  BIGINT,
  TargetQuantitationType  BIGINT,
  DerivedBioAssayDataTarget  BIGINT,
  QuantitationTypeMapping  BIGINT,
  DesignElementMapping  BIGINT,
  Transformation_BioAssayMapping  BIGINT,
  BioMaterial_Treatments  BIGINT,
  Order_  SMALLINT,
  Treatment_Action  BIGINT,
  Treatment_ActionMeasurement  BIGINT,
  Array_  BIGINT,
  PhysicalBioAssayTarget  BIGINT,
  PhysicalBioAssay  BIGINT,
  Target  BIGINT,
  PhysicalBioAssaySource  BIGINT,
  MeasuredBioAssayTarget  BIGINT,
  PhysicalBioAssay2  BIGINT,
  --
  CONSTRAINT PK_BioEvent PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE BioAssayData
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  MAGEClass  VARCHAR(100)  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  BioAssayDimension  BIGINT,
  DesignElementDimension  BIGINT,
  QuantitationTypeDimension  BIGINT,
  BioAssayData_BioDataValues  BIGINT,
  ProducerTransformation  BIGINT,
  --
  CONSTRAINT PK_BioAssayData PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE BioAssayDimension
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  --
  CONSTRAINT PK_BioAssayDimension PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE BioAssayMapping
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_BioAssayMapping PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE BioAssayTuple
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  BioAssay  BIGINT,
  BioDataTuples_BioAssayTuples  BIGINT,
  --
  CONSTRAINT PK_BioAssayTuple PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE BioDataValues
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  MAGEClass  VARCHAR(100)  NOT NULL,
  Order_  VARCHAR(25),
  BioDataCube_DataInternal  BIGINT,
  BioDataCube_DataExternal  BIGINT,
  --
  CONSTRAINT PK_BioDataValues PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE DataExternal
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  DataFormat  VARCHAR(255),
  DataFormatInfoURI  VARCHAR(255),
  FilenameURI  VARCHAR(255),
  --
  CONSTRAINT PK_DataExternal PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE DataInternal
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_DataInternal PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Datum
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Value  VARCHAR(255),
  --
  CONSTRAINT PK_Datum PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE DesignElementDimension
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  MAGEClass  VARCHAR(100)  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  --
  CONSTRAINT PK_DesignElementDimension PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE DesignElementMapping
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_DesignElementMapping PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE DesignElementTuple
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  BioAssayTuple  BIGINT,
  DesignElement  BIGINT,
  --
  CONSTRAINT PK_DesignElementTuple PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE QuantitationTypeDimension
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  --
  CONSTRAINT PK_QuantitationTypeDimension PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE QuantitationTypeMapping
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  --
  CONSTRAINT PK_QuantitationTypeMapping PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE QuantitationTypeTuple
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  DesignElementTuple  BIGINT,
  QuantitationType  BIGINT,
  QuantitationTypeTuple_Datum  BIGINT,
  --
  CONSTRAINT PK_QuantitationTypeTuple PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE BioMaterialMeasurement
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  BioMaterial  BIGINT,
  Measurement  BIGINT,
  Treatment  BIGINT,
  BioAssayCreation  BIGINT,
  --
  CONSTRAINT PK_BioMaterialMeasurement PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE CompoundMeasurement
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Compound_ComponentCompounds  BIGINT,
  Compound  BIGINT,
  Measurement  BIGINT,
  Treatment_CompoundMeasurements  BIGINT,
  --
  CONSTRAINT PK_CompoundMeasurement PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE BioAssay
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  MAGEClass  VARCHAR(100)  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  DerivedBioAssay_Type  BIGINT,
  FeatureExtraction  BIGINT,
  BioAssayCreation  BIGINT,
  --
  CONSTRAINT PK_BioAssay PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Channel
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  --
  CONSTRAINT PK_Channel PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Image
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  URI  VARCHAR(255),
  Image_Format  BIGINT,
  PhysicalBioAssay  BIGINT,
  --
  CONSTRAINT PK_Image PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE BioAssayDataCluster
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  ClusterBioAssayData  BIGINT,
  --
  CONSTRAINT PK_BioAssayDataCluster PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Node
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  BioAssayDataCluster_Nodes  BIGINT,
  Node_Nodes  BIGINT,
  --
  CONSTRAINT PK_Node PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE NodeContents
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Node_NodeContents  BIGINT,
  BioAssayDimension  BIGINT,
  DesignElementDimension  BIGINT,
  QuantitationDimension  BIGINT,
  --
  CONSTRAINT PK_NodeContents PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE NodeValue
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Node_NodeValue  BIGINT,
  Name  VARCHAR(255),
  Value  VARCHAR(255),
  NodeValue_Type  BIGINT,
  NodeValue_Scale  BIGINT,
  NodeValue_DataType  BIGINT,
  --
  CONSTRAINT PK_NodeValue PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Measurement
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Type_  VARCHAR(25),
  Value  VARCHAR(255),
  KindCV  VARCHAR(25),
  OtherKind  VARCHAR(255),
  Measurement_Unit  BIGINT,
  --
  CONSTRAINT PK_Measurement PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Unit
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  MAGEClass  VARCHAR(100)  NOT NULL,
  UnitName  VARCHAR(255),
  UnitNameCV  VARCHAR(25),
  UnitNameCV2  VARCHAR(25),
  UnitNameCV3  VARCHAR(25),
  UnitNameCV4  VARCHAR(25),
  UnitNameCV5  VARCHAR(25),
  UnitNameCV6  VARCHAR(25),
  UnitNameCV7  VARCHAR(25),
  --
  CONSTRAINT PK_Unit PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Parameter
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  Parameter_DefaultValue  BIGINT,
  Parameter_DataType  BIGINT,
  Parameterizable_ParameterTypes  BIGINT,
  --
  CONSTRAINT PK_Parameter PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE ParameterValue
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  Value  VARCHAR(255),
  ParameterType  BIGINT,
  ParameterizableApplication  BIGINT,
  --
  CONSTRAINT PK_ParameterValue PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE Parameterizable
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  MAGEClass  VARCHAR(100)  NOT NULL,
  Identifier  VARCHAR(255),
  Name  VARCHAR(255),
  URI  VARCHAR(255),
  Model  VARCHAR(255),
  Make  VARCHAR(255),
  Hardware_Type  BIGINT,
  Text  VARCHAR(1000),
  Title  VARCHAR(255),
  Protocol_Type  BIGINT,
  Software_Type  BIGINT,
  Hardware  BIGINT,
  --
  CONSTRAINT PK_Parameterizable PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE ParameterizableApplication
(
  WID  BIGINT  NOT NULL,
  DataSetWID  BIGINT  NOT NULL,
  MAGEClass  VARCHAR(100)  NOT NULL,
  ArrayDesign  BIGINT,
  ArrayManufacture  BIGINT,
  BioEvent_ProtocolApplications  BIGINT,
  SerialNumber  VARCHAR(255),
  Hardware  BIGINT,
  ActivityDate  VARCHAR(255),
  ProtocolApplication  BIGINT,
  ProtocolApplication2  BIGINT,
  Protocol  BIGINT,
  Version  VARCHAR(255),
  ReleaseDate  DATETIME,
  Software  BIGINT,
  --
  CONSTRAINT PK_ParameterizableApplication PRIMARY KEY (WID)
) TYPE=INNODB;



CREATE TABLE ArrayDesignWIDReporterGroupWID
(
  ArrayDesignWID  BIGINT  NOT NULL,
  ReporterGroupWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ArrayDesignWIDCompositeGrpWID
(
  ArrayDesignWID  BIGINT  NOT NULL,
  CompositeGroupWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ArrayDesignWIDContactWID
(
  ArrayDesignWID  BIGINT  NOT NULL,
  ContactWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ComposGrpWIDComposSequenceWID
(
  CompositeGroupWID  BIGINT  NOT NULL,
  CompositeSequenceWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ReporterGroupWIDReporterWID
(
  ReporterGroupWID  BIGINT  NOT NULL,
  ReporterWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ExperimentWIDContactWID
(
  ExperimentWID  BIGINT  NOT NULL,
  ContactWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ExperimWIDBioAssayDataClustWID
(
  ExperimentWID  BIGINT  NOT NULL,
  BioAssayDataClusterWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ExperimentWIDBioAssayDataWID
(
  ExperimentWID  BIGINT  NOT NULL,
  BioAssayDataWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ExperimentWIDBioAssayWID
(
  ExperimentWID  BIGINT  NOT NULL,
  BioAssayWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ExperimentDesignWIDBioAssayWID
(
  ExperimentDesignWID  BIGINT  NOT NULL,
  BioAssayWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE QuantTypeWIDConfidenceIndWID
(
  QuantitationTypeWID  BIGINT  NOT NULL,
  ConfidenceIndicatorWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE QuantTypeWIDQuantTypeMapWID
(
  QuantitationTypeWID  BIGINT  NOT NULL,
  QuantitationTypeMapWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE DatabaseWIDContactWID
(
  DatabaseWID  BIGINT  NOT NULL,
  ContactWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ArrayGroupWIDArrayWID
(
  ArrayGroupWID  BIGINT  NOT NULL,
  ArrayWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ArrayManufactureWIDArrayWID
(
  ArrayManufactureWID  BIGINT  NOT NULL,
  ArrayWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ArrayManufactureWIDContactWID
(
  ArrayManufactureWID  BIGINT  NOT NULL,
  ContactWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE CompositeSeqWIDBioSeqWID
(
  CompositeSequenceWID  BIGINT  NOT NULL,
  BioSequenceWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ComposSeqWIDRepoComposMapWID
(
  CompositeSequenceWID  BIGINT  NOT NULL,
  ReporterCompositeMapWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ComposSeqWIDComposComposMapWID
(
  CompositeSequenceWID  BIGINT  NOT NULL,
  CompositeCompositeMapWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE FeatureWIDFeatureWID
(
  FeatureWID1  BIGINT  NOT NULL,
  FeatureWID2  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE FeatureWIDFeatureWID2
(
  FeatureWID1  BIGINT  NOT NULL,
  FeatureWID2  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ReporterWIDBioSequenceWID
(
  ReporterWID  BIGINT  NOT NULL,
  BioSequenceWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ReporterWIDFeatureReporMapWID
(
  ReporterWID  BIGINT  NOT NULL,
  FeatureReporterMapWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE BioAssayDimensioWIDBioAssayWID
(
  BioAssayDimensionWID  BIGINT  NOT NULL,
  BioAssayWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE BioAssayMapWIDBioAssayWID
(
  BioAssayMapWID  BIGINT  NOT NULL,
  BioAssayWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE BAssayMappingWIDBAssayMapWID
(
  BioAssayMappingWID  BIGINT  NOT NULL,
  BioAssayMapWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ComposSeqDimensWIDComposSeqWID
(
  CompositeSequenceDimensionWID  BIGINT  NOT NULL,
  CompositeSequenceWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE DesnElMappingWIDDesnElMapWID
(
  DesignElementMappingWID  BIGINT  NOT NULL,
  DesignElementMapWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE FeatureDimensionWIDFeatureWID
(
  FeatureDimensionWID  BIGINT  NOT NULL,
  FeatureWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE QuantTypeDimensWIDQuantTypeWID
(
  QuantitationTypeDimensionWID  BIGINT  NOT NULL,
  QuantitationTypeWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE QuantTypeMapWIDQuantTypeWID
(
  QuantitationTypeMapWID  BIGINT  NOT NULL,
  QuantitationTypeWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE QuantTyMapWIDQuantTyMapWI
(
  QuantitationTypeMappingWID  BIGINT  NOT NULL,
  QuantitationTypeMapWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ReporterDimensWIDReporterWID
(
  ReporterDimensionWID  BIGINT  NOT NULL,
  ReporterWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE TransformWIDBioAssayDataWID
(
  TransformationWID  BIGINT  NOT NULL,
  BioAssayDataWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE BioSourceWIDContactWID
(
  BioSourceWID  BIGINT  NOT NULL,
  ContactWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE LabeledExtractWIDCompoundWID
(
  LabeledExtractWID  BIGINT  NOT NULL,
  CompoundWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE BioAssayWIDChannelWID
(
  BioAssayWID  BIGINT  NOT NULL,
  ChannelWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE BioAssayWIDFactorValueWID
(
  BioAssayWID  BIGINT  NOT NULL,
  FactorValueWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ChannelWIDCompoundWID
(
  ChannelWID  BIGINT  NOT NULL,
  CompoundWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE DerivBioAWIDDerivBioADataWID
(
  DerivedBioAssayWID  BIGINT  NOT NULL,
  DerivedBioAssayDataWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE DerivBioAssayWIDBioAssayMapWID
(
  DerivedBioAssayWID  BIGINT  NOT NULL,
  BioAssayMapWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ImageWIDChannelWID
(
  ImageWID  BIGINT  NOT NULL,
  ChannelWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ImageAcquisitionWIDImageWID
(
  ImageAcquisitionWID  BIGINT  NOT NULL,
  ImageWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE MeasBAssayWIDMeasBAssayDataWID
(
  MeasuredBioAssayWID  BIGINT  NOT NULL,
  MeasuredBioAssayDataWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE HardwareWIDSoftwareWID
(
  HardwareWID  BIGINT  NOT NULL,
  SoftwareWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE HardwareWIDContactWID
(
  HardwareWID  BIGINT  NOT NULL,
  ContactWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ProtocolWIDHardwareWID
(
  ProtocolWID  BIGINT  NOT NULL,
  HardwareWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ProtocolWIDSoftwareWID
(
  ProtocolWID  BIGINT  NOT NULL,
  SoftwareWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE ProtocolApplWIDPersonWID
(
  ProtocolApplicationWID  BIGINT  NOT NULL,
  PersonWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE SoftwareWIDSoftwareWID
(
  SoftwareWID1  BIGINT  NOT NULL,
  SoftwareWID2  BIGINT  NOT NULL
  --
) TYPE=INNODB;



CREATE TABLE SoftwareWIDContactWID
(
  SoftwareWID  BIGINT  NOT NULL,
  ContactWID  BIGINT  NOT NULL
  --
) TYPE=INNODB;



ALTER TABLE Entry
ADD CONSTRAINT FK_Entry
FOREIGN KEY (DatasetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE GeneExpressionData
ADD CONSTRAINT FK_GEDBAV
FOREIGN KEY (BioAssayValuesWID)
REFERENCES BioDataValues (WID) ON DELETE CASCADE;

ALTER TABLE Valence
ADD CONSTRAINT FK_Valence
FOREIGN KEY (OtherWID)
REFERENCES Element (WID) ON DELETE CASCADE;

ALTER TABLE LightSource
ADD CONSTRAINT FK_LightSource1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE FlowCytometrySample
ADD CONSTRAINT FK_FlowCytometrySample1
FOREIGN KEY (BioSourceWID)
REFERENCES BioSource (WID) ON DELETE CASCADE;

ALTER TABLE FlowCytometrySample
ADD CONSTRAINT FK_FlowCytometrySample2
FOREIGN KEY (FlowCytometryProbeWID)
REFERENCES FlowCytometryProbe (WID) ON DELETE CASCADE;

ALTER TABLE FlowCytometrySample
ADD CONSTRAINT FK_FlowCytometrySample3
FOREIGN KEY (MeasurementWID)
REFERENCES Measurement (WID) ON DELETE CASCADE;

ALTER TABLE FlowCytometrySample
ADD CONSTRAINT FK_FlowCytometrySample4
FOREIGN KEY (ManufacturerWID)
REFERENCES Contact (WID) ON DELETE CASCADE;

ALTER TABLE FlowCytometrySample
ADD CONSTRAINT FK_FlowCytometrySampleDS
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE FlowCytometryProbe
ADD CONSTRAINT FK_Probe1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE TranscriptionUnit
ADD CONSTRAINT FK_TranscriptionUnit1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE TranscriptionUnitComponent
ADD CONSTRAINT FK_TranscriptionUnitComponent1
FOREIGN KEY (TranscriptionUnitWID)
REFERENCES TranscriptionUnit (WID) ON DELETE CASCADE;

ALTER TABLE Chemical
ADD CONSTRAINT FK_Chemical1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Reaction
ADD CONSTRAINT FK_Reaction
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Interaction
ADD CONSTRAINT FK_Interaction1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Protein
ADD CONSTRAINT FK_Protein
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Feature
ADD CONSTRAINT FK_Feature
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Function
ADD CONSTRAINT FK_Function
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE EnzymaticReaction
ADD CONSTRAINT FK_EnzymaticReaction1
FOREIGN KEY (ReactionWID)
REFERENCES Reaction (WID) ON DELETE CASCADE;

ALTER TABLE EnzymaticReaction
ADD CONSTRAINT FK_EnzymaticReaction2
FOREIGN KEY (ProteinWID)
REFERENCES Protein (WID) ON DELETE CASCADE;

ALTER TABLE EnzymaticReaction
ADD CONSTRAINT FK_EnzymaticReaction3
FOREIGN KEY (ComplexWID)
REFERENCES Protein (WID) ON DELETE CASCADE;

ALTER TABLE EnzymaticReaction
ADD CONSTRAINT FK_EnzymaticReaction4
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE GeneticCode
ADD CONSTRAINT FK_GeneticCode
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Division
ADD CONSTRAINT FK_Division
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Taxon
ADD CONSTRAINT FK_Taxon_Division
FOREIGN KEY (DivisionWID)
REFERENCES Division (WID) ON DELETE CASCADE;

ALTER TABLE Taxon
ADD CONSTRAINT FK_Taxon_GeneticCode
FOREIGN KEY (GencodeWID)
REFERENCES GeneticCode (WID) ON DELETE CASCADE;

ALTER TABLE Taxon
ADD CONSTRAINT FK_Taxon
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE BioSource
ADD CONSTRAINT FK_BioSource1
FOREIGN KEY (TaxonWID)
REFERENCES Taxon (WID) ON DELETE CASCADE;

ALTER TABLE BioSource
ADD CONSTRAINT FK_BioSource2
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE BioSubtype
ADD CONSTRAINT FK_BioSubtype2
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE NucleicAcid
ADD CONSTRAINT FK_NucleicAcid1
FOREIGN KEY (GeneticCodeWID)
REFERENCES GeneticCode (WID) ON DELETE CASCADE;

ALTER TABLE NucleicAcid
ADD CONSTRAINT FK_NucleicAcid2
FOREIGN KEY (BioSourceWID)
REFERENCES BioSource (WID) ON DELETE CASCADE;

ALTER TABLE NucleicAcid
ADD CONSTRAINT FK_NucleicAcid3
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Subsequence
ADD CONSTRAINT FK_Subsequence1
FOREIGN KEY (NucleicAcidWID)
REFERENCES NucleicAcid (WID) ON DELETE CASCADE;

ALTER TABLE Subsequence
ADD CONSTRAINT FK_Subsequence2
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Gene
ADD CONSTRAINT FK_Gene1
FOREIGN KEY (NucleicAcidWID)
REFERENCES NucleicAcid (WID) ON DELETE CASCADE;

ALTER TABLE Gene
ADD CONSTRAINT FK_Gene2
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Pathway
ADD CONSTRAINT FK_Pathway1
FOREIGN KEY (BioSourceWID)
REFERENCES BioSource (WID) ON DELETE CASCADE;

ALTER TABLE Pathway
ADD CONSTRAINT FK_Pathway2
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Computation
ADD CONSTRAINT FK_Computation
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Citation
ADD CONSTRAINT FK_Citation
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Experiment
ADD CONSTRAINT FK_Experiment3
FOREIGN KEY (ContactWID)
REFERENCES Contact (WID) ON DELETE CASCADE;

ALTER TABLE Experiment
ADD CONSTRAINT FK_Experiment4
FOREIGN KEY (ArchiveWID)
REFERENCES Archive (WID) ON DELETE CASCADE;

ALTER TABLE Experiment
ADD CONSTRAINT FK_Experiment2
FOREIGN KEY (GroupWID)
REFERENCES Experiment (WID) ON DELETE CASCADE;

ALTER TABLE Experiment
ADD CONSTRAINT FK_Experiment5
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Experiment
ADD CONSTRAINT FK_Experiment6
FOREIGN KEY (BioSourceWID)
REFERENCES BioSource (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentData
ADD CONSTRAINT FK_ExpData1
FOREIGN KEY (ExperimentWID)
REFERENCES Experiment (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentData
ADD CONSTRAINT FK_ExpDataMD
FOREIGN KEY (MageData)
REFERENCES ParameterValue (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentData
ADD CONSTRAINT FK_ExpData2
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE ChemicalAtom
ADD CONSTRAINT FK_ChemicalAtom
FOREIGN KEY (ChemicalWID)
REFERENCES Chemical (WID) ON DELETE CASCADE;

ALTER TABLE ChemicalBond
ADD CONSTRAINT FK_ChemicalBond
FOREIGN KEY (ChemicalWID)
REFERENCES Chemical (WID) ON DELETE CASCADE;

ALTER TABLE EnzReactionCofactor
ADD CONSTRAINT FK_EnzReactionCofactor1
FOREIGN KEY (EnzymaticReactionWID)
REFERENCES EnzymaticReaction (WID) ON DELETE CASCADE;

ALTER TABLE EnzReactionCofactor
ADD CONSTRAINT FK_EnzReactionCofactor2
FOREIGN KEY (ChemicalWID)
REFERENCES Chemical (WID) ON DELETE CASCADE;

ALTER TABLE EnzReactionAltCompound
ADD CONSTRAINT FK_ERAC1
FOREIGN KEY (EnzymaticReactionWID)
REFERENCES EnzymaticReaction (WID) ON DELETE CASCADE;

ALTER TABLE EnzReactionAltCompound
ADD CONSTRAINT FK_ERAC2
FOREIGN KEY (PrimaryWID)
REFERENCES Chemical (WID) ON DELETE CASCADE;

ALTER TABLE EnzReactionAltCompound
ADD CONSTRAINT FK_ERAC3
FOREIGN KEY (AlternativeWID)
REFERENCES Chemical (WID) ON DELETE CASCADE;

ALTER TABLE EnzReactionInhibitorActivator
ADD CONSTRAINT FK_EnzReactionIA1
FOREIGN KEY (EnzymaticReactionWID)
REFERENCES EnzymaticReaction (WID) ON DELETE CASCADE;

ALTER TABLE Location
ADD CONSTRAINT FK_Location
FOREIGN KEY (ProteinWID)
REFERENCES Protein (WID) ON DELETE CASCADE;

ALTER TABLE PathwayLink
ADD CONSTRAINT FK_PathwayLink1
FOREIGN KEY (Pathway1WID)
REFERENCES Pathway (WID) ON DELETE CASCADE;

ALTER TABLE PathwayLink
ADD CONSTRAINT FK_PathwayLink2
FOREIGN KEY (Pathway2WID)
REFERENCES Pathway (WID) ON DELETE CASCADE;

ALTER TABLE PathwayLink
ADD CONSTRAINT FK_PathwayLink3
FOREIGN KEY (ChemicalWID)
REFERENCES Chemical (WID) ON DELETE CASCADE;

ALTER TABLE PathwayReaction
ADD CONSTRAINT FK_PathwayReaction1
FOREIGN KEY (PathwayWID)
REFERENCES Pathway (WID) ON DELETE CASCADE;

ALTER TABLE PathwayReaction
ADD CONSTRAINT FK_PathwayReaction3
FOREIGN KEY (PriorReactionWID)
REFERENCES Reaction (WID) ON DELETE CASCADE;

ALTER TABLE Product
ADD CONSTRAINT FK_Product
FOREIGN KEY (ReactionWID)
REFERENCES Reaction (WID) ON DELETE CASCADE;

ALTER TABLE Reactant
ADD CONSTRAINT FK_Reactant
FOREIGN KEY (ReactionWID)
REFERENCES Reaction (WID) ON DELETE CASCADE;

ALTER TABLE InteractionParticipant
ADD CONSTRAINT FK_InteractionParticipant1
FOREIGN KEY (InteractionWID)
REFERENCES Interaction (WID) ON DELETE CASCADE;

ALTER TABLE SequenceMatch
ADD CONSTRAINT FK_SequenceMatch
FOREIGN KEY (ComputationWID)
REFERENCES Computation (WID) ON DELETE CASCADE;

ALTER TABLE Subunit
ADD CONSTRAINT FK_Subunit1
FOREIGN KEY (ComplexWID)
REFERENCES Protein (WID) ON DELETE CASCADE;

ALTER TABLE Subunit
ADD CONSTRAINT FK_Subunit2
FOREIGN KEY (SubunitWID)
REFERENCES Protein (WID) ON DELETE CASCADE;

ALTER TABLE SuperPathway
ADD CONSTRAINT FK_SuperPathway1
FOREIGN KEY (SubPathwayWID)
REFERENCES Pathway (WID) ON DELETE CASCADE;

ALTER TABLE SuperPathway
ADD CONSTRAINT FK_SuperPathway2
FOREIGN KEY (SuperPathwayWID)
REFERENCES Pathway (WID) ON DELETE CASCADE;

ALTER TABLE TermRelationship
ADD CONSTRAINT FK_TermRelationship1
FOREIGN KEY (TermWID)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE TermRelationship
ADD CONSTRAINT FK_TermRelationship2
FOREIGN KEY (RelatedTermWID)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE RelatedTerm
ADD CONSTRAINT FK_RelatedTerm1
FOREIGN KEY (TermWID)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE CitationWIDOtherWID
ADD CONSTRAINT FK_CitationWIDOtherWID
FOREIGN KEY (CitationWID)
REFERENCES Citation (WID) ON DELETE CASCADE;

ALTER TABLE BioSourceWIDBioSubtypeWID
ADD CONSTRAINT FK_BioSourceWIDBioSubtypeWID1
FOREIGN KEY (BioSourceWID)
REFERENCES BioSource (WID) ON DELETE CASCADE;

ALTER TABLE BioSourceWIDBioSubtypeWID
ADD CONSTRAINT FK_BioSourceWIDBioSubtypeWID2
FOREIGN KEY (BioSubtypeWID)
REFERENCES BioSubtype (WID) ON DELETE CASCADE;

ALTER TABLE BioSourceWIDGeneWID
ADD CONSTRAINT FK_BioSourceWIDGeneWID1
FOREIGN KEY (BioSourceWID)
REFERENCES BioSource (WID) ON DELETE CASCADE;

ALTER TABLE BioSourceWIDGeneWID
ADD CONSTRAINT FK_BioSourceWIDGeneWID2
FOREIGN KEY (GeneWID)
REFERENCES Gene (WID) ON DELETE CASCADE;

ALTER TABLE BioSourceWIDProteinWID
ADD CONSTRAINT FK_BioSourceWIDProteinWID1
FOREIGN KEY (BioSourceWID)
REFERENCES BioSource (WID) ON DELETE CASCADE;

ALTER TABLE BioSourceWIDProteinWID
ADD CONSTRAINT FK_BioSourceWIDProteinWID2
FOREIGN KEY (ProteinWID)
REFERENCES Protein (WID) ON DELETE CASCADE;

ALTER TABLE GeneWIDNucleicAcidWID
ADD CONSTRAINT FK_GeneWIDNucleicAcidWID1
FOREIGN KEY (GeneWID)
REFERENCES Gene (WID) ON DELETE CASCADE;

ALTER TABLE GeneWIDNucleicAcidWID
ADD CONSTRAINT FK_GeneWIDNucleicAcidWID2
FOREIGN KEY (NucleicAcidWID)
REFERENCES NucleicAcid (WID) ON DELETE CASCADE;

ALTER TABLE GeneWIDProteinWID
ADD CONSTRAINT FK_GeneWIDProteinWID1
FOREIGN KEY (GeneWID)
REFERENCES Gene (WID) ON DELETE CASCADE;

ALTER TABLE GeneWIDProteinWID
ADD CONSTRAINT FK_GeneWIDProteinWID2
FOREIGN KEY (ProteinWID)
REFERENCES Protein (WID) ON DELETE CASCADE;

ALTER TABLE ProteinWIDFunctionWID
ADD CONSTRAINT FK_ProteinWIDFunctionWID2
FOREIGN KEY (ProteinWID)
REFERENCES Protein (WID) ON DELETE CASCADE;

ALTER TABLE ProteinWIDFunctionWID
ADD CONSTRAINT FK_ProteinWIDFunctionWID3
FOREIGN KEY (FunctionWID)
REFERENCES Function (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentRelationship
ADD CONSTRAINT FK_ExpRelationship1
FOREIGN KEY (ExperimentWID)
REFERENCES Experiment (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentRelationship
ADD CONSTRAINT FK_ExpRelationship2
FOREIGN KEY (RelatedExperimentWID)
REFERENCES Experiment (WID) ON DELETE CASCADE;

ALTER TABLE GelLocation
ADD CONSTRAINT FK_GelLocSpotWid
FOREIGN KEY (SpotWID)
REFERENCES Spot (WID) ON DELETE CASCADE;

ALTER TABLE GelLocation
ADD CONSTRAINT FK_GelLocExp
FOREIGN KEY (ExperimentWID)
REFERENCES Experiment (WID) ON DELETE CASCADE;

ALTER TABLE GelLocation
ADD CONSTRAINT FK_GelLocDataset
FOREIGN KEY (DatasetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE ProteinWIDSpotWID
ADD CONSTRAINT FK_ProteinWIDSpotWID1
FOREIGN KEY (ProteinWID)
REFERENCES Protein (WID) ON DELETE CASCADE;

ALTER TABLE ProteinWIDSpotWID
ADD CONSTRAINT FK_ProteinWIDSpotWID2
FOREIGN KEY (SpotWID)
REFERENCES Spot (WID) ON DELETE CASCADE;

ALTER TABLE Spot
ADD CONSTRAINT FK_Spot
FOREIGN KEY (DatasetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE SpotIdMethod
ADD CONSTRAINT FK_SpotIdMethDataset
FOREIGN KEY (DatasetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE SpotWIDSpotIdMethodWID
ADD CONSTRAINT FK_SpotWIDMethWID1
FOREIGN KEY (SpotWID)
REFERENCES Spot (WID) ON DELETE CASCADE;

ALTER TABLE SpotWIDSpotIdMethodWID
ADD CONSTRAINT FK_SpotWIDMethWID2
FOREIGN KEY (SpotIdMethodWID)
REFERENCES SpotIdMethod (WID) ON DELETE CASCADE;

ALTER TABLE NameValueType
ADD CONSTRAINT FK_NameValueType1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE NameValueType
ADD CONSTRAINT FK_NameValueType66
FOREIGN KEY (NameValueType_PropertySets)
REFERENCES NameValueType (WID) ON DELETE CASCADE;

ALTER TABLE Contact
ADD CONSTRAINT FK_Contact1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Contact
ADD CONSTRAINT FK_Contact3
FOREIGN KEY (Parent)
REFERENCES Contact (WID) ON DELETE CASCADE;

ALTER TABLE Contact
ADD CONSTRAINT FK_Contact4
FOREIGN KEY (Affiliation)
REFERENCES Contact (WID) ON DELETE CASCADE;

ALTER TABLE ArrayDesign
ADD CONSTRAINT FK_ArrayDesign1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE ArrayDesign
ADD CONSTRAINT FK_ArrayDesign3
FOREIGN KEY (SurfaceType)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE DesignElementGroup
ADD CONSTRAINT FK_DesignElementGroup1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE DesignElementGroup
ADD CONSTRAINT FK_DesignElementGroup3
FOREIGN KEY (ArrayDesign_FeatureGroups)
REFERENCES ArrayDesign (WID) ON DELETE CASCADE;

ALTER TABLE DesignElementGroup
ADD CONSTRAINT FK_DesignElementGroup4
FOREIGN KEY (DesignElementGroup_Species)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE DesignElementGroup
ADD CONSTRAINT FK_DesignElementGroup5
FOREIGN KEY (FeatureGroup_TechnologyType)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE DesignElementGroup
ADD CONSTRAINT FK_DesignElementGroup6
FOREIGN KEY (FeatureGroup_FeatureShape)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE DesignElementGroup
ADD CONSTRAINT FK_DesignElementGroup7
FOREIGN KEY (FeatureGroup_DistanceUnit)
REFERENCES Unit (WID) ON DELETE CASCADE;

ALTER TABLE Zone
ADD CONSTRAINT FK_Zone1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Zone
ADD CONSTRAINT FK_Zone3
FOREIGN KEY (Zone_DistanceUnit)
REFERENCES Unit (WID) ON DELETE CASCADE;

ALTER TABLE Zone
ADD CONSTRAINT FK_Zone4
FOREIGN KEY (ZoneGroup_ZoneLocations)
REFERENCES ZoneGroup (WID) ON DELETE CASCADE;

ALTER TABLE ZoneGroup
ADD CONSTRAINT FK_ZoneGroup1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE ZoneGroup
ADD CONSTRAINT FK_ZoneGroup2
FOREIGN KEY (PhysicalArrayDesign_ZoneGroups)
REFERENCES ArrayDesign (WID) ON DELETE CASCADE;

ALTER TABLE ZoneGroup
ADD CONSTRAINT FK_ZoneGroup3
FOREIGN KEY (ZoneGroup_DistanceUnit)
REFERENCES Unit (WID) ON DELETE CASCADE;

ALTER TABLE ZoneGroup
ADD CONSTRAINT FK_ZoneGroup4
FOREIGN KEY (ZoneGroup_ZoneLayout)
REFERENCES ZoneLayout (WID) ON DELETE CASCADE;

ALTER TABLE ZoneLayout
ADD CONSTRAINT FK_ZoneLayout1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE ZoneLayout
ADD CONSTRAINT FK_ZoneLayout2
FOREIGN KEY (ZoneLayout_DistanceUnit)
REFERENCES Unit (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentDesign
ADD CONSTRAINT FK_ExperimentDesign1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentDesign
ADD CONSTRAINT FK_ExperimentDesign3
FOREIGN KEY (Experiment_ExperimentDesigns)
REFERENCES Experiment (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentalFactor
ADD CONSTRAINT FK_ExperimentalFactor1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentalFactor
ADD CONSTRAINT FK_ExperimentalFactor3
FOREIGN KEY (ExperimentDesign)
REFERENCES ExperimentDesign (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentalFactor
ADD CONSTRAINT FK_ExperimentalFactor4
FOREIGN KEY (ExperimentalFactor_Category)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE FactorValue
ADD CONSTRAINT FK_FactorValue1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE FactorValue
ADD CONSTRAINT FK_FactorValue3
FOREIGN KEY (ExperimentalFactor)
REFERENCES ExperimentalFactor (WID) ON DELETE CASCADE;

ALTER TABLE FactorValue
ADD CONSTRAINT FK_FactorValue4
FOREIGN KEY (ExperimentalFactor2)
REFERENCES ExperimentalFactor (WID) ON DELETE CASCADE;

ALTER TABLE FactorValue
ADD CONSTRAINT FK_FactorValue5
FOREIGN KEY (FactorValue_Measurement)
REFERENCES Measurement (WID) ON DELETE CASCADE;

ALTER TABLE FactorValue
ADD CONSTRAINT FK_FactorValue6
FOREIGN KEY (FactorValue_Value)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE QuantitationType
ADD CONSTRAINT FK_QuantitationType1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE QuantitationType
ADD CONSTRAINT FK_QuantitationType3
FOREIGN KEY (Channel)
REFERENCES Channel (WID) ON DELETE CASCADE;

ALTER TABLE QuantitationType
ADD CONSTRAINT FK_QuantitationType4
FOREIGN KEY (QuantitationType_Scale)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE QuantitationType
ADD CONSTRAINT FK_QuantitationType5
FOREIGN KEY (QuantitationType_DataType)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE QuantitationType
ADD CONSTRAINT FK_QuantitationType6
FOREIGN KEY (TargetQuantitationType)
REFERENCES QuantitationType (WID) ON DELETE CASCADE;

ALTER TABLE Database_
ADD CONSTRAINT FK_Database_1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Array_
ADD CONSTRAINT FK_Array_1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Array_
ADD CONSTRAINT FK_Array_3
FOREIGN KEY (ArrayDesign)
REFERENCES ArrayDesign (WID) ON DELETE CASCADE;

ALTER TABLE Array_
ADD CONSTRAINT FK_Array_4
FOREIGN KEY (Information)
REFERENCES ArrayManufacture (WID) ON DELETE CASCADE;

ALTER TABLE Array_
ADD CONSTRAINT FK_Array_5
FOREIGN KEY (ArrayGroup)
REFERENCES ArrayGroup (WID) ON DELETE CASCADE;

ALTER TABLE ArrayGroup
ADD CONSTRAINT FK_ArrayGroup1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE ArrayGroup
ADD CONSTRAINT FK_ArrayGroup3
FOREIGN KEY (ArrayGroup_SubstrateType)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE ArrayGroup
ADD CONSTRAINT FK_ArrayGroup4
FOREIGN KEY (ArrayGroup_DistanceUnit)
REFERENCES Unit (WID) ON DELETE CASCADE;

ALTER TABLE ArrayManufacture
ADD CONSTRAINT FK_ArrayManufacture1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE ArrayManufactureDeviation
ADD CONSTRAINT FK_ArrayManufactureDeviation1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE ArrayManufactureDeviation
ADD CONSTRAINT FK_ArrayManufactureDeviation2
FOREIGN KEY (Array_)
REFERENCES Array_ (WID) ON DELETE CASCADE;

ALTER TABLE FeatureDefect
ADD CONSTRAINT FK_FeatureDefect1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE FeatureDefect
ADD CONSTRAINT FK_FeatureDefect2
FOREIGN KEY (ArrayManufactureDeviation)
REFERENCES ArrayManufactureDeviation (WID) ON DELETE CASCADE;

ALTER TABLE FeatureDefect
ADD CONSTRAINT FK_FeatureDefect3
FOREIGN KEY (FeatureDefect_DefectType)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE FeatureDefect
ADD CONSTRAINT FK_FeatureDefect4
FOREIGN KEY (FeatureDefect_PositionDelta)
REFERENCES PositionDelta (WID) ON DELETE CASCADE;

ALTER TABLE FeatureDefect
ADD CONSTRAINT FK_FeatureDefect5
FOREIGN KEY (Feature)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE Fiducial
ADD CONSTRAINT FK_Fiducial1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Fiducial
ADD CONSTRAINT FK_Fiducial3
FOREIGN KEY (ArrayGroup_Fiducials)
REFERENCES ArrayGroup (WID) ON DELETE CASCADE;

ALTER TABLE Fiducial
ADD CONSTRAINT FK_Fiducial4
FOREIGN KEY (Fiducial_FiducialType)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE Fiducial
ADD CONSTRAINT FK_Fiducial5
FOREIGN KEY (Fiducial_DistanceUnit)
REFERENCES Unit (WID) ON DELETE CASCADE;

ALTER TABLE Fiducial
ADD CONSTRAINT FK_Fiducial6
FOREIGN KEY (Fiducial_Position)
REFERENCES Position_ (WID) ON DELETE CASCADE;

ALTER TABLE ManufactureLIMS
ADD CONSTRAINT FK_ManufactureLIMS1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE ManufactureLIMS
ADD CONSTRAINT FK_ManufactureLIMS3
FOREIGN KEY (ArrayManufacture_FeatureLIMSs)
REFERENCES ArrayManufacture (WID) ON DELETE CASCADE;

ALTER TABLE ManufactureLIMS
ADD CONSTRAINT FK_ManufactureLIMS4
FOREIGN KEY (Feature)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE ManufactureLIMS
ADD CONSTRAINT FK_ManufactureLIMS5
FOREIGN KEY (BioMaterial)
REFERENCES BioSource (WID) ON DELETE CASCADE;

ALTER TABLE PositionDelta
ADD CONSTRAINT FK_PositionDelta1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE PositionDelta
ADD CONSTRAINT FK_PositionDelta2
FOREIGN KEY (PositionDelta_DistanceUnit)
REFERENCES Unit (WID) ON DELETE CASCADE;

ALTER TABLE ZoneDefect
ADD CONSTRAINT FK_ZoneDefect1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE ZoneDefect
ADD CONSTRAINT FK_ZoneDefect2
FOREIGN KEY (ArrayManufactureDeviation)
REFERENCES ArrayManufactureDeviation (WID) ON DELETE CASCADE;

ALTER TABLE ZoneDefect
ADD CONSTRAINT FK_ZoneDefect3
FOREIGN KEY (ZoneDefect_DefectType)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE ZoneDefect
ADD CONSTRAINT FK_ZoneDefect4
FOREIGN KEY (ZoneDefect_PositionDelta)
REFERENCES PositionDelta (WID) ON DELETE CASCADE;

ALTER TABLE ZoneDefect
ADD CONSTRAINT FK_ZoneDefect5
FOREIGN KEY (Zone)
REFERENCES Zone (WID) ON DELETE CASCADE;

ALTER TABLE SeqFeatureLocation
ADD CONSTRAINT FK_SeqFeatureLocation1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE SeqFeatureLocation
ADD CONSTRAINT FK_SeqFeatureLocation2
FOREIGN KEY (SeqFeature_Regions)
REFERENCES Feature (WID) ON DELETE CASCADE;

ALTER TABLE SeqFeatureLocation
ADD CONSTRAINT FK_SeqFeatureLocation3
FOREIGN KEY (SeqFeatureLocation_Subregions)
REFERENCES SeqFeatureLocation (WID) ON DELETE CASCADE;

ALTER TABLE SeqFeatureLocation
ADD CONSTRAINT FK_SeqFeatureLocation4
FOREIGN KEY (SeqFeatureLocation_Coordinate)
REFERENCES SequencePosition (WID) ON DELETE CASCADE;

ALTER TABLE SequencePosition
ADD CONSTRAINT FK_SequencePosition1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE SequencePosition
ADD CONSTRAINT FK_SequencePosition2
FOREIGN KEY (CompositeCompositeMap)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE SequencePosition
ADD CONSTRAINT FK_SequencePosition3
FOREIGN KEY (Composite)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE SequencePosition
ADD CONSTRAINT FK_SequencePosition4
FOREIGN KEY (ReporterCompositeMap)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE SequencePosition
ADD CONSTRAINT FK_SequencePosition5
FOREIGN KEY (Reporter)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE DesignElement
ADD CONSTRAINT FK_DesignElement1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE DesignElement
ADD CONSTRAINT FK_DesignElement3
FOREIGN KEY (FeatureGroup_Features)
REFERENCES DesignElementGroup (WID) ON DELETE CASCADE;

ALTER TABLE DesignElement
ADD CONSTRAINT FK_DesignElement4
FOREIGN KEY (DesignElement_ControlType)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE DesignElement
ADD CONSTRAINT FK_DesignElement5
FOREIGN KEY (Feature_Position)
REFERENCES Position_ (WID) ON DELETE CASCADE;

ALTER TABLE DesignElement
ADD CONSTRAINT FK_DesignElement6
FOREIGN KEY (Zone)
REFERENCES Zone (WID) ON DELETE CASCADE;

ALTER TABLE DesignElement
ADD CONSTRAINT FK_DesignElement7
FOREIGN KEY (Feature_FeatureLocation)
REFERENCES FeatureLocation (WID) ON DELETE CASCADE;

ALTER TABLE DesignElement
ADD CONSTRAINT FK_DesignElement8
FOREIGN KEY (FeatureGroup)
REFERENCES DesignElementGroup (WID) ON DELETE CASCADE;

ALTER TABLE DesignElement
ADD CONSTRAINT FK_DesignElement9
FOREIGN KEY (Reporter_WarningType)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE FeatureInformation
ADD CONSTRAINT FK_FeatureInformation1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE FeatureInformation
ADD CONSTRAINT FK_FeatureInformation2
FOREIGN KEY (Feature)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE FeatureInformation
ADD CONSTRAINT FK_FeatureInformation3
FOREIGN KEY (FeatureReporterMap)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE FeatureLocation
ADD CONSTRAINT FK_FeatureLocation1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE MismatchInformation
ADD CONSTRAINT FK_MismatchInformation1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE MismatchInformation
ADD CONSTRAINT FK_MismatchInformation2
FOREIGN KEY (CompositePosition)
REFERENCES SequencePosition (WID) ON DELETE CASCADE;

ALTER TABLE MismatchInformation
ADD CONSTRAINT FK_MismatchInformation3
FOREIGN KEY (FeatureInformation)
REFERENCES FeatureInformation (WID) ON DELETE CASCADE;

ALTER TABLE MismatchInformation
ADD CONSTRAINT FK_MismatchInformation4
FOREIGN KEY (ReporterPosition)
REFERENCES SequencePosition (WID) ON DELETE CASCADE;

ALTER TABLE Position_
ADD CONSTRAINT FK_Position_1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Position_
ADD CONSTRAINT FK_Position_2
FOREIGN KEY (Position_DistanceUnit)
REFERENCES Unit (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent3
FOREIGN KEY (CompositeSequence)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent4
FOREIGN KEY (Reporter)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent5
FOREIGN KEY (CompositeSequence2)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent6
FOREIGN KEY (BioAssayMapTarget)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent7
FOREIGN KEY (TargetQuantitationType)
REFERENCES QuantitationType (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent8
FOREIGN KEY (DerivedBioAssayDataTarget)
REFERENCES BioAssayData (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent9
FOREIGN KEY (QuantitationTypeMapping)
REFERENCES QuantitationTypeMapping (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent10
FOREIGN KEY (DesignElementMapping)
REFERENCES DesignElementMapping (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent11
FOREIGN KEY (Transformation_BioAssayMapping)
REFERENCES BioAssayMapping (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent12
FOREIGN KEY (BioMaterial_Treatments)
REFERENCES BioSource (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent13
FOREIGN KEY (Treatment_Action)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent14
FOREIGN KEY (Treatment_ActionMeasurement)
REFERENCES Measurement (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent15
FOREIGN KEY (Array_)
REFERENCES Array_ (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent16
FOREIGN KEY (PhysicalBioAssayTarget)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent17
FOREIGN KEY (PhysicalBioAssay)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent18
FOREIGN KEY (Target)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent19
FOREIGN KEY (PhysicalBioAssaySource)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent20
FOREIGN KEY (MeasuredBioAssayTarget)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE BioEvent
ADD CONSTRAINT FK_BioEvent21
FOREIGN KEY (PhysicalBioAssay2)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayData
ADD CONSTRAINT FK_BioAssayData1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayData
ADD CONSTRAINT FK_BioAssayData3
FOREIGN KEY (BioAssayDimension)
REFERENCES BioAssayDimension (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayData
ADD CONSTRAINT FK_BioAssayData4
FOREIGN KEY (DesignElementDimension)
REFERENCES DesignElementDimension (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayData
ADD CONSTRAINT FK_BioAssayData5
FOREIGN KEY (QuantitationTypeDimension)
REFERENCES QuantitationTypeDimension (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayData
ADD CONSTRAINT FK_BioAssayData6
FOREIGN KEY (BioAssayData_BioDataValues)
REFERENCES BioDataValues (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayData
ADD CONSTRAINT FK_BioAssayData7
FOREIGN KEY (ProducerTransformation)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayDimension
ADD CONSTRAINT FK_BioAssayDimension1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayMapping
ADD CONSTRAINT FK_BioAssayMapping1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayTuple
ADD CONSTRAINT FK_BioAssayTuple1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayTuple
ADD CONSTRAINT FK_BioAssayTuple2
FOREIGN KEY (BioAssay)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayTuple
ADD CONSTRAINT FK_BioAssayTuple3
FOREIGN KEY (BioDataTuples_BioAssayTuples)
REFERENCES BioDataValues (WID) ON DELETE CASCADE;

ALTER TABLE BioDataValues
ADD CONSTRAINT FK_BioDataValues1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE BioDataValues
ADD CONSTRAINT FK_BioDataValues2
FOREIGN KEY (BioDataCube_DataInternal)
REFERENCES DataInternal (WID) ON DELETE CASCADE;

ALTER TABLE BioDataValues
ADD CONSTRAINT FK_BioDataValues3
FOREIGN KEY (BioDataCube_DataExternal)
REFERENCES DataExternal (WID) ON DELETE CASCADE;

ALTER TABLE DataExternal
ADD CONSTRAINT FK_DataExternal1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE DataInternal
ADD CONSTRAINT FK_DataInternal1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Datum
ADD CONSTRAINT FK_Datum1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE DesignElementDimension
ADD CONSTRAINT FK_DesignElementDimension1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE DesignElementMapping
ADD CONSTRAINT FK_DesignElementMapping1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE DesignElementTuple
ADD CONSTRAINT FK_DesignElementTuple1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE DesignElementTuple
ADD CONSTRAINT FK_DesignElementTuple2
FOREIGN KEY (BioAssayTuple)
REFERENCES BioAssayTuple (WID) ON DELETE CASCADE;

ALTER TABLE DesignElementTuple
ADD CONSTRAINT FK_DesignElementTuple3
FOREIGN KEY (DesignElement)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE QuantitationTypeDimension
ADD CONSTRAINT FK_QuantitationTypeDimension1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE QuantitationTypeMapping
ADD CONSTRAINT FK_QuantitationTypeMapping1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE QuantitationTypeTuple
ADD CONSTRAINT FK_QuantitationTypeTuple1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE QuantitationTypeTuple
ADD CONSTRAINT FK_QuantitationTypeTuple2
FOREIGN KEY (DesignElementTuple)
REFERENCES DesignElementTuple (WID) ON DELETE CASCADE;

ALTER TABLE QuantitationTypeTuple
ADD CONSTRAINT FK_QuantitationTypeTuple3
FOREIGN KEY (QuantitationType)
REFERENCES QuantitationType (WID) ON DELETE CASCADE;

ALTER TABLE QuantitationTypeTuple
ADD CONSTRAINT FK_QuantitationTypeTuple4
FOREIGN KEY (QuantitationTypeTuple_Datum)
REFERENCES Datum (WID) ON DELETE CASCADE;

ALTER TABLE BioMaterialMeasurement
ADD CONSTRAINT FK_BioMaterialMeasurement1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE BioMaterialMeasurement
ADD CONSTRAINT FK_BioMaterialMeasurement2
FOREIGN KEY (BioMaterial)
REFERENCES BioSource (WID) ON DELETE CASCADE;

ALTER TABLE BioMaterialMeasurement
ADD CONSTRAINT FK_BioMaterialMeasurement3
FOREIGN KEY (Measurement)
REFERENCES Measurement (WID) ON DELETE CASCADE;

ALTER TABLE BioMaterialMeasurement
ADD CONSTRAINT FK_BioMaterialMeasurement4
FOREIGN KEY (Treatment)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE BioMaterialMeasurement
ADD CONSTRAINT FK_BioMaterialMeasurement5
FOREIGN KEY (BioAssayCreation)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE CompoundMeasurement
ADD CONSTRAINT FK_CompoundMeasurement1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE CompoundMeasurement
ADD CONSTRAINT FK_CompoundMeasurement2
FOREIGN KEY (Compound_ComponentCompounds)
REFERENCES Chemical (WID) ON DELETE CASCADE;

ALTER TABLE CompoundMeasurement
ADD CONSTRAINT FK_CompoundMeasurement3
FOREIGN KEY (Compound)
REFERENCES Chemical (WID) ON DELETE CASCADE;

ALTER TABLE CompoundMeasurement
ADD CONSTRAINT FK_CompoundMeasurement4
FOREIGN KEY (Measurement)
REFERENCES Measurement (WID) ON DELETE CASCADE;

ALTER TABLE CompoundMeasurement
ADD CONSTRAINT FK_CompoundMeasurement5
FOREIGN KEY (Treatment_CompoundMeasurements)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE BioAssay
ADD CONSTRAINT FK_BioAssay1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE BioAssay
ADD CONSTRAINT FK_BioAssay3
FOREIGN KEY (DerivedBioAssay_Type)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE BioAssay
ADD CONSTRAINT FK_BioAssay4
FOREIGN KEY (FeatureExtraction)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE BioAssay
ADD CONSTRAINT FK_BioAssay5
FOREIGN KEY (BioAssayCreation)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE Channel
ADD CONSTRAINT FK_Channel1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Image
ADD CONSTRAINT FK_Image1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Image
ADD CONSTRAINT FK_Image3
FOREIGN KEY (Image_Format)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE Image
ADD CONSTRAINT FK_Image4
FOREIGN KEY (PhysicalBioAssay)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayDataCluster
ADD CONSTRAINT FK_BioAssayDataCluster1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayDataCluster
ADD CONSTRAINT FK_BioAssayDataCluster3
FOREIGN KEY (ClusterBioAssayData)
REFERENCES BioAssayData (WID) ON DELETE CASCADE;

ALTER TABLE Node
ADD CONSTRAINT FK_Node1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Node
ADD CONSTRAINT FK_Node3
FOREIGN KEY (BioAssayDataCluster_Nodes)
REFERENCES BioAssayDataCluster (WID) ON DELETE CASCADE;

ALTER TABLE Node
ADD CONSTRAINT FK_Node4
FOREIGN KEY (Node_Nodes)
REFERENCES Node (WID) ON DELETE CASCADE;

ALTER TABLE NodeContents
ADD CONSTRAINT FK_NodeContents1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE NodeContents
ADD CONSTRAINT FK_NodeContents3
FOREIGN KEY (Node_NodeContents)
REFERENCES Node (WID) ON DELETE CASCADE;

ALTER TABLE NodeContents
ADD CONSTRAINT FK_NodeContents4
FOREIGN KEY (BioAssayDimension)
REFERENCES BioAssayDimension (WID) ON DELETE CASCADE;

ALTER TABLE NodeContents
ADD CONSTRAINT FK_NodeContents5
FOREIGN KEY (DesignElementDimension)
REFERENCES DesignElementDimension (WID) ON DELETE CASCADE;

ALTER TABLE NodeContents
ADD CONSTRAINT FK_NodeContents6
FOREIGN KEY (QuantitationDimension)
REFERENCES QuantitationTypeDimension (WID) ON DELETE CASCADE;

ALTER TABLE NodeValue
ADD CONSTRAINT FK_NodeValue1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE NodeValue
ADD CONSTRAINT FK_NodeValue2
FOREIGN KEY (Node_NodeValue)
REFERENCES Node (WID) ON DELETE CASCADE;

ALTER TABLE NodeValue
ADD CONSTRAINT FK_NodeValue3
FOREIGN KEY (NodeValue_Type)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE NodeValue
ADD CONSTRAINT FK_NodeValue4
FOREIGN KEY (NodeValue_Scale)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE NodeValue
ADD CONSTRAINT FK_NodeValue5
FOREIGN KEY (NodeValue_DataType)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE Measurement
ADD CONSTRAINT FK_Measurement1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Measurement
ADD CONSTRAINT FK_Measurement2
FOREIGN KEY (Measurement_Unit)
REFERENCES Unit (WID) ON DELETE CASCADE;

ALTER TABLE Unit
ADD CONSTRAINT FK_Unit1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Parameter
ADD CONSTRAINT FK_Parameter1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Parameter
ADD CONSTRAINT FK_Parameter3
FOREIGN KEY (Parameter_DefaultValue)
REFERENCES Measurement (WID) ON DELETE CASCADE;

ALTER TABLE Parameter
ADD CONSTRAINT FK_Parameter4
FOREIGN KEY (Parameter_DataType)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE Parameter
ADD CONSTRAINT FK_Parameter5
FOREIGN KEY (Parameterizable_ParameterTypes)
REFERENCES Parameterizable (WID) ON DELETE CASCADE;

ALTER TABLE ParameterValue
ADD CONSTRAINT FK_ParameterValue1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE ParameterValue
ADD CONSTRAINT FK_ParameterValue2
FOREIGN KEY (ParameterType)
REFERENCES Parameter (WID) ON DELETE CASCADE;

ALTER TABLE ParameterValue
ADD CONSTRAINT FK_ParameterValue3
FOREIGN KEY (ParameterizableApplication)
REFERENCES ParameterizableApplication (WID) ON DELETE CASCADE;

ALTER TABLE Parameterizable
ADD CONSTRAINT FK_Parameterizable1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE Parameterizable
ADD CONSTRAINT FK_Parameterizable3
FOREIGN KEY (Hardware_Type)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE Parameterizable
ADD CONSTRAINT FK_Parameterizable4
FOREIGN KEY (Protocol_Type)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE Parameterizable
ADD CONSTRAINT FK_Parameterizable5
FOREIGN KEY (Software_Type)
REFERENCES Term (WID) ON DELETE CASCADE;

ALTER TABLE Parameterizable
ADD CONSTRAINT FK_Parameterizable6
FOREIGN KEY (Hardware)
REFERENCES Parameterizable (WID) ON DELETE CASCADE;

ALTER TABLE ParameterizableApplication
ADD CONSTRAINT FK_ParameterizableApplicatio1
FOREIGN KEY (DataSetWID)
REFERENCES DataSet (WID) ON DELETE CASCADE;

ALTER TABLE ParameterizableApplication
ADD CONSTRAINT FK_ParameterizableApplicatio3
FOREIGN KEY (ArrayDesign)
REFERENCES ArrayDesign (WID) ON DELETE CASCADE;

ALTER TABLE ParameterizableApplication
ADD CONSTRAINT FK_ParameterizableApplicatio4
FOREIGN KEY (ArrayManufacture)
REFERENCES ArrayManufacture (WID) ON DELETE CASCADE;

ALTER TABLE ParameterizableApplication
ADD CONSTRAINT FK_ParameterizableApplicatio5
FOREIGN KEY (BioEvent_ProtocolApplications)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE ParameterizableApplication
ADD CONSTRAINT FK_ParameterizableApplicatio6
FOREIGN KEY (Hardware)
REFERENCES Parameterizable (WID) ON DELETE CASCADE;

ALTER TABLE ParameterizableApplication
ADD CONSTRAINT FK_ParameterizableApplicatio7
FOREIGN KEY (ProtocolApplication)
REFERENCES ParameterizableApplication (WID) ON DELETE CASCADE;

ALTER TABLE ParameterizableApplication
ADD CONSTRAINT FK_ParameterizableApplicatio8
FOREIGN KEY (ProtocolApplication2)
REFERENCES ParameterizableApplication (WID) ON DELETE CASCADE;

ALTER TABLE ParameterizableApplication
ADD CONSTRAINT FK_ParameterizableApplicatio9
FOREIGN KEY (Protocol)
REFERENCES Parameterizable (WID) ON DELETE CASCADE;

ALTER TABLE ParameterizableApplication
ADD CONSTRAINT FK_ParameterizableApplicatio10
FOREIGN KEY (Software)
REFERENCES Parameterizable (WID) ON DELETE CASCADE;

ALTER TABLE ArrayDesignWIDReporterGroupWID
ADD CONSTRAINT FK_ArrayDesignWIDReporterGro1
FOREIGN KEY (ArrayDesignWID)
REFERENCES ArrayDesign (WID) ON DELETE CASCADE;

ALTER TABLE ArrayDesignWIDReporterGroupWID
ADD CONSTRAINT FK_ArrayDesignWIDReporterGro2
FOREIGN KEY (ReporterGroupWID)
REFERENCES DesignElementGroup (WID) ON DELETE CASCADE;

ALTER TABLE ArrayDesignWIDCompositeGrpWID
ADD CONSTRAINT FK_ArrayDesignWIDCompositeGr1
FOREIGN KEY (ArrayDesignWID)
REFERENCES ArrayDesign (WID) ON DELETE CASCADE;

ALTER TABLE ArrayDesignWIDCompositeGrpWID
ADD CONSTRAINT FK_ArrayDesignWIDCompositeGr2
FOREIGN KEY (CompositeGroupWID)
REFERENCES DesignElementGroup (WID) ON DELETE CASCADE;

ALTER TABLE ArrayDesignWIDContactWID
ADD CONSTRAINT FK_ArrayDesignWIDContactWID1
FOREIGN KEY (ArrayDesignWID)
REFERENCES ArrayDesign (WID) ON DELETE CASCADE;

ALTER TABLE ArrayDesignWIDContactWID
ADD CONSTRAINT FK_ArrayDesignWIDContactWID2
FOREIGN KEY (ContactWID)
REFERENCES Contact (WID) ON DELETE CASCADE;

ALTER TABLE ComposGrpWIDComposSequenceWID
ADD CONSTRAINT FK_ComposGrpWIDComposSequenc1
FOREIGN KEY (CompositeGroupWID)
REFERENCES DesignElementGroup (WID) ON DELETE CASCADE;

ALTER TABLE ComposGrpWIDComposSequenceWID
ADD CONSTRAINT FK_ComposGrpWIDComposSequenc2
FOREIGN KEY (CompositeSequenceWID)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE ReporterGroupWIDReporterWID
ADD CONSTRAINT FK_ReporterGroupWIDReporterW1
FOREIGN KEY (ReporterGroupWID)
REFERENCES DesignElementGroup (WID) ON DELETE CASCADE;

ALTER TABLE ReporterGroupWIDReporterWID
ADD CONSTRAINT FK_ReporterGroupWIDReporterW2
FOREIGN KEY (ReporterWID)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentWIDContactWID
ADD CONSTRAINT FK_ExperimentWIDContactWID1
FOREIGN KEY (ExperimentWID)
REFERENCES Experiment (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentWIDContactWID
ADD CONSTRAINT FK_ExperimentWIDContactWID2
FOREIGN KEY (ContactWID)
REFERENCES Contact (WID) ON DELETE CASCADE;

ALTER TABLE ExperimWIDBioAssayDataClustWID
ADD CONSTRAINT FK_ExperimWIDBioAssayDataClu1
FOREIGN KEY (ExperimentWID)
REFERENCES Experiment (WID) ON DELETE CASCADE;

ALTER TABLE ExperimWIDBioAssayDataClustWID
ADD CONSTRAINT FK_ExperimWIDBioAssayDataClu2
FOREIGN KEY (BioAssayDataClusterWID)
REFERENCES BioAssayDataCluster (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentWIDBioAssayDataWID
ADD CONSTRAINT FK_ExperimentWIDBioAssayData1
FOREIGN KEY (ExperimentWID)
REFERENCES Experiment (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentWIDBioAssayDataWID
ADD CONSTRAINT FK_ExperimentWIDBioAssayData2
FOREIGN KEY (BioAssayDataWID)
REFERENCES BioAssayData (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentWIDBioAssayWID
ADD CONSTRAINT FK_ExperimentWIDBioAssayWID1
FOREIGN KEY (ExperimentWID)
REFERENCES Experiment (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentWIDBioAssayWID
ADD CONSTRAINT FK_ExperimentWIDBioAssayWID2
FOREIGN KEY (BioAssayWID)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentDesignWIDBioAssayWID
ADD CONSTRAINT FK_ExperimentDesignWIDBioAss1
FOREIGN KEY (ExperimentDesignWID)
REFERENCES ExperimentDesign (WID) ON DELETE CASCADE;

ALTER TABLE ExperimentDesignWIDBioAssayWID
ADD CONSTRAINT FK_ExperimentDesignWIDBioAss2
FOREIGN KEY (BioAssayWID)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE QuantTypeWIDConfidenceIndWID
ADD CONSTRAINT FK_QuantTypeWIDConfidenceInd1
FOREIGN KEY (QuantitationTypeWID)
REFERENCES QuantitationType (WID) ON DELETE CASCADE;

ALTER TABLE QuantTypeWIDConfidenceIndWID
ADD CONSTRAINT FK_QuantTypeWIDConfidenceInd2
FOREIGN KEY (ConfidenceIndicatorWID)
REFERENCES QuantitationType (WID) ON DELETE CASCADE;

ALTER TABLE QuantTypeWIDQuantTypeMapWID
ADD CONSTRAINT FK_QuantTypeWIDQuantTypeMapW1
FOREIGN KEY (QuantitationTypeWID)
REFERENCES QuantitationType (WID) ON DELETE CASCADE;

ALTER TABLE QuantTypeWIDQuantTypeMapWID
ADD CONSTRAINT FK_QuantTypeWIDQuantTypeMapW2
FOREIGN KEY (QuantitationTypeMapWID)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE DatabaseWIDContactWID
ADD CONSTRAINT FK_DatabaseWIDContactWID1
FOREIGN KEY (DatabaseWID)
REFERENCES Database_ (WID) ON DELETE CASCADE;

ALTER TABLE DatabaseWIDContactWID
ADD CONSTRAINT FK_DatabaseWIDContactWID2
FOREIGN KEY (ContactWID)
REFERENCES Contact (WID) ON DELETE CASCADE;

ALTER TABLE ArrayGroupWIDArrayWID
ADD CONSTRAINT FK_ArrayGroupWIDArrayWID1
FOREIGN KEY (ArrayGroupWID)
REFERENCES ArrayGroup (WID) ON DELETE CASCADE;

ALTER TABLE ArrayGroupWIDArrayWID
ADD CONSTRAINT FK_ArrayGroupWIDArrayWID2
FOREIGN KEY (ArrayWID)
REFERENCES Array_ (WID) ON DELETE CASCADE;

ALTER TABLE ArrayManufactureWIDArrayWID
ADD CONSTRAINT FK_ArrayManufactureWIDArrayW1
FOREIGN KEY (ArrayManufactureWID)
REFERENCES ArrayManufacture (WID) ON DELETE CASCADE;

ALTER TABLE ArrayManufactureWIDArrayWID
ADD CONSTRAINT FK_ArrayManufactureWIDArrayW2
FOREIGN KEY (ArrayWID)
REFERENCES Array_ (WID) ON DELETE CASCADE;

ALTER TABLE ArrayManufactureWIDContactWID
ADD CONSTRAINT FK_ArrayManufactureWIDContac1
FOREIGN KEY (ArrayManufactureWID)
REFERENCES ArrayManufacture (WID) ON DELETE CASCADE;

ALTER TABLE ArrayManufactureWIDContactWID
ADD CONSTRAINT FK_ArrayManufactureWIDContac2
FOREIGN KEY (ContactWID)
REFERENCES Contact (WID) ON DELETE CASCADE;

ALTER TABLE CompositeSeqWIDBioSeqWID
ADD CONSTRAINT FK_CompositeSeqWIDBioSeqWID1
FOREIGN KEY (CompositeSequenceWID)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE ComposSeqWIDRepoComposMapWID
ADD CONSTRAINT FK_ComposSeqWIDRepoComposMap1
FOREIGN KEY (CompositeSequenceWID)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE ComposSeqWIDRepoComposMapWID
ADD CONSTRAINT FK_ComposSeqWIDRepoComposMap2
FOREIGN KEY (ReporterCompositeMapWID)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE ComposSeqWIDComposComposMapWID
ADD CONSTRAINT FK_ComposSeqWIDComposComposM1
FOREIGN KEY (CompositeSequenceWID)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE ComposSeqWIDComposComposMapWID
ADD CONSTRAINT FK_ComposSeqWIDComposComposM2
FOREIGN KEY (CompositeCompositeMapWID)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE FeatureWIDFeatureWID
ADD CONSTRAINT FK_FeatureWIDFeatureWID1
FOREIGN KEY (FeatureWID1)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE FeatureWIDFeatureWID
ADD CONSTRAINT FK_FeatureWIDFeatureWID2
FOREIGN KEY (FeatureWID2)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE FeatureWIDFeatureWID2
ADD CONSTRAINT FK_FeatureWIDFeatureWID21
FOREIGN KEY (FeatureWID1)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE FeatureWIDFeatureWID2
ADD CONSTRAINT FK_FeatureWIDFeatureWID22
FOREIGN KEY (FeatureWID2)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE ReporterWIDBioSequenceWID
ADD CONSTRAINT FK_ReporterWIDBioSequenceWID1
FOREIGN KEY (ReporterWID)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE ReporterWIDFeatureReporMapWID
ADD CONSTRAINT FK_ReporterWIDFeatureReporMa1
FOREIGN KEY (ReporterWID)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE ReporterWIDFeatureReporMapWID
ADD CONSTRAINT FK_ReporterWIDFeatureReporMa2
FOREIGN KEY (FeatureReporterMapWID)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayDimensioWIDBioAssayWID
ADD CONSTRAINT FK_BioAssayDimensioWIDBioAss1
FOREIGN KEY (BioAssayDimensionWID)
REFERENCES BioAssayDimension (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayDimensioWIDBioAssayWID
ADD CONSTRAINT FK_BioAssayDimensioWIDBioAss2
FOREIGN KEY (BioAssayWID)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayMapWIDBioAssayWID
ADD CONSTRAINT FK_BioAssayMapWIDBioAssayWID1
FOREIGN KEY (BioAssayMapWID)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayMapWIDBioAssayWID
ADD CONSTRAINT FK_BioAssayMapWIDBioAssayWID2
FOREIGN KEY (BioAssayWID)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE BAssayMappingWIDBAssayMapWID
ADD CONSTRAINT FK_BAssayMappingWIDBAssayMap1
FOREIGN KEY (BioAssayMappingWID)
REFERENCES BioAssayMapping (WID) ON DELETE CASCADE;

ALTER TABLE BAssayMappingWIDBAssayMapWID
ADD CONSTRAINT FK_BAssayMappingWIDBAssayMap2
FOREIGN KEY (BioAssayMapWID)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE ComposSeqDimensWIDComposSeqWID
ADD CONSTRAINT FK_ComposSeqDimensWIDComposS1
FOREIGN KEY (CompositeSequenceDimensionWID)
REFERENCES DesignElementDimension (WID) ON DELETE CASCADE;

ALTER TABLE ComposSeqDimensWIDComposSeqWID
ADD CONSTRAINT FK_ComposSeqDimensWIDComposS2
FOREIGN KEY (CompositeSequenceWID)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE DesnElMappingWIDDesnElMapWID
ADD CONSTRAINT FK_DesnElMappingWIDDesnElMap1
FOREIGN KEY (DesignElementMappingWID)
REFERENCES DesignElementMapping (WID) ON DELETE CASCADE;

ALTER TABLE DesnElMappingWIDDesnElMapWID
ADD CONSTRAINT FK_DesnElMappingWIDDesnElMap2
FOREIGN KEY (DesignElementMapWID)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE FeatureDimensionWIDFeatureWID
ADD CONSTRAINT FK_FeatureDimensionWIDFeatur1
FOREIGN KEY (FeatureDimensionWID)
REFERENCES DesignElementDimension (WID) ON DELETE CASCADE;

ALTER TABLE FeatureDimensionWIDFeatureWID
ADD CONSTRAINT FK_FeatureDimensionWIDFeatur2
FOREIGN KEY (FeatureWID)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE QuantTypeDimensWIDQuantTypeWID
ADD CONSTRAINT FK_QuantTypeDimensWIDQuantTy1
FOREIGN KEY (QuantitationTypeDimensionWID)
REFERENCES QuantitationTypeDimension (WID) ON DELETE CASCADE;

ALTER TABLE QuantTypeDimensWIDQuantTypeWID
ADD CONSTRAINT FK_QuantTypeDimensWIDQuantTy2
FOREIGN KEY (QuantitationTypeWID)
REFERENCES QuantitationType (WID) ON DELETE CASCADE;

ALTER TABLE QuantTypeMapWIDQuantTypeWID
ADD CONSTRAINT FK_QuantTypeMapWIDQuantTypeW1
FOREIGN KEY (QuantitationTypeMapWID)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE QuantTypeMapWIDQuantTypeWID
ADD CONSTRAINT FK_QuantTypeMapWIDQuantTypeW2
FOREIGN KEY (QuantitationTypeWID)
REFERENCES QuantitationType (WID) ON DELETE CASCADE;

ALTER TABLE QuantTyMapWIDQuantTyMapWI
ADD CONSTRAINT FK_QuantTyMapWIDQuantTyMapWI1
FOREIGN KEY (QuantitationTypeMappingWID)
REFERENCES QuantitationTypeMapping (WID) ON DELETE CASCADE;

ALTER TABLE QuantTyMapWIDQuantTyMapWI
ADD CONSTRAINT FK_QuantTyMapWIDQuantTyMapWI2
FOREIGN KEY (QuantitationTypeMapWID)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE ReporterDimensWIDReporterWID
ADD CONSTRAINT FK_ReporterDimensWIDReporter1
FOREIGN KEY (ReporterDimensionWID)
REFERENCES DesignElementDimension (WID) ON DELETE CASCADE;

ALTER TABLE ReporterDimensWIDReporterWID
ADD CONSTRAINT FK_ReporterDimensWIDReporter2
FOREIGN KEY (ReporterWID)
REFERENCES DesignElement (WID) ON DELETE CASCADE;

ALTER TABLE TransformWIDBioAssayDataWID
ADD CONSTRAINT FK_TransformWIDBioAssayDataW1
FOREIGN KEY (TransformationWID)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE TransformWIDBioAssayDataWID
ADD CONSTRAINT FK_TransformWIDBioAssayDataW2
FOREIGN KEY (BioAssayDataWID)
REFERENCES BioAssayData (WID) ON DELETE CASCADE;

ALTER TABLE BioSourceWIDContactWID
ADD CONSTRAINT FK_BioSourceWIDContactWID1
FOREIGN KEY (BioSourceWID)
REFERENCES BioSource (WID) ON DELETE CASCADE;

ALTER TABLE BioSourceWIDContactWID
ADD CONSTRAINT FK_BioSourceWIDContactWID2
FOREIGN KEY (ContactWID)
REFERENCES Contact (WID) ON DELETE CASCADE;

ALTER TABLE LabeledExtractWIDCompoundWID
ADD CONSTRAINT FK_LabeledExtractWIDCompound1
FOREIGN KEY (LabeledExtractWID)
REFERENCES BioSource (WID) ON DELETE CASCADE;

ALTER TABLE LabeledExtractWIDCompoundWID
ADD CONSTRAINT FK_LabeledExtractWIDCompound2
FOREIGN KEY (CompoundWID)
REFERENCES Chemical (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayWIDChannelWID
ADD CONSTRAINT FK_BioAssayWIDChannelWID1
FOREIGN KEY (BioAssayWID)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayWIDChannelWID
ADD CONSTRAINT FK_BioAssayWIDChannelWID2
FOREIGN KEY (ChannelWID)
REFERENCES Channel (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayWIDFactorValueWID
ADD CONSTRAINT FK_BioAssayWIDFactorValueWID1
FOREIGN KEY (BioAssayWID)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE BioAssayWIDFactorValueWID
ADD CONSTRAINT FK_BioAssayWIDFactorValueWID2
FOREIGN KEY (FactorValueWID)
REFERENCES FactorValue (WID) ON DELETE CASCADE;

ALTER TABLE ChannelWIDCompoundWID
ADD CONSTRAINT FK_ChannelWIDCompoundWID1
FOREIGN KEY (ChannelWID)
REFERENCES Channel (WID) ON DELETE CASCADE;

ALTER TABLE ChannelWIDCompoundWID
ADD CONSTRAINT FK_ChannelWIDCompoundWID2
FOREIGN KEY (CompoundWID)
REFERENCES Chemical (WID) ON DELETE CASCADE;

ALTER TABLE DerivBioAWIDDerivBioADataWID
ADD CONSTRAINT FK_DerivBioAWIDDerivBioAData1
FOREIGN KEY (DerivedBioAssayWID)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE DerivBioAWIDDerivBioADataWID
ADD CONSTRAINT FK_DerivBioAWIDDerivBioAData2
FOREIGN KEY (DerivedBioAssayDataWID)
REFERENCES BioAssayData (WID) ON DELETE CASCADE;

ALTER TABLE DerivBioAssayWIDBioAssayMapWID
ADD CONSTRAINT FK_DerivBioAssayWIDBioAssayM1
FOREIGN KEY (DerivedBioAssayWID)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE DerivBioAssayWIDBioAssayMapWID
ADD CONSTRAINT FK_DerivBioAssayWIDBioAssayM2
FOREIGN KEY (BioAssayMapWID)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE ImageWIDChannelWID
ADD CONSTRAINT FK_ImageWIDChannelWID1
FOREIGN KEY (ImageWID)
REFERENCES Image (WID) ON DELETE CASCADE;

ALTER TABLE ImageWIDChannelWID
ADD CONSTRAINT FK_ImageWIDChannelWID2
FOREIGN KEY (ChannelWID)
REFERENCES Channel (WID) ON DELETE CASCADE;

ALTER TABLE ImageAcquisitionWIDImageWID
ADD CONSTRAINT FK_ImageAcquisitionWIDImageW1
FOREIGN KEY (ImageAcquisitionWID)
REFERENCES BioEvent (WID) ON DELETE CASCADE;

ALTER TABLE ImageAcquisitionWIDImageWID
ADD CONSTRAINT FK_ImageAcquisitionWIDImageW2
FOREIGN KEY (ImageWID)
REFERENCES Image (WID) ON DELETE CASCADE;

ALTER TABLE MeasBAssayWIDMeasBAssayDataWID
ADD CONSTRAINT FK_MeasBAssayWIDMeasBAssayDa1
FOREIGN KEY (MeasuredBioAssayWID)
REFERENCES BioAssay (WID) ON DELETE CASCADE;

ALTER TABLE MeasBAssayWIDMeasBAssayDataWID
ADD CONSTRAINT FK_MeasBAssayWIDMeasBAssayDa2
FOREIGN KEY (MeasuredBioAssayDataWID)
REFERENCES BioAssayData (WID) ON DELETE CASCADE;

ALTER TABLE HardwareWIDSoftwareWID
ADD CONSTRAINT FK_HardwareWIDSoftwareWID1
FOREIGN KEY (HardwareWID)
REFERENCES Parameterizable (WID) ON DELETE CASCADE;

ALTER TABLE HardwareWIDSoftwareWID
ADD CONSTRAINT FK_HardwareWIDSoftwareWID2
FOREIGN KEY (SoftwareWID)
REFERENCES Parameterizable (WID) ON DELETE CASCADE;

ALTER TABLE HardwareWIDContactWID
ADD CONSTRAINT FK_HardwareWIDContactWID1
FOREIGN KEY (HardwareWID)
REFERENCES Parameterizable (WID) ON DELETE CASCADE;

ALTER TABLE HardwareWIDContactWID
ADD CONSTRAINT FK_HardwareWIDContactWID2
FOREIGN KEY (ContactWID)
REFERENCES Contact (WID) ON DELETE CASCADE;

ALTER TABLE ProtocolWIDHardwareWID
ADD CONSTRAINT FK_ProtocolWIDHardwareWID1
FOREIGN KEY (ProtocolWID)
REFERENCES Parameterizable (WID) ON DELETE CASCADE;

ALTER TABLE ProtocolWIDHardwareWID
ADD CONSTRAINT FK_ProtocolWIDHardwareWID2
FOREIGN KEY (HardwareWID)
REFERENCES Parameterizable (WID) ON DELETE CASCADE;

ALTER TABLE ProtocolWIDSoftwareWID
ADD CONSTRAINT FK_ProtocolWIDSoftwareWID1
FOREIGN KEY (ProtocolWID)
REFERENCES Parameterizable (WID) ON DELETE CASCADE;

ALTER TABLE ProtocolWIDSoftwareWID
ADD CONSTRAINT FK_ProtocolWIDSoftwareWID2
FOREIGN KEY (SoftwareWID)
REFERENCES Parameterizable (WID) ON DELETE CASCADE;

ALTER TABLE ProtocolApplWIDPersonWID
ADD CONSTRAINT FK_ProtocolApplWIDPersonWID1
FOREIGN KEY (ProtocolApplicationWID)
REFERENCES ParameterizableApplication (WID) ON DELETE CASCADE;

ALTER TABLE ProtocolApplWIDPersonWID
ADD CONSTRAINT FK_ProtocolApplWIDPersonWID2
FOREIGN KEY (PersonWID)
REFERENCES Contact (WID) ON DELETE CASCADE;

ALTER TABLE SoftwareWIDSoftwareWID
ADD CONSTRAINT FK_SoftwareWIDSoftwareWID1
FOREIGN KEY (SoftwareWID1)
REFERENCES Parameterizable (WID) ON DELETE CASCADE;

ALTER TABLE SoftwareWIDSoftwareWID
ADD CONSTRAINT FK_SoftwareWIDSoftwareWID2
FOREIGN KEY (SoftwareWID2)
REFERENCES Parameterizable (WID) ON DELETE CASCADE;

ALTER TABLE SoftwareWIDContactWID
ADD CONSTRAINT FK_SoftwareWIDContactWID1
FOREIGN KEY (SoftwareWID)
REFERENCES Parameterizable (WID) ON DELETE CASCADE;

ALTER TABLE SoftwareWIDContactWID
ADD CONSTRAINT FK_SoftwareWIDContactWID2
FOREIGN KEY (ContactWID)
REFERENCES Contact (WID) ON DELETE CASCADE;


commit;
