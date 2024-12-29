import { LightningElement, api, track } from 'lwc';
import createLending from '@salesforce/apex/LendingHistoryController.createLending';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddLendingForm extends LightningElement {
  @api isOpen = false;
  @api bookId;
  @track lenderName = '';
  @track lendingDate = new Date().toISOString().split('T')[0];

  handleInputChange(event) {
    const field = event.target.dataset.id;
    this[field] = event.target.value;
  }

  closeModal() {
    this.dispatchEvent(new CustomEvent('closemodal'));
  }

  saveLending() {
    if (!this.lenderName) {
      this.showToast('Kļūda!', 'Aizņēmēja vārds ir obligāts.', 'error');
      return;
    }

    if (!this.lendingDate) {
      this.showToast('Kļūda!', 'Aizdošanas datums ir obligāts.', 'error');
      return;
    }

    const currentDate = new Date().toISOString().split('T')[0];
    if (this.lendingDate > currentDate) {
      this.showToast('Kļūda!', 'Aizdošanas datums nevar būt nākotnē.', 'error');
      return;
    }

    createLending({
      bookCollectionId: this.bookId,
      lenderName: this.lenderName,
      lendingDate: this.lendingDate,
      returnStatus: 'Not returned'
    })
      .then(() => {
        this.showToast('Veiksme!', 'Grāmata veiksmīgi aizdota.', 'success');
        this.dispatchEvent(new CustomEvent('lendingadded'));
        this.closeModal();
      })
      .catch((error) => {
        console.error('Error saving lending:', error);
        this.showToast('Kļūda!', 'Neizdevās saglabāt aizdošanas informāciju.', 'error');
      });
  }


  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
