export class Editor {
  constructor(options = {}) {
    this.element = document.querySelector(".erased-editor");

    this.#setupAdjacencyList();
    this.#setupCurrentBlockAttributes();
    this.#setupBlockAttributes();

    this.element.addEventListener("click", this.clickListener);

    if (options.onClick) {
      this.onClick = options.onClick.bind(this);
    }
  }

  destroy() {
    this.element.removeEventListener("click", this.clickListener);
  }

  clickListener = (event) => {
    const block = event.target.closest("[data-erased-block]");

    if (!block) return;

    const type = block.dataset.erasedBlockName;
    const availableAttributes = this.availableBlockAttributes[type];
    const id = block.dataset.erasedBlock;
    const blockAttributes = this.currentBlockAttributes[id];

    if (this.onClick) {
      this.onClick(block, type, availableAttributes, blockAttributes);
    }
  };

  #setupBlockAttributes() {
    const attributesScript = this.element.querySelector(
      "#erased-editor-attributes"
    );

    this.availableBlockAttributes = JSON.parse(attributesScript.textContent);
  }

  #setupAdjacencyList() {
    const listScript = this.element.querySelector("#erased-editor-adjacency");

    this.adjacencyList = JSON.parse(listScript.textContent);
  }

  #setupCurrentBlockAttributes() {
    const attributesScript = this.element.querySelector(
      "#erased-editor-blocks"
    );

    this.currentBlockAttributes = JSON.parse(attributesScript.textContent);
  }
}
