export default {
  mounted() {
    window.addEventListener("keydown", (event) => {
      if(document.archiveTarget && event.key == "c") {
        this.pushEvent("archive_card", {
          card: document.archiveTarget
        })
      }

      if(document.archiveTarget && event.key == "1") {
        this.pushEvent("set_color", {
          card: document.archiveTarget,
          color: "green"
        })
      }

      if(document.archiveTarget && event.key == "2") {
        this.pushEvent("set_color", {
          card: document.archiveTarget,
          color: "yellow"
        })
      }

      if(document.archiveTarget && event.key == "3") {
        this.pushEvent("set_color", {
          card: document.archiveTarget,
          color: "orange"
        })
      }

      if(document.archiveTarget && event.key == "4") {
        this.pushEvent("set_color", {
          card: document.archiveTarget,
          color: "red"
        })
      }
    })
  }
}
