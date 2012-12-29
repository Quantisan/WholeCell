CREATE INDEX ENUM_TBNAME ON Enumeration(TABLENAME);
CREATE INDEX ENUM_COLNAME ON Enumeration(COLUMNNAME);
CREATE INDEX ENUM_VALUE ON Enumeration(VALUE);

CREATE INDEX DATASET_NAME_Version ON DataSet(Name,Version);

CREATE INDEX ENTRY_INSERTDATE ON Entry(InsertDate);
CREATE INDEX ENTRY_CREATEDATE ON Entry(CreationDate);
CREATE INDEX ENTRY_MODDATE ON Entry(ModifiedDate);
CREATE INDEX ENTRY_DATASETWID ON Entry(DatasetWID);

CREATE INDEX ELEMENT_NAME ON Element(Name);
CREATE INDEX ELEMENT_ELEMENTSYMBOL ON Element(ElementSymbol);
CREATE INDEX ELEMENT_ATOMICWEIGHT ON Element(AtomicWeight);
CREATE INDEX ELEMENT_ATOMICNUMBER ON Element(AtomicNumber);

CREATE INDEX VALENCE_WID ON Valence(OtherWID);
CREATE INDEX VALENCE_VALENCE ON Valence(Valence);

CREATE INDEX LightSource_Instrument ON LightSource(InstrumentWID);
CREATE INDEX LightSource_Wavelength ON LightSource(Wavelength);

CREATE INDEX FlowCytometrySample_BioSource ON FlowCytometrySample(BioSourceWID);
CREATE INDEX FlowCytometrySample_Manufac ON FlowCytometrySample(ManufacturerWID);
CREATE INDEX FlowCytometrySample_Meas ON FlowCytometrySample(MeasurementWID);
CREATE INDEX FlowCytometrySample_Probe ON FlowCytometrySample(FlowCytometryProbeWID);


CREATE INDEX TranscriptionUnit_Name ON TranscriptionUnit(Name);

CREATE INDEX TranscriptionUnitComponent_TU ON TranscriptionUnitComponent(TranscriptionUnitWID);
CREATE INDEX TranscriptionUnitComponent_Other ON TranscriptionUnitComponent(OtherWID);

CREATE INDEX CHEMICAL_BEILSTEINNAME ON Chemical(BEILSTEINNAME);
CREATE INDEX CHEMICAL_SYSTEMATICNAME ON Chemical(SYSTEMATICNAME);
CREATE INDEX CHEMICAL_CAS ON Chemical(CAS);
CREATE INDEX CHEMICAL_CHARGE ON Chemical(CHARGE);
CREATE INDEX CHEMICAL_EMPIRICALFORMULA ON Chemical(EMPIRICALFORMULA);
CREATE INDEX CHEMICAL_MOLEWEIGHTCALC ON Chemical(MOLECULARWEIGHTCALC);
CREATE INDEX CHEMICAL_MOLEWEIGHTEXP ON Chemical(MOLECULARWEIGHTEXP);
CREATE INDEX CHEMICAL_OCTH2OCOEFF ON Chemical(OCTH2OPARTITIONCOEFF);
CREATE INDEX CHEMICAL_PKA1 ON Chemical(PKA1);
CREATE INDEX CHEMICAL_PKA2 ON Chemical(PKA2);
CREATE INDEX CHEMICAL_PKA3 ON Chemical(PKA3);
CREATE INDEX CHEMICAL_SMILES ON Chemical(SMILES);
CREATE INDEX CHEMICAL_DATASETWID ON Chemical(DATASETWID);

CREATE INDEX REACTION_DeltaG ON Reaction(DeltaG);
CREATE INDEX REACTION_ECNumber ON Reaction(ECNumber);
CREATE INDEX REACTION_ECNumberProposed ON Reaction(ECNumberProposed);


CREATE INDEX PROTEIN_NAME ON Protein(NAME(20));
CREATE INDEX PROTEIN_CHARGE ON Protein(CHARGE);
CREATE INDEX PROTEIN_MOLEWEIGHTCALC ON Protein(MOLECULARWEIGHTCALC);
CREATE INDEX PROTEIN_MOLEWEIGHTEXP ON Protein(MOLECULARWEIGHTEXP);
CREATE INDEX PROTEIN_PICALC ON Protein(PICALC);
CREATE INDEX PROTEIN_PIEXP ON Protein(PIEXP);

CREATE INDEX FEATURE_Description ON Feature(Description(20));
CREATE INDEX FEATURE_TYPE ON Feature(Type);
CREATE INDEX FEATURE_Class ON Feature(Class);
CREATE INDEX FEATURE_SequenceWID ON Feature(SequenceWID);
CREATE INDEX FEATURE_START_ENDPOS ON Feature(STARTPOSITION,ENDPOSITION);
CREATE INDEX FEATURE_ENDPOSITION ON Feature(ENDPOSITION);
#CREATE INDEX FEATURE_PointPosition ON Feature(PointPosition);
CREATE INDEX FEATURE_DATASETWID ON Feature(DATASETWID);

CREATE INDEX FUNCTION_NAME ON Function(NAME);
CREATE INDEX FUNCTION_DATASETWID ON Function(DATASETWID);

CREATE INDEX ER_REAWID ON EnzymaticReaction(REACTIONWID);
CREATE INDEX ER_PROWID ON EnzymaticReaction(PROTEINWID);
CREATE INDEX ER_COMWID ON EnzymaticReaction(COMPLEXWID);
CREATE INDEX ER_DIRWID ON EnzymaticReaction(REACTIONDIRECTION);

CREATE INDEX GENCODE_NAME ON GeneticCode(NAME);
CREATE INDEX GENCODE_TRANSTABLE ON GeneticCode(TRANSLATIONTABLE);
CREATE INDEX GENCODE_STARTCODON ON GeneticCode(STARTCODON);
CREATE INDEX GENCODE_DATASETWID ON GeneticCode(DATASETWID);

CREATE INDEX DIVISION_NAME ON Division(NAME);
CREATE INDEX DIVISION_DIVCODE ON Division(CODE);
CREATE INDEX DIVISION_DATASETWID ON Division(DATASETWID);

CREATE INDEX TAXON_PARENTWID ON Taxon(PARENTWID);
CREATE INDEX TAXON_NAME ON Taxon(NAME);
CREATE INDEX TAXON_RANK ON Taxon(RANK);
CREATE INDEX TAXON_DIVWID ON Taxon(DIVISIONWID);
CREATE INDEX TAXON_GENCODEWID ON Taxon(GENCODEWID);
CREATE INDEX TAXON_MCGENCODEWID ON Taxon(MCGENCODEWID);
CREATE INDEX TAXON_DATASETWID ON Taxon(DATASETWID);

CREATE INDEX BIOSOURCE_NAME ON BioSource(Name);
CREATE INDEX BIOSOURCE_ATCC ON BioSource(ATCCId);
CREATE INDEX BIOSOURCE_TAXONWID ON BioSource(TAXONWID);
CREATE INDEX BIOSOURCE_DATASETWID ON BioSource(DATASETWID);

CREATE INDEX BIOSUBTYPE_Type ON BioSubtype(Type);
CREATE INDEX BIOSUBTYPE_Value ON BioSubtype(Value);
CREATE INDEX BIOSUBTYPE_DATASETWID ON BioSubtype(DATASETWID);

CREATE INDEX NUCLEICACID_Name ON NucleicAcid(Name);
CREATE INDEX NUCLEICACID_Type ON NucleicAcid(Type);
CREATE INDEX NUCLEICACID_Class ON NucleicAcid(Class);
CREATE INDEX NUCLEICACID_MoleculeLength ON NucleicAcid(MoleculeLength);
CREATE INDEX NUCLEICACID_CumulativeLength ON NucleicAcid(CumulativeLength);
CREATE INDEX NUCLEICACID_GCWID ON NucleicAcid(GeneticCodeWID);
CREATE INDEX NUCLEICACID_BSWID ON NucleicAcid(BioSourceWID);
CREATE INDEX NUCLEICACID_DATASETWID ON NucleicAcid(DATASETWID);

