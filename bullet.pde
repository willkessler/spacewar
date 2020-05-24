class Bullet {
  PVector pos, vel, accel; //acceleration is only due to the sun's gravity affecting the bullets
  float bulletSize = 5;
  int lifeSpan = 200; // drawing cycles before bullet disappears
  int ttl; // how much time is left on a bullet's lifecycle
  float mass = .4;
  float gunForceMag = 1.5; 
  boolean live; // if false, this bullet is not active and can be replaced with a new ("live") bullet.
  color bulletColor;
  float collisionTolerance = shipWidth / 2;
  
  Bullet(color bulletCol) {
    live = false;
    ttl = lifeSpan;
    pos = new PVector (0,0,0);
    vel = new PVector (0,0,0);
    accel = new PVector (0,0,0);
    bulletColor = bulletCol;
  }
  
  boolean isLive() {
    return live;
  }

  void die() {
    live = false;
  }

  boolean collides (PVector objectPos) {
    float bulletDistance = pos.dist(objectPos);
    return (bulletDistance < collisionTolerance);
  }
  
  void fire(PVector initialPos, PVector initialVel, float shipRot) {
    float damper = 0.2; // how much weight we give to the actual ship's movement vs firing direction
    live = true;
    //println("bullet fire:", initialPos.x, initialVel);
    pos.set(initialPos);
    float shipRotRad = radians(shipRot);
    PVector fireVelocity = new PVector(sin(shipRotRad), -cos(shipRotRad));
    fireVelocity.normalize();
    pos.add(fireVelocity.x * shipHeight / 2, fireVelocity.y * shipHeight / 2);
    fireVelocity.mult(gunForceMag);
    PVector bulletVel = new PVector(initialVel.x * damper, initialVel.y * damper);
    bulletVel.add(fireVelocity);
    vel.set(bulletVel);
    ttl = lifeSpan;
    gunshot.play();
  }
  
  void update() {
   accel.add(calculateGravityForce(pos,mass));
   vel.add(accel);
    pos.add(vel);
    if (insideSun(pos)) {
      live = false;
    }
    wrapAroundEdges(pos);

    ttl -= 1;
    if (ttl == 0) {
      ttl = lifeSpan;
      live = false; // bullet has "died"
    }
    accel.mult(0);
  }
  
  void render() {
    if (live) {
      fill(bulletColor);
      stroke(bulletColor);
      pushMatrix();
      translate(pos.x,pos.y);
      ellipse(-bulletSize / 2, -bulletSize / 2, bulletSize, bulletSize);
      popMatrix();
    }
  }
}
