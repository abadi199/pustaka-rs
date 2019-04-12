import screenfull from "screenfull";
import icon from "./assets/fullscreen.svg";

class Fullscreen extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    const shadow = this.attachShadow({ mode: "open" });
    const button: HTMLButtonElement = document.createElement("button");
    const image: HTMLImageElement = document.createElement("img");
    image.src = icon;
    image.style.height = "35px";
    button.style.padding = "0";
    button.style.height = "100%";
    button.style.background = "none";
    button.style.display = "flex";
    button.style.justifyContent = "center";
    button.style.alignItems = "center";
    button.style.margin = "0";
    button.style.border = "none";
    button.appendChild(image);
    shadow.appendChild(button);

    button.addEventListener("click", () => {
      if (screenfull.enabled) {
        screenfull.toggle();
      }
    });
  }

  disconnectedCallback() {}
}

document.addEventListener("DOMContentLoaded", function(event) {
  customElements.define("full-screen", Fullscreen);
});
