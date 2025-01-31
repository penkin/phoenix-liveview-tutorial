export default {
    mounted() {
      const classMappings = {
      'correct': 'bg-green-600',
      'incorrect': 'bg-red-600',
      'partial': 'bg-yellow-600'
    };
  
    this.handleEvent('guess-reveal-animation', data => {
      const currentRow = document.getElementById(`input-row-${data.guess_row}`);
      const inputCells = Array.from(currentRow.children);
  
      inputCells.forEach((inputCell, index) => {
        setTimeout(() => {
          let letterGuessResult = data.letter_statuses[index];
          let backgroundColor = classMappings[letterGuessResult];
          let componentID = `#input-cell-${data.guess_row}-${index}`;
          this.pushEventTo(componentID, "cell_background_update", { background: backgroundColor });
        }, index * 300);
      });
  
    });
  
    }
  };