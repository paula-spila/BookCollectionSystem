import { LightningElement, wire, track } from 'lwc';
import getCurrentlyReadingBooks from '@salesforce/apex/BookInUserCollectionController.getCurrentlyReadingBooks';


export default class CurrentlyReadingComponent extends LightningElement {
  @track books = [];
  @track error;

  @wire(getCurrentlyReadingBooks, { userId: '$userId' })
  wiredBooks({ error, data }) {
    if (data) {
      this.books = data;
    } else if (error) {
      this.error = error;
    }
  }

  handleEditPage(event) {
    const bookId = event.target.dataset.id;
    // Implement edit logic
    console.log(`Edit page for book ID: ${bookId}`);
  }
}
