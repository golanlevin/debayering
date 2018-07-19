// Processing program to correctly display Bayer8 images 
// (i.e, de-bayering, de-mosaicing) with the GRBG pattern.
// Written for Processing v.3.3.7, Golan Levin, July 2018

PImage bayerImg; 
int bayerValues[];

void setup() {
  size(1280, 720);
  //noLoop();
  bayerImg = loadImage("bayer-raw.png");  

  /*
  // precomputeBayerValues();
   This function is only necessary for debayerSimple() or debayerBilinear()
   It is not used by debayerOnePass() or debayerEdgeAwareOnePass().
   */
}


void draw() {
  background(0);

  loadPixels(); 

  if (!mousePressed) {
    debayerBilinearOnePass();
  } else {
    debayerBilinearEdgeAwareOnePass();
  }

  updatePixels();
}


//============================================
void debayerBilinearOnePass() {

  color bayerPixels[] = bayerImg.pixels;
  int w = bayerImg.width;
  int wm1 = w-1;
  int h = bayerImg.height; 
  int hm1 = h-1;

  int index0, index1, index2; 
  int index3, index4, index5; 
  int index6, index7, index8;

  int col0, col1, col2; 
  int col3, col4, col5; 
  int col6, col7, col8; 

  int src0r, src0g, src0b; 
  int src1r, src1g, src1b; 
  int src2r, src2g, src2b; 
  int src3r, src3g, src3b; 
  int src4r, src4g, src4b; 
  int src5r, src5g, src5b; 
  int src6r, src6g, src6b; 
  int src7r, src7g, src7b; 
  int src8r, src8g, src8b; 

  for (int y=0; y<h; y++) {

    // Handle edge cases
    int ym1 = (y == 0  ) ? (y+1) : (y-1); // y minus 1
    int yp1 = (y == hm1) ? (y-1) : (y+1); // y plus 1
    int ym1w = w*(ym1); 
    int yp1w = w*(yp1); 
    int yp0w = w*(y); 

    for (int x=0; x<w; x++) {
      int xm1 = (x == 0  ) ? (x+1) : (x-1); // x minus 1
      int xp1 = (x == wm1) ? (x-1) : (x+1); // x plus 1
      int xp0 = x; 

      // Compute the array indices of our 3x3 patch of pixels
      index0 = ym1w + xm1; 
      index1 = ym1w + xp0;
      index2 = ym1w + xp1;
      index3 = yp0w + xm1;
      index4 = yp0w + xp0;
      index5 = yp0w + xp1;
      index6 = yp1w + xm1;
      index7 = yp1w + xp0;
      index8 = yp1w + xp1;

      // Fetch ARGB colors (integers) from the image's pixels array
      col0 = bayerPixels[index0];
      col1 = bayerPixels[index1];
      col2 = bayerPixels[index2];
      col3 = bayerPixels[index3];
      col4 = bayerPixels[index4];
      col5 = bayerPixels[index5];
      col6 = bayerPixels[index6];
      col7 = bayerPixels[index7];
      col8 = bayerPixels[index8];

      // Fetch individual R,G,B values from Processing's packed ARGB integers
      src0r = (col0 & 0x00FF0000) >> 16; 
      src0g = (col0 & 0x0000FF00) >> 8;  
      src0b = (col0 & 0x000000FF);

      src1r = (col1 & 0x00FF0000) >> 16; 
      src1g = (col1 & 0x0000FF00) >> 8;  
      src1b = (col1 & 0x000000FF);

      src2r = (col2 & 0x00FF0000) >> 16; 
      src2g = (col2 & 0x0000FF00) >> 8;  
      src2b = (col2 & 0x000000FF);

      src3r = (col3 & 0x00FF0000) >> 16; 
      src3g = (col3 & 0x0000FF00) >> 8;  
      src3b = (col3 & 0x000000FF);

      src4r = (col4 & 0x00FF0000) >> 16; 
      src4g = (col4 & 0x0000FF00) >> 8;  
      src4b = (col4 & 0x000000FF);

      src5r = (col5 & 0x00FF0000) >> 16; 
      src5g = (col5 & 0x0000FF00) >> 8;  
      src5b = (col5 & 0x000000FF);

      src6r = (col6 & 0x00FF0000) >> 16; 
      src6g = (col6 & 0x0000FF00) >> 8;  
      src6b = (col6 & 0x000000FF);

      src7r = (col7 & 0x00FF0000) >> 16; 
      src7g = (col7 & 0x0000FF00) >> 8;  
      src7b = (col7 & 0x000000FF);

      src8r = (col8 & 0x00FF0000) >> 16; 
      src8g = (col8 & 0x0000FF00) >> 8;  
      src8b = (col8 & 0x000000FF);

      int dstr = 0;
      int dstg = 0; 
      int dstb = 0;

      if (y%2 == 0) {
        if (x%2 == 0) {
          // GREEN (upper left)
          dstr = (src3g + src5g)/2; // sideAvg;
          dstg = src4b;
          dstb = (src1g + src7g)/2; // vertAvg;
        } else {
          // RED position
          dstr = src4g;
          dstg = (src1r + src3b + src5b + src7r)/4; // cardAvg; 
          dstb = (src0g + src2g + src6g + src8g)/4; // diagAvg;
        }
      } else { // y%2 == 1
        if (x%2 == 0) {
          // BLUE position 
          dstr = (src0g + src2g + src6g + src8g)/4; // diagAvg; 
          dstg = (src1b + src3r + src5r + src7b)/4; // cardAvg; 
          dstb = src4g;
        } else {
          // GREEN (bottom right)
          dstr = (src1g + src7g)/2; // vertAvg;
          dstg = src4r;
          dstb = (src3g + src5g)/2; // sideAvg;
        }
      }

      pixels[index4] = 0xFF000000 + (dstr<<16) + (dstg<<8) + (dstb); 
      // pixels[index4] = color(dstr, dstg, dstb);
    }
  }
}


