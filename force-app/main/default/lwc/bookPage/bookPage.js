import { LightningElement, track } from 'lwc';
import getBooks from '@salesforce/apex/BookController.getBooks';

export default class BookPage extends LightningElement {
  @track books = [];
  @track isModalOpen = false;
  @track columns = [
    { label: 'Grāmata', fieldName: 'Name' },
    { label: 'Autors', fieldName: 'AuthorName' },
    { label: 'Lappušu skaits', fieldName: 'NumberOfPages', type: 'number' },
    { label: 'Žanrs', fieldName: 'GenreName' },
    { label: 'Pievienošanas datums', fieldName: 'DateAdded', type: 'date' }
  ];

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

  handleOpenModal() {
    const modal = this.template.querySelector('c-book-addition-form');
    if (modal) {
      modal.openModal();
    }
  }

  handleBookAdded() {
    this.isModalOpen = false;
    this.loadBooks();
  }
}
