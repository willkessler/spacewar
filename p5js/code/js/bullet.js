class Bullet {
  constructor(parent) {
    //acceleration is only due to the sun's gravity affecting the bullets
    this.p5 = parent.p5;
    this.spacewar = parent.spacewar;
    this.live = false; // if false, this bullet is not active and can be replaced with a new ("live") bullet.
    this.ttl = this.lifeSpan;
    this.pos = this.p5.createVector (0,0,0);
    this.vel = this.p5.createVector (0,0,0);
    this.accel = this.p5.createVector (0,0,0);
    this.bulletColor = parent.getShipColor();

    this.bulletSize = 5;
    this.lifeSpan = 200; // drawing cycles before bullet disappears
    this.mass = .4;
    this.gunForceMag = 1.5; 
    this.shipBulletCollisionTolerance = parent.shipWidth / 2;
    this.bulletBulletCollisionTolerance = parent.shipWidth / 4;
  }
  
  isLive = () => {
    return this.live;
  }

  die = () => {
    this.live = false;
  }

  collides = (objectPos, collisionTolerance) => {
    const bulletDistance = this.pos.dist(objectPos);
    return (bulletDistance < collisionTolerance);
  }
  
  fire = (initialPos, initialVel, shipRot) => {
    const damper = 0.2; // how much weight we give to the actual ship's movement vs firing direction
    this.live = true;
    //println("bullet fire:", initialPos.x, initialVel);
    this.pos.set(initialPos);
    const shipRotRad = this.p5.radians(shipRot);
    const fireVelocity = this.p5.createVector(this.p5.sin(shipRotRad), -this.p5.cos(shipRotRad));
    fireVelocity.normalize();
    this.pos.add(fireVelocity.x * shipHeight / 2, fireVelocity.y * shipHeight / 2);
    fireVelocity.mult(this.gunForceMag);
    const bulletVel = this.p5.createVector(initialVel.x * damper, initialVel.y * damper);
    bulletVel.add(fireVelocity);
    this.vel.set(bulletVel);
    this.ttl = this.lifeSpan;
    this.spacewar.gunshot.play();
  }
  
  update = () => {
    this.accel.add(calculateSunsGravityForce(this.pos,this.mass));
    this.accel.add(calculatePlanetsGravityForce(this.pos,this.mass));
    this.vel.add(this.accel);
    this.pos.add(this.vel);
    if (this.spacewar.insideSun(this.pos) || this.spacewar.thePlanet.collides(this.pos)) {
      this.die();
    }
    this.spacewar.wrapAroundEdges(this.pos);

    this.ttl -= 1;
    if (this.ttl == 0) {
      this.ttl = this.lifeSpan;
      this.live = false; // bullet has "died"
    }
    this.accel.mult(0);
  }
  
  render = () => {
    if (this.live) {
      this.p5.fill(this.bulletColor);
      this.p5.stroke(this.bulletColor);
      this.p5.push();
      this.p5.translate(this.pos.x,this.pos.y);
      this.p5.ellipse(-this.bulletSize / 2, -this.bulletSize / 2, this.bulletSize, this.bulletSize);
      this.p5.pop();
    }
  }
}
