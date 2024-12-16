import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class BookPage extends NavigationMixin(LightningElement) {
  @track books = [];
  @track isBookModalOpen = false;
  @track isAuthorModalOpen = false;

  @track filters = {
    search: '',
    genre: '',
    author: '',
  };

  handleFilterChange(event) {
    const { filterType, filterValue } = event.detail;
    this.filters[filterType] = filterValue;

    const bookCard = this.template.querySelector('c-book-card');
    if (bookCard) {
      bookCard.applyFilters(this.filters);
    }
  }

  handleClearFilters() {
    this.filters = { title: '', genre: '', author: '' };

    const bookCard = this.template.querySelector('c-book-card');
    if (bookCard) {
      bookCard.applyFilters(this.filters);
    }
  }

  handleOpenBookModal() {
    const bookModal = this.template.querySelector('c-add-book-form');
    if (bookModal) {
      bookModal.openModal();
    }
  }

  handleOpenAuthorModal() {
    const authorModal = this.template.querySelector('c-add-author-form');
    if (authorModal) {
      authorModal.openModal();
    }
  }

  handleBookAdded() {
    this.isBookModalOpen = false;
    const bookCard = this.template.querySelector('c-book-card');
    if (bookCard) {
      bookCard.loadBooks();
    }
  }

  handleAuthorAdded() {
    this.isAuthorModalOpen = false;
  }

  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
      })
    );
  }

  showError(message) {
    this.showToast('Error', message, 'error');
  }
}
