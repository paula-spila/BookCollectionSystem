import { LightningElement, api } from 'lwc';

export default class BookCard extends LightningElement {
  @api pageName;

  // @api book;

  // handleLendBook() {
  //   this.dispatchEvent(new CustomEvent('lendbook', { detail: this.book.Id }));
  // }

  // handleAddBookToCollection() {
  //   this.dispatchEvent(new CustomEvent('addbooktocollection', { detail: this.book.Id }));
  // }

  // handleViewDetails() {
  //   this.dispatchEvent(new CustomEvent('viewdetails', { detail: this.book.Id }));
  // }

}
