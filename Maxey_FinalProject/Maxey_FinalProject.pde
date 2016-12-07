/*
 Title: Atomic Paint
  Instructions: 
   'z' activates color, 'x' activates b&w, 'shift' enables "paint mode", 'space' takes a snapshot,
   's' swaps between depth camera and video camera;    
*/

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

float[] depthLookUp = new float[2048];
boolean capture;
boolean switcher = true;
boolean swapper = true;

Kinect kinect;

void setup() {
  fullScreen(P3D);
  background(0, 0);
  noStroke();
  ellipseMode(CENTER);
  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.initVideo();
  kinect.enableIR(true);
  kinect.enableColorDepth(false);
  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToMeters(i);
  }
}

void draw() {
  if (switcher) {
    background(0, 0);
  }
  if (capture) {
    saveFrame("snapshot-####.jpg");
  }

  PImage dImg = kinect.getDepthImage();
  PImage vImg = kinect.getVideoImage();
  PImage img;

  if (swapper) {
    img = dImg;
  } else {
    img = vImg;
  }

  int space = 5;
  int[] depth = kinect.getRawDepth();
  translate(width/2, height/2, 100);
  for (int x = 0; x < img.width && x < kinect.width; x += space) {
    for (int y = 0; y < img.height && y < kinect.height; y += space) {
      int index = x + y * img.width;
      int dIndex = x + y * kinect.width;
      int rawDepth = depth[dIndex];
      PVector v = depthToWorld(x, y, rawDepth);
      float r = red(img.pixels[index]);
      float g = green(img.pixels[index]);
      float b = blue(img.pixels[index]);
      float a = alpha(img.pixels[index]);
      fill(r, g, b, a);
      pushMatrix();
      float factor = 800;
      translate(v.x*factor, v.y*factor, factor-v.z*factor);
      ellipse(0, 0, space, space);
      popMatrix();
    }
  }
  if (capture) {
    capture = false;
  }
}

void keyPressed() {
  if (keyCode == SHIFT) {
    switcher = !switcher;
  }
  if (key == 's') {
    swapper = !swapper;
  }
  if (key == ' ') {
    capture = true;
  }
  if (key == 'z') {
    kinect.enableIR(false);
    kinect.enableColorDepth(true);
  }
  if (key == 'x') {
    kinect.enableIR(true);
    kinect.enableColorDepth(false);
  }
}

// These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}

PVector depthToWorld(int x, int y, int depthValue) {

  final double fx_d = 1.0 / 5.9421434211923247e+02;
  final double fy_d = 1.0 / 5.9104053696870778e+02;
  final double cx_d = 3.3930780975300314e+02;
  final double cy_d = 2.4273913761751615e+02;

  PVector result = new PVector();
  double depth =  depthLookUp[depthValue];//rawDepthToMeters(depthValue);
  result.x = (float)((x - cx_d) * depth * fx_d);
  result.y = (float)((y - cy_d) * depth * fy_d);
  result.z = (float)(depth);
  return result;
}