//============================================
void debayerBilinear() {
  // Requires pre-computation of bayerValues array

  int w = 1280;
  int m = w-1;

  int h = 720; 
  int u = h-1;

  for (int y=0; y<h; y++) {

    int ym1 = (y == 0) ? y : (y-1);
    int yp1 = (y == u) ? y : (y+1);
    int rowm1 = w * ym1;
    int rowy0 = w * y; 
    int rowp1 = w * yp1;

    for (int x=0; x<w; x++) {

      int xm1 = (x == 0) ? x : (x-1);
      int xp1 = (x == m) ? x : (x+1);

      int v0 = bayerValues[rowm1 + (xm1)];
      int v1 = bayerValues[rowm1 + (x  )];
      int v2 = bayerValues[rowm1 + (xp1)];

      int v3 = bayerValues[rowy0 + (xm1)];
      int v4 = bayerValues[rowy0 + (x  )];
      int v5 = bayerValues[rowy0 + (xp1)];

      int v6 = bayerValues[rowp1 + (xm1)];
      int v7 = bayerValues[rowp1 + (x  )];
      int v8 = bayerValues[rowp1 + (xp1)];

      int r, g, b; 
      int cardAvg = (v3 + v5 + v1 + v7)/4;
      int diagAvg = (v0 + v2 + v6 + v8)/4;
      int sideAvg = (v3 + v5)/2;
      int vertAvg = (v1 + v7)/2;

      if (y%2 == 0) {
        if (x%2 == 0) {
          // GREEN (upper left)
          r = sideAvg;
          g = v4;
          b = vertAvg;
        } else {
          // RED position
          r = v4;
          g = cardAvg;
          b = diagAvg;
        }
      } else {
        if (x%2 == 0) {
          // BLUE position 
          r = diagAvg;
          g = cardAvg;
          b = v4;
        } else {
          // GREEN (bottom right)
          r = vertAvg;
          g = v4;
          b = sideAvg;
        }
      }

      pixels[rowy0 + x] = color(r, g, b);
    }
  }
}


