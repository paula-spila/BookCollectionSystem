import { LightningElement, api, track } from 'lwc';
import addToCollection from '@salesforce/apex/BookInUserCollectionController.addToCollection';
import removeFromWishlist from '@salesforce/apex/WishlistController.removeFromWishlist';
import isBookInWishlist from '@salesforce/apex/WishlistController.isBookInWishlist';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class AddToCollectionForm extends NavigationMixin(LightningElement) {
  @api isOpen;
  @api bookId;

  @track dateStarted = '';
  @track dateFinished = '';
  @track currentPage = 0;
  @track isbn = '';
  @track dateBought = '';
  @track readingStatus = '';
  @track timesRead = 0;
  @track format = '';

  readingStatusOptions = [
    { label: 'Izlasīta', value: 'Izlasīta' },
    { label: 'Gribu izlasīt', value: 'Gribu izlasīt' },
    { label: 'Pašlaik lasu', value: 'Pašlaik lasu' }
  ];

  formatOptions = [
    { label: '--Nav norādīts--', value: '' },
    { label: 'Cietie vāki', value: 'Cietie vāki' },
    { label: 'Mikstie vāki', value: 'Mikstie vāki' },
    { label: 'E-grāmata', value: 'E-grāmata' },
    { label: 'Audiogrāmata', value: 'Audiogrāmata' }
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
      this.showToast('Kļūda!', 'Lasīšanas statuss ir obligāts.', 'error');
      return;
    }
    const today = new Date().toISOString().split('T')[0];
    const dateToSave = this.dateBought || today;

    if (new Date(dateToSave) > new Date()) {
      this.showToast('Kļūda!', 'Pirkšanas datums nevar būt nākotnē.', 'error');
      return;
    }
    if (this.currentPage < 0 || isNaN(this.currentPage)) {
      this.showToast('Kļūda!', 'Pašreizējā lappusei jābūt pozitīvai vērtībai.', 'error');
      return;
    }
    if (this.timesRead < 0 || isNaN(this.timesRead)) {
      this.showToast('Kļūda!', 'Lasīšanas reizēm jābūt pozitīvam skaitlim.', 'error');
      return;
    }

    addToCollection({
      bookId: this.bookId,
      dateStarted: this.dateStarted || null,
      dateFinished: this.dateFinished || null,
      currentPage: this.currentPage,
      isbn: this.isbn || null,
      dateBought: dateToSave,
      readingStatus: this.readingStatus,
      timesRead: this.timesRead,
      format: this.format,
      dateBought: dateToSave,
    })
      .then(() => {
        return isBookInWishlist({ bookId: this.bookId });
      })
      .then((isInWishlist) => {
        if (isInWishlist) {
          return removeFromWishlist({ bookId: this.bookId });
        }
        return Promise.resolve();
      })
      .then(() => {
        this.showToast(
          'Veiksme!',
          'Grāmata veiksmīgi pievienota kolekcijai.' +
          (this.readingStatus === 'Gribu izlasīt'
            ? ' (Un noņemta arī no vēlmju saraksta.)'
            : ''),
          'success'
        );
        this.closeModal();
        this[NavigationMixin.Navigate]({
          type: 'standard__navItemPage',
          attributes: {
            apiName: 'Mana_kolekcija'
          }
        });
      })
      .catch((error) => {
        console.error('Error:', error);
        this.showToast('Kļūda!', 'Neizdevās saglabāt datus. Mēģiniet vēlreiz.', 'error');
      });
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
