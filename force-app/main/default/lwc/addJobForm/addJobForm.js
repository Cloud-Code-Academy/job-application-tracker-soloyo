import { LightningElement, track } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddJobForm extends NavigationMixin(LightningElement) {
    @track formData = {
        jobTitle: '',
        jobCompany: '',
        jobLocation: '',
        jobLink: '',
        jobSalary: ''
    };
    @track jobData;
    @track showSpinner = false;
    storedData

    loadData() {        
        this.storedData = sessionStorage.getItem('selectedJobData');
        console.log('Stored Data: ', this.storedData);
        console.log('connectedCallback called');

        if (this.storedData) {
            this.jobData = JSON.parse(this.storedData);

            this.formData.jobTitle = this.jobData.title;
            this.formData.jobCompany = this.jobData.company;
            this.formData.jobLocation = this.jobData.location;
            this.formData.jobLink = this.jobData.link.substring(0, this.jobData.link.indexOf('?'));
            this.formData.jobSalary = this.jobData.salary;
            this.formData.date = this.jobData.updated;
            sessionStorage.removeItem('selectedJobData');
        } else {
            console.log('Error', 'No job data found in session storage');
        }
    }

    // a lifecycle hook that gets executed when a component is added to the DOM
    connectedCallback() {
        this.loadData();
    }

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
        
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess() {
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Job Application created successfully!',
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);

        // reset the form after successful submission
        this.handleCancel();
    }

    handleCancel() {
        this.navigateBackToDashboard();
    }

    navigateBackToDashboard() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/lightning/n/Job_Tracker'
            }
        });
    }
}