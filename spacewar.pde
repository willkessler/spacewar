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
// X hyperspace time limit
// X orbiting planet
// X keys legend at bottom of screen
// X planet has gravity!
// X heat-seaking missile... dumb, runs out of fuel, can't turn that fast, only sees in front of it
// X AI choice between 1 player and 2 player
// limited number of ships (5), and then game over. whoever has the most points wins


import processing.sound.*;

int windowSize = 800;
float shipWidth = 15;
float shipHeight = shipWidth * 1.5;
float halfShipHeight = shipHeight / 2;
float halfShipWidth = shipWidth / 2;
int gameStatus; // 0 == opening, 1 == playing, 2 == paused, 3 == game over
boolean useAI = true;

SoundFile[] explosions;
SoundFile gunshot;
SoundFile engineAlarm;
SoundFile missileShot;
SoundFile bigSwoosh;
SoundFile gameOverNoise;
Stats stats;
WhiteNoise noise = new WhiteNoise(this);

Ship ship1, ship2;
Stars theStars;
Planet thePlanet;
AI theAI;
int killPoints = 10;

// =-=-==-=-==-=-==-=-==-=-==-=-= UTILITY FUNCTIONS =-=-==-=-==-=-==-=-==-=-==-=-=

void keyPressed() {  
 stats.hideInstructions();
  switch (key) {
   case '0':
   case '1':
   case '2':
     if (gameOpening() || gamePaused()) {
       setGamePlaying();
     } else {
       setGamePaused();
     }
   
     if (key == '2') {
       useAI = false;
     }
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

PVector calculateGravityForce(PVector gravityWellPos, PVector pos, float mass, float G) {
  float distToWell = pos.dist(gravityWellPos);
  PVector shipToWellVector = PVector.sub(gravityWellPos, pos);
  shipToWellVector.normalize();
  float gravityFactor = (1.0 / (pow(distToWell, 1.57))) * G * mass;
  PVector gravityVector = PVector.mult(shipToWellVector, gravityFactor);
  return gravityVector;
}

PVector calculateSunsGravityForce(PVector pos, float mass) {
  PVector sunPos = new PVector (windowSize / 2, windowSize/2);
  float G = 30;
  PVector gravityVector = calculateGravityForce(sunPos, pos, mass, G);
  return gravityVector;
}

PVector calculatePlanetsGravityForce(PVector pos, float mass) {
  PVector planetPos = thePlanet.getPlanetPos();
 float G = 18;
 PVector gravityVector = calculateGravityForce(planetPos, pos, mass,G);
  return gravityVector;
}
 
// see: https://www.euclideanspace.com/maths/algebra/vectors/angleBetween/
float angleBetweenVectors(PVector v1, PVector v2) {
  float dp = v1.dot(v2);
  float denom = v1.mag() * v2.mag();
  float angle = acos(dp/denom);
  return degrees(angle);
}

void playRandomExplosionSound() {
  int randomExplosionSound = int(random(10));
  explosions[randomExplosionSound].play();
}

boolean gameOpening() {
  return gameStatus == 0;
}

boolean gamePlaying() {
  return gameStatus == 1;
}

boolean gamePaused() {
  return gameStatus == 2;
}

boolean gameOver() {
  return gameStatus == 3;
}

void setGameOpening() {
  gameStatus = 0; // opening
  bigSwoosh.play();
}

void setGamePlaying() {
  gameStatus = 1; // playing
}

void setGamePaused() {
  gameStatus = 2; // paused
}

void setGameOver() {
  gameStatus = 3; // game over
  gameOverNoise.play();
}

// =-=-==-=-==-=-==-=-==-=-==-=-= MAIN CODE =-=-==-=-==-=-==-=-==-=-==-=-=

void setup()
{
  stats = new Stats();
  theStars = new Stars();
  thePlanet = new Planet();
  theAI = new AI();
  
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
  bigSwoosh = new SoundFile(this, "bigswoosh.mp3");
  gameOverNoise = new SoundFile(this, "smb_gameover.wav");
  
  //println("does this update git hub?????? ");
  
  size(800,800);
  background(255,255,255);
  mouseX = width / 2;
  mouseY = height / 2;
  int partWindow = windowSize /8;
  ship1 = new Ship(0, partWindow, partWindow, color(0,255,0));
  ship2 = new Ship(1, windowSize - partWindow,windowSize - partWindow, color(255,0,0));
  ship1.setEnemyShip(ship2);
  ship2.setEnemyShip(ship1);
  if (useAI) {
    theAI.assignShips(ship2, ship1);
  }
  noise.amp(0.5);
  setGameOpening();
}

void draw()
{
  background(0,0,0);
  theStars.render();
  theStars.renderSun(25);
  stats.render(ship1,ship2);
  if (gamePlaying()) {
    thePlanet.update();
  }
  thePlanet.render();
  
  if (ship1.hitOtherShip(ship2)) {
    ship1.blowUp();
    ship2.blowUp();
  }
  
  if (ship1.onALiveBullet(ship2)) {
    ship2.blowUp();
    ship1.addPoints(killPoints);
  }
  
  if (ship2.onALiveBullet(ship1)) {
    ship1.blowUp();
    ship2.addPoints(killPoints);
  }
  
  if (ship1.hitOtherShipsMissile(ship2)) {
    ship1.blowUp();
    ship2.addPoints(killPoints);
    ship2.killMissile();
  }
  
  if (ship2.hitOtherShipsMissile(ship1)) {
    ship2.blowUp();
    ship1.addPoints(killPoints);
    ship1.killMissile();
  }
  
  if (ship1.missileHitOtherShipsMissile (ship2)) {
    ship1.killMissile();
    ship2.killMissile();
  }

   if (ship1.missileOnALiveBullet(ship2)) {
    ship2.killMissile();
  }
  
  if (ship2.missileOnALiveBullet(ship1)) {
    ship1.killMissile();
  }
 
  ship1.checkBulletsCollide(ship2);
  
  if (thePlanet.collides(ship1.pos)) {
    ship1.blowUp();
    ship1.addPoints(-killPoints);
  }
  
  if (thePlanet.collides(ship2.pos)) {
    ship2.blowUp();
    ship2.addPoints(-killPoints);
  }
  
  if (gamePlaying()) {
    ship1.update();
  }
  if (!gameOver()) {
    ship1.render();  
  }
  
  if (gamePlaying()) {
    ship2.update();
  }
  
  if (!gameOver()) {
    ship2.render(); 
  }
  
  if(gamePlaying() && useAI) {
    theAI.control();
  }
}
