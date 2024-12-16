import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getCurrentlyReadingBooks from '@salesforce/apex/BookInUserCollectionController.getCurrentlyReadingBooks';
import updateCurrentPage from '@salesforce/apex/BookInUserCollectionController.updateCurrentPage';
import markBookAsCompleted from '@salesforce/apex/BookInUserCollectionController.markBookAsCompleted';

export default class CurrentlyReadingComponent extends NavigationMixin(LightningElement) {
  @track books = [];
  @track showModal = false;
  @track selectedBookId = null;
  @track selectedCurrentPage = 0;
  @track selectedTotalPages = 0;

  @wire(getCurrentlyReadingBooks)
  wiredBooks({ error, data }) {
    if (data) {
      this.books = data;
    } else {
      this.books = [];
      this.showToast('Error', 'Failed to fetch books currently being read.', 'error');
    }
  }

  handleEditPage(event) {
    event.stopPropagation();
    const { id, currentPage, totalPages } = event.target.dataset;
    this.selectedBookId = id;
    this.selectedCurrentPage = parseInt(currentPage, 10);
    this.selectedTotalPages = parseInt(totalPages, 10);
    this.showModal = true;
  }

  handlePageChange(event) {
    this.selectedCurrentPage = event.detail.currentPage;
  }

  handleModalSave() {
    if (this.selectedCurrentPage === 0) {
      this.selectedCurrentPage = 1;
      this.showToast('Warning', 'Pašreizējā lapa nevar būt 0. Tika iestatīta uz 1.', 'warning');
    }

    if (this.selectedCurrentPage === this.selectedTotalPages) {
      this.markAsCompleted();
    } else {
      this.updateCurrentPage();
    }
  }

  updateCurrentPage() {
    updateCurrentPage({ bookId: this.selectedBookId, currentPage: this.selectedCurrentPage })
      .then(() => {
        this.books = this.books.map(book => {
          if (book.Id === this.selectedBookId) {
            return { ...book, Current_page__c: this.selectedCurrentPage };
          }
          return book;
        });
        this.showToast('Success', `Pašreizējā lapa atjaunināta uz ${this.selectedCurrentPage}.`, 'success');
      })
      .catch(() => {
        this.showToast('Error', 'Failed to update the current page.', 'error');
      })
      .finally(() => {
        this.showModal = false;
      });
  }

  markAsCompleted() {
    markBookAsCompleted({ bookId: this.selectedBookId })
      .then(() => {
        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
            recordId: this.selectedBookId,
            objectApiName: 'BookInUserCollection__c',
            actionName: 'view',
          },
        });
        this.books = this.books.filter(book => book.Id !== this.selectedBookId);
        this.showToast('Success', 'Grāmata veiksmīgi pabeigta.', 'success');
      })
      .catch(() => {
        this.showToast('Error', 'Failed to mark the book as completed.', 'error');
      })
      .finally(() => {
        this.showModal = false;
      });
  }

  handleMarkAsCompleted() {
    this.markAsCompleted();
  }

  handleBookClick(event) {
    const bookInUserCollectionId = event.currentTarget.dataset.id;
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: bookInUserCollectionId,
        objectApiName: 'BookInUserCollection__c',
        actionName: 'view',
      },
    });
  }

  handleModalClose() {
    this.showModal = false;
  }

  handleShowToast(event) {
    const { title, message, variant } = event.detail;
    this.showToast(title, message, variant);
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title,
      message,
      variant,
    });
    this.dispatchEvent(event);
  }
}
