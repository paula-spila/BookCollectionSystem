import { LightningElement, track, api } from 'lwc';
import addReview from '@salesforce/apex/BookReviewController.addReview';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddBookReviewForm extends LightningElement {
  @api isOpen;
  @api book;
  @track rating;
  @track reviewText;

  handleInputChange(event) {
    const field = event.target.dataset.id;
    if (field === 'rating') {
      this.rating = event.target.value;
    } else if (field === 'reviewText') {
      this.reviewText = event.target.value;
    }
  }

  handleClose() {
    try {
      this.dispatchEvent(new CustomEvent('close', {
        bubbles: true,
        composed: true,
      }));
    } catch (error) {
      console.error('Error in handleClose:', error);
    }
  }

  handleSave() {
    if (!this.rating || this.rating < 0 || this.rating > 5) {
      this.showToast('Error', 'Please provide a rating between 0 and 5.', 'error');
      return;
    }

    if (!this.book || !this.book.Id) {
      this.showToast('Error', 'Book information is missing.', 'error');
      console.error('Missing book:', this.book);
      return;
    }

    addReview({
      book: this.book.Id,
      rating: this.rating,
      reviewText: this.reviewText
    })
      .then(() => {
        this.showToast('Success', 'Review added successfully!', 'success');
        this.handleClose();
        this.dispatchEvent(new CustomEvent('reviewadded'));
        location.reload();
      })
      .catch((error) => {
        console.error('Error saving review:', error);
        this.showToast('Error', 'Failed to save review.', 'error');
      });
  }

  showToast(title, message, variant) {
    try {
      const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
      });
      this.dispatchEvent(event);
    } catch (toastError) {
      console.error('Error showing toast:', toastError);
    }
  }

}
