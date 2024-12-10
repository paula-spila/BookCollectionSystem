import { LightningElement, api, track } from 'lwc';
import getBooksByAuthor from '@salesforce/apex/BookController.getBooksByAuthor';
import { NavigationMixin } from 'lightning/navigation';

export default class BooksByAuthorComponent extends NavigationMixin(LightningElement) {
  @api authorId;
  @api authorName;
  @api authorSurname;
  @track books = [];

  connectedCallback() {
    if (this.authorId) {
      this.loadBooks();
    } else {
      console.error('No Author ID provided.');
    }
  }

  loadBooks() {
    getBooksByAuthor({ authorId: this.authorId })
      .then((data) => {
        this.books = data.map((book) => ({
          Id: book.Id,
          Name: book.Name,
          BookCover: book.Book_cover__c || 'https://placeholder6-dev-ed.develop.file.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=068d20000025O8b&operationContext=CHATTER&contentId=05Td2000002Osvl',
        }));
      })
      .catch((error) => {
        console.error('Error fetching books by author:', error);
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
