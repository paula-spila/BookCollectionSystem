import { LightningElement, track, api } from 'lwc';
import addReview from '@salesforce/apex/BookReviewController.addReview';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddBookReviewForm extends LightningElement {
  @api isOpen;
  @api book;
  @track rating = '';
  @track reviewText = '';

  handleInputChange(event) {
    const field = event.target.dataset.id;
    if (field === 'rating') {
      this.rating = event.target.value;
    } else if (field === 'reviewText') {
      this.reviewText = event.target.value;
    }
  }

  handleClose() {
    this.dispatchEvent(new CustomEvent('close'));
  }

  handleSave() {
    if (!this.rating || this.rating < 0 || this.rating > 5) {
      this.showToast('Kļūda!', 'Lūdzu ievadiet vērtējumu no 0 līdz 5.', 'error');
      return;
    }

    if (!this.book || !this.book.BookId) {
      this.showToast('Kļūda!', 'Neizdevās atrast saistīto grāmatu.', 'error');
      return;
    }

    addReview({
      bookId: this.book.BookId,
      rating: this.rating,
      reviewText: this.reviewText
    })
      .then(() => {
        this.showToast('Veiksme!', 'Atsauksme veiksmīgi saglabāta!', 'success');
        this.handleClose();
        this.dispatchEvent(new CustomEvent('reviewadded'));
      })
      .catch((error) => {
        console.error('Error saving review:', error);
        this.showToast('Kļūda!', 'Neizdevās saglabāt atsauksmi.', 'error');
      });
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({
      title,
      message,
      variant
    }));
  }
}
