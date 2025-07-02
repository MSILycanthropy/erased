export class Editor {
  constructor(options = {}) {
    this.element = document.querySelector(".erased-editor");

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

    if (this.onClick) {
      this.onClick(block, type, this.availableBlockAttributes[type]);
    }
  };

  #setupBlockAttributes() {
    const attributesScript = this.element.querySelector(
      "#erased-editor-attributes"
    );

    this.availableBlockAttributes = JSON.parse(attributesScript.textContent);
  }
}
