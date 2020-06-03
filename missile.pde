// X player 1 fires with 'E' key
// X player 2 fires with 'U' key
// X while missile in flight, cannot fire bullets
// X fire missile
// X hit sun and dies
// X gravitational pull applies
// X track ship
// X collide with ship
// X improve missile display
// X missile explosion sound in sun
// X orientation must track its velocity vector
// X shoot missile with bullets! very important
// X thrust display on missiles
// X collisions with the other missile
// X collisions with the other missile
// X missile explosion
// X missile explodes near ship, ship blows up
// when missiles "die" because they time out, play explosion but fizzle

class Missile {

  PVector pos, vel, accel;
  float fuel;
  boolean live;
  int ttl;
  int lifeSpan = 500;
  float rot; // where the missile is facing
  MissileExplosion missileExplosion;
  Ship parent;
  Ship enemyShip;
  float enemyRange = windowSize; // can track you over entire screen right now
  float enemyAngleTolerance = 360;
  float mass = .5;
  float missileLaunchForce = 1;
  float missileSmartFactor = 0.045;
  float maxSpeed = 3;
  float halfMissileWidth = halfShipWidth * 0.3;
  float halfMissileHeight = halfShipHeight * .8;
  
  Missile(Ship ship) {
    fuel = 1000;
    pos = new PVector(0,0);
    vel = new PVector(0,0);
    accel = new PVector(0,0);
    parent = ship;
    missileExplosion = new MissileExplosion(this);
  }
  
  PVector getMissilePos() {
    return pos;
  }
  
  PVector getMissileVel() {
    return vel;
  }
  
  color getMissileColor() {
    return parent.shipColor;
  }
  
  // calculate if the enemy ship is near enough to "see" and in front of the missile. Return a zero vector if not.
  // otherwise return a vector indicating a velocity change to track the enemy
  PVector calculateEnemyShipDirection() {
    PVector adjustment = new PVector(0,0);
    PVector missileToShip = new PVector(0,0);
    missileToShip.set(enemyShip.pos);
    missileToShip.sub(pos);
    float distanceToEnemy = missileToShip.mag();
    if (distanceToEnemy > enemyRange) { // have to be close to it, first off
      return adjustment;
    }
    missileToShip.normalize();
    float angleToEnemy = angleBetweenVectors(vel, missileToShip);
    
   // println("In range of enemy ship:", distanceToEnemy, "angle:", angleToEnemy);
    if (angleToEnemy <= enemyAngleTolerance) { // limited view in front of the missile
       PVector crossProduct = vel.cross(missileToShip);
       // calculate turn based on how large the angle is
       float adjustmentAngle = angleToEnemy * crossProduct.z;
       float adjustmentAngleRadians = radians(adjustmentAngle);
       float ca = cos(adjustmentAngleRadians);
       float sa = sin(adjustmentAngleRadians);
       adjustment.set(ca * vel.x - sa * vel.y,
                      sa * vel.x + ca * vel.y);  
       adjustment.normalize();
       adjustment.mult(missileSmartFactor);
       // println("  Adjustment vector:", adjustment);
    }
    return adjustment;
  }
  
  void fire() {
    if (live) {
      return; // cannot fire if another missile in flight
    }
    
    float damper = 0.2; // how much weight we give to the actual ship's movement vs firing direction
    pos.set(parent.pos);
    // almost same code in bullet, so needs refactor
    float shipRotRad = radians(parent.rot);
    PVector fireVelocity = new PVector(sin(shipRotRad), -cos(shipRotRad));
    fireVelocity.normalize();
    pos.add(fireVelocity.x * shipHeight / 2, fireVelocity.y * shipHeight / 2);
    fireVelocity.mult(missileLaunchForce);
    PVector missileVel = new PVector(parent.vel.x * damper, parent.vel.y * damper);
    missileVel.add(fireVelocity);
    vel.set(missileVel);
    rot = parent.rot;
    ttl = lifeSpan;
    live = true;
    missileShot.play();
  }
  
