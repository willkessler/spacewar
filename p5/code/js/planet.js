class Planet {
  constructor(p5, spacewar, windowSize) {
    this.p5 = p5;
    this.spacewar = spacewar;
    this.planetColor = this.p5.color(40,40,255);
    this.orbitDistance = this.p5.random(150,200);
    this.orbitalVelocity = this.p5.random(-110,-85);
    this.initialAngle = -55;
    this.initialAngleRadians = this.p5.radians(this.initialAngle);
    this.initialVelAngleRadians = this.p5.radians(this.initialAngle - 90);
    this.pos = this.p5.createVector(windowSize /2 + this.p5.cos(this.initialAngleRadians) * this.orbitDistance, windowSize/2 + this.p5.sin(this.initialAngleRadians) * this.orbitDistance);
    this.vel = this.p5.createVector(this.p5.cos(this.initialVelAngleRadians) * this.orbitalVelocity, this.p5.sin(this.initialVelAngleRadians) * this.orbitalVelocity);
    this.accel = this.p5.createVector(0,0);
    this.radius = 25;
    this.mass = 0.4;
    this.maxSpeed = 1;
    this.innerSpin = 1;
    this.innerSpinInc = 0.1;
    this.collisionTolerance = this.radius * 0.8;
  }

  getPlanetPos = () => {
    return this.pos;
  }
  
  collides = (checkPos) => {
    const planetDistance = this.pos.dist(checkPos);
    return (planetDistance < this.collisionTolerance);
  }
  
  update = () => {
    // apply sun's gravity
    this.accel.add(this.spacewar.calculateSunsGravityForce(this.pos,this.mass));
    this.vel.add(this.accel);
    this.vel.limit(this.maxSpeed);
    this.pos.add(this.vel);
    this.accel.mult(0);
  }
  
  render = () => {
    this.p5.push();
    this.p5.translate(this.pos.x, this.pos.y);
    this.p5.fill(this.planetColor);
    this.p5.noStroke();
    this.p5.ellipse(0,0, this.radius, this.radius);
    this.p5.stroke(40,255,40);
    this.p5.noFill();
    this.p5.ellipse(0,0, this.radius * this.innerSpin / 10, this.radius);
    this.p5.ellipse(0,0, this.radius * this.innerSpin / 10 - 10, this.radius);
    this.p5.pop();
    
    if (!this.spacewar.gamePaused()){
    
      this.innerSpin = this.innerSpin + this.innerSpinInc;
      if (this.innerSpin > 10) {
        this.innerSpinInc = -1 * this.innerSpinInc;
        this.innerSpin = 10;
      } else if (this.innerSpin < 1) {
        this.innerSpinInc = -1 * this.innerSpinInc;
        this.innerSpin = 1;
      }    
    }
  }
}
