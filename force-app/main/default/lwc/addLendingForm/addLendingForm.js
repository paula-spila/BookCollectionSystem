import { LightningElement, track, api } from 'lwc';
import createLending from '@salesforce/apex/LendingHistoryController.createLending';
//import getBookOptions from '@salesforce/apex/BookController.getBookOptions';
import getReturnStatusOptions from '@salesforce/apex/LendingHistoryController.getReturnStatusOptions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddLendingForm extends LightningElement {

  // @track bookOptions = [];
  @track returnStatusOptions = [];
  // @track book = '';
  @track lendingHistoryName = '';
  @track lendingDate = new Date().toISOString().split('T')[0];
  @track returnDate = '';
  @track returnStatus = 'Not returned';
  @api isOpen = false;

  connectedCallback() {
    // this.loadBookOptions();
    this.loadReturnStatusOptions();
  }

  @api openModal() {
    this.isOpen = true;
    this.lendingDate = new Date().toISOString().split('T')[0];
    this.returnStatus = 'Not returned';
  }

  handleClose() {
    this.isOpen = false;
  }

  handleInputChange(event) {
    const field = event.target.dataset.id;
    this[field] = event.target.value;
  }

  // handleBookChange(event) {
  //   this.book = event.detail.value;
  // }

  handleReturnStatusChange(event) {
    this.returnStatus = event.detail.value;
  }

  // loadBookOptions() {
  //   getBookOptions()
  //     .then(result => {
  //       this.bookOptions = result.map(option => ({
  //         label: option.label,
  //         value: option.value
  //       }));
  //     })
  //     .catch(error => {
  //       this.showError('Error loading books: ' + (error.body ? error.body.message : error.message));
  //     });
  // }

  loadReturnStatusOptions() {
    getReturnStatusOptions()
      .then(result => {
        this.returnStatusOptions = result.map(option => ({
          label: option.label,
          value: option.value
        }));
      })
      .catch(error => {
        this.showError('Error loading return statuses: ' + (error.body ? error.body.message : error.message));
      });
  }

  handleSave() {
    if (!this.book || !this.lendingHistoryName) {
      this.showError('Please fill in all required fields: Book and Lending History Name.');
      return;
    }

    createLending({
      // bookId: this.book,
      lendingHistoryName: this.lendingHistoryName,
      lendingDate: this.lendingDate || null,
      returnDate: this.returnDate || null,
      returnStatus: this.returnStatus || null
    })
      .then(() => {
        this.isOpen = false;
        this.dispatchEvent(new CustomEvent('lendingadded'));
        this.showSuccess('Lending has been added successfully');
      })
      .catch(error => {
        console.error('Error:', error);
        this.showError('Error saving lending: ' + (error.body ? error.body.message : error.message));
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
