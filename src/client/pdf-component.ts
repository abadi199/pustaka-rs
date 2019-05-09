import pdfjs, {
  PDFJS,
  PDFPageProxy,
  PDFDocumentProxy,
  PDFRenderParams
} from "pdfjs-dist";

class PdfViewer extends HTMLElement {
  constructor() {
    super();
  }

  static get observedAttributes() {
    return [];
  }

  attributeChangedCallback(name: string, oldValue: string, newValue: string) {}

  connectedCallback() {
    const shadow = this.attachShadow({ mode: "open" });
    const canvas: HTMLCanvasElement = document.createElement("canvas");
    const src = this.getAttribute("src");

    if (src === null) {
      return;
    }

    shadow.appendChild(canvas);

    pdfjs.getDocument(src).promise.then(pdf => this.getPage(pdf, canvas));
  }

  getPage(pdf: PDFDocumentProxy, canvas: HTMLCanvasElement) {
    pdf.getPage(1).then(page => this.renderPage(page, canvas));
  }

  renderPage(page: PDFPageProxy, canvas: HTMLCanvasElement) {
    const scale = 1;
    const viewport = page.getViewport(scale);
    var context: CanvasRenderingContext2D | null = canvas.getContext("2d");
    canvas.height = viewport.height;
    canvas.width = viewport.width;

    if (context === null) {
      return;
    }

    // Render PDF page into canvas context
    var renderContext: PDFRenderParams = {
      canvasContext: context,
      viewport: viewport
    };
    var renderTask = page.render(renderContext);
    renderTask.promise.then(function() {
      console.log("Page rendered");
    });
  }
}
