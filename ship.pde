class Ship {
  
  PVector pos, vel, accel;
  float thrustConstant = 0.2;
  float maxSpeed, friction;
  color shipColor;
  int shipId;
  int score;
  int shipState; // 0 == visible, 1 == in hyperspace (not drawn), 2 == exploding (not drawn), 3 == overheated
  int shipStateTimeout; // counter for how long ships stay in hyperspace (or are exploding)
  int engineTemp; // how hot your engine is getting. Don't go too high!
  float rot, rotChange, rotIncrement;
  float accelFactor;
  int numBullets = 5;
  float mass = 1.0;
  float tooHotEngineTemp = 550;
  boolean thrustOn;
  float engineHeatConstant = 3.5;
  Bullet[] bullets;
  Explosion shipExplosion;
  Missile missile;
  int hyperspaceTimeLimit = 500; // number of draw cycles before you can do another hyperspace
  int hyperspaceCountdown;
  int totalLives = 5; // how many lives your ship gets before GAME OVER
  int livesLeft;
  
  Ship(int id, float x, float y, color sColor) {
    score = 0;
    accel = new PVector(0,0);
    vel = new PVector(random(-0.5, 0.5), random(-0.5, 0.5));
    pos = new PVector(x,y);
    livesLeft = totalLives;
    maxSpeed = 5;
    shipWidth = 15;
    shipColor = sColor;    
    rot = 90;
    rotChange = 0;
    rotIncrement = 3;
    thrustOn = false;
    engineTemp = 0;
    accelFactor = 0.009;
    shipId = id;
    shipState = 0; // visible
    friction = 0.9998; // even in outer space, you slow down! whaaaa?
    bullets = new Bullet[numBullets];
    for (int i = 0; i < numBullets; ++i) {
      bullets[i] = new Bullet(shipColor);
    }
    shipExplosion = new Explosion(this);
    missile = new Missile(this);
  }
 
// =-=-==-=-==-=-==-=-==-=-==-=-= UTILITY METHODS =-=-==-=-==-=-==-=-==-=-==-=-=

  int getScore(){
    return score;
  }
  
  int getShipState() {
    return shipState;
  }
  
  PVector getShipPos() {
    return pos;
  }
  
  PVector getShipVel() {
    return vel;
  }
  
  float getShipRot() {
    return rot - 90; // because of the way the ships are rendered, the "actual" ship heading is off by 90 degrees so we compensate here
  }
  
  void setShipState(int newShipState) {
    shipState = newShipState;
  }
  
  void setEnemyShip(Ship enemy) {
    missile.setEnemyShip(enemy);
  }
  
  int getEngineTemp() {
    return engineTemp;
  }
  
  int getShipColor() {
    return shipColor;
  }
  
  int getLivesLeft() {
    return livesLeft;
  }
    
  void fireBullet() {
    if (missile.isLive() || gamePaused() || gameOver()) {
      return; // can't fire bullets while your missile is away! or the game is paused
    }

      for (Bullet bullet : bullets) {
        if (!bullet.isLive()) {
          bullet.fire(pos,vel,rot);
          break;
        }
    }
  }
  
  void fireMissile() {
    //println("Missile for ship " + shipId + " is away!");
    missile.fire();    
  }
  
  void killMissile() {
    missile.die();
  }
  
  void checkBulletsCollide(Ship otherShip) {
    for (Bullet bullet1 : bullets) {
      for (Bullet bullet2 : otherShip.bullets) {
        if (bullet1.isLive() && bullet2.isLive()) {
           if (bullet1.collides(bullet2.pos, bullet1.bulletBulletCollisionTolerance)) {
             bullet1.die();
             bullet2.die();
             playRandomExplosionSound();
          }
        }
      }
    }
  }
  
  void goIntoHyperspace() {
    if (hyperspaceCountdown == 0) {
      setShipState(1); // ship is now in hyperspace
      shipStateTimeout = 100; // how long ship stays in hyperspace
      pos.x = random(width);
      pos.y = random(height);
      hyperspaceCountdown = hyperspaceTimeLimit;
    }    
  }
  
  void updateHyperspaceCountdown() {
    hyperspaceCountdown = max(0, hyperspaceCountdown - 1);
    //println("shipid", shipId, "hyperspace ct", hyperspaceCountdown);
  }
  
  void updateBullets() {
    for (Bullet bullet : bullets) {
      if (bullet.isLive()) {
        bullet.update();
      }
    }
  }
  
  void renderBullets() {
    for (Bullet bullet : bullets) {
      if (bullet.isLive()) {
        bullet.render();
      }
    }
  }
  
  void addPoints(int amountToAdd) {
    score = max(0,score + amountToAdd);
  }

  boolean onALiveBullet(Ship opponentShip) {
    for (Bullet bullet : bullets) {
      if (bullet.isLive()) {
        if (bullet.collides(opponentShip.pos, bullet.shipBulletCollisionTolerance)) {
          bullet.die();
          return true;
        }
      }
    }
    return false;
  }
  
   boolean missileOnALiveBullet(Ship opponentShip) {
    for (Bullet bullet : bullets) {
      if (bullet.isLive()) {
        if (bullet.collides(opponentShip.missile.getMissilePos(), bullet.shipBulletCollisionTolerance)) {
          bullet.die();
          return true;
        }
      }
    }
    return false;
  } 
 
  boolean engineGettingTooHot() {
    return (engineTemp > tooHotEngineTemp * 0.75);
  }
      
  void startTurning(float direction) {
    rotChange = direction * rotIncrement;
  }
  
  void stopTurning() {
    rotChange = 0;
  }
  
  void applyThrust() {
    if (gamePaused() || gameOver()) {
      return;
    }
    if (shipState == 0) { // can't accelerate if not alive
      thrustOn = true;
      
    }
  }

  void cancelThrust() {
    thrustOn = false;
    noise.stop();
  }
  
  boolean hitOtherShip(Ship otherShip) {
    return (((abs(pos.x - otherShip.pos.x) < 10) && (abs(pos.y - otherShip.pos.y) < 10)));
  }
  
  boolean hitOtherShipsMissile(Ship otherShip) {
    PVector missilePos = otherShip.missile.getMissilePos();
    boolean impact = (((abs(pos.x - missilePos.x) < 10) && (abs(pos.y - missilePos.y) < 10)));
    return impact && otherShip.missile.isLive();
  }
  
  
   boolean missileHitOtherShipsMissile(Ship otherShip) {
     PVector missile1Pos = missile.getMissilePos();
     PVector missile2Pos = otherShip.missile.getMissilePos();
     boolean impact = (((abs(missile1Pos.x - missile2Pos.x) < 10) && (abs(missile1Pos.y - missile2Pos.y) < 10)));
     return impact && missile.isLive() && otherShip.missile.isLive();
   }
  
  void blowUp() {
    setShipState(2);
    shipExplosion.start(this);
    // make ship respawn somewhere near the margins so you don't get insta-die by spawning near planet or sun.
    float buffer = 50;
    float newX, newY;
    if (shipId == 0) {
      newX = random(0, windowSize);
      if (newX < buffer) {
        newY = random(0, windowSize);
      } else {
        newY = random(0,buffer);
      }
    } else {
      newX = random(0,windowSize);
      if (newX < windowSize - buffer) {
        newY = random(windowSize - buffer, windowSize);
      } else {
        newY = random(0,windowSize);
      }
    }
   
    pos.set( newX, newY);
    vel.x = 0;
    vel.y = 0;
    engineTemp = 0;
    playRandomExplosionSound();
    cancelThrust();
    
    livesLeft = livesLeft - 1;
    if (livesLeft == 0) {
      // GAME OVER! A ship is out of lives.
      setGameOver();
    }
  }
  
  void drawShip(PVector pos, float rot, float proportion, color shipColor, boolean drawThrust) {
    pushMatrix();
    translate(pos.x,pos.y);
    scale(proportion);
    rotate(radians(rot));
    fill(0);
    stroke(shipColor);
    beginShape();
    vertex(-halfShipWidth,  halfShipHeight);
    vertex(0,  -halfShipHeight);
    vertex(halfShipWidth,  halfShipHeight);
    vertex(0, halfShipHeight / 2);
    endShape(CLOSE);
    if (drawThrust) {
      // draw flames
      float flicker = random(0,10) / 10 + 1; 
      fill(255 * flicker,255 * flicker,0);
      stroke(255 * flicker,255 * flicker,0);
      beginShape();
      vertex(-halfShipWidth / 2, halfShipHeight * 1.1);
      vertex(0, halfShipHeight * 1.6 * flicker);
      vertex(halfShipWidth / 2, halfShipHeight * 1.1);
      vertex(0, halfShipHeight * 1.4);
      endShape(CLOSE);
    }
    popMatrix();
  }
  
// =-=-==-=-==-=-==-=-==-=-==-=-= MAIN CODE FOR SHIPS =-=-==-=-==-=-==-=-==-=-==-=-= 
  
  void update() {
    updateHyperspaceCountdown();
    if (thrustOn) {
      accel.x = sin(radians(rot)) * accelFactor;
      accel.y = -cos(radians(rot)) * accelFactor;
      noise.play();
      engineTemp += engineHeatConstant;
    } else { 
      engineTemp = max (0,engineTemp - 1);
    }
    accel.add(calculateSunsGravityForce(pos,mass));
    accel.add(calculatePlanetsGravityForce(pos,mass));
    vel.add(accel);
    vel.mult(friction);
    //if (shipId == 0) {
    //  println("speed:", vel.mag());
    //}
    vel.limit(maxSpeed);
    pos.add(vel);
    rot = rot + rotChange;
    wrapAroundEdges(pos);
    if (insideSun(pos)) {
      blowUp();
      addPoints(-killPoints);
    } else if (engineTemp > tooHotEngineTemp) {
      // you overheated, you die!
      blowUp();
      addPoints(-killPoints);
      setShipState(3); // overheat
      shipStateTimeout = 100;
    }    
    
    accel.mult(0);
  
    updateBullets();
  }
  
  void render() {
    shipExplosion.render(); // if an explosion is live, render it
    renderBullets();
    missile.update();
    missile.render();
    if (shipState != 0) { // if ship is not visible, don't draw anything (e.g. in hyperspace or exploding)
      shipStateTimeout -= 1;
      if (shipStateTimeout == 0) {
        shipState = 0; // ship becomes visible again
      } else {
        return;
      }
    }
    
    drawShip(pos, rot, 1.0, shipColor, thrustOn);    
   }
}
