import { LightningElement, api } from 'lwc';

export default class ReviewsComponent extends LightningElement {
  @api book;
  @api reviews = [];
}
