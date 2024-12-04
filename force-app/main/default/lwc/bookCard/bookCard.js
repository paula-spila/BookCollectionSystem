import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getBooks from '@salesforce/apex/BookController.getBooks';

export default class BookCard extends NavigationMixin(LightningElement) {
  @api filters = {};
  @track books = [];
  @track filteredBooks = [];
  @track isLoading = true;

  connectedCallback() {
    this.loadBooks();
  }

  @api
  loadBooks() {
    const { title, author, genre } = this.filters;

    getBooks({ title, author, genre })
      .then((data) => {
        this.books = data.map((book) => ({
          Id: book.Id,
          Name: book.Name,
          AuthorName: book.Author__r?.Name || 'Nezināms autors',
          AuthorSurname: book.Author__r?.Surname__c || '',
          GenreName: book.Genre__r?.Name || 'Nezināms žanrs',
          BookCover: book.Book_cover__c,
        }));
        this.filteredBooks = [...this.books];
        this.isLoading = false;
      })
      .catch((error) => {
        console.error('Error loading books:', error);
        this.isLoading = false;
      });
  }

  @api
  applyFilters(filters) {
    this.filteredBooks = this.books.filter((book) => {
      const titleMatch = !filters.title || book.Name.toLowerCase().includes(filters.title.toLowerCase());
      const genreMatch = !filters.genre || book.GenreName === filters.genre;
      const authorMatch =
        !filters.author ||
        `${book.AuthorName} ${book.AuthorSurname}`.toLowerCase().includes(filters.author.toLowerCase());
      return titleMatch && genreMatch && authorMatch;
    });
  }

  handleCardClick(event) {
    const bookId = event.currentTarget.dataset.id;
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: bookId,
        objectApiName: 'Book__c',
        actionName: 'view',
      },
    });
  }
}
