import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ['input'];

  isNumber(event) {
    const keyCode = event.which ? event.which : event.keyCode;
    if (keyCode >= 48 && keyCode <= 57) { // keyCode for 0-9: 48-57
      return true;
    } else {
      event.preventDefault();
      return false;
    }
  }
}
