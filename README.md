# MandelbrotSetViewer

### Vladyslav Khibovskyi 18/01/22 ###

The program written with flat assembler (fasm).

To zoom in the image click the left button, move the cursor along X axis and release. To restore the start view click the right button.
If the zooming rectangle filled with red color it means incorrect area or too small area (it was done for the possibility to discard the chosen area)
The green color allows you to draw the new image after releasing the left button. However, the zooming has a certain limit, it caused by
maximal number of digits after the floating point of a float type variable (the calculation mechanism based on defining if a certain point of the complex numbers plane belong to the "Mandelbrot set" or not. The more zeros after floating point available the more detailed image you can get).
You can also change the resolution, maximal number of iterations and color palette. To do it open Options/Set Options

---

__Some screens:__

![screen1](/screenshots/screen1.png)

![screen2](/screenshots/screen2.png)

![screen3](/screenshots/screen3.png)
