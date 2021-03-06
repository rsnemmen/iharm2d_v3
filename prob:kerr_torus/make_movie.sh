#!/bin/sh
#
# syntax: make_movie 
#
cd ./images
#
# look in images directory and determine what movies need to be made 
image_types=`/bin/ls im_*_0000.ppm | sed "s/im_//g" | sed "s/_0000.ppm//g"`
echo $image_types
#
# first x1-x2 version of movie 
#
for fil in $image_types
do
	#
	echo $fil
	ls im_${fil}_*.ppm
	#
	# yuv420p is necessary for the movie to be understood
	# by quicktime.  You can find information about this under
	# "encoding for dumb players".
	#
	# -crf 1 is the minimum loss that will permit the movie to
	# play under quicktime.
	#
	ffmpeg -loop 0 -i im_${fil}_%04d.ppm -c:v libx264 -crf 1 \
		-pix_fmt yuv420p -r 30 ${fil}_x1x2.mov
	#
done
#
#
# second: r-z version of movie
#
# cause rz_image to spit out arguments:
../rz_image
#
for fil in $image_types
do
	# first convert images to new coordinates
	for nfil in `ls im_${fil}_*.ppm`
	do
		echo $nfil
		../rz_image 256 512 1.32 40. 40. 40. 0.3 \
			< $nfil > tmp_$nfil
	done

	# make animation
	ffmpeg -loop 0 -i tmp_im_${fil}_%04d.ppm -c:v libx264 -crf 1 \
		-pix_fmt yuv420p -r 30 ${fil}_rz.mov

	# tidy up
	rm tmp_*.ppm
done
#
