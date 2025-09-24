import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["tagList", "newTag", "template", "list"];
  static values = { onlyOne: Boolean };

  addTag(event) {
    // prevent hotkey form submitting the form (default action for "enter" key)
    event.preventDefault();

    // Check if tag already exist
    const newTagName = this.newTagTarget.value.trim();
    if (newTagName.length == 0) {
      return;
    }

    const tags = this.tagListTarget.value.split(",");
    const index = tags.indexOf(newTagName);
    if (index != -1) {
      // highlight the value in red
      this.newTagTarget.classList.add("tag-error");
      return;
    }

    // add to tagList
    if (this.tagListTarget.value == "") {
      this.tagListTarget.value = newTagName;
    } else {
      this.tagListTarget.value = this.tagListTarget.value.concat(`,${newTagName}`);
    }
    // manualy dispatch an Input event so the change can get picked up by other controllers
    this.tagListTarget.dispatchEvent(new InputEvent("input"));

    // Create new li component with value
    const newTagElement = this.templateTarget.content.cloneNode(true);
    const spanElement = newTagElement.querySelector("span");
    spanElement.innerText = newTagName;
    this.listTarget.appendChild(newTagElement);

    // Clear new tag value
    this.newTagTarget.value = "";

    // hide tag input if limited to one tag
    if (this.tagListTarget.value.split(",").length == 1 && this.onlyOneValue == true) {
      this.newTagTarget.style.display = "none";
    }
  }

  removeTag(event) {
    // Text to remove
    const tagName = event.srcElement.previousElementSibling.textContent;

    // Remove tag from list
    const tags = this.tagListTarget.value.split(",");
    this.tagListTarget.value = tags.filter((tag) => tag != tagName).join(",");

    // manualy dispatch an Input event so the change gets picked up by the bulk form controller
    this.tagListTarget.dispatchEvent(new InputEvent("input"));

    // Remove HTML element from the list
    event.srcElement.parentElement.parentElement.remove();

    // Make sure the tag input is displayed
    if (this.tagListTarget.value.length == 0) {
      this.newTagTarget.style.display = "block";
    }
  }

  filterInput(event) {
    // clear error class if key is not enter
    if (event.key !== "Enter") {
      this.newTagTarget.classList.remove("tag-error");
    }

    // Strip comma from tag name
    if (event.key === ",") {
      event.srcElement.value = event.srcElement.value.replace(",", "");
    }
  }
}
