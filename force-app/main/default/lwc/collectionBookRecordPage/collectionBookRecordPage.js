import { LightningElement, api, track } from 'lwc';
import getBookCollectionDetails from '@salesforce/apex/BookInUserCollectionController.getBookCollectionDetails';
import deleteBookFromCollection from '@salesforce/apex/BookInUserCollectionController.deleteBookFromCollection';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getReviews from '@salesforce/apex/BookReviewController.getBookReviews';

export default class CollectionBookRecordPage extends NavigationMixin(LightningElement) {
  @api recordId;
  @track collection;
  @track isLoading = true;
  @track isEditModalOpen = false;
  @track isEditPageModalOpen = false;
  @track isLendBookModalOpen = false;
  @track reviews = [];
  @track isLoading = true;
  @track isReviewModalOpen = false;

  connectedCallback() {
    this.loadCollectionDetails();
  }

  loadCollectionDetails() {
    this.isLoading = true;
    getBookCollectionDetails({ recordId: this.recordId })
      .then((data) => {
        if (data) {
          this.collection = {
            Id: data.Id,
            BookId: data.Book__c,
            BookName: data.Book__r?.Name || 'Nezināms',
            AuthorName: data.Book__r?.Author__r?.Name || 'Nezināms',
            AuthorSurname: data.Book__r?.Author__r?.Surname__c || '',
            PublicationDate: data.Book__r?.Publication_date__c || 'Nezināms',
            GenreName: data.Book__r?.Genre__r?.Name || 'Nezināms',
            BookCover: data.Book__r?.Book_cover__c || 'https://placeholder6-dev-ed.develop.file.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=068d20000025O8b&operationContext=CHATTER&contentId=05Td2000002Osvl',
            CurrentPage: data.Current_page__c || 0,
            TotalPages: data.Book__r?.Number_of_pages__c || 0,
            TimesRead: data.Times_read__c || 0,
            DateStarted: data.Date_started__c || 'Nav',
            DateFinished: data.Date_finished__c || 'Nav',
            DateBought: data.Date_bought__c || 'Nav',
            ISBN: data.ISBN__c || 'Nav pieejams',
            Format: data.Format__c || 'Nav norādīts',
            ReadingStatus: data.Reading_status__c || 'Nav norādīts',
            IsRead: data.Reading_status__c === 'Read',
          };
        } else {
          this.collection = null;
        }
      })
      .catch((error) => {
        console.error('Error fetching collection details:', error);
        this.showToast('Kļūda!', 'Neizdevās ielādēt kolekcijas datus.', 'error');
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  navigateToBook() {
    if (this.collection?.BookId) {
      this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
          recordId: this.collection.BookId,
          objectApiName: 'Book__c',
          actionName: 'view',
        },
      });
    } else {
      this.showToast('Kļūda!', 'Neizdevās atrast saistīto grāmatas ierakstu.', 'error');
    }
  }

  handleDelete() {
    deleteBookFromCollection({ recordId: this.collection.Id })
      .then(() => {
        this.showToast('Veiksme!', 'Grāmata veiksmīgi dzēsta no kolekcijas.', 'success');

        this[NavigationMixin.Navigate]({
          type: 'standard__navItemPage',
          attributes: {
            apiName: 'Mana_kolekcija'
          }
        });
      })
      .catch((error) => {
        console.error('Error deleting collection entry:', error);
        this.showToast('Kļūda!', 'Neizdevās dzēst grāmatu no kolekcijas.', 'error');
      });
  }


  handleCollectionUpdated() {
    console.log('Collection update event received.');
    this.loadCollectionDetails();
  }

  loadReviews() {
    getReviews({ bookId: this.collection.Id })
      .then((data) => {
        this.reviews = data;
      })
      .catch((error) => {
        console.error('Error fetching reviews:', error);
      });
  }

  handleOpenReviewModal() {
    this.isReviewModalOpen = true;
  }

  closeReviewModal() {
    this.isReviewModalOpen = false;
  }

  handleReviewAdded() {
    this.isReviewModalOpen = false;
  }

  handleLendBookUpdated() {
    this.isLendBookModalOpen = false;
  }

  handleSavePageUpdate() {
    this.isEditPageModalOpen = false;
    this.loadCollectionDetails();
  }

  openEditModal() {
    this.isEditModalOpen = true;
  }

  closeEditModal() {
    this.isEditModalOpen = false;
  }

  openEditPageModal() {
    this.isEditPageModalOpen = true;
  }

  closeEditPageModal() {
    this.isEditPageModalOpen = false;
  }

  openLendBookModal() {
    this.isLendBookModalOpen = true;
  }

  closeLendBookModal() {
    this.isLendBookModalOpen = false;
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
