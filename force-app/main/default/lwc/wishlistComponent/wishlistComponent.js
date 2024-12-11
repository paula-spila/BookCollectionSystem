import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getWishlistBooks from '@salesforce/apex/WishlistController.getWishlistBooks';

export default class WishlistComponent extends NavigationMixin(LightningElement) {
  @api filters = {};
  @track wishlistBooks = [];
  @track filteredBooks = [];
  @track isLoading = true;

  connectedCallback() {
    this.loadWishlist();
  }

  loadWishlist() {
    this.isLoading = true;
    getWishlistBooks()
      .then((data) => {
        if (data && data.length > 0) {
          this.wishlistBooks = data.map((book) => ({
            Id: book.Id,
            BookId: book.Book__c,
            Name: book.Book__r?.Name || 'Nezināms',
            AuthorName: book.Book__r?.Author__r?.Name || 'Nezināms',
            AuthorSurname: book.Book__r?.Author__r?.Surname__c || '',
            GenreName: book.Book__r?.Genre__r?.Name || 'Nezināms',
            DateAdded: book.Date_added__c || 'Nezināms',
            BookCover: book.Book__r?.Book_cover__c,
          }));
          this.applyFilters(this.filters);
        } else {
          this.wishlistBooks = [];
        }
        this.isLoading = false;
      })
      .catch((error) => {
        console.error('Error fetching wishlist books:', error);
        this.isLoading = false;
      });
  }

  @api
  applyFilters(filters = {}) {
    if (!this.wishlistBooks || this.wishlistBooks.length === 0) {
      this.filteredBooks = [];
      return;
    }

    this.filteredBooks = this.wishlistBooks.filter((book) => {
      const titleMatch = !filters.title || book.Name.toLowerCase().includes(filters.title.toLowerCase());
      const genreMatch = !filters.genre || book.GenreName === filters.genre;
      const authorMatch = !filters.author || `${book.AuthorName} ${book.AuthorSurname}`.toLowerCase().includes(filters.author.toLowerCase());
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
