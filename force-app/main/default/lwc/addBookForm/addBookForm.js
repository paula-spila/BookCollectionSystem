import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addBook from '@salesforce/apex/BookController.addBook';
import getAuthors from '@salesforce/apex/BookController.getAuthors';
import getGenres from '@salesforce/apex/BookController.getGenres';

export default class AddBookForm extends LightningElement {
  @api isOpen = false;

  @track book = {
    Name: '',
    PublicationDate: '',
    NumberOfPages: '',
    Description: '',
    AuthorId: null,
    GenreId: null,
    BookCover: '',
  };

  @track authorOptions = [];
  @track genreOptions = [];

  connectedCallback() {
    this.loadAuthorOptions();
    this.loadGenreOptions();
  }

  @api openModal() {
    this.isOpen = true;
  }

  loadAuthorOptions() {
    getAuthors()
      .then((data) => {
        this.authorOptions = data.map((author) => ({
          label: `${author.Name} ${author.Surname__c || ''}`.trim(),
          value: author.Id,
        }));
      })
      .catch((error) => {
        this.showToast('Kļūda!', 'Neizdevās ielādēt autorus.', 'error');
      });
  }

  loadGenreOptions() {
    getGenres()
      .then((data) => {
        this.genreOptions = data.map((genre) => ({
          label: genre.Name,
          value: genre.Id,
        }));
      })
      .catch((error) => {
        this.showToast('Kļūda!', 'Neizdevās ielādēt žanrus.', 'error');
      });
  }

  handleInputChange(event) {
    const field = event.target.dataset.id;
    this.book = { ...this.book, [field]: event.target.value };
  }

  handleAuthorChange(event) {
    this.book.AuthorId = event.detail.value || null;
  }

  handleGenreChange(event) {
    this.book.GenreId = event.detail.value || null;
  }

  validateForm() {
    if (!this.book.Name) {
      this.showToast('Kļūda!', 'Grāmatas nosaukums ir obligāts.', 'error');
      return false;
    }

    if (this.book.NumberOfPages) {
      const numberOfPages = parseInt(this.book.NumberOfPages, 10);
      if (numberOfPages < 0) {
        this.showToast('Kļūda!', 'Lappušu skaits nevar būt negatīvs.', 'error');
        return false;
      }
      if (numberOfPages > 9999) {
        this.showToast('Kļūda!', 'Lappušu skaits nevar pārsniegt 9999.', 'error');
        return false;
      }
    }

    if (this.book.PublicationDate && this.book.PublicationDate > new Date().toISOString().split('T')[0]) {
      this.showToast('Kļūda!', 'Publicēšanas datums nevar būt nākotnē.', 'error');
      return false;
    }

    return true;
  }


  handleSave() {
    if (!this.validateForm()) return;

    addBook({
      name: this.book.Name,
      publicationDate: this.book.PublicationDate || null,
      numberOfPages: this.book.NumberOfPages ? parseInt(this.book.NumberOfPages, 10) : null,
      description: this.book.Description || null,
      authorId: this.book.AuthorId || null,
      genreId: this.book.GenreId || null,
      bookCover: this.book.BookCover || null,
    })
      .then(() => {
        this.showToast('Veiksme!', 'Grāmata veiksmīgi pievienota.', 'success');
        this.resetForm();
        this.dispatchEvent(new CustomEvent('bookadded'));
        this.isOpen = false;
      })
      .catch((error) => {
        console.error('Error saving book:', error);
        this.showToast('Kļūda!', error.body?.message || 'Neizdevās pievienot grāmatu.', 'error');
      });
  }

  resetForm() {
    this.book = {
      Name: '',
      PublicationDate: '',
      NumberOfPages: '',
      Description: '',
      AuthorId: null,
      GenreId: null,
      BookCover: '',
    };
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }

  handleClose() {
    this.resetForm();
    this.isOpen = false;
  }
}