//============================================
void debayerSimple() {
  // Crappy but works
  // Requires pre-computation of bayerValues array

  int w = 1280;
  int h = 720; 
  for (int y=0; y<(h-1); y+=2) {
    for (int x=0; x<(w-1); x+=2) {

      int v0 = bayerValues[(y+0)*w + (x+0)]; //G1
      int v1 = bayerValues[(y+0)*w + (x+1)]; //R
      int v2 = bayerValues[(y+1)*w + (x+0)]; //B
      int v3 = bayerValues[(y+1)*w + (x+1)]; //G2
      int r = v1; 
      int g = (v0+v3)/2;
      int b = v2;

      color col = color(r, g, b);
      pixels[(y+0)*w + (x+0)] = col;
      pixels[(y+0)*w + (x+1)] = col;
      pixels[(y+1)*w + (x+0)] = col;
      pixels[(y+1)*w + (x+1)] = col;
    }
  }
}

//============================================
void precomputeBayerValues() {
  // Only necessary for debayerSimple() or debayerBilinear()

  int index = 0; 
  bayerValues = new int[1280*720];
  color bayerPixels[] = bayerImg.pixels;
  for (int y=0; y<720; y++) {
    for (int x=0; x<1280; x++) {
      color col = bayerPixels[index];
      int r = (int) red(col); 
      int g = (int) green(col); 
      int b = (int) blue(col); 

      int val = 0;
      if (y%2 == 1) {
        if (x%2 == 0) {
          val = g;
        } else {
          val = r;
        }
      } else { // y%2 == 0
        if (x%2 == 0) {
          val = b;
        } else {
          val = g;
        }
      } 
      bayerValues[index] = val; 
      index++;
    }
  }


  byte[] bytes = new byte[1280*720];
  for (int i=0; i<(1280*720); i++) {
    bytes[i] = (byte)bayerValues[i];
  }
  saveBytes("bayer-monochrome.raw", bytes);
}




