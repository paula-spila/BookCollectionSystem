import { LightningElement, api, track } from 'lwc';
import getLendingHistory from '@salesforce/apex/LendingHistoryController.getLendingHistory';
import markAsReturned from '@salesforce/apex/LendingHistoryController.markAsReturned';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LendingHistoryComponent extends LightningElement {
  @api bookCollectionId;
  @track lendingHistory = [];
  @track isLoading = true;
  @track isAddLendingModalOpen = false;
  @track hasActiveLending = false;

  columns = [
    { label: 'Aizņēmēja vārds', fieldName: 'LenderName', type: 'text' },
    { label: 'Aizdošanas datums', fieldName: 'LendingDate', type: 'date-local' },
    { label: 'Atgriešanas datums', fieldName: 'ReturnDate', type: 'date-local' }
  ];

  connectedCallback() {
    this.fetchLendingHistory();
  }

  fetchLendingHistory() {
    this.isLoading = true;
    getLendingHistory({ bookCollectionId: this.bookCollectionId })
      .then((data) => {
        this.lendingHistory = data.map((record) => ({
          Id: record.Id,
          LenderName: record.Lender_name__c || 'Nezināms',
          LendingDate: record.Lending_date__c,
          ReturnDate: record.Return_date__c || 'Nav norādīts',
          isActive: record.Return_status__c === 'Not returned'
        }));

        this.hasActiveLending = this.lendingHistory.some((item) => item.isActive);
      })
      .catch((error) => {
        console.error('Error fetching lending history:', error);
        this.showToast('Kļūda!', 'Neizdevās ielādēt aizdošanas vēsturi.', 'error');
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  handleMarkAsReturned() {
    const activeLending = this.lendingHistory.find((item) => item.isActive);
    if (activeLending) {
      markAsReturned({ lendingId: activeLending.Id })
        .then(() => {
          this.showToast('Veiksme!', 'Grāmata atzīmēta kā atgriezta.', 'success');
          this.fetchLendingHistory();
        })
        .catch((error) => {
          console.error('Error marking as returned:', error);
          this.showToast('Kļūda!', 'Neizdevās atzīmēt grāmatu kā atgrieztu.', 'error');
        });
    }
  }

  openAddLendingForm() {
    this.isAddLendingModalOpen = true;
  }

  closeAddLendingForm() {
    this.isAddLendingModalOpen = false;
  }

  refreshLendingHistory() {
    this.closeAddLendingForm();
    this.fetchLendingHistory();
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
