public with sharing class BookReviewController {
    @AuraEnabled
    public static Id addReview(Id bookId, String reviewName, Date dateOfReview, Integer rating, String reviewText) {
        if (bookId == null) {
            throw new AuraHandledException('Missing required field: Book.');
        }
        if (String.isBlank(reviewName)) {
            throw new AuraHandledException('Missing required field: Review Name.');
        }

        if (reviewName.length() > 80) {
            throw new AuraHandledException('Review Name should not exceed 80 characters.');
        }
        if (reviewText != null && reviewText.length() > 3000) {
            throw new AuraHandledException('Review Text should not exceed 3000 characters.');
        }
        if (rating != null && (rating < 0 || rating > 5)) {
            throw new AuraHandledException('Rating should be between 0 and 5.');
        }
        if (dateOfReview != null && dateOfReview > Date.today()) {
            throw new AuraHandledException('Date of Review cannot be in the future.');
        }

        Book_Review__c newReview = new Book_Review__c(
            Book__c = bookId,
            Name = reviewName,
            Date_of_review__c = dateOfReview,
            Rating__c = rating,
            Review_text__c = reviewText
        );

        try {
            insert newReview;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            throw new AuraHandledException('Error creating new review: ' + e.getMessage());
        }

        return newReview.Id;
    }
}
