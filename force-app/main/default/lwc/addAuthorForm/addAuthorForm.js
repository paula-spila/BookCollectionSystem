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
        this.regionOptions = result.map(region => {
          return { label: region.label, value: region.value };
        });
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error loading regions',
            message: error.body.message,
            variant: 'error',
          })
        );
      });
  }


  handleSave() {
    try {
      if (!this.authorName) {
        this.showError('Please enter the author name.');
        return;
      }

      addAuthor({
        name: this.authorName,
        surname: this.surname || null,
        description: this.description || null,
        region: this.selectedRegion || null
      })
        .then(() => {
          this.isOpen = false;
          this.dispatchEvent(new CustomEvent('authoradded'));
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Success',
              message: 'Author has been added successfully',
              variant: 'success',
            })
          );
        })
        .catch(error => {
          this.showError('Error saving author: ' + error.body.message);
        });
    } catch (e) {
      console.error('Unexpected error:', e);
      this.showError('An unexpected error occurred: ' + e.message);
    }
  }


  showError(message) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Error',
        message: message,
        variant: 'error',
      })
    );
  }
}
