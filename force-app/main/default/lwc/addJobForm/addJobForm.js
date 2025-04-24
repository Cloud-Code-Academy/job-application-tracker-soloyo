import { LightningElement, wire, track } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import JOB_APPLICATION_CHANNEL from '@salesforce/messageChannel/JobApplicationMessageChannel__c';

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
    subscription = null;

    @wire(MessageContext)
    messageContext;

    // a lifecycle hook that gets executed when a component is added to the DOM
    connectedCallBack() {
        this.subscription = subscribe(
            this.messageContext,
            JOB_APPLICATION_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    // lifecycle hook fires when a component is removed or hidden from the DOM
    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage(message) {
        this.jobData = message.jobData;

        this.formData.jobTitle = this.jobData.title;
        this.formData.jobCompany = this.jobData.company;
        this.formData.jobLocation = this.jobData.location;
        this.formData.jobLink = this.jobData.link.substring(0, this.jobData.link.indexOf('?'));
        this.formData.jobSalary = this.jobData.salary;
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