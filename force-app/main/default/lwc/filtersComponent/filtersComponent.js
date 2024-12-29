import { LightningElement, api } from 'lwc';
import getGenres from '@salesforce/apex/BookController.getGenres';
import getAuthors from '@salesforce/apex/BookController.getAuthors';

export default class FiltersComponent extends LightningElement {
  @api genreOptions = [];
  @api authorOptions = [];

  @api filters = {
    title: '',
    genre: '',
    author: '',
  };

  connectedCallback() {
    this.loadFilterOptions();
  }

  loadFilterOptions() {
    getGenres()
      .then(result => {
        this.genreOptions = [{ label: 'Visi', value: '' }, ...result.map(genre => ({
          label: genre.Name,
          value: genre.Name,
        }))];
      })
      .catch(error => {
        this.showError('Kļūda ielādējot žanrus: ' + (error.body ? error.body.message : error.message));
      });

    getAuthors()
      .then(result => {
        this.authorOptions = [{ label: 'Visi', value: '' }, ...result.map(author => ({
          label: `${author.Name} ${author.Surname__c}`,
          value: author.Name,
        }))];
      })
      .catch(error => {
        this.showError('Kļūda ielādējot autorus: ' + (error.body ? error.body.message : error.message));
      });
  }

  handleFilterChange(event) {
    const filterType = event.target.dataset.id;
    const filterValue = event.target.value;
    this.dispatchEvent(new CustomEvent('filterchange', {
      detail: { filterType, filterValue },
    }));
  }

  clearFilters() {
    this.filters = {
      title: '',
      genre: '',
      author: ''
    };

    const inputs = this.template.querySelectorAll('lightning-input, lightning-combobox');
    inputs.forEach((input) => {
      input.value = '';
    });

    this.dispatchEvent(new CustomEvent('clearfilters', {
      detail: this.filters
    }));
  }

  showError(message) {
    this.showToast('Kļūda', message, 'error');
  }

}
