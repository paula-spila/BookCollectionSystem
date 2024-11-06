import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBooks from '@salesforce/apex/BookController.getBooks';

export default class BookPage extends LightningElement {
  @track books = [];
  @track columns = [
    { label: 'Grāmata', fieldName: 'Name' },
    { label: 'Autors', fieldName: 'AuthorName' },
    { label: 'Lappušu skaits', fieldName: 'NumberOfPages', type: 'number' },
    { label: 'Žanrs', fieldName: 'GenreName' },
    { label: 'Pievienošanas datums', fieldName: 'DateAdded', type: 'date' }
  ];

  @track isBookModalOpen = false;
  @track isAuthorModalOpen = false;
  @track isReviewModalOpen = false;
  @track isLendingModalOpen = false;

  connectedCallback() {
    this.loadBooks();
  }

  loadBooks() {
    getBooks()
      .then(result => {
        this.books = result.map(book => {
          return {
            Id: book.Id,
            Name: book.Name,
            AuthorName: book.Author__r ? book.Author__r.Name : 'Nezināms autors',
            DateAdded: book.Date_added__c,
            NumberOfPages: book.Number_of_pages__c,
            GenreName: book.Genre__r ? book.Genre__r.Name : 'Nezināms žanrs'
          };
        });
      })
      .catch(error => {
        console.error('Error loading books:', error);
      });
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

}
