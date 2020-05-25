// Handles starfield and sun
class Stars {
  int numStars = 100;
  PVector[] stars = new PVector[numStars];

  Stars() {
    for (int i = 0; i < numStars; ++i) {
      stars[i] = new PVector (random(0,windowSize), random (0, windowSize));
    }
  }

  void render() {
    float flicker;
    for (int i = 0; i < numStars; ++i) {
      flicker = (random(0,5) / 10) + 0.5;
      stroke(150 * flicker, 150 * flicker, 255 * flicker);
      point(stars[i].x, stars[i].y);
    }
  }

  void renderSun(float size) {
    pushMatrix();
    translate(windowSize/2, windowSize / 2);
    fill(255,255, 0);
    stroke(255,205,0);
    int fc = frameCount;
    int mod = 30;
    float modF = 105.0;
    float pulse = ((fc % mod) / modF) + 1.0;
    //println((fc % 10) / 10.0);
    ellipse(0,0,size * pulse,size * pulse);
    popMatrix();
  }

}
