class MissileExplosion {
  PVector pos, vel;
  int numPieces = 5;
  PVector[] piecesStart, piecesEnd, piecesRot, piecesTVec;
  
  MissileExplosion () {
    float x1,x2;
    float rot;
    piecesStart = new PVector[numPieces];
    piecesEnd = new PVector[numPieces];
    piecesRot = new PVector[numPieces];
    piecesTVec = new PVector[numPieces];
    for (int i = 0; i < numPieces; ++i) {
      rot = random(0,359);
      x1 = random (0,1) * -1;
      x2 = random(0,1);
      piecesStart[i] = new PVector(x1,0);
      piecesEnd[i] = new PVector(x2,0);
    }
  }
  
}
