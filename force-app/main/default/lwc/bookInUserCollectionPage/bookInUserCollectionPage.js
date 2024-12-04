import { LightningElement, track } from 'lwc';

export default class BookInUserCollectionPage extends LightningElement {
  @track filters = {
    title: '',
    genre: '',
    author: '',
  };

  @track activeTab = 'allBooks';

  get isAllBooks() {
    return this.activeTab === 'allBooks';
  }

  get isReadBooks() {
    return this.activeTab === 'readBooks';
  }

  get isWantToRead() {
    return this.activeTab === 'wantToRead';
  }

  handleTabChange(event) {
    const selectedTab = event.target.label;

    if (selectedTab.includes('Visas manas grāmatas')) {
      this.activeTab = 'allBooks';
    } else if (selectedTab.includes('Izlasītas')) {
      this.activeTab = 'readBooks';
    } else if (selectedTab.includes('Gribu izlasīt')) {
      this.activeTab = 'wantToRead';
    }

    this.applyFiltersToActiveTab();
  }

  handleFilterChange(event) {
    const { filterType, filterValue } = event.detail;
    this.filters = { ...this.filters, [filterType]: filterValue };

    this.applyFiltersToActiveTab();
  }

  handleClearFilters() {
    this.filters = {
      title: '',
      genre: '',
      author: '',
    };

    this.applyFiltersToActiveTab();
  }

  applyFiltersToActiveTab() {
    const bookCard = this.template.querySelector('c-collection-book-card');
    if (bookCard) {
      bookCard.applyFilters(this.filters);
    }
  }
}
