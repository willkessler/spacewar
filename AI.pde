// X shoots when aiming at player
// runs a randomizer every time its too far away for a bullet, it tries to fire a missile
// it trys to avoid the sun, and the planet 
// in the begining of the game, you can choose between 2-players and vs the AI
// it only thrusts when it needs to get near the player or away from the planet or sun
// makes sure to not overheat but sometimes messes up like a human

class AI {
  Ship parentShip, otherShip;
  boolean activateThrust;
  boolean activateBulletFire;
  boolean activateMissile;
  int minThrustTime = 150; // we will never apply thrust for less than this many draw cycles
  int thrustTimeCountdown = 0;
  int minMissileTime = 500;
  int missileTimeCountdown = 0; // we won't fire missiles too soon after last missile
  boolean otherShipInGunsight = false;
  
  // constructor
  AI () {
    println("Created the AI.");
    activateThrust = false;
    activateBulletFire = false;
    activateMissile = false;
  }

  void assignShips(Ship pShip, Ship oShip) {
    parentShip = pShip;
    otherShip = oShip;
  }
  
  void attackOtherShip() {
    PVector p1, p2;
    p1 = parentShip.getShipPos();
    p2 = otherShip.getShipPos();
    PVector directionVector = new PVector(0,0);
    directionVector.set(p2);
    directionVector.sub(p1);
    directionVector.normalize();
    float rot = parentShip.getShipRot();
    PVector rotVec = new PVector();
    float radRot = radians(rot);
    rotVec.set(cos(radRot), sin(radRot));
    float rotDiff = angleBetweenVectors(directionVector,rotVec) ;
    PVector crossProduct = rotVec.cross(directionVector);
    float turnSign = crossProduct.z < 0 ? -1 : 1;
    //println("directionVector:", directionVector, "rotVector:", rotVec,  "angle", rotDiff);
    if (abs(rotDiff) > 10) {
      if (rotDiff < 0) {
        parentShip.startTurning(-turnSign);
      } else {
        parentShip.startTurning(turnSign);
      }
      otherShipInGunsight = false;
    } else {
      parentShip.stopTurning();
      tryToThrust(); // try to go towards the other ship
      otherShipInGunsight = true; // 
    }
    
  }
  
  boolean inFiringRange(float likelihood) {
    float timeToFire = random(0,1);
    PVector p1, p2;
    p1 = parentShip.getShipPos();
    p2 = otherShip.getShipPos();
    float distToOtherShip = p1.dist(p2);
    return (distToOtherShip < windowSize / 4) && (timeToFire < likelihood) && otherShipInGunsight;
  }

  void fireMissileAtOtherShip() {
    float timeToFire = random(0,1);
    PVector p1, p2;
    p1 = parentShip.getShipPos();
    p2 = otherShip.getShipPos();
    float distToOtherShip = p1.dist(p2);
    activateMissile |= (distToOtherShip < windowSize / 4) && (timeToFire < 0.01) && otherShipInGunsight;
  }
  
  void tryToThrust() {
    if (thrustTimeCountdown == 0) {
      activateThrust = true; // only activate thrust when not already turned on
      thrustTimeCountdown = minThrustTime;
    }
  }
  
  // If falling towards the sun (vel towards sun) and within range of the sun, turn perpendicular to the sun and apply thrust
  void avoidSun() {
    float timeToThrust = random(0,1);
    if (timeToThrust < 0.01) {
      //tryToThrust();
    } 
  }
  
  void avoidPlanet() {
  }
  
  void avoidMissile() {
  }
  
  void avoidOverheating() {
    float stupidityFactor = random(0,1); // like a human, sometimes it (randomly?) ignores the overheating indicator!
    if (parentShip.engineGettingTooHot() && stupidityFactor > 0.95) {
      activateThrust = false; // deactivate the thrust if we're close to overheating
      parentShip.cancelThrust();
    }
  }
  
  // Depending on all decisions made up to this point, do the final control actions on the ship
  void takeAction() {
    if (thrustTimeCountdown > 0) {
      if (activateThrust) {
        parentShip.applyThrust();
      }
      --thrustTimeCountdown;
    } else {
      parentShip.cancelThrust();
      activateThrust = false;
    }
    
    if (activateBulletFire) {
      parentShip.fireBullet();
    }
    activateBulletFire = false;
    
    if (missileTimeCountdown > 0) {
      missileTimeCountdown--; // don't fire another missile too soon
    } else if (activateMissile) {
        parentShip.fireMissile();
        missileTimeCountdown = minMissileTime;
    }
    activateMissile = false;
 }
  
  // control the ship
  void control() {
    avoidSun();
    avoidPlanet();
    avoidMissile();
    attackOtherShip();    
    avoidOverheating();
    activateBulletFire = inFiringRange(0.25);
    activateMissile = inFiringRange(0.05);
    
    takeAction();
  }
  
}
