# KiCAD Tools

## create-prod-files.sh
It will create all the needed production files for PCB manufacturing and PCB assembly, primarily focused on JLCPCB.
Each Revision is generated in full, inside the revision directory, and is expected to be committed to Git, perhaps
with the exception of the Gerber and Drill files, which exists inside a Zip file. Set that up with `.gitignore` if
those files shouldn't be committed to Git.

* Expectations;
  * Revisions are "A", "B", "C" or "A1", "B1", "B2" or similar.
  * Executions has the KiCAD project directory as $PWD/$CWD
  * The name of the directory is the same name as the KiCAD project files.
  * A BOM preset exists called "JLCPCB"
  
* Extracts the Revision from the either the Project "REVISION" variable or from the "Revision" field in Page Settings.
  If the latter, it will make sure that both Revisions are identical. 
    
* Sets the "Date" field to current date in both Schematics and PCB page settings.

* Create a directory named "Rev${REVISION}", and store all generated outputs in that directory.

* Generate the Gerber and Drill files.

* Zip the Gerber and Drill files.

* Generate a component placement file, (only Top side). CSV format is for JLCPCB.

* Generate BOM.csv

* Generate SVGs
  * One SVG per sheet

* Generate PDFs
  * Schematics
  * PCB with outer layers only, useful for manufacturing.
  * PCB with all "useful" layers, i.e. remove Fab, Courtyard, Margin, User-ECO*, User_Comment and Adhesive.
  
* (Optional) Generate 3D model (STEP or GLB/GLTF). 
  Put "GEN_3D" as an argument with either "STEP" or "GLB" as the value, example `GEN_3D=GLB create-prod-files.sh`



  