CREATE INDEX Subsequence_NAWID ON Subsequence(NucleicAcidWID);
CREATE INDEX Subsequence_Length ON Subsequence(Length);
CREATE INDEX Subsequence_PercentGC ON Subsequence(PercentGC);
CREATE INDEX Subsequence_DWID ON Subsequence(DATASETWID);

CREATE INDEX GENE_Name ON Gene(Name);
CREATE INDEX GENE_Type ON Gene(Type);
CREATE INDEX GENE_GenomeID ON Gene(GenomeID);
CREATE INDEX GENE_START_END_POSITION ON Gene(CODINGREGIONSTART, CODINGREGIONEND);
CREATE INDEX GENE_ENDPOSITION ON Gene(CODINGREGIONEND);
CREATE INDEX GENE_NAWID ON Gene(NucleicAcidWID);
CREATE INDEX GENE_SubsequenceWID ON Gene(SubsequenceWID);

CREATE INDEX PATHWAY_Name ON Pathway(Name);

CREATE INDEX TERM_NAME ON Term(NAME);

CREATE INDEX COMPUTATION_NAME ON Computation(NAME);
CREATE INDEX COMPUTATION_DATASETWID ON Computation(DataSetWID);

CREATE INDEX CITATION_PMID ON Citation(PMID);
CREATE INDEX CITATION_DATASETWID ON Citation(DataSetWID);

CREATE INDEX ARCHIVE_OTHERWID ON Archive(OTHERWID);
CREATE INDEX ARCHIVE_TOOL ON Archive(TOOLNAME);
CREATE INDEX ARCHIVE_DATASETWID ON Archive(DataSetWID);

CREATE INDEX EXP_TYPE ON Experiment(TYPE);
CREATE INDEX EXP_CON ON Experiment(CONTACTWID);
CREATE INDEX EXP_GROUP ON Experiment(GROUPWID);
CREATE INDEX EXP_DS ON Experiment(DATASETWID);

CREATE INDEX EXPDATA_ExperimentWID ON ExperimentData(ExperimentWID);
CREATE INDEX EXPDATA_Kind ON ExperimentData(Kind);
CREATE INDEX EXPDATA_MageData ON ExperimentData(MageData);
CREATE INDEX EXPDATA_OtherWID ON ExperimentData(OtherWID);
CREATE INDEX EXPDATA_DS ON ExperimentData(DATASETWID);

CREATE INDEX SUPPORT_OTHERWID ON Support(OTHERWID);
CREATE INDEX SUPPORT_TYPE ON Support(TYPE);
CREATE INDEX SUPPORT_CONFIDENCE ON Support(CONFIDENCE);

CREATE INDEX CA_WID ON ChemicalAtom(CHEMICALWID);
CREATE INDEX CA_ATOMINDEX ON ChemicalAtom(ATOMINDEX);
CREATE INDEX CA_ATOM ON ChemicalAtom(ATOM);
CREATE INDEX CA_CHARGE ON ChemicalAtom(CHARGE);
CREATE INDEX CA_X ON ChemicalAtom(X);
CREATE INDEX CA_Y ON ChemicalAtom(Y);
CREATE INDEX CA_Z ON ChemicalAtom(Z);
CREATE INDEX CA_SPARITY ON ChemicalAtom(STEREOPARITY);

CREATE INDEX CB_WID ON ChemicalBond(ChemicalWID);
CREATE INDEX CB_INDEX1 ON ChemicalBond(ATOM1INDEX);
CREATE INDEX CB_INDEX2 ON ChemicalBond(ATOM2INDEX);
CREATE INDEX CB_BONDTYPE ON ChemicalBond(BONDTYPE);
CREATE INDEX CB_BONDSTEREO ON ChemicalBond(BONDSTEREO);

CREATE INDEX ERCOFACTOR_ERWID ON EnzReactionCofactor(ENZYMATICREACTIONWID);
CREATE INDEX ERCOFACTOR_CHEMWID ON EnzReactionCofactor(CHEMICALWID);

CREATE INDEX ERALT_ERWID ON EnzReactionAltCompound(ENZYMATICREACTIONWID);
CREATE INDEX ERALT_PRIMWID ON EnzReactionAltCompound(PRIMARYWID);
CREATE INDEX ERALT_ALTWID ON EnzReactionAltCompound(ALTERNATIVEWID);

CREATE INDEX ERIA_ERWID ON EnzReactionInhibitorActivator(ENZYMATICREACTIONWID);
CREATE INDEX ERIA_COMPOUNDWID ON EnzReactionInhibitorActivator(CompoundWID);
CREATE INDEX ERIA_MECH ON EnzReactionInhibitorActivator(Mechanism);

CREATE INDEX LOCATION_ProteinWID ON Location(ProteinWID);

CREATE INDEX PATHLINK_P1WID_P2WID_CHEMWID ON PathwayLink(PATHWAY1WID, PATHWAY2WID, CHEMICALWID);
CREATE INDEX PATHLINK_P2WID ON PathwayLink(PATHWAY2WID);
CREATE INDEX PATHLINK_CHEMWID ON PathwayLink(CHEMICALWID);

CREATE INDEX PR_REACTIONWID ON PathwayReaction(ReactionWID);
CREATE INDEX PR_PRIORWID ON PathwayReaction(PriorReactionWID);

CREATE INDEX PRODUCT_REACTWID ON Product(REACTIONWID);
CREATE INDEX PRODUCT_OTHERWID ON Product(OTHERWID);
CREATE INDEX PRODUCT_COEFFICIENT ON Product(COEFFICIENT);

CREATE INDEX REACTANT_WID ON Reactant(ReactionWID);
CREATE INDEX REACTANT_OTHERWID ON Reactant(OTHERWID);
CREATE INDEX REACTANT_COEFFICIENT ON Reactant(Coefficient);


CREATE INDEX SM_QUERYWID ON SequenceMatch(QueryWID);
CREATE INDEX SM_MATCHWID ON SequenceMatch(MatchWID);
CREATE INDEX SM_COMPUTATIONWID ON SequenceMatch(ComputationWID);
CREATE INDEX SM_EVALUE ON SequenceMatch(EValue);
CREATE INDEX SM_PVALUE ON SequenceMatch(PValue);
CREATE INDEX SM_PIDENTICAL ON SequenceMatch(PercentIdentical);
CREATE INDEX SM_PSIMILAR ON SequenceMatch(PercentSimilar);
CREATE INDEX SM_RANK ON SequenceMatch(Rank);
CREATE INDEX SM_LENGTH ON SequenceMatch(Length);
CREATE INDEX SM_QSTART_QEND ON SequenceMatch(QueryStart, QueryEnd);
CREATE INDEX SM_QEND ON SequenceMatch(QueryEnd);
CREATE INDEX SM_MSTART_MEND ON SequenceMatch(MatchStart,MatchEnd);
CREATE INDEX SM_MEND ON SequenceMatch(MatchEnd);

CREATE INDEX SUBUNIT_PROW1ID ON Subunit(COMPLEXWID);
CREATE INDEX SUBUNIT_PROW2ID ON Subunit(SubunitWID);
CREATE INDEX SUBUNIT_COEF ON Subunit(COEFFICIENT);

CREATE INDEX SUPER_SUBWID_SUPERWID ON SuperPathway(SUBPATHWAYWID,SUPERPATHWAYWID);
CREATE INDEX SUPER_SUPERWID_SUBWID ON SuperPathway(SUPERPATHWAYWID,SUBPATHWAYWID);

CREATE INDEX TR_TermRelationship ON TermRelationship(TermWID,RelatedTermWID);
CREATE INDEX RT_TermRelationship ON TermRelationship(RelatedTermWID,TermWID);

