import { LightningElement, track } from 'lwc';
import getBooks from '@salesforce/apex/BookController.getBooks';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

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

  handleBookAdded() {
    this.isModalOpen = false;
    this.loadBooks();
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Success',
        message: 'Book has been added successfully',
        variant: 'success',
      })
    );
  }

  handleAuthorAdded() {
    this.isAuthorModalOpen = false;
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Success',
        message: 'Author has been added successfully',
        variant: 'success',
      })
    );
  }

}
