// shoots when aming at player
// runs a randomizer every time its too far away for a bullet, it tries to fire a missile
// it trys to avoid the sun, and the planet 
// in the begining of the game, you can choose between 2-players and vs the AI
// if only thrusts when it needs to get near the player or away from the planet or sun
// makes sure to not overheat but sometimes messes up like a human

class AI {
  Ship parentShip, otherShip;
  // constructor
  AI () {
    println("Created an AI");
  }

  void assignShips(Ship pShip, Ship oShip) {
    parentShip = pShip;
    otherShip = oShip;
  }
  
  void pointAtOtherShip() {
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
    println("directionVector:", directionVector, "rotVector:", rotVec,  "angle", rotDiff);
    if (abs(rotDiff) > 10) {
      if (rotDiff < 0) {
        parentShip.startTurning(-turnSign);
      } else {
        parentShip.startTurning(turnSign);
      }
    } else {
      parentShip.stopTurning();
    }
    
  }
  
  
  void fireAtOtherShip() {
    float timeToFire = random(0,1);
    PVector p1, p2;
    p1 = parentShip.getShipPos();
    p2 = otherShip.getShipPos();
    float distToOtherShip = p1.dist(p2);
    if (distToOtherShip < windowSize / 4) {
      if (timeToFire < 0.25) {
        parentShip.fireBullet();
      }
    }
  }
  
  // control the ship
  void control() {
    
    pointAtOtherShip();
    fireAtOtherShip();
  }
  
}
