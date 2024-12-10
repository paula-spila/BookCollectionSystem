import { LightningElement, api, track } from 'lwc';
import updateBook from '@salesforce/apex/BookController.updateBook';
import getAuthors from '@salesforce/apex/BookController.getAuthors';
import getGenres from '@salesforce/apex/BookController.getGenres';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EditBookForm extends LightningElement {
  @api isOpen;
  @api book;
  @track authorOptions = [];
  @track genreOptions = [];

  connectedCallback() {
    this.loadAuthorOptions();
    this.loadGenreOptions();
  }

  loadAuthorOptions() {
    getAuthors()
      .then((data) => {
        this.authorOptions = data.map((author) => ({
          label: `${author.Name} ${author.Surname__c || ''}`,
          value: author.Id,
        }));
      })
      .catch((error) => {
        console.error('Error fetching author options:', error);
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
        console.error('Error fetching genre options:', error);
      });
  }

  handleInputChange(event) {
    const field = event.target.dataset.id;
    this.book = { ...this.book, [field]: event.target.value };
  }

  validateForm() {
    if (!this.book.Name) {
      this.showToast('Kļūda!', 'Grāmatas nosaukums ir obligāts.', 'error');
      return false;
    }

    if (this.book.NumberOfPages && this.book.NumberOfPages < 0) {
      this.showToast('Kļūda!', 'Lappušu skaits nevar būt negatīvs.', 'error');
      return false;
    }

    if (this.book.PublicationDate && this.book.PublicationDate > new Date().toISOString().split('T')[0]) {
      this.showToast('Kļūda!', 'Publicēšanas datums nevar būt nākotnē.', 'error');
      return false;
    }

    if (this.book.Description && this.book.Description.length > 5000) {
      this.showToast('Kļūda!', 'Grāmatas apraksts nevar būt garāks par 5000 rakstzīmēm.', 'error');
      return false;
    }

    return true;
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

  closeModal() {
    const closeEvent = new CustomEvent('closemodal');
    this.dispatchEvent(closeEvent);
  }

  saveChanges() {
    if (!this.validateForm()) {
      return;
    }
    const bookToUpdate = {
      Id: this.book.Id,
      Name: this.book.Name,
      Author__c: this.book.AuthorId,
      Genre__c: this.book.GenreId,
      Number_of_pages__c: this.book.NumberOfPages,
      Publication_date__c: this.book.PublicationDate,
      Description__c: this.book.Description,
      Book_cover__c: this.book.BookCover,
    };

    updateBook({ book: bookToUpdate })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Veiksme!',
            message: 'Grāmata veiksmīgi atjaunināta.',
            variant: 'success',
          })
        );
        const savedEvent = new CustomEvent('bookupdated');
        this.dispatchEvent(savedEvent);
        this.closeModal();
        location.reload();
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Kļūda!',
            message: 'Neizdevās atjaunināt grāmatu. Mēģiniet vēlreiz.',
            variant: 'error',
          })
        );
        console.error('Error updating book:', error);
      });
  }

}
