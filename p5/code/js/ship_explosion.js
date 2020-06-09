
class ShipExplosion {
  PVector pos, vel;
  float rot;
  boolean live;
  int ttl;
  int lifeSpan = 100;
  float explosionScale, scaleGrowth = 1.04;
  Ship parentShip; // which ship owns this explosion
  color explosionColor;
  int[] partsRots = new int[4];
  int[] partsRotsIncs = new int[4];
  float[] shipLineCoords = { -halfShipWidth, halfShipHeight, 
                             0, -halfShipHeight,
                             0, -halfShipHeight,
                             halfShipWidth, halfShipHeight,
                             halfShipWidth, halfShipHeight,
                             0, halfShipHeight / 2,
                             0, halfShipHeight / 2,
                             -halfShipWidth,  halfShipHeight,
                             -halfShipWidth,  halfShipHeight,
                             halfShipWidth, halfShipHeight };
                           
  Explosion (Ship ship) {
    pos = new PVector(0,0);
    vel = new PVector(0,0);
    rot = 0;
    live = false;
    ttl = 0;
    explosionColor = ship.shipColor;
    parentShip = ship;
   }
  
  void start(Ship ship) {
   for (int i = 0; i < 4; ++i) {
      partsRots[i] = 0;
      partsRotsIncs[i] = int(random(4,7));
    }
    ttl = lifeSpan;
    live = true;
    pos.set(ship.pos);
    vel.set(ship.vel);
    vel.mult(0.5);
    explosionScale = 1.0;
  }
  
  void checkStop() {
    if (ttl == 0) {
      live = false;
      parentShip.setShipState(0); // visible again
    }
  }
  
  void update() {
    if (live) {
       // now decrease ttl
      ttl--;
      explosionScale *= scaleGrowth;
      checkStop();
    }
    pos.add(vel);
    rot++;
  }
  
  void render() {
    update();
    if (live) {
      // draw the explosion!
      pushMatrix();
      translate(pos.x,pos.y);
      rotate(radians(rot));
      fill(0);
      stroke(explosionColor);
      
      int j;
      PVector expandVec = new PVector(1.0, 1.0);
      for (int i = 0; i < 4; ++i) {
         j = i * 4;
         pushMatrix();
         rotate(radians(partsRots[i]));
         expandVec.set(cos(radians(i * 45)), sin(radians(i*45)));
         expandVec.mult(explosionScale);
         line(shipLineCoords[j] + expandVec.x, shipLineCoords[j+1] + expandVec.y, 
              shipLineCoords[j+2] + expandVec.x, shipLineCoords[j+3] + expandVec.y);
         popMatrix();
         partsRots[i] += partsRotsIncs[i];
     }    
      popMatrix();
    }
  }
  
}
