import { LightningElement, api, track } from 'lwc';
import addToCollection from '@salesforce/apex/BookInUserCollectionController.addToCollection';
import removeFromWishlist from '@salesforce/apex/WishlistController.removeFromWishlist';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddToCollectionForm extends LightningElement {
  @api isOpen;
  @api bookId;

  @track readingStatus = '';
  @track dateBought = '';
  @track isbn = '';

  readingStatusOptions = [
    { label: 'Izlasīta', value: 'Read' },
    { label: 'Gribu izlasīt', value: 'Want to Read' },
    { label: 'Pašlaik lasu', value: 'Currently Reading' }
  ];

  handleInputChange(event) {
    const field = event.target.dataset.id;
    this[field] = event.target.value;
  }

  closeModal() {
    this.dispatchEvent(new CustomEvent('closemodal'));
  }

  saveToCollection() {
    if (!this.readingStatus) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Kļūda!',
          message: 'Lasīšanas statuss ir obligāts.',
          variant: 'error'
        })
      );
      return;
    }

    const today = new Date().toISOString().split('T')[0];
    const dateToSave = this.dateBought || today;

    if (new Date(dateToSave) > new Date()) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Kļūda!',
          message: 'Pirkšanas datums nevar būt nākotnē.',
          variant: 'error'
        })
      );
      return;
    }

    addToCollection({
      bookId: this.bookId,
      readingStatus: this.readingStatus,
      dateBought: dateToSave,
      isbn: this.isbn
    })
      .then(() => {
        return removeFromWishlist({ bookId: this.bookId });
      })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Veiksme!',
            message: 'Grāmata veiksmīgi pievienota kolekcijai un noņemta no vēlmju saraksta.',
            variant: 'success'
          })
        );
        this.closeModal();
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Kļūda!',
            message: 'Neizdevās pievienot grāmatu kolekcijai vai noņemt no vēlmju saraksta. Mēģiniet vēlreiz.',
            variant: 'error'
          })
        );
        console.error('Error processing request:', error);
      });
  }
}
