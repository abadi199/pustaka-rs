class EpubViewer extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    const shadow = this.attachShadow({ mode: "open" });
    const info = document.createElement("div");
    const location = this.getAttribute("epub");
    console.log(location);

    shadow.appendChild(info);

    const book = ePub(location);
    const rendition = book.renderTo(info, { width: 600, height: 400 });
    const displayed = rendition.display();
  }
}

document.addEventListener("DOMContentLoaded", function(event) {
  customElements.define("epub-viewer", EpubViewer);
  Elm.Main.init();
});
