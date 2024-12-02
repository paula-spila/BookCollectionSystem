import { LightningElement, api } from 'lwc';

export default class EditBookForm extends LightningElement {
  @api showModal = false;
  @api currentPage = 0;
  @api totalPages = 0;

  handlePageChange(event) {
    let inputPage = parseInt(event.target.value, 10);
    let adjustedPage = inputPage;

    if (inputPage > this.totalPages) {
      adjustedPage = this.totalPages;
      this.dispatchEvent(
        new CustomEvent('showtoast', {
          detail: {
            title: 'Warning',
            message: `Pašreizējā lapa nevar pārsniegt kopējās lapas (${this.totalPages}).`,
            variant: 'warning',
          },
        })
      );
    } else if (inputPage < 1) {
      adjustedPage = 1;
      this.dispatchEvent(
        new CustomEvent('showtoast', {
          detail: {
            title: 'Warning',
            message: 'Pašreizējā lapa nevar būt mazāka par 1.',
            variant: 'warning',
          },
        })
      );
    }

    event.target.value = adjustedPage;
    this.currentPage = adjustedPage;

    this.dispatchEvent(
      new CustomEvent('pagechange', {
        detail: { currentPage: adjustedPage },
      })
    );
  }

  handleSave() {
    this.dispatchEvent(new CustomEvent('save'));
  }

  handleComplete() {
    this.dispatchEvent(new CustomEvent('complete'));
  }

  handleCancel() {
    this.dispatchEvent(new CustomEvent('cancel'));
  }
}
