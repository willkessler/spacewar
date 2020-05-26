// X player 1 fires with 'E' key
// X player 2 fires with 'U' key
// X while missile in flight, cannot fire bullets
// X fire missile
// X hit sun and dies
// X gravitational pull applies
// track ship
// collide with ship
// missile explosion
// orientation must track its velocity vector
// run out of fuel becuase missile is stupid
// collisions with other missiles
// missile explodes near ship, it blows up

class Missile {

  PVector pos, vel, accel;
  float fuel;
  boolean live;
  int ttl;
  int lifeSpan = 500;
  float rot; // where the missile is facing
  Ship parent;
  Ship enemyShip;
  float enemyRange = windowSize;
  float enemyAngleTolerance = 360;
  float mass = .3;
  float missileLaunchForce = 1; 
  float maxSpeed = 3;
  
  Missile(Ship ship) {
    fuel = 1000;
    pos = new PVector(0,0);
    vel = new PVector(0,0);
    accel = new PVector(0,0);
    parent = ship;
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
       adjustment.mult(.05);
       // Pass the adjustment direction back in its z value so we can rotate the missile
       adjustment.z = crossProduct.z <= 0 ? -1 : 1;
       println("  Adjustment vector:", adjustment);
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
    //accel.add(calculateGravityForce(pos,mass));
    PVector enemyShipDirection = calculateEnemyShipDirection();
    // we stuff the angle diff into the z value so we can return it in a single call to this function, but
    // we use it to adjust the ship's orientation
    PVector zeroAngleVec = new PVector(1,0);
    rot = angleBetweenVectors(vel, zeroAngleVec);
    //rot *= enemyShipDirection.z;
    enemyShipDirection.z = 0;
    
    accel.add(enemyShipDirection); // try to track enemy ship
    vel.add(accel);
    vel.limit(maxSpeed);
    pos.add(vel);
    if (insideSun(pos)) {
       live = false;
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
      fill(parent.shipColor);
      stroke(parent.shipColor);
      pushMatrix();
      translate(pos.x,pos.y);
      rotate(radians(rot));
      rect(-2,-15,4,30);
      popMatrix();
    }    
  }
  
  
}
