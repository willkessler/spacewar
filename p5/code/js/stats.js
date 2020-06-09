class Stats {
  constructor(p5, windowSize) {
    const showInstructions = true;
    const scores = [];
    const gameOverRot = 135;
    const gameOpeningScale = 6;
    const gameOverScale = 16;
    const p = p5;
  }
 
  hideInstructions = () => {
    showInstructions = false;  
  }
 
  renderEngineTemp = (ship) => {
    const barHeight = 10;
    const barTop = 80;
    const barWidth = 100;
    const leftOffset = ship.shipId == 0 ? 10 : width - barWidth - 15;
    const tempColor = ship.getShipColor();
    const scaledTemp = (ship.getEngineTemp() / ship.tooHotEngineTemp) * barWidth;
    
    p.fill(tempColor);
    p.text("Engine Temp:" , leftOffset ,barTop - 5);
    p.fill(0);
    p.stroke(255);
    p.rect(leftOffset - 1, barTop - 1, barWidth + 1, barHeight + 1, 2);
    if (ship.engineGettingTooHot()) {
      p.fill(255,0,0); // this is red if your engine is getting hot
    } else {
      p.fill(255,255,255); // white, you're still ok
    }
    p.rect(leftOffset, barTop, scaledTemp, barHeight, 2);
    
  }
  
  renderShipStatus = (ship) => {
     // display status messages! e.g. hyperspace, destroyed, overheat
     const displays = [ " ", "Hyperspace!", "Destroyed!", "Overheated!" ];
     const leftOffset = ship.shipId == 0 ? 10 : width - 120;
     p.fill(ship.getShipColor());
     p.text(displays[ship.getShipState()], leftOffset, 40);
   }
   
  renderLivesLeft = (ship) => {
    // display how many lives ya got left
    const leftOffset = ship.shipId == 0 ? 20 : width - 110;
    p.fill(ship.getShipColor());
    //text("Ships left:" + ship.getLivesLeft(), leftOffset, 110);
    let pos = p.createVector(leftOffset, 110);
    const rot = 0;
    const shipColor = ship.getShipColor();
    const thrustOn = false;
    const livesLeft = ship.getLivesLeft();
    for (let i = 0; i < livesLeft; i++) {
      pos.set (leftOffset + i * 16, 110);
      ship.drawShip(pos, rot, 0.75, shipColor, thrustOn);
    }
  }
 
  
  render = (ship1, ship2) => {
    p.textFont(f);
    // player 1 score
    p.fill(0,255,0);
    p.text("Player 1: " + ship1.getScore(),10,20);
    // player 2 score
    p.fill(255,0,0);
    p.text("Player2: " + ship2.getScore(),width - 120,20);
        
    if (gameOpening()) {
      p.fill (200);
      p.text ("Welcome to Spacewar!   ", 20, windowSize - 110);
      p.text ("ship1: WASDE keys. ship2: IJKLU keys. " , 20, windowSize - 90);
      p.text ("space key = hyperspace, 0 or 1 key = pause.", 20, windowSize - 70);
      p.text ("Start-> Press 1 for 1 player, 2 for 2 player" , 20, windowSize - 50); 
      
      p.fill(255);
      p.pushMatrix();
      p.translate(windowSize / 2 , windowSize / 2 + 20);
      p.scale(gameOpeningScale);
      p.textFont('Courier', 64);
      p.text("SPACE    WAR!", -270,0 );
      p.popMatrix();
      p.textFont('Courier',16);// reset font size
      gameOpeningScale = max(1.0, gameOpeningScale - 0.25);
    } else if (gameOver()) {
      const ship1Score = ship1.getScore();
      const ship2Score = ship2.getScore();
      let winnerShipId;
      if (ship1Score == ship2Score) {
        winnerShipId = ship1.getLivesLeft() == 0 ? 2 : 1;
      } else {
        winnerShipId = ship1Score < ship2Score ? 2 : 1;
      }
      gameOverRot = max(0, gameOverRot - 5);
      gameOverScale = max(1.0, gameOverScale - 0.2);
      p.pushMatrix();
      p.translate(windowSize / 2 , windowSize / 2 + 20);
      p.scale(gameOverScale);
      p.rotate(radians(gameOverRot));
      p.textFont('Courier', 64);
      p.text("GAME   OVER!", -215,0 );
      p.popMatrix();
      p.textFont('Courier',16);// reset font size
      p.fill(winnerShipId == 2 ? ship2.getShipColor() : ship1.getShipColor() );
      p.text("Winner:  Ship " + winnerShipId, windowSize / 2 - 80 , windowSize / 2 + 60);
    }    

    renderShipStatus(ship1);
    renderShipStatus(ship2);
    
    renderEngineTemp(ship1);
    renderEngineTemp(ship2);
    
    renderLivesLeft(ship1);
    renderLivesLeft(ship2);

  }
}
