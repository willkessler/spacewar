class Ship {
  
  PVector pos, vel, accel;
  float thrustConstant = 0.2;
  float maxSpeed, friction;
  color shipColor;
  int shipId;
  int score;
  int shipState; // 0 == visible, 1 == in hyperspace (not drawn), 2 == exploding (not drawn)
  int shipStateTimeout; // counter for how long ships stay in hyperspace (or are exploding)
  int engineTemp; // how hot your engine is getting. Don't go too high!
  float rot, rotChange, rotIncrement;
  float accelFactor;
  int numBullets = 5;
  float mass = 1.0;
  boolean thrustOn;
  PVector startPos;
  Bullet[] bullets;
  
  Ship(int id, float x, float y, color sColor) {
    score = 0;
    accel = new PVector(0,0);
    vel = new PVector(random(-0.5, 0.5), random(-0.5, 0.5));
    pos = new PVector(x,y);
    startPos = new PVector(x,y);
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
    friction = 0.9995; // even in outer space, you slow down! whaaaa?
    bullets = new Bullet[numBullets];
    for (int i = 0; i < numBullets; ++i) {
      bullets[i] = new Bullet(shipColor);
    }
  }
  
  int getScore(){
    return score;
  }
  
  int getShipState() {
    return shipState;
  }
  int getEngineTemp(){
    return engineTemp;
  }
  
  void fireBullet(PVector pos, PVector vel) {
    for (Bullet bullet : bullets) {
      if (!bullet.isLive()) {
        bullet.fire(pos,vel,rot);
        break;
      }
    }
  }
  
  void goIntoHyperspace() {
    shipState = 1; // ship is now in hyperspace
    shipStateTimeout = 100; // how long ship stays in hyperspace
    pos.x = random(width);
    pos.y = random(height);
  }
  
  void update() {
    if (thrustOn) {
      accel.x = sin(radians(rot)) * accelFactor;
      accel.y = -cos(radians(rot)) * accelFactor;
      noise.play();
      engineTemp += 5;
    } else { 
      engineTemp = max (0,engineTemp - 1);
    }
    accel.add(calculateGravityForce(pos,mass));
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
      addPoints(-1);
    } else if (engineTemp > 300) {
      // you overheated, you die!
       blowUp();
      addPoints(-1);
      shipState = 2; // exploding
      shipStateTimeout = 100;
  }
    
    
    accel.mult(0);
  
    updateBullets();
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
        if (bullet.collides(opponentShip.pos)) {
          bullet.die();
          return true;
        }
      }
    }
    return false;
  } 
 
  void startTurning(float direction) {
    rotChange = direction * rotIncrement;
  }
  
  void stopTurning() {
    rotChange = 0;
  }
  
  void applyThrust() {
    thrustOn = true;
  }

  void cancelThrust() {
    thrustOn = false;
    noise.stop();
  }
  
  boolean hitOtherShip(Ship otherShip) {
    return (((abs(pos.x - otherShip.pos.x) < 10) && (abs(pos.y - otherShip.pos.y) < 10)));
  }
  
  void blowUp() {
    int randomExplosionSound = int(random(10));
    explosions[randomExplosionSound].play();
    pos.x = startPos.x;
    pos.y = startPos.y;
    vel.x = 0;
    vel.y = 0;
    engineTemp = 0;
  }
  
  void fireBullet() {
    for (Bullet bullet: bullets) {
      if (!bullet.isLive()) {
        bullet.fire(pos,vel,rot);
        break;
      } 
    }
  }
  
  void render() {
    if (shipState != 0) { // if ship is not visible, don't draw anything (e.g. in hyperspace or exploding)
      shipStateTimeout -= 1;
      if (shipStateTimeout == 0) {
        shipState = 0; // ship becomes visible again
      } else {
        return;
      }
    }
    
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(radians(rot));
    float halfHeight = shipHeight / 2;
    float halfWidth = shipWidth / 2;
    fill(0);
    stroke(shipColor);
    beginShape();
    vertex(-halfWidth,  halfHeight);
    vertex(0,  -halfHeight);
    vertex(halfWidth,  halfHeight);
    vertex(0, halfHeight / 2);
    endShape(CLOSE);
    if (thrustOn) {
      // draw flames
      float flicker = random(0,10) / 10 + 1; 
      fill(255 * flicker,255 * flicker,0);
      stroke(255 * flicker,255 * flicker,0);
      beginShape();
      vertex(-halfWidth / 2, halfHeight * 1.1);
      vertex(0, halfHeight * 1.6 * flicker);
      vertex(halfWidth / 2, halfHeight * 1.1);
      vertex(0, halfHeight * 1.4);
      endShape(CLOSE);
    }
    popMatrix();
    
    renderBullets();
  }
}