CREATE INDEX TO_RelatedTerm ON RelatedTerm(TermWID,OtherWID);
CREATE INDEX OT_RelatedTerm ON RelatedTerm(OtherWID,TermWID);

CREATE INDEX CO_OTHERWID_CITATIONWID ON CitationWIDOtherWID(OtherWID,CitationWID);
CREATE INDEX CO_CITATIONWID_OTHERWID ON CitationWIDOtherWID(CitationWID,OtherWID);

CREATE INDEX COMMENT_OTHERWID ON CommentTable( OTHERWID );

CREATE INDEX CROSS_OTHERWID ON CrossReference(OTHERWID);
CREATE INDEX CROSS_XID ON CrossReference(XID);

CREATE INDEX Description_OTHERWID ON Description( OTHERWID );


CREATE INDEX SYNONYM_SYN ON SynonymTable(Syn);

CREATE INDEX TOOL_OTHERWID ON ToolAdvice(OtherWID);
CREATE INDEX TOOL_NAME ON ToolAdvice(ToolName);

CREATE INDEX BB_BSWID_BSTWID ON BioSourceWIDBioSubtypeWID(BioSourceWID, BioSubtypeWID);
CREATE INDEX BB_BSTWID_BSWID ON BioSourceWIDBioSubtypeWID(BioSubtypeWID, BioSourceWID);

CREATE INDEX BG_BIOSOURCEWID_GENEWID ON BioSourceWIDGeneWID(BioSourceWID, GENEWID);
CREATE INDEX BG_GENEWID_BIOSOURCEWID ON BioSourceWIDGeneWID(GENEWID, BioSourceWID);

CREATE INDEX BP_BIOSOURCEWID_PROWID ON BioSourceWIDProteinWID(BioSourceWID,PROTEINWID);
CREATE INDEX BP_PROWID_BIOSOURCEWID ON BioSourceWIDProteinWID(PROTEINWID, BioSourceWID);

CREATE INDEX GN_GENEWID_NAWID ON GeneWIDNucleicAcidWID(GENEWID,NUCLEICACIDWID);
CREATE INDEX GN_NAWID_GENEWID ON GeneWIDNucleicAcidWID(NUCLEICACIDWID,GENEWID);

CREATE INDEX GP_GENEWID_PROWID ON GeneWIDProteinWID(GENEWID,PROTEINWID);
CREATE INDEX GP_PROWID_GENEWID ON GeneWIDProteinWID(PROTEINWID,GENEWID);

CREATE INDEX PF_FunctionWID_PROWID ON ProteinWIDFunctionWID(FunctionWID,PROTEINWID);
CREATE INDEX PF_PROWID_FunctionWID ON ProteinWIDFunctionWID(PROTEINWID,FunctionWID);

CREATE INDEX PS_PROTEINWID_SPOTWID ON ProteinWIDSpotWID(ProteinWID, SpotWID);
CREATE INDEX PS_SPOTWID_PROTEINWID ON ProteinWIDSpotWID(SpotWID, ProteinWID);

CREATE INDEX SM_SPOTWID_IDMETHWID ON SpotWIDSpotIdMethodWID(SpotWID, SpotIdMethodWID);
CREATE INDEX SM_IDMETHWID_SPOTWID ON SpotWIDSpotIdMethodWID(SpotIdMethodWID, SpotWID);

CREATE INDEX NameValueType1 ON NameValueType(DataSetWID);
CREATE INDEX NameValueType2 ON NameValueType(Name);
CREATE INDEX NameValueType3 ON NameValueType(Value);
CREATE INDEX NameValueType4 ON NameValueType(Type_);
CREATE INDEX NameValueType5 ON NameValueType(NameValueType_PropertySets);
CREATE INDEX NameValueType6 ON NameValueType(OtherWID);

CREATE INDEX Contact1 ON Contact(DataSetWID);
CREATE INDEX Contact2 ON Contact(MAGEClass);
CREATE INDEX Contact3 ON Contact(Identifier);
CREATE INDEX Contact4 ON Contact(Name);
CREATE INDEX Contact5 ON Contact(URI);
CREATE INDEX Contact6 ON Contact(Address);
CREATE INDEX Contact7 ON Contact(Phone);
CREATE INDEX Contact8 ON Contact(TollFreePhone);
CREATE INDEX Contact9 ON Contact(Email);
CREATE INDEX Contact10 ON Contact(Fax);
CREATE INDEX Contact11 ON Contact(Parent);
CREATE INDEX Contact12 ON Contact(LastName);
CREATE INDEX Contact13 ON Contact(FirstName);
CREATE INDEX Contact14 ON Contact(MidInitials);
CREATE INDEX Contact15 ON Contact(Affiliation);

CREATE INDEX ArrayDesign1 ON ArrayDesign(DataSetWID);
CREATE INDEX ArrayDesign2 ON ArrayDesign(MAGEClass);
CREATE INDEX ArrayDesign3 ON ArrayDesign(Identifier);
CREATE INDEX ArrayDesign4 ON ArrayDesign(Name);
CREATE INDEX ArrayDesign5 ON ArrayDesign(Version);
CREATE INDEX ArrayDesign6 ON ArrayDesign(NumberOfFeatures);
CREATE INDEX ArrayDesign7 ON ArrayDesign(SurfaceType);

CREATE INDEX DesignElementGroup1 ON DesignElementGroup(DataSetWID);
CREATE INDEX DesignElementGroup2 ON DesignElementGroup(MAGEClass);
CREATE INDEX DesignElementGroup3 ON DesignElementGroup(Identifier);
CREATE INDEX DesignElementGroup4 ON DesignElementGroup(Name);
CREATE INDEX DesignElementGroup5 ON DesignElementGroup(ArrayDesign_FeatureGroups);
CREATE INDEX DesignElementGroup6 ON DesignElementGroup(DesignElementGroup_Species);
CREATE INDEX DesignElementGroup7 ON DesignElementGroup(FeatureWidth);
CREATE INDEX DesignElementGroup8 ON DesignElementGroup(FeatureLength);
CREATE INDEX DesignElementGroup9 ON DesignElementGroup(FeatureHeight);
CREATE INDEX DesignElementGroup10 ON DesignElementGroup(FeatureGroup_TechnologyType);
CREATE INDEX DesignElementGroup11 ON DesignElementGroup(FeatureGroup_FeatureShape);
CREATE INDEX DesignElementGroup12 ON DesignElementGroup(FeatureGroup_DistanceUnit);

CREATE INDEX Zone1 ON Zone(DataSetWID);
CREATE INDEX Zone2 ON Zone(Identifier);
CREATE INDEX Zone3 ON Zone(Name);
CREATE INDEX Zone4 ON Zone(Row_);
CREATE INDEX Zone5 ON Zone(Column_);
CREATE INDEX Zone6 ON Zone(UpperLeftX);
CREATE INDEX Zone7 ON Zone(UpperLeftY);
CREATE INDEX Zone8 ON Zone(LowerRightX);
CREATE INDEX Zone9 ON Zone(LowerRightY);
CREATE INDEX Zone10 ON Zone(Zone_DistanceUnit);
CREATE INDEX Zone11 ON Zone(ZoneGroup_ZoneLocations);

CREATE INDEX ZoneGroup1 ON ZoneGroup(DataSetWID);
CREATE INDEX ZoneGroup2 ON ZoneGroup(PhysicalArrayDesign_ZoneGroups);
CREATE INDEX ZoneGroup3 ON ZoneGroup(SpacingsBetweenZonesX);
CREATE INDEX ZoneGroup4 ON ZoneGroup(SpacingsBetweenZonesY);
CREATE INDEX ZoneGroup5 ON ZoneGroup(ZonesPerX);
CREATE INDEX ZoneGroup6 ON ZoneGroup(ZonesPerY);
CREATE INDEX ZoneGroup7 ON ZoneGroup(ZoneGroup_DistanceUnit);
CREATE INDEX ZoneGroup8 ON ZoneGroup(ZoneGroup_ZoneLayout);

