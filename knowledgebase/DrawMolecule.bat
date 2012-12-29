@ECHO OFF
REM Compiles and tests DrawMolecule program
REM Requires MarvinBeans (C:\Program Files\ChemAxon\MarvinBeans\lib\MarvinBeans.jar) either to be added to system java class path variable, or added to class path as below

REM parameters
SET Smiles=%1
SET Width=%2
SET Height=%3
SET BGColor=%4 %5 %6
SET Format=%7
SET Output=%8

REM Set class path
SET CLASSPATH=C:\Program Files\ChemAxon\MarvinBeans\lib\MarvinBeans.jar;%CLASSPATH%

REM Compile
javac DrawMolecule.java

REM Execute
java -Djava.awt.headless=true DrawMolecule %Smiles% %Width% %Height% %BGColor% %Format% %Output%
