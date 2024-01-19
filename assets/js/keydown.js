export default {
  mounted() {
    window.addEventListener("keydown", (event) => {
      if(document.archiveTarget && event.key == "c") {
        this.pushEvent("archive_card", {
          card: document.archiveTarget
        })
      }
    })
  }
}
