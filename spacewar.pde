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
// X explosion animation
// X improved stats: display "Overheated", "Destroyed", "Hit the sun!"
// heat-seaking missile... dumb, runs out of fuel, can't turn that fast, only sees in front of it
// orbiting planet
// hyperspace time limit
// keys legend at bottom of screen

import processing.sound.*;

int windowSize = 800;
float shipWidth = 15;
float shipHeight = shipWidth * 1.5;
float halfShipHeight = shipHeight / 2;
float halfShipWidth = shipWidth / 2;
boolean gamePaused;

SoundFile[] explosions;
SoundFile gunshot;
SoundFile engineAlarm;
SoundFile missileShot;
Stats stats;
WhiteNoise noise = new WhiteNoise(this);

Ship ship1, ship2;
Stars theStars;

// =-=-==-=-==-=-==-=-==-=-==-=-= UTILITY FUNCTIONS =-=-==-=-==-=-==-=-==-=-==-=-=

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
   case 'e':
    ship1.fireMissile();
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
   case 'u':
    ship2.fireMissile();
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
 
// see: https://www.euclideanspace.com/maths/algebra/vectors/angleBetween/
float angleBetweenVectors(PVector v1, PVector v2) {
  float dp = v1.dot(v2);
  float denom = v1.mag() * v2.mag();
  float angle = acos(dp/denom);
  return degrees(angle);
}

// =-=-==-=-==-=-==-=-==-=-==-=-= MAIN CODE =-=-==-=-==-=-==-=-==-=-==-=-=

void setup()
{
  stats = new Stats();
  theStars = new Stars();

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
  missileShot = new SoundFile(this, "Missile+2.mp3");
  
  size(800,800);
  background(255,255,255);
  mouseX = width / 2;
  mouseY = height / 2;
  int partWindow = windowSize /8;
  ship1 = new Ship(0, partWindow, partWindow, color(0,255,0));
  ship2 = new Ship(1, windowSize - partWindow,windowSize - partWindow, color(255,0,0));
  ship1.setEnemyShip(ship2);
  ship2.setEnemyShip(ship1);
  
  noise.amp(0.5);
  gamePaused = false;

}

void draw()
{
  background(0,0,0);
  theStars.render();
  theStars.renderSun(25);
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
  
  if (ship1.hitOtherShipsMissile(ship2)) {
    ship1.blowUp();
    ship2.addPoints(1);
    ship2.killMissile();
  }
  
  if (ship2.hitOtherShipsMissile(ship1)) {
    ship2.blowUp();
    ship1.addPoints(1);
    ship1.killMissile();
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
