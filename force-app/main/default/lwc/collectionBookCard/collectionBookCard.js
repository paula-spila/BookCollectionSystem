import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getBooks from '@salesforce/apex/BookInUserCollectionController.getBooks';

export default class CollectionBookCard extends NavigationMixin(LightningElement) {
  @api pageName;
  @api filters = {};
  @track books = [];
  @track filteredBooks = [];
  @track isLoading = true;

  connectedCallback() {
    this.loadBooks();
  }

  @api
  loadBooks() {
    this.isLoading = true;
    getBooks({ collectionType: this.pageName })
      .then(data => {
        if (data) {
          this.books = data.filter(bookEntry => bookEntry.Book__r);
          this.applyFilters(this.filters);
        } else {
          this.books = [];
        }
        this.isLoading = false;
      })
      .catch(error => {
        console.error('Error loading books:', error);
        this.isLoading = false;
      });
  }

  @api
  applyFilters(filters = {}) {
    if (!this.books || this.books.length === 0) {
      this.filteredBooks = [];
      return;
    }

    this.filteredBooks = this.books.filter(bookEntry => {
      const titleMatch = !filters.title || bookEntry.Book__r.Name.toLowerCase().includes(filters.title.toLowerCase());
      const genreMatch = !filters.genre || (bookEntry.Book__r.Genre__r && bookEntry.Book__r.Genre__r.Name === filters.genre);
      const authorMatch = !filters.author || `${bookEntry.Book__r.Author__r.Name} ${bookEntry.Book__r.Author__r.Surname__c}`.toLowerCase().includes(filters.author.toLowerCase());
      return titleMatch && genreMatch && authorMatch;
    });
  }

  handleCardClick(event) {
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
}
