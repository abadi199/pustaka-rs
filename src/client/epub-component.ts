declare var Elm: any;

import ePub from "epubjs";

class EpubViewer extends HTMLElement {
  constructor(
    private rendition: any,
    private book: any,
    private displayed: any,
  ) {
    super();
  }

  static get observedAttributes() {
    return ["page", "width", "height"];
  }

  attributeChangedCallback(name: string, oldValue: string, newValue: string) {
    if (!this.rendition) {
      return;
    }
    if (name === "width" || name === "height") {
      const width = this.getAttribute("width");
      const height = this.getAttribute("height");
      this.rendition.resize(width, height);
    }
    else if (name === "page") {
      const oldPage = parseInt(oldValue, 10);
      const newPage = parseInt(newValue, 10);
      if (newPage > oldPage) {
        this.book.package.metadata.direction === "rtl"
          ? this.rendition.prev()
          : this.rendition.next();
      } else {
        this.book.package.metadata.direction === "rtl"
          ? this.rendition.next()
          : this.rendition.prev();
      }
    }
  }

  connectedCallback() {
    const shadow = this.attachShadow({ mode: "open" });
    const bookContainer = document.createElement("div");
    const location = this.getAttribute("epub");
    const width = this.getAttribute("width");
    const height = this.getAttribute("height");

    shadow.appendChild(bookContainer);

    if (!location) {
      alert("location attribute is empty!");
      return;
    }

    this.book = ePub(location);
    this.rendition = this.book.renderTo(bookContainer, {
      flow: "paginated",
      width: width,
      height: height
    });

    this.displayed = this.rendition.display();
  }
}

document.addEventListener("DOMContentLoaded", function(event) {
  customElements.define("epub-viewer", EpubViewer);
});