  void checkIfShouldKillEnemyShip() {
    float distanceFromEnemyShip;
    PVector missileToShip = new PVector(0,0);
    missileToShip.set(enemyShip.pos);
    missileToShip.sub(pos);
    distanceFromEnemyShip = missileToShip.mag();

    float blowupDistance = 50;
    if (distanceFromEnemyShip < blowupDistance) {
     enemyShip.blowUp();
    }
 }
  
  void die() {
    live = false;
    playRandomExplosionSound();
    missileExplosion.start();
 }
 
  
  boolean isLive () {
    return live;
  }
  
  void setEnemyShip(Ship enemy) {
    enemyShip = enemy;
  }
  
  void update() {
    if (gamePaused() || !live) {
     return; 
    }
    if (enemyShip.getShipState() != 0) {
      die();
    }
    
    accel.add(calculateSunsGravityForce(pos,mass));
    accel.add(calculatePlanetsGravityForce(pos,mass));
   
    PVector enemyShipDirection = calculateEnemyShipDirection();
    PVector currentPos = new PVector();
    // save the current position so after we move we can align a ship along a vector
    // between the current position and the newly calculated position.
    currentPos.set(pos); 
    
    accel.add(enemyShipDirection); // try to track enemy ship
    vel.add(accel);
    vel.limit(maxSpeed);
    pos.add(vel);

    // align the missile along its path
    PVector shipMotionVec = new PVector();
    shipMotionVec.set(pos.x,pos.y);
    shipMotionVec.sub(currentPos);
    shipMotionVec.normalize();
    rot = degrees(atan2(shipMotionVec.y, shipMotionVec.x)) - 90;
        
    if (insideSun(pos) || thePlanet.collides(pos)) {
       die();
    }
    wrapAroundEdges(pos);

    ttl -= 1;
    if (ttl == 0) {
      die();
      checkIfShouldKillEnemyShip();
    }
    accel.mult(0);
  }
  
  void render() {
    missileExplosion.render(); // if an explosion is live, render it
    if (live) {
      //println("Missile away at : ", pos);
      fill(0);
      stroke(parent.shipColor);
      pushMatrix();
      translate(pos.x,pos.y);
      rotate(radians(rot));
      
      // main body of missile
      beginShape();
      vertex(-halfMissileWidth,  -halfMissileHeight);
      vertex(-halfMissileWidth,  halfMissileHeight);
      vertex(0, halfMissileHeight * 1.4);
      vertex(halfMissileWidth, halfMissileHeight);
      vertex(halfMissileWidth, -halfMissileHeight);
      vertex(0, -halfMissileHeight * 0.7);
      endShape(CLOSE);
      // fin1
      line(-halfMissileWidth, -halfMissileHeight, -halfMissileWidth * 1.5, -halfMissileHeight * 1.4);
      line(-halfMissileWidth * 1.5, -halfMissileHeight * 1.4,-halfMissileWidth, -halfMissileHeight * 0.85);
      // fin2
      line(halfMissileWidth, -halfMissileHeight, halfMissileWidth * 1.5, -halfMissileHeight * 1.4);
      line(halfMissileWidth * 1.5, -halfMissileHeight * 1.4,halfMissileWidth, -halfMissileHeight * 0.85);
     
     float flicker = random(0,10) / 10 + 1; 
      fill(255 * flicker,255 * flicker,0);
      stroke(255 * flicker,255 * flicker,0);
      beginShape();
      vertex(-halfMissileWidth / 6, -halfMissileHeight * 1.1);
      vertex(0, -halfMissileHeight * 1.6 * flicker);
      vertex(-halfMissileWidth / 6, -halfMissileHeight * 1.1);
      vertex(0, -halfMissileHeight * 1.4);
      endShape(CLOSE);
    
     
      popMatrix();
    }    
  }
  
  
}
