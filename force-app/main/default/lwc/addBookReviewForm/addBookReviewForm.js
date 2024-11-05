import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addReview from '@salesforce/apex/BookReviewController.addReview';
import getBookOptions from '@salesforce/apex/BookController.getBookOptions';

export default class AddBookReviewForm extends LightningElement {

  @track bookOptions = [];
  @track book = '';
  @track reviewName = '';
  @track dateOfReview = '';
  @track rating = '';
  @track reviewText = '';
  @api isOpen = false;

  @api openModal() {
    this.isOpen = true;
  }

  connectedCallback() {
    this.loadBookOptions();
  }

  handleClose() {
    this.isOpen = false;
  }

  handleInputChange(event) {
    const field = event.target.dataset.id;
    this[field] = event.target.value;
  }

  handleBookChange(event) {
    this.book = event.detail.value;
  }

  loadBookOptions() {
    getBookOptions()
      .then(result => {
        this.bookOptions = result.map(option => ({
          label: option.label,
          value: option.value
        }));
      })
      .catch(error => {
        this.showError('Error loading books: ' + (error.body ? error.body.message : error.message));
      });
  }

  handleSave() {
    if (!this.book || !this.reviewName) {
      this.showError('Please fill in all required fields: Book and Book Review Name.');
      return;
    }

    addReview({
      bookId: this.book,
      reviewName: this.reviewName,
      dateOfReview: this.dateOfReview || null,
      rating: this.rating ? parseInt(this.rating, 10) : null,
      reviewText: this.reviewText || null
    })
      .then(() => {
        this.isOpen = false;
        this.dispatchEvent(new CustomEvent('reviewadded'));
        this.showSuccess('Review has been added successfully');
      })
      .catch(error => {
        console.error('Error:', error);
        this.showError('Error saving review: ' + (error.body ? error.body.message : error.message));
      });
  }

  showSuccess(message) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Success',
        message: message,
        variant: 'success'
      })
    );
  }

  showError(message) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Error',
        message: message,
        variant: 'error'
      })
    );
  }
}
