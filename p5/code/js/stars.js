// Handles starfield and sun
class Stars {
  constructor(p, windowSize) {
    this.numStars = 100;
    this.p = p;
    this.stars = [];
    for (let i = 0; i < this.numStars; ++i) {
      this.stars[i] = this.p.createVector (this.p.random(0,windowSize), this.p.random (0, windowSize));
    }

  }

  render = () => {
    let flicker;
    for (let i = 0; i < this.numStars; ++i) {
      flicker = (this.p.random(0,5) / 10) + 0.5;
      this.p.stroke(150 * flicker, 150 * flicker, 255 * flicker);
      this.p.point(this.stars[i].x, this.stars[i].y);
    }
  }

  renderSun = (size) => {
    this.p.pushMatrix();
    this.p.translate(windowSize/2, windowSize / 2);
    this.p.fill(255,255, 0);
    this.p.stroke(255,205,0);
    const fc = frameCount;
    const mod = 30;
    const modF = 105.0;
    const pulse = ((fc % mod) / modF) + 1.0;
    //println((fc % 10) / 10.0);
    this.p.ellipse(0,0,size * pulse,size * pulse);
    this.p.popMatrix();
  }

}
