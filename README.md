# KiCAD Tools

## create-prod-files.sh
Executed inside a KiCAD project. It will do the following;

* Expectations;
  * Revisions are "A", "B", "C" or "A1", "B1", "B2" or similar.
  * Executions has the KiCAD project directory as $PWD/$CWD
  * The name of the directory is the same name as the KiCAD project files.
  * A BOM preset exists called "JLCPCB"
  
* Extracts the Revision from the either the Project "REVISION" variable or from the "Revision" field in Page Settings.
  If the latter, it will make sure that both Revisions are identical. 
    
* Sets the "DATE" to current date in both Schematics and PCB.

* Create a directory named "Rev${REVISION}", and store all generated outputs in that directory.

* Generate the Gerber and Drill files.

* Zip the Gerber and Drill files.

* Generate a component placement file, (only Top side). CSV format is for JLCPCB.

* Generate BOM.csv

* Generate PDFs
  * Schematics
  * PCB with outer layers only, useful for manufacturing.
  * PCB with all "useful" layers, i.e. remove Fab, Courtyard, Margin, User-ECO*, User_Comment and Adhesive.
  
* (Optional) Generate 3D model (STEP or GLB/GLTF). 
  Put "GEN_3D" as an argument with either "STEP" or "GLB" as the value, example `GEN_3D=GLB create-prod-files.sh`



  

