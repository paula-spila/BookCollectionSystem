import { LightningElement, api, track } from 'lwc';

export default class ReviewsComponent extends LightningElement {
  @api book;
  @track isReviewModalOpen = false;
  @api reviews = [];

  handleOpenReviewForm() {
    this.isReviewModalOpen = true;
  }

  handleReviewModalClose() {
    this.isReviewModalOpen = false;
  }

  refreshReviews() {
    if (!this.book) {
      console.error('Book information is missing, cannot refresh reviews.');
      return;
    }
    const refreshEvent = new CustomEvent('refreshreviews', {
      detail: { bookId: this.book.Id },
    });
    this.dispatchEvent(refreshEvent);
  }
}
