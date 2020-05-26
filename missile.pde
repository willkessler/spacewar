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
// thrust display on missiles
// missile explosion
// when missiles "die" play sound
// run out of fuel becuase missile is stupid
// collisions with other missiles
// missile explodes near ship, it blows up

class Missile {

  PVector pos, vel, accel;
  float fuel;
  boolean live;
  int ttl;
  int lifeSpan = 600;
  float rot; // where the missile is facing
  Ship parent;
  Ship enemyShip;
  float enemyRange = windowSize; // can track you over entire screen right now
  float enemyAngleTolerance = 360;
  float mass = .4;
  float missileLaunchForce = 1;
  float missileSmartFactor = 0.038;
  float maxSpeed = 3;
  float halfMissileWidth = halfShipWidth * 0.4;
  float halfMissileHeight = halfShipHeight * .8;

  
  Missile(Ship ship) {
    fuel = 1000;
    pos = new PVector(0,0);
    vel = new PVector(0,0);
    accel = new PVector(0,0);
    parent = ship;
  }
  
  PVector getMissilePos() {
    return pos;
  }
  
  // calculate if the enemy ship is near enough to "see" and in front of the missile. Return a zero vector is not.
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
  
  void die() {
    live = false;
    playRandomExplosionSound();
 }
  
  boolean isLive () {
    return live;
  }
  
  void setEnemyShip(Ship enemy) {
    enemyShip = enemy;
  }
  
  void update() {
    if (!live) {
      return;
    }
    if (enemyShip.getShipState() != 0) {
      die();
    }
    
    accel.add(calculateGravityForce(pos,mass));
    
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
        
    if (insideSun(pos)) {
       die();
    }
    wrapAroundEdges(pos);

    ttl -= 1;
    if (ttl == 0) {
      ttl = lifeSpan;
      live = false; // missile has "died"
    }
    accel.mult(0);
  }
  
  void render() {
    if (live) {
      //println("Missile away at : ", pos);
      fill(0);
      stroke(parent.shipColor);
      pushMatrix();
      translate(pos.x,pos.y);
      rotate(radians(rot));
      
      beginShape();
      vertex(-halfMissileWidth,  -halfMissileHeight);
      vertex(-halfMissileWidth,  halfMissileHeight);
      vertex(0, halfMissileHeight * 1.4);
      vertex(halfMissileWidth, halfMissileHeight);
      vertex(halfMissileWidth, -halfMissileHeight);
      vertex(0, -halfMissileHeight * 0.7);
      endShape(CLOSE);
      // rect(-2,-15,4,30);
      popMatrix();
    }    
  }
  
  
}
