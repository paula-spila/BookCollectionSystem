import { LightningElement, api, track } from 'lwc';
import getBookDetails from '@salesforce/apex/BookController.getBookDetails';
import getBookReviews from '@salesforce/apex/BookReviewController.getBookReviews';
import addToWishlist from '@salesforce/apex/WishlistController.addToWishlist';
import isBookInWishlist from '@salesforce/apex/WishlistController.isBookInWishlist';
import removeFromWishlist from '@salesforce/apex/WishlistController.removeFromWishlist';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BookRecordPage extends LightningElement {
  @api recordId;
  @track book;
  @track reviews = [];
  @track averageRating = null;
  @track authorId;
  @track isEditModalOpen = false;
  @track isInWishlist = false;
  @track isAddToCollectionModalOpen = false;
  @track isLoading = true;

  connectedCallback() {
    this.loadData();
  }

  loadData() {
    this.isLoading = true;
    Promise.all([this.loadBookDetails(), this.loadBookReviews(), this.checkWishlistStatus()])
      .catch((error) => console.error('Error loading data:', error))
      .finally(() => {
        this.isLoading = false;
      });
  }

  loadBookDetails() {
    return getBookDetails({ bookId: this.recordId })
      .then((data) => {
        this.book = {
          Id: data.Id,
          Name: data.Name,
          AuthorName: data.Author__r?.Name || 'Nezināms',
          AuthorSurname: data.Author__r?.Surname__c || '',
          AuthorDescription: data.Author__r?.Description__c || 'Nav pieejams autora apraksts',
          GenreName: data.Genre__r?.Name || 'Nezināms',
          NumberOfPages: data.Number_of_pages__c,
          PublicationDate: data.Publication_date__c,
          Description: data.Description__c,
          BookCover: data.Book_cover__c || 'https://placeholder6-dev-ed.develop.file.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=068d20000025O8b&operationContext=CHATTER&contentId=05Td2000002Osvl',
        };

        this.authorId = data.Author__c;
      });
  }

  loadBookReviews() {
    return getBookReviews({ bookId: this.recordId })
      .then((data) => {
        this.reviews = data.map((review) => ({
          Id: review.Id,
          ReviewerName: review.CreatedBy?.Name || 'Nezināms',
          ReviewText: review.Review_text__c,
          Rating: review.Rating__c,
        }));
        this.calculateAverageRating();
      });
  }

  calculateAverageRating() {
    if (this.reviews.length > 0) {
      const totalRating = this.reviews.reduce((sum, review) => sum + review.Rating, 0);
      this.averageRating = (totalRating / this.reviews.length).toFixed(1);
    } else {
      this.averageRating = null;
    }
  }

  checkWishlistStatus() {
    return isBookInWishlist({ bookId: this.recordId })
      .then((result) => {
        this.isInWishlist = result;
      });
  }

  handleAddToWishlist() {
    addToWishlist({ bookId: this.book.Id })
      .then(() => {
        this.isInWishlist = true;
        this.showToast('Veiksme!', 'Grāmata veiksmīgi pievienota vēlmju sarakstam.', 'success');
      })
      .catch((error) => {
        this.showToast('Kļūda!', 'Neizdevās pievienot grāmatu vēlmju sarakstam.', 'error');
        console.error('Error adding book to wishlist:', error);
      });
  }

  handleRemoveFromWishlist() {
    removeFromWishlist({ bookId: this.book.Id })
      .then(() => {
        this.isInWishlist = false;
        this.showToast('Veiksme!', 'Grāmata veiksmīgi noņemta no vēlmju saraksta.', 'success');
      })
      .catch((error) => {
        this.showToast('Kļūda!', 'Neizdevās noņemt grāmatu no vēlmju saraksta.', 'error');
        console.error('Error removing book from wishlist:', error);
      });
  }

  openAddToCollection() {
    this.isAddToCollectionModalOpen = true;
  }

  closeAddToCollectionModal() {
    this.isAddToCollectionModalOpen = false;
  }

  openEditModal() {
    this.isEditModalOpen = true;
  }

  closeEditModal() {
    this.isEditModalOpen = false;
    this.loadBookDetails();
  }

  handleBookUpdated() {
    this.loadBookDetails();
    this.isEditModalOpen = false;
  }

  handleBookAddedToCollection() {
    this.isAddToCollectionModalOpen = false;
    if (this.isInWishlist) {
      this.handleRemoveFromWishlist();
    }
  }

  handleRefreshReviews() {
    this.loadBookReviews();
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
