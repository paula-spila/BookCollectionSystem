import { LightningElement, api, track } from 'lwc';
import getBookDetails from '@salesforce/apex/BookController.getBookDetails';
import getBookReviews from '@salesforce/apex/BookReviewController.getBookReviews';

export default class BookRecordPage extends LightningElement {
  @api recordId;
  @track book;
  @track reviews = [];
  @track authorId;

  connectedCallback() {
    this.loadBookDetails();
    this.loadBookReviews();
  }

  loadBookDetails() {
    getBookDetails({ bookId: this.recordId })
      .then((data) => {
        this.book = {
          Id: data.Id,
          Name: data.Name,
          AuthorName: data.Author__r?.Name || 'Nezināms',
          AuthorSurname: data.Author__r?.Surname__c || '',
          GenreName: data.Genre__r?.Name || 'Nezināms',
          NumberOfPages: data.Number_of_pages__c,
          PublicationDate: data.Publication_date__c,
          Description: data.Description__c,
          BookCover: data.Book_cover__c || 'https://placeholder6-dev-ed.develop.file.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=068d20000025O8b&operationContext=CHATTER&contentId=05Td2000002Osvl',
        };
        this.authorId = data.Author__c;
      })
      .catch((error) => {
        console.error('Error fetching book details:', error);
      });
  }

  loadBookReviews() {
    getBookReviews({ bookId: this.recordId })
      .then((data) => {
        this.reviews = data.map((review) => ({
          Id: review.Id,
          ReviewerName: review.CreatedBy?.Name || 'Nezināms',
          ReviewText: review.Review_text__c,
          Rating: review.Rating__c,
        }));
      })
      .catch((error) => {
        console.error('Error fetching reviews:', error);
      });
  }

  refreshReviews() {
    this.loadBookReviews();
  }

  // Action handlers
  addToWishlist() {
    console.log('Add to Wishlist functionality');
  }

  addToCollection() {
    console.log('Add to Collection functionality');
  }

  editBook() {
    console.log('Edit book functionality');
  }
}
