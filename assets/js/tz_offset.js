export const TzOffset = {
  mounted() {
    const date = new Date();
    let tz_offset = date.getTimezoneOffset();
    this.pushEvent("local-timezone", {tz_offset: tz_offset})
  }
}
