import { LightningElement } from 'lwc';
// import getAllBooksInUserCollection from '@salesforce/apex/BookInUserCollectionController.getAllBooksInUserCollection';
// import lendBook from '@salesforce/apex/BookInUserCollectionController.lendBook';
// import addBookToCollection from '@salesforce/apex/BookInUserCollectionController.addBookToCollection';

// import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BookInUserCollectionPage extends LightningElement {
  handleTabChange(event) {
    const tabId = event.target.dataId;
    console.log(`Current tab is ${tabId}`);
  }

  // @track books;
  // @track selectedBook;
  // // @track reviews;
  // // @track isReviewModalOpen = false;

  // @wire(getAllBooksInUserCollection)
  // wiredBooks({ error, data }) {
  //   if (data) {
  //     this.books = data.map(item => item.Book__r);
  //   } else if (error) {
  //     this.showToast('Error', error.body.message, 'error');
  //   }
  // }

  // handleLendBook(event) {
  //   lendBook({ bookId: event.detail })
  //     .then(result => {
  //       this.showToast('Success', result, 'success');
  //     })
  //     .catch(error => {
  //       this.showToast('Error', error.body.message, 'error');
  //     });
  // }

  // handleAddBookToCollection(event) {
  //   addBookToCollection({ bookId: event.detail })
  //     .then(result => {
  //       this.showToast('Success', result, 'success');
  //     })
  //     .catch(error => {
  //       this.showToast('Error', error.body.message, 'error');
  //     });
  // }


  // // handleOpenReviewModal() {
  // //   this.isReviewModalOpen = true;
  // // }

  // // handleCloseReviewModal() {
  // //   this.isReviewModalOpen = false;
  // // }

  // // handleReviewAdded() {
  // //   this.handleSelectBook({ detail: this.selectedBook });
  // //   this.handleCloseReviewModal();
  // // }

  // showToast(title, message, variant) {
  //   const evt = new ShowToastEvent({
  //     title: title,
  //     message: message,
  //     variant: variant,
  //   });
  //   this.dispatchEvent(evt);
  // }

}