CREATE INDEX ZoneLayout1 ON ZoneLayout(DataSetWID);
CREATE INDEX ZoneLayout2 ON ZoneLayout(NumFeaturesPerRow);
CREATE INDEX ZoneLayout3 ON ZoneLayout(NumFeaturesPerCol);
CREATE INDEX ZoneLayout4 ON ZoneLayout(SpacingBetweenRows);
CREATE INDEX ZoneLayout5 ON ZoneLayout(SpacingBetweenCols);
CREATE INDEX ZoneLayout6 ON ZoneLayout(ZoneLayout_DistanceUnit);

CREATE INDEX ExperimentDesign1 ON ExperimentDesign(DataSetWID);
CREATE INDEX ExperimentDesign2 ON ExperimentDesign(Experiment_ExperimentDesigns);
CREATE INDEX ExperimentDesign3 ON ExperimentDesign(QualityControlDescription);
CREATE INDEX ExperimentDesign4 ON ExperimentDesign(NormalizationDescription);
CREATE INDEX ExperimentDesign5 ON ExperimentDesign(ReplicateDescription);

CREATE INDEX ExperimentalFactor1 ON ExperimentalFactor(DataSetWID);
CREATE INDEX ExperimentalFactor2 ON ExperimentalFactor(Identifier);
CREATE INDEX ExperimentalFactor3 ON ExperimentalFactor(Name);
CREATE INDEX ExperimentalFactor4 ON ExperimentalFactor(ExperimentDesign);
CREATE INDEX ExperimentalFactor5 ON ExperimentalFactor(ExperimentalFactor_Category);

CREATE INDEX FactorValue1 ON FactorValue(DataSetWID);
CREATE INDEX FactorValue2 ON FactorValue(Identifier);
CREATE INDEX FactorValue3 ON FactorValue(Name);
CREATE INDEX FactorValue4 ON FactorValue(ExperimentalFactor);
CREATE INDEX FactorValue5 ON FactorValue(ExperimentalFactor2);
CREATE INDEX FactorValue6 ON FactorValue(FactorValue_Measurement);
CREATE INDEX FactorValue7 ON FactorValue(FactorValue_Value);

CREATE INDEX QuantitationType1 ON QuantitationType(DataSetWID);
CREATE INDEX QuantitationType2 ON QuantitationType(MAGEClass);
CREATE INDEX QuantitationType3 ON QuantitationType(Identifier);
CREATE INDEX QuantitationType4 ON QuantitationType(Name);
CREATE INDEX QuantitationType5 ON QuantitationType(IsBackground);
CREATE INDEX QuantitationType6 ON QuantitationType(Channel);
CREATE INDEX QuantitationType7 ON QuantitationType(QuantitationType_Scale);
CREATE INDEX QuantitationType8 ON QuantitationType(QuantitationType_DataType);
CREATE INDEX QuantitationType9 ON QuantitationType(TargetQuantitationType);

CREATE INDEX Database_1 ON Database_(DataSetWID);
CREATE INDEX Database_2 ON Database_(Identifier);
CREATE INDEX Database_3 ON Database_(Name);
CREATE INDEX Database_4 ON Database_(Version);
CREATE INDEX Database_5 ON Database_(URI);

CREATE INDEX Array_1 ON Array_(DataSetWID);
CREATE INDEX Array_2 ON Array_(Identifier);
CREATE INDEX Array_3 ON Array_(Name);
CREATE INDEX Array_4 ON Array_(ArrayIdentifier);
CREATE INDEX Array_5 ON Array_(ArrayXOrigin);
CREATE INDEX Array_6 ON Array_(ArrayYOrigin);
CREATE INDEX Array_7 ON Array_(OriginRelativeTo);
CREATE INDEX Array_8 ON Array_(ArrayDesign);
CREATE INDEX Array_9 ON Array_(Information);
CREATE INDEX Array_10 ON Array_(ArrayGroup);

CREATE INDEX ArrayGroup1 ON ArrayGroup(DataSetWID);
CREATE INDEX ArrayGroup2 ON ArrayGroup(Identifier);
CREATE INDEX ArrayGroup3 ON ArrayGroup(Name);
CREATE INDEX ArrayGroup4 ON ArrayGroup(Barcode);
CREATE INDEX ArrayGroup5 ON ArrayGroup(ArraySpacingX);
CREATE INDEX ArrayGroup6 ON ArrayGroup(ArraySpacingY);
CREATE INDEX ArrayGroup7 ON ArrayGroup(NumArrays);
CREATE INDEX ArrayGroup8 ON ArrayGroup(OrientationMark);
CREATE INDEX ArrayGroup9 ON ArrayGroup(OrientationMarkPosition);
CREATE INDEX ArrayGroup10 ON ArrayGroup(Width);
CREATE INDEX ArrayGroup11 ON ArrayGroup(Length);
CREATE INDEX ArrayGroup12 ON ArrayGroup(ArrayGroup_SubstrateType);
CREATE INDEX ArrayGroup13 ON ArrayGroup(ArrayGroup_DistanceUnit);

CREATE INDEX ArrayManufacture1 ON ArrayManufacture(DataSetWID);
CREATE INDEX ArrayManufacture2 ON ArrayManufacture(Identifier);
CREATE INDEX ArrayManufacture3 ON ArrayManufacture(Name);
CREATE INDEX ArrayManufacture4 ON ArrayManufacture(ManufacturingDate);
CREATE INDEX ArrayManufacture5 ON ArrayManufacture(Tolerance);

CREATE INDEX ArrayManufactureDeviation1 ON ArrayManufactureDeviation(DataSetWID);
CREATE INDEX ArrayManufactureDeviation2 ON ArrayManufactureDeviation(Array_);

CREATE INDEX FeatureDefect1 ON FeatureDefect(DataSetWID);
CREATE INDEX FeatureDefect2 ON FeatureDefect(ArrayManufactureDeviation);
CREATE INDEX FeatureDefect3 ON FeatureDefect(FeatureDefect_DefectType);
CREATE INDEX FeatureDefect4 ON FeatureDefect(FeatureDefect_PositionDelta);
CREATE INDEX FeatureDefect5 ON FeatureDefect(Feature);

CREATE INDEX Fiducial1 ON Fiducial(DataSetWID);
CREATE INDEX Fiducial2 ON Fiducial(ArrayGroup_Fiducials);
CREATE INDEX Fiducial3 ON Fiducial(Fiducial_FiducialType);
CREATE INDEX Fiducial4 ON Fiducial(Fiducial_DistanceUnit);
CREATE INDEX Fiducial5 ON Fiducial(Fiducial_Position);

CREATE INDEX ManufactureLIMS1 ON ManufactureLIMS(DataSetWID);
CREATE INDEX ManufactureLIMS2 ON ManufactureLIMS(MAGEClass);
CREATE INDEX ManufactureLIMS3 ON ManufactureLIMS(ArrayManufacture_FeatureLIMSs);
CREATE INDEX ManufactureLIMS4 ON ManufactureLIMS(Quality);
CREATE INDEX ManufactureLIMS5 ON ManufactureLIMS(Feature);
CREATE INDEX ManufactureLIMS6 ON ManufactureLIMS(BioMaterial);
CREATE INDEX ManufactureLIMS7 ON ManufactureLIMS(ManufactureLIMS_IdentifierLIMS);
CREATE INDEX ManufactureLIMS8 ON ManufactureLIMS(BioMaterialPlateIdentifier);
CREATE INDEX ManufactureLIMS9 ON ManufactureLIMS(BioMaterialPlateRow);
CREATE INDEX ManufactureLIMS10 ON ManufactureLIMS(BioMaterialPlateCol);

CREATE INDEX PositionDelta1 ON PositionDelta(DataSetWID);
CREATE INDEX PositionDelta2 ON PositionDelta(DeltaX);
CREATE INDEX PositionDelta3 ON PositionDelta(DeltaY);
CREATE INDEX PositionDelta4 ON PositionDelta(PositionDelta_DistanceUnit);

