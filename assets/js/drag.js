export default {
  mounted() {
    this.el.ondrop = (event) => {
      event.preventDefault();
      const sourceCard = event.dataTransfer.getData("cardId");
      const targetCard = event.target.getAttribute("phx-value-card");
      const list = event.target.getAttribute("phx-value-list");

      this.pushEvent("reorder_card", {
        sourceCard: sourceCard,
        targetCard: targetCard,
        list: list,
      })

      event.currentTarget.classList.remove("pt-12");
    }

    this.el.ondragover = (event) => {
      event.currentTarget.classList.add("pt-12");
    }

    this.el.ondragleave = (event) => {
      event.currentTarget.classList.remove("pt-12");
    }

    this.el.ondragstart = (event) => {
      event.dataTransfer.setData(
        "cardId",
        event.target.getAttribute("phx-value-card")
      )
    }

    this.el.onmouseover = (event) => {
      document.archiveTarget = event.target.getAttribute("phx-value-card")
    }

    this.el.onmouseout = (event) => {
      document.archiveTarget = undefined
    }
  }
}
