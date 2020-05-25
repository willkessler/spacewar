// X flickering starfield
// X collisions
// X bullets
// X bullet collision with ship
// X sounds
// X hyperspace
// X thrust sounds (white noise)
// X scoring and keystroke display (legend)
// X pause game
// X engine overheating!
// X bullet collisions 
// heat-seaking missile... dumb, runs out of fuel, can't turn that fast, only sees in front of it
// explosion animation
// improved stats: display "Overheated", "Destroyed", "Hit the sun!"

import processing.sound.*;
SoundFile[] explosions;
SoundFile gunshot;
SoundFile engineAlarm;
Stats stats;
WhiteNoise noise = new WhiteNoise(this);

int windowSize = 800;
int numStars = 100;
float shipWidth = 15;
float shipHeight = shipWidth * 1.5;
boolean gamePaused;

PVector[] stars = new PVector[numStars];


Ship ship1, ship2;
 
void setup()
{
  stats = new Stats();
  Missile oneMissile = new Missile();
  // Load a soundfile from the /data folder of the sketch and play it back
  explosions = new SoundFile[10];
  explosions[0] = new SoundFile(this, "Explosion+1.mp3");
  explosions[1] = new SoundFile(this, "Explosion+2.mp3");
  explosions[2] = new SoundFile(this, "Explosion+3.mp3");
  explosions[3] = new SoundFile(this, "Explosion+4.mp3");
  explosions[4] = new SoundFile(this, "Explosion+5.mp3");
  explosions[5] = new SoundFile(this, "Explosion+6.mp3");
  explosions[6] = new SoundFile(this, "Explosion+7.mp3");
  explosions[7] = new SoundFile(this, "Explosion+9.mp3");
  explosions[8] = new SoundFile(this, "Explosion+10.mp3");
  explosions[9] = new SoundFile(this, "Explosion+11.mp3");
  gunshot = new SoundFile(this, "Gun+Silencer.mp3");
  engineAlarm = new SoundFile(this, "beep-07.mp3");
  
  size(800,800);
  background(255,255,255);
  mouseX = width / 2;
  mouseY = height / 2;
  int partWindow = windowSize /8;
  ship1 = new Ship(0, partWindow, partWindow, color(0,255,0));
  ship2 = new Ship(1, windowSize - partWindow,windowSize - partWindow, color(255,0,0));
  createStars();
  noise.amp(0.5);
  gamePaused = false;

}

void draw()
{
  background(0,0,0);
  pushMatrix();
  translate(windowSize/2, windowSize / 2);
  drawSun(25);  
  popMatrix();
  drawStars();
  stats.render(ship1,ship2);
  
  if (ship1.hitOtherShip(ship2)) {
    ship1.blowUp();
    ship2.blowUp();
  }
  
  if (ship1.onALiveBullet(ship2)) {
    ship2.blowUp();
    ship1.addPoints(1);
  }
  
  if (ship2.onALiveBullet(ship1)) {
    ship1.blowUp();
    ship2.addPoints(1);
  }
  
  ship1.checkBulletsCollide(ship2);
  
  if (!gamePaused) {
    ship1.update();
  }
  ship1.render();  
  
  if (!gamePaused) {
    ship2.update();
  }
  ship2.render(); 
  
}

void keyPressed() {  
 switch (key) {
   case '0':
   case '1':
     gamePaused = !gamePaused;
     break;
   case ' ':
     ship1.goIntoHyperspace();
     ship2.goIntoHyperspace();
     break; 
   case 's':
    ship1.applyThrust();
    break;
   case 'w':
    ship1.fireBullet();
    break;
   case 'a':
    ship1.startTurning(-1);
    break;
   case 'd':
    ship1.startTurning(1);
    break;
   case 'k':
    ship2.applyThrust();
    break;
   case 'i':
    ship2.fireBullet();
    break;
   case 'j':
     ship2.startTurning(-1);
     break;
   case 'l':
    ship2.startTurning(1);
    break;
  } 
    
}

void keyReleased() {
 switch (key) {
   case 's':
    ship1.cancelThrust();
    break;
   case 'w':
    //ship1.fireBullet();
    break;
   case 'a':
   case 'd':
    ship1.stopTurning();
     break;
   case 'k':
    ship2.cancelThrust();
    break;
   case 'i':
    //ship1.fireBullet();
    break;
   case 'j':
   case 'l':
     ship2.stopTurning();
     break;
  }
}

// wrap a moving object around screen edges
void wrapAroundEdges(PVector pos) {
  if (pos.x < 0) {
   pos.x = windowSize; 
  }
  if (pos.y < 0) {
    pos.y = windowSize;
  }
  if (pos.x > windowSize) {
   pos.x = 0; 
  }
  if (pos.y > windowSize) {
    pos.y = 0;
  }
}

boolean insideSun (PVector pos) {
  float halfWindow = windowSize / 2;
  return ((abs(halfWindow - pos.x) < 10) && (abs(halfWindow - pos.y) < 10));  
}

PVector calculateGravityForce(PVector pos, float mass) {
  PVector sunVector = new PVector(windowSize / 2, windowSize/2);
  float distToSun = pos.dist(sunVector);
  PVector shipToSunVector = PVector.sub(sunVector, pos);
  shipToSunVector.normalize();
  float G = 32;
  float gravityFactor = (1.0 / (pow(distToSun, 1.57))) * G * mass;
  PVector gravityVector = PVector.mult(shipToSunVector, gravityFactor);

  return gravityVector;
}
 
 
void createStars() {
  for (int i = 0; i < numStars; ++i) {
    stars[i] = new PVector (random(0,windowSize), random (0, windowSize));
  }
}

void drawStars() {
  float flicker;
  for (int i = 0; i < numStars; ++i) {
    flicker = (random(0,5) / 10) + 0.5;
    stroke(150 * flicker, 150 * flicker, 255 * flicker);
    point(stars[i].x, stars[i].y);
  }
}

void drawSun(float size) {
  fill(255,255, 0);
  stroke(255,205,0);
  int fc = frameCount;
  int mod = 30;
  float modF = 105.0;
  float pulse = ((fc % mod) / modF) + 1.0;
  //println((fc % 10) / 10.0);
  ellipse(0,0,size * pulse,size * pulse);
}
