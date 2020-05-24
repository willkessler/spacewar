class Stats {
 int[] scores;
 PFont f;
 
  Stats() {
   f = createFont("Courier",16,true); 
 }
  
  void render(Ship ship1, Ship ship2) {
   textFont(f);
    // player 1 score
    fill(0,255,0);
   text("Player 1:" + ship1.getScore(),20,20);
   // player 2 score
    fill(255,0,0);
    text("Player2:" + ship2.getScore(),width - 100,20);
  }
}
