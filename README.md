# KiCAD Tools

## create-prod-files.sh
Executed inside a KiCAD project. It will do the following;

* Extract the Revision from the either the Project "REVISION" variable or from the "Revision" in Page Settings.
  If the latter, it will make sure that both Revisions are identical. 
  The expectation is that we use revisions "A", "B", "C" or "A1", "B1", "B2" or similar.
  
* Set the "DATE" to current date in both Schematics and PCB.

* Create a directory named "Rev${REVISION}", and store all generated outputs in that directory.

* Generate the Gerber and Drill files.

* Zip the Gerber and Drill files.

* Generate a component placement file, (only Top side). CSV format is for JLCPCB.

* Generate BOM.csv. Expects a "JLCPCB" preset in the project.

* Generate PDFs
  * Schematics
  * PCB with outer layers only, useful for manufacturing.
  * PCB with all "useful" layers. I.e. remove Fab, Courtyard, Margin, User-ECO*, User_Comment and Adhesive.
  
* (Optional) Generate 3D model (STEP or GLB/GLTF). Put "GEN_3D" as an argument, example `GEN_3D=GLB create-prod-files.sh`



  

