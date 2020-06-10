// Handles starfield and sun
class Stars {
  constructor(p5, windowSize) {
    this.numStars = 100;
    this.p5 = p5;
    this.stars = [];
    for (let i = 0; i < this.numStars; ++i) {
      this.stars[i] = this.p5.createVector (this.p5.random(0,windowSize), this.p5.random (0, windowSize));
    }

  }

  render = () => {
    let flicker;
    for (let i = 0; i < this.numStars; ++i) {
      flicker = (this.p5.random(0,5) / 10) + 0.5;
      this.p5.stroke(150 * flicker, 150 * flicker, 255 * flicker);
      this.p5.point(this.stars[i].x, this.stars[i].y);
    }
  }

  renderSun = (size) => {
    this.p5.push();
    this.p5.translate(windowSize/2, windowSize / 2);
    this.p5.fill(255,255, 0);
    this.p5.stroke(255,205,0);
    const fc = this.p5.frameCount;
    const mod = 30;
    const modF = 105.0;
    const pulse = ((fc % mod) / modF) + 1.0;
    //println((fc % 10) / 10.0);
    this.p5.ellipse(0,0,size * pulse,size * pulse);
    this.p5.pop();
  }

}
