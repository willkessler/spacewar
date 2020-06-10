class MissileExplosion {
  constructor(p5, spacewar, missile) {
    this.p5 = p5;
    this.spacewar = spacewar;
    this.parent = missile;
    this.rotInc = this.p5.random(2,5);
    this.explosionColor = this.parent.getMissileColor();
    this.live = false;
    this.pos = this.p5.createVector(0,0);
    this.vel = this.p5.createVector(0,0);
    this.numPieces = 5;
    this.piecesX1 = [];
    this.piecesX2 = [];
    this.piecesRot = [];
    this.piecesTVec = [];
    this.lifeSpan = 100;
    let rot, pieceRot;
    const pieceSize = 15;
    for (let i = 0; i < this.numPieces; ++i) {
      this.piecesRot[i] = this.p5.random(0,359);
      pieceRot = this.p5.random(0,359);
      rot = this.p5.radians(pieceRot);
      this.piecesTVec[i] = this.p5.createVector(this.p5.cos(rot),this.p5.sin(rot));
      this.piecesX1[i] = this.p5.random(0, pieceSize) * -1; // left edge of line fragment explosion piece
      this.piecesX2[i] = this.p5.random(0.2, pieceSize);       // right edge of line fragment explosion piece
    }
  }

  start = () => {
    this.ttl = lifeSpan;
    this.live = true;
    const missilePos = this.parent.getMissilePos();
    const missileVel = this.parent.getMissileVel();
    //println("setting missile ex pos", missilePos);
    this.pos.set(missilePos);
    //println("setting missile ex vel");
    this.vel.set(missileVel);
    this.vel.mult(0.5);
    this.tVecMultiplier = 1.0;
  }
  
  checkStop = () => {
    if (this.ttl == 0) {
      this.live = false;
    }
  }
  
  update = () => {
    if (this.live) {
       // now decrease ttl
      this.ttl--;
      this.checkStop();
    }
    for (let i = 0; i < this.numPieces; ++i) {
      this.piecesRot[i] += this.rotInc;
    }
    this.tVecMultiplier += 0.1;
    this.pos.add(this.vel);
  }

  render = () => {
    this.update();
    if (this.live) {
      let transVec = this.p5.createVector(0,0);
      // draw the explosion!
      this.p5.stroke(explosionColor);
      this.p5.fill(255);
      for (let i = 0; i < this.numPieces; ++i) {
        this.p5.push();
        transVec.set(0,0);
        transVec.add(this.piecesTVec[i]);
        transVec.mult(this.tVecMultiplier);
        transVec.add(this.pos);
        //println("piece ", i, "rot:", piecesRot[i], "tranlsation:", transVec);
        this.p5.translate(transVec.x, transVec.y);
        this.p5.rotate(this.p5.radians(this.piecesRot[i]));
        this.p5.line(this.piecesX1[0],0, this.piecesX2[1], 0);
        this.p5.pop();
      }
    }
  }
  
}
