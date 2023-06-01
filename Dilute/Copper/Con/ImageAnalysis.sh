#!/usr/bin/env

# This is the second half of the Foci measuring pipeline
# Upon first use, be sure to copy the following files into a direcory of your choice and cite the paths in this scripts
  # imagesort.R
  # BatchFociIntersect.py
  # Fociplot.R

# Usage: Copy this script into your working directory and then run via:
  #  bash imageanalysis.sh

#==============================================================================

#will move Max projection to its own folder
mkdir MaxProj/
mv MAX*.tif MaxProj

#will generate Folders for each track/cell
Rscript /Users/andrewd/Documents/scripts/imageSort.R

#Will move all the images into their corresponding folder
echo "Sorting Track_IDs..."
for i in $(ls *.tif | rev | cut -d '_' -f2- | rev | uniq); do\
  echo "Moving Track_ID:" ${i};
  mv *_${i}_*.tif ${i}_*.tif ${i}/ 2>/dev/null;
done
echo "Images have been sorted..."

#Direcory management
cd MaxProj/
mv *.tif ../
cd ..
rm -rf MaxProj/


#Will start a new instance of FIJI to measure nuclei and foci
/Applications/Fiji.app/Contents/MacOS/ImageJ-macosx --ij2 --run /Users/andrewd/Documents/scripts/BatchFociIntersect_V4.py

#will read CSV files from FIJI output to plot
Rscript /Users/andrewd/Documents/scripts/Fociplot_V2.R

#houseKeeping to clean up working directory
mkdir Outputs/ ROIs/
mv [0-9]*/ ROIs/
mv [0-9]*.png ROIs/
mv *.png Outputs/
mv ROI_values.csv Outputs/
mv Log.txt Outputs/
mv Rplots.pdf Outputs/
mv *Intensity.csv Outputs/
cd Outputs/
mkdir Figures/
mv Rplots.pdf Figures/
mv *.png Figures/
cd ../ROIs


# for d in */ ; do\
#   #echo "Cleaning:" ${d%/};
#   cd ${d}
#   rm -rf [0-9]*.tif
#   cp Stack.tif ${d%/}.tif
#   rm -rf Stack.tif
#   cd ..
# done

for i in $(ls *.png | rev | cut -d '.' -f2- | rev | uniq); do\
  #echo "Moving Intensity Trace:" ${i};
  mv ${i}.png ${i}/  2>/dev/null;
done

echo "..."
echo "..."
echo "..."
echo "..."
echo "...Image processing completed"