CREATE INDEX ZoneDefect1 ON ZoneDefect(DataSetWID);
CREATE INDEX ZoneDefect2 ON ZoneDefect(ArrayManufactureDeviation);
CREATE INDEX ZoneDefect3 ON ZoneDefect(ZoneDefect_DefectType);
CREATE INDEX ZoneDefect4 ON ZoneDefect(ZoneDefect_PositionDelta);
CREATE INDEX ZoneDefect5 ON ZoneDefect(Zone);

CREATE INDEX SeqFeatureLocation1 ON SeqFeatureLocation(DataSetWID);
CREATE INDEX SeqFeatureLocation2 ON SeqFeatureLocation(SeqFeature_Regions);
CREATE INDEX SeqFeatureLocation3 ON SeqFeatureLocation(StrandType);
CREATE INDEX SeqFeatureLocation4 ON SeqFeatureLocation(SeqFeatureLocation_Subregions);
CREATE INDEX SeqFeatureLocation5 ON SeqFeatureLocation(SeqFeatureLocation_Coordinate);

CREATE INDEX SequencePosition1 ON SequencePosition(DataSetWID);
CREATE INDEX SequencePosition2 ON SequencePosition(MAGEClass);
CREATE INDEX SequencePosition3 ON SequencePosition(Start_);
CREATE INDEX SequencePosition4 ON SequencePosition(End);
CREATE INDEX SequencePosition5 ON SequencePosition(CompositeCompositeMap);
CREATE INDEX SequencePosition6 ON SequencePosition(Composite);
CREATE INDEX SequencePosition7 ON SequencePosition(ReporterCompositeMap);
CREATE INDEX SequencePosition8 ON SequencePosition(Reporter);

CREATE INDEX DesignElement1 ON DesignElement(DataSetWID);
CREATE INDEX DesignElement2 ON DesignElement(MAGEClass);
CREATE INDEX DesignElement3 ON DesignElement(Identifier);
CREATE INDEX DesignElement4 ON DesignElement(Name);
CREATE INDEX DesignElement5 ON DesignElement(FeatureGroup_Features);
CREATE INDEX DesignElement6 ON DesignElement(DesignElement_ControlType);
CREATE INDEX DesignElement7 ON DesignElement(Feature_Position);
CREATE INDEX DesignElement8 ON DesignElement(Zone);
CREATE INDEX DesignElement9 ON DesignElement(Feature_FeatureLocation);
CREATE INDEX DesignElement10 ON DesignElement(FeatureGroup);
CREATE INDEX DesignElement11 ON DesignElement(Reporter_WarningType);

CREATE INDEX FeatureInformation1 ON FeatureInformation(DataSetWID);
CREATE INDEX FeatureInformation2 ON FeatureInformation(Feature);
CREATE INDEX FeatureInformation3 ON FeatureInformation(FeatureReporterMap);

CREATE INDEX FeatureLocation1 ON FeatureLocation(DataSetWID);
CREATE INDEX FeatureLocation2 ON FeatureLocation(Row_);
CREATE INDEX FeatureLocation3 ON FeatureLocation(Column_);

CREATE INDEX MismatchInformation1 ON MismatchInformation(DataSetWID);
CREATE INDEX MismatchInformation2 ON MismatchInformation(CompositePosition);
CREATE INDEX MismatchInformation3 ON MismatchInformation(FeatureInformation);
CREATE INDEX MismatchInformation4 ON MismatchInformation(StartCoord);
CREATE INDEX MismatchInformation5 ON MismatchInformation(NewSequence);
CREATE INDEX MismatchInformation6 ON MismatchInformation(ReplacedLength);
CREATE INDEX MismatchInformation7 ON MismatchInformation(ReporterPosition);

CREATE INDEX Position_1 ON Position_(DataSetWID);
CREATE INDEX Position_2 ON Position_(X);
CREATE INDEX Position_3 ON Position_(Y);
CREATE INDEX Position_4 ON Position_(Position_DistanceUnit);

CREATE INDEX BioEvent1 ON BioEvent(DataSetWID);
CREATE INDEX BioEvent2 ON BioEvent(MAGEClass);
CREATE INDEX BioEvent3 ON BioEvent(Identifier);
CREATE INDEX BioEvent4 ON BioEvent(Name);
CREATE INDEX BioEvent5 ON BioEvent(CompositeSequence);
CREATE INDEX BioEvent6 ON BioEvent(Reporter);
CREATE INDEX BioEvent7 ON BioEvent(CompositeSequence2);
CREATE INDEX BioEvent8 ON BioEvent(BioAssayMapTarget);
CREATE INDEX BioEvent9 ON BioEvent(TargetQuantitationType);
CREATE INDEX BioEvent10 ON BioEvent(DerivedBioAssayDataTarget);
CREATE INDEX BioEvent11 ON BioEvent(QuantitationTypeMapping);
CREATE INDEX BioEvent12 ON BioEvent(DesignElementMapping);
CREATE INDEX BioEvent13 ON BioEvent(Transformation_BioAssayMapping);
CREATE INDEX BioEvent14 ON BioEvent(BioMaterial_Treatments);
CREATE INDEX BioEvent15 ON BioEvent(Order_);
CREATE INDEX BioEvent16 ON BioEvent(Treatment_Action);
CREATE INDEX BioEvent17 ON BioEvent(Treatment_ActionMeasurement);
CREATE INDEX BioEvent18 ON BioEvent(Array_);
CREATE INDEX BioEvent19 ON BioEvent(PhysicalBioAssayTarget);
CREATE INDEX BioEvent20 ON BioEvent(PhysicalBioAssay);
CREATE INDEX BioEvent21 ON BioEvent(Target);
CREATE INDEX BioEvent22 ON BioEvent(PhysicalBioAssaySource);
CREATE INDEX BioEvent23 ON BioEvent(MeasuredBioAssayTarget);
CREATE INDEX BioEvent24 ON BioEvent(PhysicalBioAssay2);

CREATE INDEX BioAssayData1 ON BioAssayData(DataSetWID);
CREATE INDEX BioAssayData2 ON BioAssayData(MAGEClass);
CREATE INDEX BioAssayData3 ON BioAssayData(Identifier);
CREATE INDEX BioAssayData4 ON BioAssayData(Name);
CREATE INDEX BioAssayData5 ON BioAssayData(BioAssayDimension);
CREATE INDEX BioAssayData6 ON BioAssayData(DesignElementDimension);
CREATE INDEX BioAssayData7 ON BioAssayData(QuantitationTypeDimension);
CREATE INDEX BioAssayData8 ON BioAssayData(BioAssayData_BioDataValues);
CREATE INDEX BioAssayData9 ON BioAssayData(ProducerTransformation);

CREATE INDEX BioAssayDimension1 ON BioAssayDimension(DataSetWID);
CREATE INDEX BioAssayDimension2 ON BioAssayDimension(Identifier);
CREATE INDEX BioAssayDimension3 ON BioAssayDimension(Name);

CREATE INDEX BioAssayMapping1 ON BioAssayMapping(DataSetWID);

CREATE INDEX BioAssayTuple1 ON BioAssayTuple(DataSetWID);
CREATE INDEX BioAssayTuple2 ON BioAssayTuple(BioAssay);
CREATE INDEX BioAssayTuple3 ON BioAssayTuple(BioDataTuples_BioAssayTuples);

CREATE INDEX BioDataValues1 ON BioDataValues(DataSetWID);
CREATE INDEX BioDataValues2 ON BioDataValues(MAGEClass);
CREATE INDEX BioDataValues3 ON BioDataValues(Order_);
CREATE INDEX BioDataValues4 ON BioDataValues(BioDataCube_DataInternal);
CREATE INDEX BioDataValues5 ON BioDataValues(BioDataCube_DataExternal);

