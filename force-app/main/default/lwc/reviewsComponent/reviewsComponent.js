import { LightningElement, api, track } from 'lwc';

export default class ReviewsComponent extends LightningElement {
  @api book;
  @track isReviewModalOpen = false;
  @api reviews = [];

  handleOpenReviewForm() {
    this.isReviewModalOpen = true;
  }

  handleReviewModalClose() {
    try {
      this.isReviewModalOpen = false;
    } catch (error) {
      console.error('Error closing the modal:', error);
    }
  }

  refreshReviews() {
    const refreshEvent = new CustomEvent('refreshreviews');
    this.dispatchEvent(refreshEvent);
  }
}
