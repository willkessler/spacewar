const spacewarMain = function(p) {

  const windowSize = 800;
  const shipWidth = 15;
  const shipHeight = shipWidth * 1.5;
  const halfShipHeight = shipHeight / 2;
  const halfShipWidth = shipWidth / 2;
  const useAI = true;

/*
  SoundFile[] explosions;
  SoundFile gunshot;
  SoundFile engineAlarm;
  SoundFile missileShot;
  SoundFile bigSwoosh;
  SoundFile gameOverNoise;
  WhiteNoise noise = new WhiteNoise(this);
*/
  let gameStatus; // 0 == opening, 1 == playing, 2 == paused, 3 == game over
  let ship1, ship2;
  let theStars;
  let thePlanet;
  let theAI;
  let stats;
  const killPoints = 10;

  // =-=-==-=-==-=-==-=-==-=-==-=-= UTILITY FUNCTIONS =-=-==-=-==-=-==-=-==-=-==-=-=

  p.keyPressed = (key) => {  
    stats.hideInstructions();
    switch (key) {
    case '0':
    case '1':
    case '2':
      if (gameOpening() || gamePaused()) {
        setGamePlaying();
      } else {
        setGamePaused();
      }
      
      if (key == '2') {
        useAI = false;
      }
      break; 
    case ' ':
      ship1.goIntoHyperspace();
      ship2.goIntoHyperspace();
      break; 
    case 's':
      ship1.applyThrust();
      break;
    case 'w':
      ship1.fireBullet();
      break;
    case 'a':
      ship1.startTurning(-1);
      break;
    case 'd':
      ship1.startTurning(1);
      break;
    case 'e':
      ship1.fireMissile();
      break;
    case 'k':
      ship2.applyThrust();
      break;
    case 'i':
      ship2.fireBullet();
      break;
    case 'j':
      ship2.startTurning(-1);
      break;
    case 'l':
      ship2.startTurning(1);
      break;   
    case 'u':
      ship2.fireMissile();
      break;
    } 
  }

  p.keyReleased = (key) => {
    switch (key) {
    case 's':
      ship1.cancelThrust();
      break;
    case 'w':
      //ship1.fireBullet();
      break;
    case 'a':
    case 'd':
      ship1.stopTurning();
      break;
    case 'k':
      ship2.cancelThrust();
      break;
    case 'i':
      //ship1.fireBullet();
      break;
    case 'j':
    case 'l':
      ship2.stopTurning();
      break;
    }
  }

  // wrap a moving object around screen edges
  p.wrapAroundEdges = (pos) => {
    if (pos.x < 0) {
      pos.x = windowSize; 
    }
    if (pos.y < 0) {
      pos.y = windowSize;
    }
    if (pos.x > windowSize) {
      pos.x = 0; 
    }
    if (pos.y > windowSize) {
      pos.y = 0;
    }
  }

  p.insideSun = (pos) => {
    const halfWindow = windowSize / 2;

    return ((abs(halfWindow - pos.x) < 10) && (abs(halfWindow - pos.y) < 10));  
  }

  p.calculateGravityForce = (gravityWellPos, pos, mass, G) => {
    const distToWell = pos.dist(gravityWellPos);
    const shipToWellVector = PVector.sub(gravityWellPos, pos);
    shipToWellVector.normalize();
    const gravityFactor = (1.0 / (pow(distToWell, 1.57))) * G * mass;
    const gravityVector = PVector.mult(shipToWellVector, gravityFactor);

    return gravityVector;
  }

  p.calculateSunsGravityForce = (pos, mass) => {
    const sunPos = new PVector (windowSize / 2, windowSize/2);
    const G = 30;
    const gravityVector = calculateGravityForce(sunPos, pos, mass, G);

    return gravityVector;
  }

  p.calculatePlanetsGravityForce = (pos, mass) => {
    const planetPos = thePlanet.getPlanetPos();
    const G = 18;
    const gravityVector = calculateGravityForce(planetPos, pos, mass,G);

    return gravityVector;
  }

  // see: https://www.euclideanspace.com/maths/algebra/vectors/angleBetween/
  p.angleBetweenVectors = (v1, v2) => {
    const dp = v1.dot(v2);
    const denom = v1.mag() * v2.mag();
    const angle = acos(dp/denom);

    return degrees(angle);
  }

  p.playRandomExplosionSound = () => {
    const randomExplosionSound = parseInt(random(10));

    explosions[randomExplosionSound].play();
  }

  p.gameOpening = () => {
    return gameStatus == 0;
  }

  p.gamePlaying = () => {
    return gameStatus == 1;
  }

  p.gamePaused = () => {
    return gameStatus == 2;
  }

  p.gameOver = () => {
    return gameStatus == 3;
  }

  p.setGameOpening = () => {
    gameStatus = 0; // opening
    bigSwoosh.play();
  }

  p.setGamePlaying = () => {
    gameStatus = 1; // playing
  }

  p.setGamePaused = () => {
    gameStatus = 2; // paused
  }

  p.setGameOver = () => {
    gameStatus = 3; // game over
    gameOverNoise.play();
  }

  // =-=-==-=-==-=-==-=-==-=-==-=-= MAIN CODE =-=-==-=-==-=-==-=-==-=-==-=-=

  p.setup = () => {
    stats = new Stats();
    theStars = new Stars();
    thePlanet = new Planet();
    theAI = new AI();
    
    // Load a soundfile from the /data folder of the sketch and play it back
    explosions = new SoundFile[10];
    explosions[0] = new SoundFile(this, "Explosion+1.mp3");
    explosions[1] = new SoundFile(this, "Explosion+2.mp3");
    explosions[2] = new SoundFile(this, "Explosion+3.mp3");
    explosions[3] = new SoundFile(this, "Explosion+4.mp3");
    explosions[4] = new SoundFile(this, "Explosion+5.mp3");
    explosions[5] = new SoundFile(this, "Explosion+6.mp3");
    explosions[6] = new SoundFile(this, "Explosion+7.mp3");
    explosions[7] = new SoundFile(this, "Explosion+9.mp3");
    explosions[8] = new SoundFile(this, "Explosion+10.mp3");
    explosions[9] = new SoundFile(this, "Explosion+11.mp3");
    gunshot = new SoundFile(this, "Gun+Silencer.mp3");
    engineAlarm = new SoundFile(this, "beep-07.mp3");
    missileShot = new SoundFile(this, "Missile+2.mp3");
    bigSwoosh = new SoundFile(this, "bigswoosh.mp3");
    gameOverNoise = new SoundFile(this, "smb_gameover.wav");
    
    //println("does this update git hub?????? ");
    
    size(800,800);
    background(255,255,255);
    mouseX = width / 2;
    mouseY = height / 2;
    const partWindow = windowSize /8;
    ship1 = new Ship(0, partWindow, partWindow, color(0,255,0));
    ship2 = new Ship(1, windowSize - partWindow,windowSize - partWindow, color(255,0,0));
    ship1.setEnemyShip(ship2);
    ship2.setEnemyShip(ship1);
    if (useAI) {
      theAI.assignShips(ship2, ship1);
    }
    noise.amp(0.5);
    setGameOpening();
  }

  p.draw = () => {
    background(0,0,0);
    theStars.render();
    theStars.renderSun(25);
    stats.render(ship1,ship2);
    if (gamePlaying()) {
      thePlanet.update();
    }
    thePlanet.render();
    
    if (ship1.hitOtherShip(ship2)) {
      ship1.blowUp();
      ship2.blowUp();
    }
    
    if (ship1.onALiveBullet(ship2)) {
      ship2.blowUp();
      ship1.addPoints(killPoints);
    }
    
    if (ship2.onALiveBullet(ship1)) {
      ship1.blowUp();
      ship2.addPoints(killPoints);
    }
    
    if (ship1.hitOtherShipsMissile(ship2)) {
      ship1.blowUp();
      ship2.addPoints(killPoints);
      ship2.killMissile();
    }
    
    if (ship2.hitOtherShipsMissile(ship1)) {
      ship2.blowUp();
      ship1.addPoints(killPoints);
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
      ship1.addPoints(-killPoints);
    }
    
    if (thePlanet.collides(ship2.pos)) {
      ship2.blowUp();
      ship2.addPoints(-killPoints);
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

  p.setup = function() {
    p.createCanvas(1000,1000);
  };

  p.draw = function() {
    p.background(0);
    p.fill(255);
    p.rect(x, y, 90, 50);
  };

}



let spacewarMain2 = function(p) {
  let x = 100;
  let y = 100;

  p.setup = function() {
    p.createCanvas(1000,1000);
  };

  p.draw = function() {
    p.background(0);
    p.fill(255);
    p.rect(x, y, 90, 50);
  };
};

let spacewar = new p5(spacewarMain);