CREATE INDEX DataExternal1 ON DataExternal(DataSetWID);
CREATE INDEX DataExternal2 ON DataExternal(DataFormat);
CREATE INDEX DataExternal3 ON DataExternal(DataFormatInfoURI);
CREATE INDEX DataExternal4 ON DataExternal(FilenameURI);

CREATE INDEX DataInternal1 ON DataInternal(DataSetWID);

CREATE INDEX Datum1 ON Datum(DataSetWID);
CREATE INDEX Datum2 ON Datum(Value);

CREATE INDEX DesignElementDimension1 ON DesignElementDimension(DataSetWID);
CREATE INDEX DesignElementDimension2 ON DesignElementDimension(MAGEClass);
CREATE INDEX DesignElementDimension3 ON DesignElementDimension(Identifier);
CREATE INDEX DesignElementDimension4 ON DesignElementDimension(Name);

CREATE INDEX DesignElementMapping1 ON DesignElementMapping(DataSetWID);

CREATE INDEX DesignElementTuple1 ON DesignElementTuple(DataSetWID);
CREATE INDEX DesignElementTuple2 ON DesignElementTuple(BioAssayTuple);
CREATE INDEX DesignElementTuple3 ON DesignElementTuple(DesignElement);

CREATE INDEX QuantitationTypeDimension1 ON QuantitationTypeDimension(DataSetWID);
CREATE INDEX QuantitationTypeDimension2 ON QuantitationTypeDimension(Identifier);
CREATE INDEX QuantitationTypeDimension3 ON QuantitationTypeDimension(Name);

CREATE INDEX QuantitationTypeMapping1 ON QuantitationTypeMapping(DataSetWID);

CREATE INDEX QuantitationTypeTuple1 ON QuantitationTypeTuple(DataSetWID);
CREATE INDEX QuantitationTypeTuple2 ON QuantitationTypeTuple(DesignElementTuple);
CREATE INDEX QuantitationTypeTuple3 ON QuantitationTypeTuple(QuantitationType);
CREATE INDEX QuantitationTypeTuple4 ON QuantitationTypeTuple(QuantitationTypeTuple_Datum);

CREATE INDEX BioMaterialMeasurement1 ON BioMaterialMeasurement(DataSetWID);
CREATE INDEX BioMaterialMeasurement2 ON BioMaterialMeasurement(BioMaterial);
CREATE INDEX BioMaterialMeasurement3 ON BioMaterialMeasurement(Measurement);
CREATE INDEX BioMaterialMeasurement4 ON BioMaterialMeasurement(Treatment);
CREATE INDEX BioMaterialMeasurement5 ON BioMaterialMeasurement(BioAssayCreation);

CREATE INDEX CompoundMeasurement1 ON CompoundMeasurement(DataSetWID);
CREATE INDEX CompoundMeasurement2 ON CompoundMeasurement(Compound_ComponentCompounds);
CREATE INDEX CompoundMeasurement3 ON CompoundMeasurement(Compound);
CREATE INDEX CompoundMeasurement4 ON CompoundMeasurement(Measurement);
CREATE INDEX CompoundMeasurement5 ON CompoundMeasurement(Treatment_CompoundMeasurements);

CREATE INDEX BioAssay1 ON BioAssay(DataSetWID);
CREATE INDEX BioAssay2 ON BioAssay(MAGEClass);
CREATE INDEX BioAssay3 ON BioAssay(Identifier);
CREATE INDEX BioAssay4 ON BioAssay(Name);
CREATE INDEX BioAssay5 ON BioAssay(DerivedBioAssay_Type);
CREATE INDEX BioAssay6 ON BioAssay(FeatureExtraction);
CREATE INDEX BioAssay7 ON BioAssay(BioAssayCreation);

CREATE INDEX Channel1 ON Channel(DataSetWID);
CREATE INDEX Channel2 ON Channel(Identifier);
CREATE INDEX Channel3 ON Channel(Name);

CREATE INDEX Image1 ON Image(DataSetWID);
CREATE INDEX Image2 ON Image(Identifier);
CREATE INDEX Image3 ON Image(Name);
CREATE INDEX Image4 ON Image(URI);
CREATE INDEX Image5 ON Image(Image_Format);
CREATE INDEX Image6 ON Image(PhysicalBioAssay);

CREATE INDEX BioAssayDataCluster1 ON BioAssayDataCluster(DataSetWID);
CREATE INDEX BioAssayDataCluster2 ON BioAssayDataCluster(Identifier);
CREATE INDEX BioAssayDataCluster3 ON BioAssayDataCluster(Name);
CREATE INDEX BioAssayDataCluster4 ON BioAssayDataCluster(ClusterBioAssayData);

CREATE INDEX Node1 ON Node(DataSetWID);
CREATE INDEX Node2 ON Node(BioAssayDataCluster_Nodes);
CREATE INDEX Node3 ON Node(Node_Nodes);

CREATE INDEX NodeContents1 ON NodeContents(DataSetWID);
CREATE INDEX NodeContents2 ON NodeContents(Node_NodeContents);
CREATE INDEX NodeContents3 ON NodeContents(BioAssayDimension);
CREATE INDEX NodeContents4 ON NodeContents(DesignElementDimension);
CREATE INDEX NodeContents5 ON NodeContents(QuantitationDimension);

CREATE INDEX NodeValue1 ON NodeValue(DataSetWID);
CREATE INDEX NodeValue2 ON NodeValue(Node_NodeValue);
CREATE INDEX NodeValue3 ON NodeValue(Name);
CREATE INDEX NodeValue4 ON NodeValue(Value);
CREATE INDEX NodeValue5 ON NodeValue(NodeValue_Type);
CREATE INDEX NodeValue6 ON NodeValue(NodeValue_Scale);
CREATE INDEX NodeValue7 ON NodeValue(NodeValue_DataType);

CREATE INDEX Measurement1 ON Measurement(DataSetWID);
CREATE INDEX Measurement2 ON Measurement(Type_);
CREATE INDEX Measurement3 ON Measurement(Value);
CREATE INDEX Measurement4 ON Measurement(KindCV);
CREATE INDEX Measurement5 ON Measurement(OtherKind);
CREATE INDEX Measurement6 ON Measurement(Measurement_Unit);

CREATE INDEX Unit1 ON Unit(DataSetWID);
CREATE INDEX Unit2 ON Unit(MAGEClass);
CREATE INDEX Unit3 ON Unit(UnitName);
CREATE INDEX Unit4 ON Unit(UnitNameCV);
CREATE INDEX Unit5 ON Unit(UnitNameCV2);
CREATE INDEX Unit6 ON Unit(UnitNameCV3);
CREATE INDEX Unit7 ON Unit(UnitNameCV4);
CREATE INDEX Unit8 ON Unit(UnitNameCV5);
CREATE INDEX Unit9 ON Unit(UnitNameCV6);
CREATE INDEX Unit10 ON Unit(UnitNameCV7);

CREATE INDEX Parameter1 ON Parameter(DataSetWID);
CREATE INDEX Parameter2 ON Parameter(Identifier);
CREATE INDEX Parameter3 ON Parameter(Name);
CREATE INDEX Parameter4 ON Parameter(Parameter_DefaultValue);
CREATE INDEX Parameter5 ON Parameter(Parameter_DataType);
CREATE INDEX Parameter6 ON Parameter(Parameterizable_ParameterTypes);

CREATE INDEX ParameterValue1 ON ParameterValue(DataSetWID);
CREATE INDEX ParameterValue2 ON ParameterValue(Value);
CREATE INDEX ParameterValue3 ON ParameterValue(ParameterType);
CREATE INDEX ParameterValue4 ON ParameterValue(ParameterizableApplication);

