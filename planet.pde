// orbiting planet gets in the way of ships, missiles, etc
//no gravity
class Planet {

  PVector pos, vel,accel;
  float radius = 25;
  color planetColor;
  float mass = 0.4;
  float maxSpeed = 1;
  float innerSpin = 1, innerSpinInc = 0.1;
  float collisionTolerance = radius * .8;
    
  Planet() {
    planetColor = color(40,40,255);
    float orbitDistance = random(150,200);
    float orbitalVelocity = random(-110,-85);
    pos = new PVector(windowSize /2 + orbitDistance, windowSize/2);
    vel = new PVector(0,orbitalVelocity);
    accel = new PVector(0,0);
  }
  
  boolean collides (PVector checkPos) {
    float planetDistance = pos.dist(checkPos);
    return (planetDistance < collisionTolerance);
 }
  
  void update() {
    // apply sun's gravity
    accel.add(calculateGravityForce(pos,mass));
    vel.add(accel);
    vel.limit(maxSpeed);
    pos.add(vel);
    accel.mult(0);
  }
  
  void render() {
    pushMatrix();
    translate(pos.x,pos.y);
    fill(planetColor);
    noStroke();
    ellipse(0,0,radius,radius);
    stroke(40,255,40);
    noFill();
    ellipse(0,0,radius * innerSpin / 10, radius);
    ellipse(0,0,radius * innerSpin / 10 - 10, radius);
    //noStroke();
    //stroke(255);
    //sphere(radius);
    popMatrix();
    
    if (!gamePaused){
    
      innerSpin = innerSpin + innerSpinInc;
      if (innerSpin > 10) {
        innerSpinInc = -innerSpinInc;
        innerSpin = 10;
      } else if (innerSpin < 1) {
        innerSpinInc = -innerSpinInc;
        innerSpin = 1;
      }    
    }
  }
}
