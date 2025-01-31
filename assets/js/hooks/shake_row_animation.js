export default {
    mounted() {
        this.handleEvent('shake-row', data => {
            const inputRowId = `input-row-${data.id}`;
            const inputRow = document.getElementById(inputRowId);

            const animationEndHandler = () => {
                inputRow.classList.remove("shake-element");
                inputRow.removeEventListener("animationend", animationEndHandler);
            }

            inputRow.classList.add("shake-element");
            inputRow.addEventListener("animationend", animationEndHandler);
        })
    }
}