CREATE INDEX Parameterizable1 ON Parameterizable(DataSetWID);
CREATE INDEX Parameterizable2 ON Parameterizable(MAGEClass);
CREATE INDEX Parameterizable3 ON Parameterizable(Identifier);
CREATE INDEX Parameterizable4 ON Parameterizable(Name);
CREATE INDEX Parameterizable5 ON Parameterizable(URI);
CREATE INDEX Parameterizable6 ON Parameterizable(Model);
CREATE INDEX Parameterizable7 ON Parameterizable(Make);
CREATE INDEX Parameterizable8 ON Parameterizable(Hardware_Type);
CREATE INDEX Parameterizable9 ON Parameterizable(Text);
CREATE INDEX Parameterizable10 ON Parameterizable(Title);
CREATE INDEX Parameterizable11 ON Parameterizable(Protocol_Type);
CREATE INDEX Parameterizable12 ON Parameterizable(Software_Type);
CREATE INDEX Parameterizable13 ON Parameterizable(Hardware);

CREATE INDEX ParameterizableApplication1 ON ParameterizableApplication(DataSetWID);
CREATE INDEX ParameterizableApplication2 ON ParameterizableApplication(MAGEClass);
CREATE INDEX ParameterizableApplication3 ON ParameterizableApplication(ArrayDesign);
CREATE INDEX ParameterizableApplication4 ON ParameterizableApplication(ArrayManufacture);
CREATE INDEX ParameterizableApplication5 ON ParameterizableApplication(BioEvent_ProtocolApplications);
CREATE INDEX ParameterizableApplication6 ON ParameterizableApplication(SerialNumber);
CREATE INDEX ParameterizableApplication7 ON ParameterizableApplication(Hardware);
CREATE INDEX ParameterizableApplication8 ON ParameterizableApplication(ActivityDate);
CREATE INDEX ParameterizableApplication9 ON ParameterizableApplication(ProtocolApplication);
CREATE INDEX ParameterizableApplication10 ON ParameterizableApplication(ProtocolApplication2);
CREATE INDEX ParameterizableApplication11 ON ParameterizableApplication(Protocol);
CREATE INDEX ParameterizableApplication12 ON ParameterizableApplication(Version);
CREATE INDEX ParameterizableApplication13 ON ParameterizableApplication(ReleaseDate);
CREATE INDEX ParameterizableApplication14 ON ParameterizableApplication(Software);

CREATE INDEX ArrayDesignWIDReporterGrou1 ON ArrayDesignWIDReporterGroupWID(ArrayDesignWID);
CREATE INDEX ArrayDesignWIDReporterGrou2 ON ArrayDesignWIDReporterGroupWID(ReporterGroupWID);

CREATE INDEX ArrayDesignWIDCompositeGr1 ON ArrayDesignWIDCompositeGrpWID(ArrayDesignWID);
CREATE INDEX ArrayDesignWIDCompositeGr2 ON ArrayDesignWIDCompositeGrpWID(CompositeGroupWID);

CREATE INDEX ArrayDesignWIDContactWID1 ON ArrayDesignWIDContactWID(ArrayDesignWID);
CREATE INDEX ArrayDesignWIDContactWID2 ON ArrayDesignWIDContactWID(ContactWID);

CREATE INDEX ComposGrpWIDComposSequenc1 ON ComposGrpWIDComposSequenceWID(CompositeGroupWID);
CREATE INDEX ComposGrpWIDComposSequenc2 ON ComposGrpWIDComposSequenceWID(CompositeSequenceWID);

CREATE INDEX ReporterGroupWIDReporte1 ON ReporterGroupWIDReporterWID(ReporterGroupWID);
CREATE INDEX ReporterGroupWIDReporte2 ON ReporterGroupWIDReporterWID(ReporterWID);

CREATE INDEX ExperimentWIDContactWID1 ON ExperimentWIDContactWID(ExperimentWID);
CREATE INDEX ExperimentWIDContactWID2 ON ExperimentWIDContactWID(ContactWID);

CREATE INDEX ExperimWIDBioAssayDataClus1 ON ExperimWIDBioAssayDataClustWID(ExperimentWID);
CREATE INDEX ExperimWIDBioAssayDataClus2 ON ExperimWIDBioAssayDataClustWID(BioAssayDataClusterWID);

CREATE INDEX ExperimentWIDBioAssayDat1 ON ExperimentWIDBioAssayDataWID(ExperimentWID);
CREATE INDEX ExperimentWIDBioAssayDat2 ON ExperimentWIDBioAssayDataWID(BioAssayDataWID);

CREATE INDEX ExperimentWIDBioAssayWID1 ON ExperimentWIDBioAssayWID(ExperimentWID);
CREATE INDEX ExperimentWIDBioAssayWID2 ON ExperimentWIDBioAssayWID(BioAssayWID);

CREATE INDEX ExperimentDesignWIDBioAssa1 ON ExperimentDesignWIDBioAssayWID(ExperimentDesignWID);
CREATE INDEX ExperimentDesignWIDBioAssa2 ON ExperimentDesignWIDBioAssayWID(BioAssayWID);

CREATE INDEX QuantTypeWIDConfidenceIn1 ON QuantTypeWIDConfidenceIndWID(QuantitationTypeWID);
CREATE INDEX QuantTypeWIDConfidenceIn2 ON QuantTypeWIDConfidenceIndWID(ConfidenceIndicatorWID);

CREATE INDEX QuantTypeWIDQuantTypeMa1 ON QuantTypeWIDQuantTypeMapWID(QuantitationTypeWID);
CREATE INDEX QuantTypeWIDQuantTypeMa2 ON QuantTypeWIDQuantTypeMapWID(QuantitationTypeMapWID);

CREATE INDEX DatabaseWIDContactWID1 ON DatabaseWIDContactWID(DatabaseWID);
CREATE INDEX DatabaseWIDContactWID2 ON DatabaseWIDContactWID(ContactWID);

CREATE INDEX ArrayGroupWIDArrayWID1 ON ArrayGroupWIDArrayWID(ArrayGroupWID);
CREATE INDEX ArrayGroupWIDArrayWID2 ON ArrayGroupWIDArrayWID(ArrayWID);

CREATE INDEX ArrayManufactureWIDArra1 ON ArrayManufactureWIDArrayWID(ArrayManufactureWID);
CREATE INDEX ArrayManufactureWIDArra2 ON ArrayManufactureWIDArrayWID(ArrayWID);

CREATE INDEX ArrayManufactureWIDContac1 ON ArrayManufactureWIDContactWID(ArrayManufactureWID);
CREATE INDEX ArrayManufactureWIDContac2 ON ArrayManufactureWIDContactWID(ContactWID);

CREATE INDEX CompositeSeqWIDBioSeqWID1 ON CompositeSeqWIDBioSeqWID(CompositeSequenceWID);
CREATE INDEX CompositeSeqWIDBioSeqWID2 ON CompositeSeqWIDBioSeqWID(BioSequenceWID);

CREATE INDEX ComposSeqWIDRepoComposMa1 ON ComposSeqWIDRepoComposMapWID(CompositeSequenceWID);
CREATE INDEX ComposSeqWIDRepoComposMa2 ON ComposSeqWIDRepoComposMapWID(ReporterCompositeMapWID);

CREATE INDEX ComposSeqWIDComposComposMa1 ON ComposSeqWIDComposComposMapWID(CompositeSequenceWID);
CREATE INDEX ComposSeqWIDComposComposMa2 ON ComposSeqWIDComposComposMapWID(CompositeCompositeMapWID);

CREATE INDEX FeatureWIDFeatureWID1 ON FeatureWIDFeatureWID(FeatureWID1);
CREATE INDEX FeatureWIDFeatureWID2 ON FeatureWIDFeatureWID(FeatureWID2);

CREATE INDEX FeatureWIDFeatureWID21 ON FeatureWIDFeatureWID2(FeatureWID1);
CREATE INDEX FeatureWIDFeatureWID22 ON FeatureWIDFeatureWID2(FeatureWID2);

CREATE INDEX ReporterWIDBioSequenceWID1 ON ReporterWIDBioSequenceWID(ReporterWID);
CREATE INDEX ReporterWIDBioSequenceWID2 ON ReporterWIDBioSequenceWID(BioSequenceWID);

