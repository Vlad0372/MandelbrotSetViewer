# MandelbrotSetViewer

### Vladyslav Khibovskyi 18/01/22 ###

The program written with flat assembler (fasm).

To zoom in the image click the left button, move the cursor along X axis and release. To restore the start view click the right button.
If the zooming rectangle filled with red color it means incorrect area or too small area (it was done for the possibility to discard the chosen area)
The green color allows you to draw the new image after releasing the left button. However, the zooming has a certain limit, it caused by
maximal number of digits after the floating point.
You can also change the resolution, maximal number of iterations and color palette. To do it open Options/Set Options
