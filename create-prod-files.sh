#!/bin/sh
#

NAME=`basename $PWD`
REV_PRO=`cat *.kicad_pro | grep REVISION | sed 's/.*: \"//' | sed 's/\"//'`
if [ -z "$REV_PRO" ] ; then
  PCB_REV=`grep '(rev' $NAME.kicad_pcb | sed 's/.*rev "//' | sed 's/".*//'`
  SCH_REV=`grep '(rev' $NAME.kicad_sch | sed 's/.*rev "//' | sed 's/".*//'`
  if [ "$SCH_REV" != "$PCB_REV" ] ; then
    echo "Revision is not set equal in PCB ($PCB_REV) and Schematics ($SCH_REV)"
    exit
  fi
  REVISION=Rev$PCB_REV
else
  REVISION=Rev$REV_PRO
fi

if [ -d $REVISION ] ; then
  echo "$REVISION already exists. Manually remove directory if regenerating the outputs."
  exit
else
  echo "Creating $REVISION"
  mkdir $REVISION
fi

CURRENT_DATE=$(date +%Y-%m-%d)
filename="$NAME.kicad_pro" 
sed -i "s/\"DATE\": \".*\"/\"DATE\": \"$CURRENT_DATE\"/" "$filename"

PDF_SCH=$REVISION/$NAME-$REVISION-schematics.pdf
PDF_PCB=$REVISION/$NAME-$REVISION-pcb
PDF_PCBFULL=$REVISION/$NAME-$REVISION-pcb-full.pdf
PDF_PCBCUSTOMER=$REVISION/$NAME-$REVISION-pcb.pdf
BOM=$REVISION/$NAME-$REVISION-bom.csv

kicad-cli pcb export gerbers --output $REVISION/ --use-drill-file-origin --no-protel-ext $NAME.kicad_pcb

# Remove unwanted layers
rm $REVISION/$NAME-F_Adhesive.gbr 2>/dev/null
rm $REVISION/$NAME-B_Adhesive.gbr 2>/dev/null
rm $REVISION/$NAME-User_Comments.gbr 2>/dev/null
rm $REVISION/$NAME-User_Eco1.gbr 2>/dev/null
rm $REVISION/$NAME-User_Eco2.gbr 2>/dev/null
rm $REVISION/$NAME-Margin.gbr 2>/dev/null
rm $REVISION/$NAME-F_Courtyard.gbr 2>/dev/null
rm $REVISION/$NAME-B_Courtyard.gbr 2>/dev/null
rm $REVISION/$NAME-F_Fab.gbr 2>/dev/null
rm $REVISION/$NAME-B_Fab.gbr 2>/dev/null
rm `ls $REVISION/*.gbr | grep "User_[0-9]+*"` 2>/dev/null

kicad-cli pcb export drill --output $REVISION/ --drill-origin plot $NAME.kicad_pcb

# Zip gerber and drill files
cd $REVISION
zip $NAME-$REVISION-gerber.zip *
cd ..

LAYERS=""
for FILE in $REVISION/*.gbr ; do
  LAYERS="$LAYERS "`basename $FILE | sed "s/$NAME-//" | sed "s/\\.gbr//" | sed "s/_/./"`
done

for LAYER in $LAYERS ; do
  echo "Creating PDF for layer $LAYER"
  kicad-cli pcb export pdf --output ${PDF_PCB}.$LAYER.pdf --layers $LAYER --black-and-white --include-border-title $NAME.kicad_pcb
done

pdfunite $REVISION/*.pdf $PDF_PCBFULL
pdfunite ${PDF_PCB}.B.Cu.pdf ${PDF_PCB}.B.Silkscreen.pdf ${PDF_PCB}.Edge.Cuts.pdf ${PDF_PCB}.F.Cu.pdf ${PDF_PCB}.F.Silkscreen.pdf ${PDF_PCB}.User.Drawings.pdf $PDF_PCBCUSTOMER

echo "Removing temporary PDF files for each layer"
for LAYER in $LAYERS ; do
  rm ${PDF_PCB}.$LAYER.pdf
done

kicad-cli pcb export pos --output $REVISION/$NAME-$REVISION-pos.csv --format csv --units mm --use-drill-file-origin --exclude-dnp $NAME.kicad_pcb
sed -i.bak "1 s/.*/Designator,Val,Package,MidX,MidY,Rotation,Layer/" $REVISION/$NAME-$REVISION-pos.csv
rm $REVISION/*.csv.bak

if [ ".$GEN_3D" = ".STEP" ] ; then
  kicad-cli pcb export step --output $REVISION/$NAME-$REVISION-3d.step --force --drill-origin --no-dnp $NAME.kicad_pcb
fi

if [ ".$GEN_3D" = ".GLB" ] ; then
  kicad-cli pcb export glb --output $REVISION/$NAME-$REVISION-3d.glb --force --drill-origin --no-dnp $NAME.kicad_pcb
fi

kicad-cli sch export pdf --output $PDF_SCH $NAME.kicad_sch
kicad-cli sch export bom --output $BOM --ref-range-delimiter "" --preset JLCPCB $NAME.kicad_sch
