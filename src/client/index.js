class EpubViewer extends HTMLElement {
  constructor() {
    super();
    const shadow = this.attachShadow({ mode: "open" });
    const info = document.createElement("div");
    debugger;
    const epubLocation = this.getAttribute("epub");
    info.textContent = epubLocation + "BLa bla bla";
    shadow.appendChild(info);
  }
}

document.addEventListener("DOMContentLoaded", function(event) {
  customElements.define("epub-viewer", EpubViewer);
  Elm.Main.init();
});
