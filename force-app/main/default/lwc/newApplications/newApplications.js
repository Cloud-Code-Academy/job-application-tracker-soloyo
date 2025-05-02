import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NewApplications extends LightningElement {
    @track showSpinner = false;

    handleSubmit(e) {
        e.preventDefault();

        this.showSpinner = true;

        const fields = e.detail.fields;

        const currentDate = new Date();
        //const currentDateFollowUp = currentDate.setDate(currentDate.getDate() + 2);

        const formattedDate = currentDate.toISOString().split('T')[0]; 
        //const formattedFollowUpDate = currentDateFollowUp.toISOString().split('T')[0];
        

        // set some defaults just in case
        if (!fields.Status_c) {
            fields.Status_c = 'Saved';
        }

        if (!fields.Application_Date__c) {
            fields.Application_Date__c = formattedDate;
        }

        // if (!fields.Follow_up_Date__c) {
        //     fields.Follow_up_Date__c = formattedFollowUpDate;
        // }

        console.log('Fields:', fields);
        
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess() {
        this.showSpinner = false;
        
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Application created successfully!',
            variant: 'success'
        });

        this.dispatchEvent(toastEvent);

        // reset the form after successful submission
        this.handleCancel();
    }

    handleCancel() { 
        const inputs = this.template.querySelectorAll('lightning-input-field');
        
        inputs.forEach(input => {
            input.reset();
        });
    }
}