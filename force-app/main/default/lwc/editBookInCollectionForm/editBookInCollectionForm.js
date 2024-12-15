import { LightningElement, api, track } from 'lwc';
import updateBookCollection from '@salesforce/apex/BookInUserCollectionController.updateBookCollection';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EditBookInCollectionForm extends LightningElement {
  @api isOpen;
  @api collection;
  @track formatOptions = [
    { label: '--Nav norādīts--', value: '' },
    { label: 'Cietie vāki', value: 'Hardcover' },
    { label: 'Mīkstie vāki', value: 'Paperback' },
    { label: 'E-grāmata', value: 'E-book' },
    { label: 'Audiogrāmata', value: 'Audiobook' }
  ];

  @track readingStatusOptions = [
    { label: 'Gribu izlasīt', value: 'Want to Read' },
    { label: 'Pašlaik lasu', value: 'Currently Reading' },
    { label: 'Izlasīta', value: 'Completed' }
  ];

  handleInputChange(event) {
    const field = event.target.dataset.id;
    const value = event.target.value === 'Nav' ? null : event.target.value;
    this.collection = { ...this.collection, [field]: event.target.value };
  }

  validateForm() {
    if (this.collection.CurrentPage && this.collection.CurrentPage < 0) {
      this.showToast('Kļūda!', 'Pašreizējā lapa nevar būt negatīva.', 'error');
      return false;
    }

    if (
      this.collection.CurrentPage &&
      this.collection.TotalPages &&
      parseInt(this.collection.CurrentPage, 10) > parseInt(this.collection.TotalPages, 10)
    ) {
      this.showToast('Kļūda!', `Pašreizējā lapa (${this.collection.CurrentPage}) nevar būt lielāka par kopējo lapu skaitu (${this.collection.TotalPages}).`, 'error');
      return false;
    }

    if (this.collection.TimesRead && this.collection.TimesRead < 0) {
      this.showToast('Kļūda!', 'Lasīšanas reižu skaits nevar būt negatīvs.', 'error');
      return false;
    }

    const isValidDate = (date) => {
      return date && !isNaN(Date.parse(date));
    };

    if (isValidDate(this.collection.DateStarted)) {
      const today = new Date().toISOString().split('T')[0];
      if (this.collection.DateStarted > today) {
        this.showToast('Kļūda!', 'Datums, kad sāka lasīt, nevar būt nākotnē.', 'error');
        return false;
      }
    }

    return true;
  }


  closeModal() {
    this.dispatchEvent(new CustomEvent('closemodal'));
  }

  saveChanges() {
    if (!this.validateForm()) {
      return;
    }
    const recordToUpdate = {
      Id: this.collection.Id,
      Current_page__c: this.collection.CurrentPage || null,
      Times_read__c: this.collection.TimesRead || null,
      Date_started__c: this.collection.DateStarted === 'Nav' ? null : this.collection.DateStarted,
      Date_finished__c: this.collection.DateFinished === 'Nav' ? null : this.collection.DateFinished,
      ISBN__c: this.collection.ISBN || null,
      Format__c: this.collection.Format === '--None--' ? null : this.collection.Format,
      Reading_status__c: this.collection.ReadingStatus === '--None--' ? null : this.collection.ReadingStatus
    };

    updateBookCollection({ bookInUserCollection: recordToUpdate })
      .then(() => {
        this.showToast('Veiksme!', 'Kolekcijas ieraksts veiksmīgi atjaunināts.', 'success');
        this.dispatchEvent(new CustomEvent('collectionupdated'));
        this.closeModal();
      })
      .catch((error) => {
        console.error('Error updating book collection:', error);
        this.showToast('Kļūda!', 'Neizdevās atjaunināt kolekcijas ierakstu.', 'error');
      });
  }

  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title,
        message,
        variant
      })
    );
  }

}
