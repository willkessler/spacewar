class AI {

  constructor(p5, spacewar, windowSize) {
    this.p5 = p5;
    this.spacewar = spacewar;
    this.windowSize = windowSize;

    this.activateThrust = false;
    this.activateBulletFire = false;
    this.activateMissile = false;
    this.minThrustTime = 150; // we will never apply thrust for less than this many draw cycles
    this.thrustTimeCountdown = 0;
    this.minMissileTime = 500;
    this.missileTimeCountdown = 0; // we won't fire missiles too soon after last missile
    this.otherShipInGunsight = false;
    this.turnAmount = 0;
    this.sunPos = this.p5.createVector(this.windowSize/2, this.windowSize/2);
  }

  assignShips = (pShip, oShip) => {
    this.parentShip = pShip;
    this.otherShip = oShip;
  }
  
  attackOtherShip = () => {
    const p1 = this.parentShip.getShipPos();
    const p2 = this.otherShip.getShipPos();
    let directionVector = this.p5.createVector(0,0);
    directionVector.set(p2);
    directionVector.sub(p1);
    directionVector.normalize();
    const rot = parentShip.getShipRot();
    const rotVec = this.p5.createVector(0,0);
    const radRot = this.p5.radians(rot);
    rotVec.set(cos(radRot), sin(radRot));
    const rotDiff = this.spacewar.angleBetweenVectors(directionVector,rotVec) ;
    const crossProduct = rotVec.cross(directionVector);
    const turnSign = crossProduct.z < 0 ? -1 : 1;
    //println("directionVector:", directionVector, "rotVector:", rotVec,  "angle", rotDiff);
    if (abs(rotDiff) > 10) {
      if (rotDiff < 0) {
        this.turnAmount = -turnSign;
      } else {
        this.turnAmount = turnSign;
      }
      this.otherShipInGunsight = false;
    } else {
      this.tryToThrust(); // try to go towards the other ship
      this.otherShipInGunsight = true; // 
    }
    
  }
  
  inFiringRange = (likelihood, minAllowedDistance, conditionType) {
    const timeToFire = this.p5.random(0,1);
    const p1 = this.parentShip.getShipPos();
    const p2 = this.otherShip.getShipPos();
    const distToOtherShip = p1.dist(p2);
    let distCheck;
    if (conditionType == "farEnoughAway") {
      distCheck = (distToOtherShip >= this.minAllowedDistance);
    } else {
      distCheck = (distToOtherShip < this.windowSize / 4);
    }
    return distCheck && (timeToFire < likelihood) && this.otherShipInGunsight;
  }
  
  tryToThrust = () => {
    if (this.thrustTimeCountdown == 0) {
      this.activateThrust = true; // only activate thrust when not already turned on
      this.thrustTimeCountdown = this.minThrustTime;
    }
  }
  
  // If falling towards the sun (vel towards sun) and within range of the sun, turn perpendicular to the sun and apply thrust
  avoidGravityWell = (gPos) => {
    const velVec = this.parentShip.getShipVel();
    const vecToGravityWell = this.p5.createVector(gPos.x, gPos.y);
    this.pos = this.parentShip.getShipPos();
    vecToGravityWell.sub(pos);
    vecToGravityWell.normalize();
    const rotDiff = this.spacewar.angleBetweenVectors(vecToGravityWell,velVec) ;
    const crossProduct = velVec.cross(vecToGravityWell);
    const turnSign = crossProduct.z < 0 ? -1 : 1;
    if (abs(rotDiff) < 10) {
      if (rotDiff < 0) {
        this.turnAmount = -turnSign;
      } else {
        this.turnAmount = turnSign;
      }
    } else {
      this.tryToThrust(); // try to go away from gravityWell
    }
  }
  
  // not coded yet
  avoidPlanet = () => {
  }
  
  // not coded yet
  avoidMissile = () => {
  }
  
  avoidOverheating = () => {
    const stupidityFactor = this.p5.random(0,1); // like a human, sometimes it (randomly?) ignores the overheating indicator!
    if (this.parentShip.engineGettingTooHot() && stupidityFactor > 0.95) {
      this.activateThrust = false; // deactivate the thrust if we're close to overheating
      this.parentShip.cancelThrust();
    }
  }
  
  // Depending on all decisions made up to this point, do the final control actions on the ship
  takeAction = () => {
    
    if (abs(this.turnAmount) > 0) { 
      this.parentShip.startTurning(this.turnAmount);
      this.turnAmount = 0;
    } else {
      this.parentShip.stopTurning();
    }
    
    if (this.thrustTimeCountdown > 0) {
      if (this.activateThrust) {
        this.parentShip.applyThrust();
      }
      --this.thrustTimeCountdown;
    } else {
      this.parentShip.cancelThrust();
      this.activateThrust = false;
    }
    
    if (this.activateBulletFire) {
      this.parentShip.fireBullet();
    }
    this.activateBulletFire = false;
    
    if (this.missileTimeCountdown > 0) {
      this.missileTimeCountdown--; // don't fire another missile too soon
    } else if (this.activateMissile) {
        this.parentShip.fireMissile();
        this.missileTimeCountdown = minMissileTime;
    }
    this.activateMissile = false;
 }
  
  // control the ship
  control = () => {
    this.attackOtherShip();    
    this.avoidMissile();
    this.avoidOverheating();
    this.activateBulletFire = this.inFiringRange(0.25,25, "closeEnough");
    this.activateMissile = this.inFiringRange(0.01, this.windowSize / 2, "farEnoughAway");
    
    this.takeAction();
  }
  
}
