import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["canvas"];

  connect() {
    this.initializeProperties();
    this.configureCanvas();

    window.addEventListener("resize", () => this.handleResize());
    this.renderStars();
  }

  initializeProperties() {
    this.bgColor = "#000";
    this.starMaxRadius = 1;
    this.starMinOpacity = 0.2;
    this.starMaxOpacity = 0.8;
    this.frame = 0;

    this.width = document.documentElement.clientWidth;
    this.height = document.documentElement.clientHeight;
    this.starsArr = this.generateStars(this.width, this.height, 35);
  }

  configureCanvas() {
    this.canvas = document.createElement("canvas");
    this.ctx = this.canvas.getContext("2d");
    this.canvas.id = "canvas";
    this.canvas.width = this.width;
    this.canvas.height = this.height;
    document.body.appendChild(this.canvas);
  }

  randomInt(max) {
    return Math.floor(Math.random() * max);
  }

  generateStars(width, height, spacing) {
    const stars = [];

    for (let x = 0; x < width; x += spacing) {
      for (let y = 0; y < height; y += spacing) {
        const starObj = {
          x: x + this.randomInt(spacing),
          y: y + this.randomInt(spacing),
          r: Math.random() * this.starMaxRadius,
          color: this.pickRandomColor(),
        };
        stars.push(starObj);
      }
    }
    return stars;
  }

  pickRandomColor() {
    const rand = Math.random();
    if (rand < 0.05) {
      return 'rgba(255, 160, 122,';
    } else if (rand < 0.4) {
      return 'rgba(82, 117, 183,';
    } else {
      return 'rgba(255, 255, 255,';
    }
  }

  drawCircle(ctx, x, y, r, fillStyle) {
    ctx.beginPath();
    ctx.fillStyle = fillStyle;
    ctx.arc(x, y, r, 0, Math.PI * 2);
    ctx.fill();
  }

  calculateOpacity(factor) {
    const opacityIncrement = (this.starMaxOpacity - this.starMinOpacity) * Math.abs(Math.sin(factor));
    const opacity = this.starMinOpacity + opacityIncrement;
    return opacity;
  }

  handleResize() {
    this.width = document.documentElement.clientWidth;
    this.height = document.documentElement.clientHeight;
    this.canvas.width = this.width;
    this.canvas.height = this.height;
    this.starsArr = this.generateStars(this.width, this.height, 30);
  }

  renderStars() {
    this.ctx.fillStyle = this.bgColor;
    this.ctx.fillRect(0, 0, this.width, this.height);

    this.starsArr.forEach((star, i) => {
      const factor = this.frame * i;
      const x = star.x;
      const y = star.y;
      const opacity = this.calculateOpacity(factor);
      this.drawCircle(
        this.ctx,
        x,
        y,
        star.r,
        `${star.color}${opacity})`
      );
    });

    this.frame++;
    requestAnimationFrame(() => this.renderStars());
  }
}
