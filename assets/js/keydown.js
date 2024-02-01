export default {
  mounted() {
    window.addEventListener("keydown", (event) => {
      if(document.archiveTarget && event.key == "c") {
        this.pushEvent("archive_card", {
          card: document.archiveTarget
        })
      }

      let colors = {
        "1": "green",
        "2": "yellow",
        "3": "orange",
        "4": "red",
        "5": "purple",
        "6": "blue"
      }

      let color = colors[event.key]
      if(document.archiveTarget && color != undefined) {
        this.pushEvent("set_color", {
          card: document.archiveTarget,
          color: color
        })
      }
    })
  }
}
