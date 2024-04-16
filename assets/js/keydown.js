export default {
  mounted() {
    window.addEventListener("keydown", (event) => {
      // Ignore any modifier keys
      if(event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) {
        return
      }

      // Ignore last slot, it will trigger events
      if(document.archiveTarget == "last") {
        return
      }

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

    this.el.onmouseover = (event) => {
      let target = event.target.closest("div[phx-value-card]")
      if(target != undefined) {
        document.archiveTarget = event.target.closest("div[phx-value-card]").getAttribute("phx-value-card")
      }
    }

    this.el.onmouseout = (event) => {
      document.archiveTarget = undefined
    }
  }
}
