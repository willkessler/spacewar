const spacewarMain = function(p5) {

  // =-=-==-=-==-=-==-=-==-=-==-=-= UTILITY FUNCTIONS =-=-==-=-==-=-==-=-==-=-==-=-=

  p5.keyPressed = (key) => {  
    this.theStats.hideInstructions();
    switch (key.key) {
    case '0':
    case '1':
    case '2':
      if (this.gameOver()) {
        this.resetGamePlay();
        this.setGamePlaying();
      } else if (this.gameOpening() || this.gamePaused()) {
        this.setGamePlaying();
      } else {
        this.setGamePaused();
      }
      
      if (key == '2') {
        this.useAI = false;
      }
      break; 
    case ' ':
      this.ship1.goIntoHyperspace();
      this.ship2.goIntoHyperspace();
      break; 
    case 's':
      this.ship1.applyThrust();
      break;
    case 'w':
      this.ship1.fireBullet();
      break;
    case 'a':
      this.ship1.startTurning(-1);
      break;
    case 'd':
      this.ship1.startTurning(1);
      break;
    case 'e':
      this.ship1.fireMissile();
      break;
    case 'k':
      this.ship2.applyThrust();
      break;
    case 'i':
      this.ship2.fireBullet();
      break;
    case 'j':
      this.ship2.startTurning(-1);
      break;
    case 'l':
      this.ship2.startTurning(1);
      break;   
    case 'u':
      this.ship2.fireMissile();
      break;
    } 
  }

  p5.keyReleased = (key) => {
    switch (key.key) {
    case 's':
      this.ship1.cancelThrust();
      break;
    case 'w':
      //ship1.fireBullet();
      break;
    case 'a':
    case 'd':
      this.ship1.stopTurning();
      break;
    case 'k':
      this.ship2.cancelThrust();
      break;
    case 'i':
      //ship1.fireBullet();
      break;
    case 'j':
    case 'l':
      this.ship2.stopTurning();
      break;
    }
  }

  // wrap a moving object around screen edges
  this.wrapAroundEdges = (pos) => {
    if (pos.x < 0) {
      pos.x = this.windowSize; 
    }
    if (pos.y < 0) {
      pos.y = this.windowSize;
    }
    if (pos.x > this.windowSize) {
      pos.x = 0; 
    }
    if (pos.y > this.windowSize) {
      pos.y = 0;
    }
  }

  this.insideSun = (pos) => {
    const halfWindow = this.windowSize / 2;

    return ((p5.abs(halfWindow - pos.x) < 10) && (p5.abs(halfWindow - pos.y) < 10));  
  }

  this.calculateGravityForce = (gravityWellPos, pos, mass, G) => {
    const distToWell = pos.dist(gravityWellPos);
    const shipToWellVector = gravityWellPos.copy();
    shipToWellVector.sub(pos).normalize();
    const gravityFactor = (1.0 / (Math.pow(distToWell, 1.57))) * G * mass;
    shipToWellVector.mult(gravityFactor);

    return shipToWellVector;
  }

  this.calculateSunsGravityForce = (pos, mass) => {
    const sunPos = p5.createVector(this.windowSize / 2, this.windowSize/2);
    const G = 30;
    const gravityVector = calculateGravityForce(sunPos, pos, mass, G);

    return gravityVector;
  }

  this.calculatePlanetsGravityForce = (pos, mass) => {
    const planetPos = thePlanet.getPlanetPos();
    const G = 18;
    const gravityVector = calculateGravityForce(planetPos, pos, mass,G);

    return gravityVector;
  }

  // see: https://www.euclideanspace.com/maths/algebra/vectors/angleBetween/
  this.angleBetweenVectors = (v1, v2) => {
    const dp = v1.dot(v2);
    const denom = v1.mag() * v2.mag();
    const angle = p5.acos(dp/denom);

    return p5.degrees(angle);
  }

  this.playRandomExplosionSound = () => {
    const randomExplosionSound = parseInt(p5.random(10));

    this.explosions[randomExplosionSound].play();
  }

  this.gameOpening = () => {
    return this.gameStatus == 0;
  }

  this.gamePlaying = () => {
    return this.gameStatus == 1;
  }

  this.gamePaused = () => {
    return this.gameStatus == 2;
  }

  this.gameOver = () => {
    return this.gameStatus == 3;
  }

  this.setGameOpening = () => {
    this.gameStatus = 0; // opening
    try {
      this.bigSwoosh.play();
    } catch(ex) {
      console.log('Cannot play intro swoosh sound yet. Queueing.');
    }
  }

  this.setGamePlaying = () => {
    this.gameStatus = 1; // playing
  }

  this.setGamePaused = () => {
    this.gameStatus = 2; // paused
  }

  this.setGameOver = () => {
    this.gameStatus = 3; // game over
    this.gameOverNoise.play();
  }

  this.resetGamePlay = () => {
    ship1.resetToStart();
    ship2.resetToStart();
  }

  // =-=-==-=-==-=-==-=-==-=-==-=-= MAIN CODE =-=-==-=-==-=-==-=-==-=-==-=-=

  p5.preload = () => {
    p5.soundFormats('mp3', 'wav');
    //p5.registerPreloadMethod('loadSound');
    
    // Load a soundfile from the /data folder of the sketch and play it back
    this.explosions = [];
    this.explosions[0] = p5.loadSound("./assets/Explosion+1.mp3");
    this.explosions[1] = p5.loadSound("./assets/Explosion+2.mp3");
    this.explosions[2] = p5.loadSound("./assets/Explosion+3.mp3");
    this.explosions[3] = p5.loadSound("./assets/Explosion+4.mp3");
    this.explosions[4] = p5.loadSound("./assets/Explosion+5.mp3");
    this.explosions[5] = p5.loadSound("./assets/Explosion+6.mp3");
    this.explosions[6] = p5.loadSound("./assets/Explosion+7.mp3");
    this.explosions[7] = p5.loadSound("./assets/Explosion+9.mp3");
    this.explosions[8] = p5.loadSound("./assets/Explosion+10.mp3");
    this.explosions[9] = p5.loadSound("./assets/Explosion+11.mp3");
    this.gunshot =       p5.loadSound("./assets/Gun+Silencer.mp3");
    this.engineAlarm =   p5.loadSound("./assets/beep-07.mp3");
    this.missileShot =   p5.loadSound("./assets/Missile+2.mp3");
    this.bigSwoosh =     p5.loadSound('./assets/bigswoosh.mp3');
    this.gameOverNoise = p5.loadSound("./assets/smb_gameover.wav");

    // Set up white noise engine sound
    // from: https://p5js.org/examples/sound-noise-drum-envelope.html
    if (false) {
    this.whiteNoise = new p5.Noise(); // other types include 'brown' and 'pink'
    this.whiteNoise.start();

    // multiply noise volume by 0
    // (keep it quiet until we're ready to make noise!)
    this.whiteNoise.amp(0.5);

    const env = new p5.Env();
    // set attackTime, decayTime, sustainRatio, releaseTime
    env.setADSR(0.001, 0.1, 0.2, 0.1);
    // set attackLevel, releaseLevel
    env.setRange(1, 0);

    // p5.Amplitude will analyze all sound in the sketch
    // unless the setInput() method is used to specify an input.
    const analyzer = new p5.Amplitude();
    }

  }
  
  p5.setup = () => {
    this.windowSize = 700;
    this.shipWidth = 15;
    this.shipHeight = this.shipWidth * 1.5;
    this.halfShipHeight = this.shipHeight / 2;
    this.halfShipWidth = this.shipWidth / 2;
    this.useAI = true;
    this.gameStatus = 0; // 0 == opening, 1 == playing, 2 == paused, 3 == game over
    this.killPoints = 10;

    p5.createCanvas(this.windowSize, this.windowSize);
    p5.background(255,255,255);

    this.theStars = new Stars(p5, this.windowSize);
    this.theStats = new Stats(p5, this.windowSize);

    const partWindow = this.windowSize /8;
    this.ship1 = new Ship(p5, this, this.windowSize, 0, partWindow, partWindow, p5.color(0,255,0));
    this.ship2 = new Ship(p5, this, this.windowSize, 1, this.windowSize - partWindow,this.windowSize - partWindow,  p5.color(255,0,0));
    this.ship1.setEnemyShip(this.ship2);
    this.ship2.setEnemyShip(this.ship1);
    

    this.thePlanet = new Planet(p5, this);
    this.theAI = new AI(p5, this);
        
    if (this.useAI) {
      this.theAI.assignShips(this.ship2, this.ship1);
    }

    this.setGameOpening();
  }

  p5.draw = () => {
    p5.background(0,0,0);
    this.theStars.render();
    this.theStars.renderSun(25);
    this.theStats.render(ship1,ship2);
    if (this.gamePlaying()) {
      this.thePlanet.update();
    }
    this.thePlanet.render();
    
    if (this.ship1.hitOtherShip(this.ship2)) {
      this.ship1.blowUp();
      this.ship2.blowUp();
    }
    
    if (this.ship1.onALiveBullet(this.ship2)) {
      this.ship2.blowUp();
      this.ship1.addPoints(this.killPoints);
    }
    
    if (this.ship2.onALiveBullet(this.ship1)) {
      this.ship1.blowUp();
      this.ship2.addPoints(this.killPoints);
    }
    
    if (this.ship1.hitOtherShipsMissile(this.ship2)) {
      this.ship1.blowUp();
      this.ship2.addPoints(this.killPoints);
      this.ship2.killMissile();
    }
    
    if (ship2.hitOtherShipsMissile(ship1)) {
      ship2.blowUp();
      ship1.addPoints(this.killPoints);
      ship1.killMissile();
    }
    
    if (ship1.missileHitOtherShipsMissile (ship2)) {
      ship1.killMissile();
      ship2.killMissile();
    }

    if (ship1.missileOnALiveBullet(ship2)) {
      ship2.killMissile();
    }
    
    if (ship2.missileOnALiveBullet(ship1)) {
      ship1.killMissile();
    }
    
    ship1.checkBulletsCollide(ship2);
    
    if (thePlanet.collides(ship1.pos)) {
      ship1.blowUp();
      ship1.addPoints(-this.killPoints);
    }
    
    if (thePlanet.collides(ship2.pos)) {
      ship2.blowUp();
      ship2.addPoints(-this.killPoints);
    }
    
    if (gamePlaying()) {
      ship1.update();
    }
    if (!gameOver()) {
      ship1.render();  
    }
    
    if (gamePlaying()) {
      ship2.update();
    }
    
    if (!gameOver()) {
      ship2.render(); 
    }
    
    if(gamePlaying() && useAI) {
      theAI.control();
    }
  }

}


let spacewar = new p5(spacewarMain);
