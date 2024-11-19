import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getBooks from '@salesforce/apex/BookController.getBooks';

export default class BookPage extends NavigationMixin(LightningElement) {
  @track books = [];
  @track columns = [
    {
      label: 'Grāmata',
      fieldName: 'Name',
      type: 'button',
      typeAttributes: {
        label: { fieldName: 'Name' },
        name: 'view_record',
        variant: 'base'
      }
    },
    { label: 'Autora vārds', fieldName: 'AuthorName' },
    { label: 'Autora uzvārds', fieldName: 'AuthorSurname' },
    { label: 'Lappušu skaits', fieldName: 'NumberOfPages', type: 'number' },
    { label: 'Žanrs', fieldName: 'GenreName' },
    {
      type: 'action',
      typeAttributes: { rowActions: this.getRowActions.bind(this) },
    },
  ];

  @track isBookModalOpen = false;
  @track isAuthorModalOpen = false;
  @track isReviewModalOpen = false;
  @track isLendingModalOpen = false;

  @track filters = {
    search: '',
    genre: '',
    author: '',
  };

  connectedCallback() {
    this.loadBooks();
  }

  loadBooks() {
    const { title, author, genre } = this.filters;
    getBooks({ title, author, genre })
      .then(result => {
        this.books = result.map(book => ({
          Id: book.Id,
          Name: book.Name,
          AuthorName: book.Author__r ? book.Author__r.Name : 'Unknown',
          AuthorSurname: book.Author__r ? book.Author__r.Surname__c : 'Unknown',
          NumberOfPages: book.Number_of_pages__c,
          GenreName: book.Genre__r ? book.Genre__r.Name : 'Unknown'
        }));
      })
      .catch(error => {
        console.error('Error loading books:', error);
        this.showError('Error loading books.');
      });
  }

  getRowActions(row, doneCallback) {
    const actions = [];
    actions.push({ label: 'Apskatīt grāmatu', name: 'view_record' });
    doneCallback(actions);
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    if (actionName === 'view_record') {
      this.viewRecord(row);
    }
  }

  viewRecord(row) {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: row.Id,
        actionName: 'view'
      }
    });
  }

  handleFilterChange(event) {
    const { filterType, filterValue } = event.detail;
    this.filters[filterType] = filterValue;
    this.loadBooks();
  }

  handleClearFilters() {
    this.filters = { title: '', genre: '', author: '' };
    this.loadBooks();
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

  handleOpenReviewModal() {
    const reviewModal = this.template.querySelector('c-add-book-review-form');
    if (reviewModal) {
      reviewModal.openModal();
    }
  }

  handleOpenLendingModal() {
    const lendingModal = this.template.querySelector('c-add-lending-form');
    if (lendingModal) {
      lendingModal.openModal();
    }
  }

  handleBookAdded() {
    this.isBookModalOpen = false;
    this.loadBooks();
    this.showToast('Success', 'Book has been added successfully', 'success');
  }

  handleAuthorAdded() {
    this.isAuthorModalOpen = false;
    this.showToast('Success', 'Author has been added successfully', 'success');
  }

  handleReviewAdded() {
    this.isReviewModalOpen = false;
    this.showToast('Success', 'Review has been added successfully', 'success');
  }

  handleLendingAdded() {
    this.isLendingModalOpen = false;
    this.showToast('Success', 'Lending has been added successfully', 'success');
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
