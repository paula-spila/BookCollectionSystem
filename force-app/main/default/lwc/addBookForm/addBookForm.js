import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addBook from '@salesforce/apex/BookController.addBook';
import getAuthors from '@salesforce/apex/BookController.getAuthors';
import getGenres from '@salesforce/apex/BookController.getGenres';

export default class AddBookForm extends LightningElement {
  @track bookName = '';
  @track publicationDate = '';
  @track numberOfPages = '';
  @track description = '';
  @track selectedAuthor = '';
  @track selectedGenre = '';
  @track authorOptions = [];
  @track genreOptions = [];
  @track bookCover = '';

  @api isOpen = false;

  connectedCallback() {
    this.loadAuthorOptions();
    this.loadGenreOptions();
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

  handleAuthorChange(event) {
    this.selectedAuthor = event.detail.value;
  }

  handleGenreChange(event) {
    this.selectedGenre = event.detail.value;
  }

  loadAuthorOptions() {
    getAuthors()
      .then(result => {
        this.authorOptions = result.map(author => {
          return { label: author.Name, value: author.Id };
        });
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error loading authors',
            message: error.body.message,
            variant: 'error',
          })
        );
      });
  }

  loadGenreOptions() {
    getGenres()
      .then(result => {
        this.genreOptions = result.map(genre => {
          return { label: genre.Name, value: genre.Id };
        });
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error loading genres',
            message: error.body.message,
            variant: 'error',
          })
        );
      });
  }

  handleSave() {
    if (!this.bookName) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error',
          message: 'Please enter a book name.',
          variant: 'error',
        })
      );
      return;
    }

    addBook({
      name: this.bookName,
      publicationDate: this.publicationDate || null,
      numberOfPages: this.numberOfPages ? parseInt(this.numberOfPages, 10) : null,
      description: this.description || null,
      authorId: this.selectedAuthor || null,
      genreId: this.selectedGenre || null,
      bookCover: this.bookCover || null
    })
      .then(() => {
        this.isOpen = false;
        this.dispatchEvent(new CustomEvent('bookadded'));
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Book has been added successfully',
            variant: 'success',
          })
        );
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error saving book',
            message: error.body.message,
            variant: 'error',
          })
        );
      });
  }

}
