export default {
  mounted() {
    this.el.ondrop = (event) => {
      event.preventDefault();
      const sourceCard = event.dataTransfer.getData("cardId");
      const targetCard = event.target.getAttribute("phx-value-card");

      this.pushEvent("reorder_card", {
        sourceCard: sourceCard,
        targetCard: targetCard,
      })

      event.currentTarget.classList.remove("bg-neutral-200");
      event.currentTarget.classList.add("bg-white");
    }
    this.el.ondragover = (event) => {
      event.currentTarget.classList.add("bg-neutral-200");
      event.currentTarget.classList.remove("bg-white");
    }
    this.el.ondragleave = (event) => {
      event.currentTarget.classList.remove("bg-neutral-200");
      event.currentTarget.classList.add("bg-white");
    }
  }
}

export const dragStart = (event) => {
  event.dataTransfer.setData(
    "cardId",
    event.target.getAttribute("phx-value-card")
  )
}
