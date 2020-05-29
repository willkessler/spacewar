class MissileExplosion {
  Missile parent;
  boolean live;
  int ttl;
  int lifeSpan = 100;
  PVector pos, vel;
  int numPieces = 5;
  float[] piecesRot;
  PVector[]  piecesTVec;
  float[] piecesX1, piecesX2;
  color explosionColor;
  float rotInc;
  float tVecMultiplier;
  float pieceSize = 15;

  MissileExplosion (Missile parentMissile) {
    rotInc = random(2,5);
    parent = parentMissile;
    explosionColor = parent.getMissileColor();
    live = false;
    float rot, pieceRot;
    pos = new PVector(0,0);
    vel = new PVector(0,0);
    piecesX1 = new float[numPieces];
    piecesX2 = new float[numPieces];
    piecesRot = new float[numPieces];
    piecesTVec = new PVector[numPieces];
    for (int i = 0; i < numPieces; ++i) {
      piecesRot[i] = random(0,359);
      pieceRot = random(0,359);
      rot = radians(pieceRot);
      piecesTVec[i] = new PVector(cos(rot),sin(rot));
      piecesX1[i] = random (0,pieceSize) * -1; // left edge of line fragment explosion piece
      piecesX2[i] = random(0.2,pieceSize);       // right edge of line fragment explosion piece
    }
  }
  
  void start() {
    ttl = lifeSpan;
    live = true;
    PVector missilePos = parent.getMissilePos();
    PVector missileVel = parent.getMissileVel();
    //println("setting missile ex pos", missilePos);
    pos.set(missilePos);
    //println("setting missile ex vel");
    vel.set(missileVel);
    vel.mult(0.5);
    tVecMultiplier = 1.0;
  }
  
  void checkStop() {
    if (ttl == 0) {
      live = false;
    }
  }
  
  void update() {
    if (live) {
       // now decrease ttl
      ttl--;
      checkStop();
    }
    for (int i = 0; i < numPieces; ++i) {
      piecesRot[i] += rotInc;
    }
    tVecMultiplier += 0.1;
    pos.add(vel);
  }

  void render() {
    update();
    if (live) {
      PVector transVec = new PVector(0,0);
      // draw the explosion!
      stroke(explosionColor);
      fill(255);
      for (int i = 0; i < numPieces; ++i) {
        pushMatrix();
        transVec.set(0,0);
        transVec.add(piecesTVec[i]);
        transVec.mult(tVecMultiplier);
        transVec.add(pos);
        //println("piece ", i, "rot:", piecesRot[i], "tranlsation:", transVec);
        translate(transVec.x, transVec.y);
        rotate(radians(piecesRot[i]));
        line(piecesX1[0],0, piecesX2[1], 0);
        popMatrix();
      }
    }
  }
  
}
