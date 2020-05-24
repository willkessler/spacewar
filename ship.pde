class Ship {
  
  PVector pos, vel, accel;
  float thrustConstant = 0.2;
  float maxSpeed, friction;
  color shipColor;
  int shipId;
  int score;
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
    accelFactor = 0.009;
    shipId = id;
    friction = 0.9995; // even in outer space, you slow down! whaaaa?
    bullets = new Bullet[numBullets];
    for (int i = 0; i < numBullets; ++i) {
      bullets[i] = new Bullet(shipColor);
    }
  }
  
  int getScore(){
    return score;
  }
  
  void fireBullet(PVector pos, PVector vel) {
    for (Bullet bullet : bullets) {
      if (!bullet.isLive()) {
        bullet.fire(pos,vel,rot);
        break;
      }
    }
  }
  
  void update() {
    if (thrustOn) {
      accel.x = sin(radians(rot)) * accelFactor;
      accel.y = -cos(radians(rot)) * accelFactor;
      noise.play();
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
    }
    
    accel.mult(0);
  
  }
  
  void renderBullets() {
    for (Bullet bullet : bullets) {
      if (bullet.isLive()) {
        bullet.update();
        bullet.render();
      }
    }
  }
  
  void addPoints(int amountToAdd) {
    score = score + amountToAdd;
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
