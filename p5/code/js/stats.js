class Stats {
  constructor(p5, windowSize) {
    this.showInstructions = true;
    this.gameOverRot = 135;
    this.gameOpeningScale = 6;
    this.gameOverScale = 16;
    this.p5 = p5;
    this.windowSize = windowSize;
  }
 
  hideInstructions = () => {
    this.showInstructions = false;  
  }
 
  renderEngineTemp = (ship) => {
    const barHeight = 10;
    const barTop = 80;
    const barWidth = 100;
    const leftOffset = ship.shipId == 0 ? 10 : this.windowSize - barWidth - 15;
    const tempColor = ship.getShipColor();
    const scaledTemp = (ship.getEngineTemp() / ship.tooHotEngineTemp) * barWidth;
    
    this.p5.fill(tempColor);
    this.p5.text("Engine Temp:" , leftOffset ,barTop - 5);
    this.p5.fill(0);
    this.p5.stroke(255);
    this.p5.rect(leftOffset - 1, barTop - 1, barWidth + 1, barHeight + 1, 2);
    if (ship.engineGettingTooHot()) {
      this.p5.fill(255,0,0); // this is red if your engine is getting hot
    } else {
      this.p5.fill(255,255,255); // white, you're still ok
    }
    this.p5.rect(leftOffset, barTop, scaledTemp, barHeight, 2);
    
  }
  
  renderShipStatus = (ship) => {
     // display status messages! e.g. hyperspace, destroyed, overheat
     const displays = [ " ", "Hyperspace!", "Destroyed!", "Overheated!" ];
     const leftOffset = ship.shipId == 0 ? 10 : this.windowSize - 120;
     this.p5.fill(ship.getShipColor());
     this.p5.text(displays[ship.getShipState()], leftOffset, 40);
   }
   
  renderLivesLeft = (ship) => {
    // display how many lives ya got left
    const leftOffset = ship.shipId == 0 ? 20 : this.windowSize - 110;
    this.p5.fill(ship.getShipColor());
    //text("Ships left:" + ship.getLivesLeft(), leftOffset, 110);
    let pos = this.p5.createVector(leftOffset, 110);
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
    this.p5.textFont('Courier');
    // player 1 score
    this.p5.fill(0,255,0);
    this.p5.text("Player 1: " + ship1.getScore(),10,20);
    // player 2 score
    this.p5.fill(255,0,0);
    this.p5.text("Player2: " + ship2.getScore(),this.windowSize - 120,20);
        
    if (gameOpening()) {
      this.p5.fill (200);
      this.p5.text ("Welcome to Spacewar!   ", 20, this.windowSize - 110);
      this.p5.text ("ship1: WASDE keys. ship2: IJKLU keys. " , 20, this.windowSize - 90);
      this.p5.text ("space key = hyperspace, 0 or 1 key = pause.", 20, this.windowSize - 70);
      this.p5.text ("Start-> Press 1 for 1 player, 2 for 2 player" , 20, this.windowSize - 50); 
      
      this.p5.fill(255);
      this.p5.push();
      this.p5.translate(this.windowSize / 2 , this.windowSize / 2 + 20);
      this.p5.scale(this.gameOpeningScale);
      this.p5.textFont('Courier', 64);
      this.p5.text("SPACE    WAR!", -270,0 );
      this.p5.pop();
      this.p5.textFont('Courier',16);// reset font size
      this.gameOpeningScale = this.p5.max(1.0, this.gameOpeningScale - 0.25);
    } else if (gameOver()) {
      const ship1Score = ship1.getScore();
      const ship2Score = ship2.getScore();
      let winnerShipId;
      if (ship1Score == ship2Score) {
        winnerShipId = ship1.getLivesLeft() == 0 ? 2 : 1;
      } else {
        winnerShipId = ship1Score < ship2Score ? 2 : 1;
      }
      this.gameOverRot = max(0, this.gameOverRot - 5);
      this.gameOverScale = max(1.0, this.gameOverScale - 0.2);
      this.p5.push();
      this.p5.translate(this.windowSize / 2 , this.windowSize / 2 + 20);
      this.p5.scale(this.gameOverScale);
      this.p5.rotate(radians(this.gameOverRot));
      this.p5.textFont('Courier', 64);
      this.p5.text("GAME   OVER!", -215,0 );
      this.p5.pop();
      this.p5.textFont('Courier',16);// reset font size
      this.p5.fill(winnerShipId == 2 ? ship2.getShipColor() : ship1.getShipColor() );
      this.p5.text("Winner:  Ship " + winnerShipId, this.windowSize / 2 - 80 , this.windowSize / 2 + 60);
    }    

    this.renderShipStatus(ship1);
    this.renderShipStatus(ship2);
    
    this.renderEngineTemp(ship1);
    this.renderEngineTemp(ship2);
    
    this.renderLivesLeft(ship1);
    this.renderLivesLeft(ship2);

  }
}
