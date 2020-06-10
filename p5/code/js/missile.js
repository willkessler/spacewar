class Missile {
  constructor(p5, spacewar, ship, windowSize) {
    this.p5 = p5;
    this.spacewar = spacewar;
    this.windowSize = windowSize;

    this.lifeSpan = 500;
    this.enemyRange = this.windowSize; // can track you over entire screen right now
    this.enemyAngleTolerance = 360;
    this.mass = .5;
    this.missileLaunchForce = 1;
    this.missileSmartFactor = 0.045;
    this.maxSpeed = 3;
    this.halfMissileWidth = this.spacewar.halfShipWidth * 0.3;
    this.halfMissileHeight = this.spacewar.halfShipHeight * .8;
    this.fuel = 1000;
    this.pos = this.p5.createVector(0,0);
    this.vel = this.p5.createVector(0,0);
    this.accel = this.p5.createVector(0,0);
    this.parent = ship;
    this.missileExplosion = new MissileExplosion(p5, spacewar, this);
  }

  getMissilePos = () => {
    return this.pos;
  }

  getMissileVel = () => {
    return this.vel;
  }

  getMissileColor = () => {
    return this.parent.shipColor;
  }

  // calculate if the enemy ship is near enough to "see" and in front of the missile. Return a zero vector if not.
  // otherwise return a vector indicating a velocity change to track the enemy
  calculateEnemyShipDirection = () => {
    const adjustment = this.p5.createVector(0,0);
    const missileToShip = this.p5.createVector(0,0);
    missileToShip.set(this.enemyShip.pos);
    missileToShip.sub(this.pos);
    const distanceToEnemy = missileToShip.mag();
    if (distanceToEnemy > this.enemyRange) { // have to be close to it, first off
      return adjustment;
    }
    missileToShip.normalize();
    const angleToEnemy = this.spacewar.angleBetweenVectors(this.vel, missileToShip);

   // println("In range of enemy ship:", distanceToEnemy, "angle:", angleToEnemy);
    if (angleToEnemy <= this.enemyAngleTolerance) { // limited view in front of the missile
      const crossProduct = this.vel.cross(missileToShip);
      // calculate turn based on how large the angle is
      const adjustmentAngle = angleToEnemy * crossProduct.z;
      const adjustmentAngleRadians = this.p5.radians(adjustmentAngle);
      const ca = this.p5.cos(adjustmentAngleRadians);
      const sa = this.p5.sin(adjustmentAngleRadians);
      adjustment.set(ca * this.vel.x - sa * this.vel.y,
                     sa * this.vel.x + ca * this.vel.y);
      adjustment.normalize();
      adjustment.mult(this.missileSmartFactor);
       // println("  Adjustment vector:", adjustment);
    }
    return adjustment;
  }

  fire = () => {
    if (this.live) {
      return; // cannot fire if another missile in flight
    }

    const damper = 0.2; // how much weight we give to the actual ship's movement vs firing direction
    this.pos.set(this.parent.pos);
    // almost same code in bullet, so needs refactor
    const shipRotRad = this.p5.radians(this.parent.rot);
    const fireVelocity = this.p5.createVector(this.p5.sin(shipRotRad), -this.p5.cos(shipRotRad));
    fireVelocity.normalize();
    this.pos.add(fireVelocity.x * this.spacewar.shipHeight / 2, fireVelocity.y * this.spacewar.shipHeight / 2);
    fireVelocity.mult(this.missileLaunchForce);
    const missileVel = this.p5.createVector(this.parent.vel.x * damper, this.parent.vel.y * damper);
    missileVel.add(fireVelocity);
    this.vel.set(missileVel);
    this.rot = this.parent.rot;
    this.ttl = this.lifeSpan;
    this.live = true;
    this.spacewar.missileShot.play();
  }

  checkIfShouldKillEnemyShip = () => {
    let missileToShip = this.p5.createVector(0,0);
    missileToShip.set(this.enemyShip.pos);
    missileToShip.sub(this.pos);
    const distanceFromEnemyShip = missileToShip.mag();
    const blowupDistance = 50;
    if (distanceFromEnemyShip < blowupDistance) {
      this.enemyShip.blowUp();
    }
 }

  die = () => {
    this.live = false;
    this.spacewar.playRandomExplosionSound();
    this.missileExplosion.start();
 }


  isLive = () => {
    return this.live;
  }

  setEnemyShip = (enemy) => {
    this.enemyShip = enemy;
  }

  update = () => {
    if (this.spacewar.gamePaused() || !this.live) {
     return;
    }
    if (this.enemyShip.getShipState() != 0) {
      this.die();
    }

    this.accel.add(this.spacewar.calculateSunsGravityForce(this.pos, this.mass));
    this.accel.add(this.spacewar.calculatePlanetsGravityForce(this.pos, this.mass));

    const enemyShipDirection = this.calculateEnemyShipDirection();
    const currentPos = this.p5.createVector(0,0);
    // save the current position so after we move we can align a ship along a vector
    // between the current position and the newly calculated position.
    currentPos.set(this.pos);

    this.accel.add(enemyShipDirection); // try to track enemy ship
    this.vel.add(this.accel);
    this.vel.limit(this.maxSpeed);
    this.pos.add(this.vel);

    // align the missile along its path
    const shipMotionVec = this.p5.createVector(0,0);
    shipMotionVec.set(this.pos.x,this.pos.y);
    shipMotionVec.sub(currentPos);
    shipMotionVec.normalize();
    this.rot = this.p5.degrees(this.p5.atan2(shipMotionVec.y, shipMotionVec.x)) - 90;

    if (this.spacewar.insideSun(this.pos) || this.spacewar.thePlanet.collides(this.pos)) {
      this.die();
    }
    this.spacewar.wrapAroundEdges(this.pos);

    this.ttl -= 1;
    if (this.ttl == 0) {
      this.die();
      this.checkIfShouldKillEnemyShip();
    }
    this.accel.mult(0);
  }

  render = () => {
    this.missileExplosion.render(); // if an explosion is live, render it
    if (this.live) {
      //println("Missile away at : ", pos);
      this.p5.fill(0);
      this.p5.stroke(this.parent.shipColor);
      this.p5.push();
      this.p5.translate(this.pos.x,this.pos.y);
      this.p5.rotate(this.p5.radians(this.rot));

      // main body of missile
      this.p5.beginShape();
      this.p5.vertex(-this.halfMissileWidth,  -this.halfMissileHeight);
      this.p5.vertex(-this.halfMissileWidth,  this.halfMissileHeight);
      this.p5.vertex(0, this.halfMissileHeight * 1.4);
      this.p5.vertex(this.halfMissileWidth, this.halfMissileHeight);
      this.p5.vertex(this.halfMissileWidth, -this.halfMissileHeight);
      this.p5.vertex(0, -this.halfMissileHeight * 0.7);
      this.p5.endShape(this.p5.CLOSE);

      // Missile fin 1
      this.p5.line(-this.halfMissileWidth, -this.halfMissileHeight, -this.halfMissileWidth * 1.5, -this.halfMissileHeight * 1.4);
      this.p5.line(-this.halfMissileWidth * 1.5, -this.halfMissileHeight * 1.4,-this.halfMissileWidth, -this.halfMissileHeight * 0.85);
      // Missile fin 2
      this.p5.line(this.halfMissileWidth, -this.halfMissileHeight, this.halfMissileWidth * 1.5, -this.halfMissileHeight * 1.4);
      this.p5.line(this.halfMissileWidth * 1.5, -this.halfMissileHeight * 1.4,this.halfMissileWidth, -this.halfMissileHeight * 0.85);

      const flicker = this.p5.random(0,10) / 10 + 1;
      this.p5.fill(255 * flicker,255 * flicker,0);
      this.p5.stroke(255 * flicker,255 * flicker,0);
      this.p5.beginShape();
      this.p5.vertex(-this.halfMissileWidth / 6, -this.halfMissileHeight * 1.1);
      this.p5.vertex(0, -this.halfMissileHeight * 1.6 * flicker);
      this.p5.vertex(-this.halfMissileWidth / 6, -this.halfMissileHeight * 1.1);
      this.p5.vertex(0, -this.halfMissileHeight * 1.4);
      this.p5.endShape(this.p5.CLOSE);


      this.p5.pop();
    }
  }


}
