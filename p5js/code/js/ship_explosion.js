class ShipExplosion {
  constructor(p5, spacewar, ship) {
    this.p5 = p5;
    this.ship = ship; // which ship owns this explosion
    this.spacewar = spacewar;
    this.pos = this.p5.createVector(0,0);
    this.vel = this.p5.createVector(0,0);
    this.rot = 0;
    this.live = false;
    this.ttl = 0;
    this.lifeSpan = 100;
    this.explosionColor = this.ship.shipColor;
    this.scaleGrowth = 1.04;

    this.partsRots = [];
    this.partsRotsIncs = [];
    this.shipLineCoords = [ -this.spacewar.halfShipWidth, this.spacewar.halfShipHeight, 
                             0, -this.spacewar.halfShipHeight,
                             0, -this.spacewar.halfShipHeight,
                             this.spacewar.halfShipWidth, this.spacewar.halfShipHeight,
                             this.spacewar.halfShipWidth, this.spacewar.halfShipHeight,
                             0, this.spacewar.halfShipHeight / 2,
                             0, this.spacewar.halfShipHeight / 2,
                             -this.spacewar.halfShipWidth,  this.spacewar.halfShipHeight,
                             -this.spacewar.halfShipWidth,  this.spacewar.halfShipHeight,
                             this.spacewar.halfShipWidth, this.spacewar.halfShipHeight ];
  }
  
  start = (ship) => {
   for (let i = 0; i < 4; ++i) {
     this.partsRots[i] = 0;
     this.partsRotsIncs[i] = parseInt(this.p5.random(4,7));
    }
    this.ttl = this.lifeSpan;
    this.live = true;
    this.pos.set(ship.pos);
    this.vel.set(ship.vel);
    this.vel.mult(0.5);
    this.explosionScale = 1.0;
  }
  
  checkStop = () => {
    if (this.ttl == 0) {
      this.live = false;
      this.ship.setShipState(0); // visible again
    }
  }
  
  cancel = () => {
    this.live = 0;
    this.ttl = 0;
  }
  
  update = () => {
    if (this.live) {
       // now decrease ttl
      this.ttl--;
      this.explosionScale *= this.scaleGrowth;
      this.checkStop();
    }
    this.pos.add(this.vel);
    this.rot++;
  }
  
  render = () => {
    this.update();
    if (this.live) {
      // draw the explosion!
      this.p5.push();

      this.p5.translate(this.pos.x,this.pos.y);
      this.p5.rotate(this.p5.radians(this.rot));
      this.p5.fill(0);
      this.p5.stroke(this.explosionColor);
      
      let expandVec = this.p5.createVector(1.0, 1.0);
      for (let j,i = 0; i < 4; ++i) {
        j = i * 4;
        this.p5.push();
        this.p5.rotate(this.p5.radians(this.partsRots[i]));
        expandVec.set(this.p5.cos(this.p5.radians(i * 45)), this.p5.sin(this.p5.radians(i*45)));
        expandVec.mult(this.explosionScale);
        this.p5.line(this.shipLineCoords[j] + expandVec.x, this.shipLineCoords[j+1] + expandVec.y, 
                     this.shipLineCoords[j+2] + expandVec.x, this.shipLineCoords[j+3] + expandVec.y);
        this.p5.pop();
        this.partsRots[i] += this.partsRotsIncs[i];
      }    

      this.p5.pop();
    }
  }
  
}
