export default {
  mounted() {
    this.el.onfocus = (event) => {
      document.isTyping = true;
      this.el.select();
    }

    this.el.onblur = (event) => {
      document.isTyping = false;
    }
  }
}
