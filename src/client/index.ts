declare var ePub: any;
declare var Elm: any;

class EpubViewer extends HTMLElement {
  constructor(
    private rendition: any,
    private book: any,
    private displayed: any,
    private pageNumber: number
  ) {
    super();
  }

  static get observedAttributes() {
    // return ["width", "height", "pageNumber"];
    return ["pageNumber"];
  }

  attributeChangedCallback(name, oldValue, newValue) {
    console.log(name);
    if (this.rendition) {
      if (name === "width" || name === "height") {
        const width = this.getAttribute("width");
        const height = this.getAttribute("height");
        this.rendition.resize(width, height);
      }
      else if (name === "pageNumber") {
        console.log(this.getAttribute("pageNumber"));
      }
    }
  }

  connectedCallback() {
    const shadow = this.attachShadow({ mode: "open" });
    const bookContainer = document.createElement("div");
    const location = this.getAttribute("epub");
    const width = this.getAttribute("width");
    const height = this.getAttribute("height");
    this.pageNumber = parseInt(this.getAttribute("pageNumber") || "", 10);
    console.log("pageNumber", this.pageNumber);

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

      if (prevButton) {
        prevButton.addEventListener(
          "click",
          e => {
            this.book.package.metadata.direction === "rtl"
              ? this.rendition.next()
              : this.rendition.prev();
          },
          false
        );
      }
      if (nextButton) {
        nextButton.addEventListener(
          "click",
          e => {
            this.book.package.metadata.direction === "rtl"
              ? this.rendition.prev()
              : this.rendition.next();
          },
          false
        );
      }
    });
  }
}

document.addEventListener("DOMContentLoaded", function(event) {
  customElements.define("epub-viewer", EpubViewer);
  if (Elm && Elm.Main && Elm.Main.init) {
    Elm.Main.init();
  }
});
