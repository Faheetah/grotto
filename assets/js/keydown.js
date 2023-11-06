export default {
  mounted() {
    window.addEventListener("keydown", (event) => {
      if(document.archiveTarget) {
        this.pushEvent("archive_card", {
          card: document.archiveTarget
        })
      }
    })
  }
}
