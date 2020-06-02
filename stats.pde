class Stats {
 boolean showInstructions = true;
 int[] scores;
 PFont f;
 float gameOverRot;
 float gameOverScale;
 
  Stats() {
   f = createFont("Courier",16,true);
   gameOverRot = 135;
   gameOverScale = 6;
  }
 
  void hideInstructions () {
    showInstructions = false;  
  }
 
  void  renderEngineTemp (Ship ship) {
    int barHeight = 10;
    int barTop = 80;
    int barWidth = 100;
    int leftOffset = ship.shipId == 0 ? 10 : width - barWidth - 15;
    color tempColor = ship.getShipColor();
    float scaledTemp = (ship.getEngineTemp() / ship.tooHotEngineTemp) * barWidth;
    
    fill(tempColor);
    text("Engine Temp:" , leftOffset ,barTop - 5);
    fill(0);
    stroke(255);
    rect(leftOffset - 1, barTop - 1, barWidth + 1, barHeight + 1, 2);
    if (ship.engineGettingTooHot()) {
      fill(255,0,0); // this is red if your engine is getting hot
    } else {
      fill(255,255,255); // white, you're still ok
    }
    rect(leftOffset, barTop, scaledTemp, barHeight, 2);
    
  }
  
   void renderShipStatus(Ship ship) {
     // display status messages! e.g. hyperspace, destroyed, overheat
     String[] displays = { " ", "Hyperspace!", "Destroyed!", "Overheated!" };
     int leftOffset = ship.shipId == 0 ? 10 : width - 120;
     fill(ship.getShipColor());
     text(displays[ship.getShipState()], leftOffset, 40);
   }
   
   void renderLivesLeft(Ship ship) {
     // display how many lives ya got left
     int leftOffset = ship.shipId == 0 ? 10 : width - 120;
     fill(ship.getShipColor());
     text("Ships left:" + ship.getLivesLeft(), leftOffset, 110);
   }
 
  
  void render(Ship ship1, Ship ship2) {
    textFont(f);
    // player 1 score
    fill(0,255,0);
    text("Player 1: " + ship1.getScore(),10,20);
    // player 2 score
    fill(255,0,0);
    text("Player2: " + ship2.getScore(),width - 120,20);
        
    if (gameOpening()) {
      fill (200);
      text ("Welcome to Spacewar!   ", 20, windowSize - 110);
      text ("ship1: WASDE keys. ship2: IJKLU keys. " , 20, windowSize - 90);
      text ("space key = hyperspace, 0 or 1 key = pause.", 20, windowSize - 70);
      text ("Start-> Press 1 for 1 player, 2 for 2 player" , 20, windowSize - 50); 
    } else if (gameOver()) {
      int ship1Score = ship1.getScore();
      int ship2Score = ship2.getScore();
      int winnerShipId;
      if (ship1Score == ship2Score) {
        winnerShipId = ship1.getLivesLeft() == 0 ? 2 : 1;
      } else {
        winnerShipId = ship1Score < ship2Score ? 2 : 1;
      }
      gameOverRot = max(0, gameOverRot - 5);
      gameOverScale = max(1.0, gameOverScale - 0.2);
      pushMatrix();
      translate(windowSize / 2 , windowSize / 2 + 20);
      scale(gameOverScale);
      rotate(radians(gameOverRot));
      textFont(f, 64);
      text("GAME   OVER!", -210,0 );
      popMatrix();
      textFont(f, 16); // reset font size
      fill(winnerShipId == 2 ? ship2.getShipColor() : ship1.getShipColor() );
      text("Winner:  Ship " + winnerShipId, windowSize / 2 - 80 , windowSize / 2 + 60);
    }    
    
    renderShipStatus(ship1);
    renderShipStatus(ship2);
    
    renderEngineTemp(ship1);
    renderEngineTemp(ship2);
    
    renderLivesLeft(ship1);
    renderLivesLeft(ship2);

  }
}
