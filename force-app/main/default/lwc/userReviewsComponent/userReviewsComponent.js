import { LightningElement, api, track } from 'lwc';
import getUserReviews from '@salesforce/apex/BookReviewController.getUserReviews';
import updateReview from '@salesforce/apex/BookReviewController.updateReview';
import deleteReview from '@salesforce/apex/BookReviewController.deleteReview';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UserReviewsComponent extends LightningElement {
  @track book;
  @track reviews = [];
  @track isLoading = true;
  @track isReviewModalOpen = false;
  @track isEditModalOpen = false;
  @track editReviewId = null;
  @track editRating = null;
  @track editReviewText = '';

  @api bookId;
  @api bookName;
  @api authorName;
  @api authorSurname;

  connectedCallback() {
    this.loadReviews();
  }

  loadReviews() {
    this.isLoading = true;
    getUserReviews({ bookId: this.bookId })
      .then((data) => {
        this.reviews = data.map((r) => ({
          Id: r.Id,
          Rating__c: r.Rating__c,
          Review_text__c: r.Review_text__c,
        }));
      })
      .catch((error) => {
        console.error('Error fetching user reviews:', error);
        this.showToast('Kļūda!', 'Neizdevās ielādēt atsauksmes.', 'error');
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  handleEdit(event) {
    const reviewId = event.target.dataset.id;
    const review = this.reviews.find((r) => r.Id === reviewId);
    if (review) {
      this.editReviewId = review.Id;
      this.editRating = review.Rating__c;
      this.editReviewText = review.Review_text__c;
      this.isEditModalOpen = true;
    }
  }

  handleRatingChange(event) {
    this.editRating = event.target.value;
  }

  handleReviewTextChange(event) {
    this.editReviewText = event.target.value;
  }

  handleCancelEdit() {
    this.isEditModalOpen = false;
    this.resetEditForm();
  }

  handleSaveEdit() {
    if (!this.editRating || this.editRating < 0 || this.editRating > 5) {
      this.showToast('Kļūda!', 'Lūdzu ievadiet vērtējumu no 0 līdz 5.', 'error');
      return;
    }

    if (this.editReviewText && this.editReviewText.length > 3000) {
      this.showToast('Kļūda!', 'Atsauksmes teksts nevar būt garāks par 3000 rakstzīmēm.', 'error');
      return false;
    }

    updateReview({
      reviewId: this.editReviewId,
      rating: this.editRating,
      reviewText: this.editReviewText,
    })
      .then(() => {
        this.showToast('Veiksme!', 'Atsauksme veiksmīgi atjaunināta.', 'success');
        this.isEditModalOpen = false;
        this.loadReviews();
      })
      .catch((error) => {
        console.error('Error updating review:', error);
        this.showToast('Kļūda!', 'Neizdevās atjaunināt atsauksmi.', 'error');
      });
  }

  handleOpenReviewModal() {
    this.isReviewModalOpen = true;
    this.book = {
      BookId: this.bookId,
      Name: this.bookName || 'Nezināms',
      AuthorName: this.authorName || 'Nezināms',
      AuthorSurname: this.authorSurname || ''
    };
  }

  handleCloseReviewModal() {
    this.isReviewModalOpen = false;
  }

  handleReviewAdded() {
    this.isReviewModalOpen = false;
    this.loadReviews();
  }

  handleDelete(event) {
    const reviewId = event.target.dataset.id;
    deleteReview({ reviewId })
      .then(() => {
        this.showToast('Veiksme!', 'Atsauksme veiksmīgi dzēsta.', 'success');
        this.loadReviews();
      })
      .catch((error) => {
        console.error('Error deleting review:', error);
        this.showToast('Kļūda!', 'Neizdevās dzēst atsauksmi.', 'error');
      });
  }

  resetEditForm() {
    this.editReviewId = null;
    this.editRating = null;
    this.editReviewText = '';
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