//============================================
void debayerBilinearEdgeAwareOnePass() {
  
  // See http://techtidings.blogspot.com/2012/01/demosaicing-exposed-normal-edge-aware.html
  // Hibbard's gradient-based method (1995)

  color bayerPixels[] = bayerImg.pixels;
  int w = bayerImg.width;
  int wm1 = w-1;
  int h = bayerImg.height; 
  int hm1 = h-1;

  int index0, index1, index2; 
  int index3, index4, index5; 
  int index6, index7, index8;

  int col0, col1, col2; 
  int col3, col4, col5; 
  int col6, col7, col8; 

  int src0r, src0g, src0b; 
  int src1r, src1g, src1b; 
  int src2r, src2g, src2b; 
  int src3r, src3g, src3b; 
  int src4r, src4g, src4b; 
  int src5r, src5g, src5b; 
  int src6r, src6g, src6b; 
  int src7r, src7g, src7b; 
  int src8r, src8g, src8b; 

  for (int y=0; y<h; y++) {

    // Handle edge cases
    int ym1 = (y == 0  ) ? (y+1) : (y-1); // y minus 1
    int yp1 = (y == hm1) ? (y-1) : (y+1); // y plus 1
    int ym1w = w*(ym1); 
    int yp1w = w*(yp1); 
    int yp0w = w*(y); 

    for (int x=0; x<w; x++) {
      int xm1 = (x == 0  ) ? (x+1) : (x-1); // x minus 1
      int xp1 = (x == wm1) ? (x-1) : (x+1); // x plus 1
      int xp0 = x; 

      // Compute the array indices of our 3x3 patch of pixels
      index0 = ym1w + xm1; 
      index1 = ym1w + xp0;
      index2 = ym1w + xp1;
      index3 = yp0w + xm1;
      index4 = yp0w + xp0;
      index5 = yp0w + xp1;
      index6 = yp1w + xm1;
      index7 = yp1w + xp0;
      index8 = yp1w + xp1;

      // Fetch ARGB colors (integers) from the image's pixels array
      col0 = bayerPixels[index0];
      col1 = bayerPixels[index1];
      col2 = bayerPixels[index2];
      col3 = bayerPixels[index3];
      col4 = bayerPixels[index4];
      col5 = bayerPixels[index5];
      col6 = bayerPixels[index6];
      col7 = bayerPixels[index7];
      col8 = bayerPixels[index8];

      // Fetch individual R,G,B values from Processing's packed ARGB integers
      src0r = (col0 & 0x00FF0000) >> 16; 
      src0g = (col0 & 0x0000FF00) >> 8;  
      src0b = (col0 & 0x000000FF);

      src1r = (col1 & 0x00FF0000) >> 16; 
      src1g = (col1 & 0x0000FF00) >> 8;  
      src1b = (col1 & 0x000000FF);

      src2r = (col2 & 0x00FF0000) >> 16; 
      src2g = (col2 & 0x0000FF00) >> 8;  
      src2b = (col2 & 0x000000FF);

      src3r = (col3 & 0x00FF0000) >> 16; 
      src3g = (col3 & 0x0000FF00) >> 8;  
      src3b = (col3 & 0x000000FF);

      src4r = (col4 & 0x00FF0000) >> 16; 
      src4g = (col4 & 0x0000FF00) >> 8;  
      src4b = (col4 & 0x000000FF);

      src5r = (col5 & 0x00FF0000) >> 16; 
      src5g = (col5 & 0x0000FF00) >> 8;  
      src5b = (col5 & 0x000000FF);

      src6r = (col6 & 0x00FF0000) >> 16; 
      src6g = (col6 & 0x0000FF00) >> 8;  
      src6b = (col6 & 0x000000FF);

      src7r = (col7 & 0x00FF0000) >> 16; 
      src7g = (col7 & 0x0000FF00) >> 8;  
      src7b = (col7 & 0x000000FF);

      src8r = (col8 & 0x00FF0000) >> 16; 
      src8g = (col8 & 0x0000FF00) >> 8;  
      src8b = (col8 & 0x000000FF);

      int dstr = 0;
      int dstg = 0; 
      int dstb = 0;

      int rDifA, rDifB; 
      int gDifA, gDifB;
      int bDifA, bDifB;

      int rSumA, rSumB;
      int gSumA, gSumB;
      int bSumA, bSumB;

      float rDifH, gDifH, bDifH;
      float U, V;

      if (y%2 == 0) {
        if (x%2 == 0) {
          // GREEN (upper left)
          dstr = (src3g + src5g)/2; // sideAvg;
          dstg = src4b;
          dstb = (src1g + src7g)/2; // vertAvg;
        } else {
          // RED position
          dstr = src4g;

          gDifA = abs(src3b - src5b);
          gDifB = abs(src1r - src7r);
          if (gDifA < gDifB) {
            dstg = (src3b + src5b)/2;
          } else if (gDifB < gDifA) {
            dstg = (src1r + src7r)/2;
          } else {
            dstg = (src1r + src3b + src5b + src7r)/4; // cardAvg;
          }

          bDifA = abs(src0g - src8g); 
          bDifB = abs(src2g - src6g); 
          if (bDifA < bDifB) {
            dstb = (src0g + src8g)/2;
          } else if (bDifB < bDifA) {
            dstb = (src2g + src6g)/2;
          } else {
            dstb = (src0g + src2g + src6g + src8g)/4; // diagAvg;
          }
        }
        ;
      } else { // y%2 == 1

        if (x%2 == 0) {
          // BLUE position 

          rDifA = abs(src0g - src8g); 
          rDifB = abs(src2g - src6g); 
          if (rDifA < rDifB) {
            dstr = (src0g + src8g)/2;
          } else if (rDifB < rDifA) {
            dstr = (src2g + src6g)/2;
          } else {
            dstr = (src0g + src2g + src6g + src8g)/4; // diagAvg;
          }

          gDifA = abs(src3r - src5r);
          gDifB = abs(src1b - src7b);
          if (gDifA < gDifB) {
            dstg = (src3r + src5r)/2;
          } else if (gDifB < gDifA) {
            dstg = (src1b + src7b)/2;
          } else {
            dstg = (src1b + src3r + src5r + src7b)/4; // cardAvg;
          }

          dstb = src4g;
          ;
        } else {
          // GREEN (bottom right)
          dstr = (src1g + src7g)/2; // vertAvg;
          dstg = src4r;
          dstb = (src3g + src5g)/2; // sideAvg;
        }
      }

      pixels[index4] = 0xFF000000 + (dstr<<16) + (dstg<<8) + (dstb); 
      // pixels[index4] = color(dstr, dstg, dstb);
    }
  }
}
