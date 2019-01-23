class EpubViewer extends HTMLElement {
  constructor() {
    super();
  }

  static get observedAttributes() {
    return ["width", "height"];
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (this.rendition) {
      const width = this.getAttribute("width");
      const height = this.getAttribute("height");
      this.rendition.resize(width, height);
    }
  }

  connectedCallback() {
    const shadow = this.attachShadow({ mode: "open" });
    const bookContainer = document.createElement("div");
    const location = this.getAttribute("epub");
    const width = this.getAttribute("width");
    const height = this.getAttribute("height");

    shadow.appendChild(bookContainer);

    this.book = ePub(location);
    this.rendition = this.book.renderTo(bookContainer, {
      flow: "paginated",
      width: width,
      height: height
    });
    this.displayed = this.rendition.display();

    this.book.ready.then(() => {
      const prevButton = document.getElementById("prevButton");
      const nextButton = document.getElementById("nextButton");

      prevButton.addEventListener(
        "click",
        e => {
          this.book.package.metadata.direction === "rtl"
            ? this.rendition.next()
            : this.rendition.prev();
        },
        false
      );
      nextButton.addEventListener(
        "click",
        e => {
          this.book.package.metadata.direction === "rtl"
            ? this.rendition.prev()
            : this.rendition.next();
        },
        false
      );
    });
  }
}

document.addEventListener("DOMContentLoaded", function(event) {
  customElements.define("epub-viewer", EpubViewer);
  Elm.Main.init();
});
