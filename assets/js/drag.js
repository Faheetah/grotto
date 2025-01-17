export default {
  mounted() {
    this.el.ondrop = (event) => {
      event.preventDefault();

      const targetCard = event.target.closest("div[phx-value-card]").getAttribute("phx-value-card");
      const list = event.target.closest("div[phx-value-card]").getAttribute("phx-value-list");

      this.pushEvent("reorder_card", {
        sourceCard: document.sourceCard,
        targetCard: targetCard,
        list: list,
      })

      event.target.classList.remove("pt-12")
      document.sourceCard = undefined
      document.draggedCards.forEach((target, i) => target.classList.remove("pt-12"))
      document.draggedCards = []
    }

    this.el.ondragover = (event) => {
      card = event.target.closest("div[phx-value-card]").getAttribute("phx-value-card")

      if(card && card != document.sourceCard) {
        target = event.target.closest("div[phx-value-card]")
        target.classList.add("pt-12")
        document.draggedCards.push(target)
      }
    }

    this.el.ondragleave = (event) => {
      card = event.target.getAttribute("phx-value-card")

      if(card) {
        event.target.closest("div[phx-value-card]").classList.remove("pt-12")
      }
    }

    this.el.ondragstart = (event) => {
      document.sourceCard = event.target.closest("div[phx-value-card]").getAttribute("phx-value-card")
      document.draggedCards = []
    }
  }
}
