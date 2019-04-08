import ePub, { Rendition, Book } from "epubjs";
import { Location, DisplayedLocation } from "epubjs/types/rendition";

class EpubViewer extends HTMLElement {
  constructor(private rendition: Rendition, private book: Book) {
    super();
  }
  static get observedAttributes() {
    return ["page", "percentage", "width", "height"];
  }

  attributeChangedCallback(name: string, oldValue: string, newValue: string) {
    if (!this.rendition) {
      return;
    }
    if (name === "width" || name === "height") {
      const width: number = parseInt(this.getAttribute("width") || "");
      const height: number = parseInt(this.getAttribute("height") || "");
      this.rendition.resize(width, height);
    } else if (name === "page") {
      const oldPage = parseInt(oldValue, 10);
      const newPage = parseInt(newValue, 10);
      if (newPage > oldPage) {
        this.rendition.next();
      } else {
        this.rendition.prev();
      }
    } else if (name === "percentage") {
      const cfi = this.book.locations.cfiFromPercentage(
        parseFloat(newValue) / 100
      );
      this.rendition.display(cfi);
    }
  }

  connectedCallback() {
    const shadow = this.attachShadow({ mode: "open" });
    const bookContainer: Element = document.createElement("div");
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

    this.rendition.on("relocated", this.relocatedListener);
    this.rendition.on("keyup", this.keyListener);
    this.rendition.hooks.content.register(contents => {
      contents.window.addEventListener("mousemove", evt => {
        this.dispatchEvent(new Event("mousemove"));
      });
    });

    const displayed = this.rendition.display();

    this.book.ready
      .then(() => {
        const locations = this.book.locations.generate(1600);
        return locations;
      })
      .then((locations: object) => {
        this.dispatchEvent(new Event("ready"));
      });
  }

  keyListener = (event: KeyboardEvent) => {
    switch (event.key) {
      case "ArrowLeft":
        this.rendition.prev();
        break;
      case "ArrowRight":
        this.rendition.next();
        break;
    }
  };

  getCurrentPercentage = (location: Location | DisplayedLocation): number => {
    if (this.isLocation(location)) {
      return this.book.locations.percentageFromCfi(location.start.cfi);
    } else {
      return this.book.locations.percentageFromCfi(location.cfi);
    }
  };

  isLocation = (
    location: Location | DisplayedLocation
  ): location is Location => {
    return (<Location>location).start != undefined;
  };

  relocatedListener = (location: Location | DisplayedLocation) => {
    const currentLocation = this.getCurrentPercentage(location);
    const pageChangeEvent = new CustomEvent("pageChanged", {
      detail: currentLocation * 100
    });
    this.dispatchEvent(pageChangeEvent);
  };
}

document.addEventListener("DOMContentLoaded", function(event) {
  customElements.define("epub-viewer", EpubViewer);
});
