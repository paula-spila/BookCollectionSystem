import { LightningElement, track, api } from 'lwc';
import addAuthor from '@salesforce/apex/AuthorController.addAuthor';
import getRegionOptions from '@salesforce/apex/AuthorController.getRegionOptions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddAuthorForm extends LightningElement {
  @track authorName = '';
  @track surname = '';
  @track description = '';
  @track selectedRegion = '';
  @track regionOptions = [];

  @api isOpen = false;

  connectedCallback() {
    this.loadRegionOptions();
  }

  @api openModal() {
    this.resetFields();
    this.isOpen = true;
  }

  handleClose() {
    this.isOpen = false;
  }

  handleInputChange(event) {
    this[event.target.dataset.id] = event.target.value;
  }

  handleRegionChange(event) {
    this.selectedRegion = event.detail.value;
  }

  loadRegionOptions() {
    getRegionOptions()
      .then(result => {
        this.regionOptions = result.map(region => ({
          label: region.label,
          value: region.value,
        }));
      })
      .catch(error => {
        this.showError('Error loading regions: ' + error.body.message);
      });
  }

  handleSave() {
    if (!this.authorName) {
      this.showError('Lūdzu ievadiet autora vārdu.');
      return;
    }

    addAuthor({
      name: this.authorName,
      surname: this.surname || null,
      description: this.description || null,
      region: this.selectedRegion || null,
    })
      .then(result => {
        this.isOpen = false;

        this.showToast('Veiksme!', 'Autors veiksmīgi pievienots.', 'success');
      })
      .catch(error => {
        this.showError('Kļūda saglabājot autoru: ' + error.body.message);
      });
  }

  resetFields() {
    this.authorName = '';
    this.surname = '';
    this.description = '';
    this.selectedRegion = '';
  }

  showError(message) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Kļūda!',
        message: message,
        variant: 'error',
      })
    );
  }

  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title,
        message,
        variant,
      })
    );
  }
}