CREATE INDEX ReporterWIDFeatureReporMa1 ON ReporterWIDFeatureReporMapWID(ReporterWID);
CREATE INDEX ReporterWIDFeatureReporMa2 ON ReporterWIDFeatureReporMapWID(FeatureReporterMapWID);

CREATE INDEX BioAssayDimensioWIDBioAssa1 ON BioAssayDimensioWIDBioAssayWID(BioAssayDimensionWID);
CREATE INDEX BioAssayDimensioWIDBioAssa2 ON BioAssayDimensioWIDBioAssayWID(BioAssayWID);

CREATE INDEX BioAssayMapWIDBioAssayWID1 ON BioAssayMapWIDBioAssayWID(BioAssayMapWID);
CREATE INDEX BioAssayMapWIDBioAssayWID2 ON BioAssayMapWIDBioAssayWID(BioAssayWID);

CREATE INDEX BAssayMappingWIDBAssayMa1 ON BAssayMappingWIDBAssayMapWID(BioAssayMappingWID);
CREATE INDEX BAssayMappingWIDBAssayMa2 ON BAssayMappingWIDBAssayMapWID(BioAssayMapWID);

CREATE INDEX ComposSeqDimensWIDComposSe1 ON ComposSeqDimensWIDComposSeqWID(CompositeSequenceDimensionWID);
CREATE INDEX ComposSeqDimensWIDComposSe2 ON ComposSeqDimensWIDComposSeqWID(CompositeSequenceWID);

CREATE INDEX DesnElMappingWIDDesnElMa1 ON DesnElMappingWIDDesnElMapWID(DesignElementMappingWID);
CREATE INDEX DesnElMappingWIDDesnElMa2 ON DesnElMappingWIDDesnElMapWID(DesignElementMapWID);

CREATE INDEX FeatureDimensionWIDFeatur1 ON FeatureDimensionWIDFeatureWID(FeatureDimensionWID);
CREATE INDEX FeatureDimensionWIDFeatur2 ON FeatureDimensionWIDFeatureWID(FeatureWID);

CREATE INDEX QuantTypeDimensWIDQuantTyp1 ON QuantTypeDimensWIDQuantTypeWID(QuantitationTypeDimensionWID);
CREATE INDEX QuantTypeDimensWIDQuantTyp2 ON QuantTypeDimensWIDQuantTypeWID(QuantitationTypeWID);

CREATE INDEX QuantTypeMapWIDQuantTyp1 ON QuantTypeMapWIDQuantTypeWID(QuantitationTypeMapWID);
CREATE INDEX QuantTypeMapWIDQuantTyp2 ON QuantTypeMapWIDQuantTypeWID(QuantitationTypeWID);

CREATE INDEX QuantTyMapWIDQuantTyMapWI1 ON QuantTyMapWIDQuantTyMapWI(QuantitationTypeMappingWID);
CREATE INDEX QuantTyMapWIDQuantTyMapWI2 ON QuantTyMapWIDQuantTyMapWI(QuantitationTypeMapWID);

CREATE INDEX ReporterDimensWIDReporte1 ON ReporterDimensWIDReporterWID(ReporterDimensionWID);
CREATE INDEX ReporterDimensWIDReporte2 ON ReporterDimensWIDReporterWID(ReporterWID);

CREATE INDEX TransformWIDBioAssayDat1 ON TransformWIDBioAssayDataWID(TransformationWID);
CREATE INDEX TransformWIDBioAssayDat2 ON TransformWIDBioAssayDataWID(BioAssayDataWID);

CREATE INDEX BioSourceWIDContactWID1 ON BioSourceWIDContactWID(BioSourceWID);
CREATE INDEX BioSourceWIDContactWID2 ON BioSourceWIDContactWID(ContactWID);

CREATE INDEX LabeledExtractWIDCompoun1 ON LabeledExtractWIDCompoundWID(LabeledExtractWID);
CREATE INDEX LabeledExtractWIDCompoun2 ON LabeledExtractWIDCompoundWID(CompoundWID);

CREATE INDEX BioAssayWIDChannelWID1 ON BioAssayWIDChannelWID(BioAssayWID);
CREATE INDEX BioAssayWIDChannelWID2 ON BioAssayWIDChannelWID(ChannelWID);

CREATE INDEX BioAssayWIDFactorValueWID1 ON BioAssayWIDFactorValueWID(BioAssayWID);
CREATE INDEX BioAssayWIDFactorValueWID2 ON BioAssayWIDFactorValueWID(FactorValueWID);

CREATE INDEX ChannelWIDCompoundWID1 ON ChannelWIDCompoundWID(ChannelWID);
CREATE INDEX ChannelWIDCompoundWID2 ON ChannelWIDCompoundWID(CompoundWID);

CREATE INDEX DerivBioAWIDDerivBioADat1 ON DerivBioAWIDDerivBioADataWID(DerivedBioAssayWID);
CREATE INDEX DerivBioAWIDDerivBioADat2 ON DerivBioAWIDDerivBioADataWID(DerivedBioAssayDataWID);

CREATE INDEX DerivBioAssayWIDBioAssayMa1 ON DerivBioAssayWIDBioAssayMapWID(DerivedBioAssayWID);
CREATE INDEX DerivBioAssayWIDBioAssayMa2 ON DerivBioAssayWIDBioAssayMapWID(BioAssayMapWID);

CREATE INDEX ImageWIDChannelWID1 ON ImageWIDChannelWID(ImageWID);
CREATE INDEX ImageWIDChannelWID2 ON ImageWIDChannelWID(ChannelWID);

CREATE INDEX ImageAcquisitionWIDImag1 ON ImageAcquisitionWIDImageWID(ImageAcquisitionWID);
CREATE INDEX ImageAcquisitionWIDImag2 ON ImageAcquisitionWIDImageWID(ImageWID);

CREATE INDEX MeasBAssayWIDMeasBAssayDat1 ON MeasBAssayWIDMeasBAssayDataWID(MeasuredBioAssayWID);
CREATE INDEX MeasBAssayWIDMeasBAssayDat2 ON MeasBAssayWIDMeasBAssayDataWID(MeasuredBioAssayDataWID);

CREATE INDEX HardwareWIDSoftwareWID1 ON HardwareWIDSoftwareWID(HardwareWID);
CREATE INDEX HardwareWIDSoftwareWID2 ON HardwareWIDSoftwareWID(SoftwareWID);

CREATE INDEX HardwareWIDContactWID1 ON HardwareWIDContactWID(HardwareWID);
CREATE INDEX HardwareWIDContactWID2 ON HardwareWIDContactWID(ContactWID);

CREATE INDEX ProtocolWIDHardwareWID1 ON ProtocolWIDHardwareWID(ProtocolWID);
CREATE INDEX ProtocolWIDHardwareWID2 ON ProtocolWIDHardwareWID(HardwareWID);

CREATE INDEX ProtocolWIDSoftwareWID1 ON ProtocolWIDSoftwareWID(ProtocolWID);
CREATE INDEX ProtocolWIDSoftwareWID2 ON ProtocolWIDSoftwareWID(SoftwareWID);

CREATE INDEX ProtocolApplWIDPersonWID1 ON ProtocolApplWIDPersonWID(ProtocolApplicationWID);
CREATE INDEX ProtocolApplWIDPersonWID2 ON ProtocolApplWIDPersonWID(PersonWID);

CREATE INDEX SoftwareWIDSoftwareWID1 ON SoftwareWIDSoftwareWID(SoftwareWID1);
CREATE INDEX SoftwareWIDSoftwareWID2 ON SoftwareWIDSoftwareWID(SoftwareWID2);

CREATE INDEX SoftwareWIDContactWID1 ON SoftwareWIDContactWID(SoftwareWID);
CREATE INDEX SoftwareWIDContactWID2 ON SoftwareWIDContactWID(ContactWID);


commit;
