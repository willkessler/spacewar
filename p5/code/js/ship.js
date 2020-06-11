class Ship {
  constructor (p5, spacewar, windowSize, id, x, y, sColor) {
    this.p5 = p5;
    this.windowSize = windowSize;
    this.spacewar = spacewar;
    this.maxSpeed = 5;
    this.friction = 0.9998; // even in outer space, you slow down! whaaaa?
    this.shipColor= sColor;
    this.shipId = id;
    this.score = 0;
    this.shipState = 0; // 0 == visible, 1 == in hyperspace (not drawn), 2 == exploding (not drawn), 3 == overheated
    this.shipStateTimeout = 0; // counter for how long ships stay in hyperspace (or are exploding)
    this.engineTemp = 0; // how hot your engine is getting. Don't go too high!
    this.numBullets = 5;
    this.mass = 1.0;
    this.tooHotEngineTemp = 550;
    this.thrustOn = false;
    this.engineHeatConstant = 3.5;
    this.bullets = [];
    this.hyperspaceTimeLimit = 500; // number of draw cycles before you can do another hyperspace
    this.hyperspaceCountdown = 0;
    this.totalLives = 5; // how many lives your ship gets before GAME OVER
    this.accel = this.p5.createVector(0,0);
    this.vel = this.p5.createVector(this.p5.random(-0.5, 0.5), this.p5.random(-0.5, 0.5));
    this.pos = this.p5.createVector(x,y);
    this.livesLeft = this.totalLives;
    this.shipWidth = 15;
    this.rot = 90;
    this.rotChange = 0;
    this.rotIncrement = 3;
    this.thrustOn = false;
    this.engineTemp = 0;
    this.accelFactor = 0.009;

    this.bullets = [];
    for (let i = 0; i < this.numBullets; ++i) {
      this.bullets[i] = new Bullet(this);
    }
    this.shipExplosion = new ShipExplosion(p5, spacewar, this);
    this.missile = new Missile(p5, spacewar, this, windowSize);

  }
 
// =-=-==-=-==-=-==-=-==-=-==-=-= UTILITY METHODS =-=-==-=-==-=-==-=-==-=-==-=-=

  getScore = () => {
    return this.score;
  }
  
  getShipState = () => {
    return this.shipState;
  }
  
  getShipPos = () => {
    return this.pos;
  }
  
  getShipVel = () => {
    return this.vel;
  }
  
  getShipRot = () => {
    return this.rot - 90; // because of the way the ships are rendered, the "actual" ship heading is off by 90 degrees so we compensate here
  }
  
  setShipState = (newShipState) => {
    this.shipState = newShipState;
  }
  
  setEnemyShip = (enemy) => {
    this.missile.setEnemyShip(enemy);
  }
  
  getEngineTemp = () => {
    return this.engineTemp;
  }
  
  getShipColor = () => {
    return this.shipColor;
  }
  
  getLivesLeft = () => {
    return this.livesLeft;
  }
    
  fireBullet = () => {
    if (this.missile.isLive() || this.spacewar.gamePaused() || this.spacewar.gameOver()) {
      return; // can't fire bullets while your missile is away! or the game is paused
    }

      for (let bullet of this.bullets) {
        if (!bullet.isLive()) {
          bullet.fire(this.pos,this.vel,this.rot);
          break;
        }
    }
  }
  
  fireMissile = () => {
    //println("Missile for ship " + shipId + " is away!");
    this.missile.fire();    
  }
  
  killMissile = () => {
    this.missile.die();
  }
  
  checkBulletsCollide = (otherShip) => {
    for (let bullet1 of this.bullets) {
      for (let bullet2 of otherShip.bullets) {
        if (bullet1.isLive() && bullet2.isLive()) {
           if (bullet1.collides(bullet2.pos, bullet1.bulletBulletCollisionTolerance)) {
             bullet1.die();
             bullet2.die();
             this.spacewar.playRandomExplosionSound();
          }
        }
      }
    }
  }
  
  goIntoHyperspace = () => {
    if (this.hyperspaceCountdown == 0) {
      this.spacewar.setShipState(1); // ship is now in hyperspace
      this.shipStateTimeout = 100; // how long ship stays in hyperspace
      this.pos.x = this.p5.random(width);
      this.pos.y = this.p5.random(height);
      this.hyperspaceCountdown = this.hyperspaceTimeLimit;
    }    
  }
  
  updateHyperspaceCountdown = () => {
    this.hyperspaceCountdown = this.p5.max(0, this.hyperspaceCountdown - 1);
    //println("shipid", shipId, "hyperspace ct", hyperspaceCountdown);
  }
  
  updateBullets = ()  => {
    for (let bullet of this.bullets) {
      if (bullet.isLive()) {
        bullet.update();
      }
    }
  }
  
  renderBullets = () => {
    for (let bullet of this.bullets) {
      if (bullet.isLive()) {
        bullet.render();
      }
    }
  }
  
  addPoints = (amountToAdd) => {
    this.score = Math.max(0, this.score + this.amountToAdd);
  }

  onALiveBullet = (opponentShip) => {
    for (let bullet of this.bullets) {
      if (bullet.isLive()) {
        if (bullet.collides(opponentShip.pos, bullet.shipBulletCollisionTolerance)) {
          bullet.die();
          return true;
        }
      }
    }
    return false;
  }
  
  missileOnALiveBullet = (opponentShip) => {
    for (let bullet of this.bullets) {
      if (bullet.isLive()) {
        if (bullet.collides(opponentShip.missile.getMissilePos(), bullet.shipBulletCollisionTolerance)) {
          bullet.die();
          return true;
        }
      }
    }
    return false;
  } 
 
  engineGettingTooHot = () => {
    return (this.engineTemp > this.tooHotEngineTemp * 0.75);
  }
      
  startTurning = (direction) => {
    this.rotChange = direction * this.rotIncrement;
  }
  
  stopTurning = () => {
    this.rotChange = 0;
  }
  
  applyThrust = () => {
    if (this.spacewar.gamePaused() || this.spacewar.gameOver()) {
      return;
    }
    if (this.shipState == 0) { // can't accelerate if not alive
      this.thrustOn = true;
      
    }
  }

  cancelThrust = () => {
    this.thrustOn = false;
    //this.p5.noise.stop();
  }
  
  hitOtherShip = (otherShip) => {
    return (((this.p5.abs(this.pos.x - otherShip.pos.x) < 10) && (this.p5.abs(this.pos.y - otherShip.pos.y) < 10)));
  }
  
  hitOtherShipsMissile = (otherShip) => {
    const missilePos = otherShip.missile.getMissilePos();
    const impact = (((this.p5.abs(this.pos.x - missilePos.x) < 10) && (this.p5.abs(this.pos.y - missilePos.y) < 10)));
    return impact && otherShip.missile.isLive();
  }
  
  missileHitOtherShipsMissile = (otherShip) => {
    const missile1Pos = this.missile.getMissilePos();
    const missile2Pos = otherShip.missile.getMissilePos();
    const impact = (((this.p5.abs(missile1Pos.x - missile2Pos.x) < 10) && (this.p5.abs(missile1Pos.y - missile2Pos.y) < 10)));
    return impact && this.missile.isLive() && otherShip.missile.isLive();
  }
  
  blowUp = () => {
    this.setShipState(2);
    this.shipExplosion.start(this);
    // make ship respawn somewhere near the margins so you don't get insta-die by spawning near planet or sun.
    const buffer = 50;
    let newX, newY;
    if (this.shipId == 0) {
      newX = this.p5.random(0, this.windowSize);
      if (newX < buffer) {
        newY = this.p5.random(0, this.windowSize);
      } else {
        newY = this.p5.random(0,buffer);
      }
    } else {
      newX = this.p5.random(0, this.windowSize);
      if (newX < this.windowSize - buffer) {
        newY = this.p5.random(this.windowSize - buffer, this.windowSize);
      } else {
        newY = this.p5.random(0, this.windowSize);
      }
    }
   
    this.pos.set( newX, newY);
    this.vel.x = 0;
    this.vel.y = 0;
    this.engineTemp = 0;
    this.spacewar.playRandomExplosionSound();
    this.cancelThrust();
    
    this.livesLeft = this.livesLeft - 1;
    if (this.livesLeft == 0) {
      // GAME OVER! A ship is out of lives.
      this.spacewar.setGameOver();
    }
  }
  
  drawShip = (pos, rot, proportion, shipColor, drawThrust) => {
    this.p5.push();
    this.p5.translate(pos.x,pos.y);
    this.p5.scale(proportion);
    this.p5.rotate(this.p5.radians(rot));
    this.p5.fill(0);
    this.p5.stroke(shipColor);
    this.p5.beginShape();
    this.p5.vertex(-this.spacewar.halfShipWidth,  this.spacewar.halfShipHeight);
    this.p5.vertex(0,  -this.spacewar.halfShipHeight);
    this.p5.vertex(this.spacewar.halfShipWidth,  this.spacewar.halfShipHeight);
    this.p5.vertex(0, this.spacewar.halfShipHeight / 2);
    this.p5.endShape(this.p5.CLOSE);
    if (drawThrust) {
      // draw flames
      const flicker = this.p5.random(0,10) / 10 + 1; 
      this.p5.fill(255 * flicker,255 * flicker,0);
      this.p5.stroke(255 * flicker,255 * flicker,0);
      this.p5.beginShape();
      this.p5.vertex(-this.spacewar.halfShipWidth / 2, this.spacewar.halfShipHeight * 1.1);
      this.p5.vertex(0, this.spacewar.halfShipHeight * 1.6 * flicker);
      this.p5.vertex(this.spacewar.halfShipWidth / 2, this.spacewar.halfShipHeight * 1.1);
      this.p5.vertex(0, this.spacewar.halfShipHeight * 1.4);
      this.p5.endShape(this.p5.CLOSE);
    }
    this.p5.pop();
  }
  
// =-=-==-=-==-=-==-=-==-=-==-=-= MAIN CODE FOR SHIPS =-=-==-=-==-=-==-=-==-=-==-=-= 
  
  update = () => {
    console.log("planet pos", thePlanet.pos);
    this.updateHyperspaceCountdown();
    if (this.thrustOn) {
      this.accel.x = this.p5.sin(this.p5.radians(this.rot)) * this.accelFactor;
      this.accel.y = -this.p5.cos(this.p5.radians(this.rot)) * this.accelFactor;
      //this.spacewar.noise.play();
      this.engineTemp += this.engineHeatConstant;
    } else { 
      this.engineTemp = this.p5.max(0,this.engineTemp - 1);
    }

    this.accel.add(calculateSunsGravityForce(this.pos,   this.mass));
    this.accel.add(calculatePlanetsGravityForce(this.pos,this.mass));
    this.vel.add(this.accel);
    this.vel.mult(this.friction);
    //if (shipId == 0) {
    //  println("speed:", vel.mag());
    //}
    this.vel.limit(this.maxSpeed);
    this.pos.add(this.vel);
    this.rot = this.rot + this.rotChange;
    this.spacewar.wrapAroundEdges(this.pos);
    if (this.spacewar.insideSun(this.pos)) {
      this.blowUp();
      this.addPoints(-this.killPoints);
    } else if (this.engineTemp > this.tooHotEngineTemp) {
      // you overheated, you die!
      this.blowUp();
      this.addPoints(-this.killPoints);
      this.setShipState(3); // overheat
      this.shipStateTimeout = 100;
    }    
    
    this.accel.mult(0);
  
    this.updateBullets();
  }
  
  render = () => {
    this.shipExplosion.render(); // if an explosion is live, render it
    this.renderBullets();
    this.missile.update();
    this.missile.render();
    if (this.shipState != 0) { // if ship is not visible, don't draw anything (e.g. in hyperspace or exploding)
      this.shipStateTimeout -= 1;
      if (this.shipStateTimeout == 0) {
        this.shipState = 0; // ship becomes visible again
      } else {
        return;
      }
    }
    
    this.drawShip(this.pos, this.rot, 1.0, this.shipColor, this.thrustOn);    
   }
}
