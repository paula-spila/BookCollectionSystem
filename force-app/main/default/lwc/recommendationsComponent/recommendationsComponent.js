import { LightningElement, api, track } from 'lwc';
import getRecommendedBooks from '@salesforce/apex/BookInUserCollectionController.getRecommendedBooks';
import { NavigationMixin } from 'lightning/navigation';

export default class RecommendationsComponent extends NavigationMixin(LightningElement) {
  @api bookCollectionId;
  @track recommendedBooks = null;

  connectedCallback() {
    if (this.bookCollectionId) {
      this.loadRecommendedBooks();
    } else {
      console.error('No Book Collection ID provided.');
    }
  }

  loadRecommendedBooks() {
    getRecommendedBooks({ bookCollectionId: this.bookCollectionId })
      .then((data) => {
        if (data.length > 0) {
          this.recommendedBooks = data.map((book) => ({
            Id: book.Id,
            Name: book.Name,
            BookCover: book.Book_cover__c || 'https://placeholder6-dev-ed.develop.file.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=068d20000025O8b&operationContext=CHATTER&contentId=05Td2000002Osvl',
            AuthorName: book.Author__r?.Name || 'Nezināms',
            AuthorSurname: book.Author__r?.Surname__c || '',
          }));
        } else {
          this.recommendedBooks = [];
        }
      })
      .catch((error) => {
        console.error('Error fetching recommended books:', error);
        this.recommendedBooks = [];
      });
  }

  handleBookClick(event) {
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
