import { LightningElement, api, wire, track } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

import POSITION from '@salesforce/schema/Job_Application__c.Position__c';
import COMPANY_NAME from '@salesforce/schema/Job_Application__c.Company_Name__c';
import LOCATION from '@salesforce/schema/Job_Application__c.Location__c';
import APPLICATION_DATE from '@salesforce/schema/Job_Application__c.Application_Date__c';
import SALARY from '@salesforce/schema/Job_Application__c.Salary__c';
import STATUS from '@salesforce/schema/Job_Application__c.Status__c';
import DESCRIPTION from '@salesforce/schema/Job_Application__c.Description__c';
import FOLLOWUP_DATE from '@salesforce/schema/Job_Application__c.Follow_up_Date__c';
import NOTES from '@salesforce/schema/Job_Application__c.Notes__c';
import RATING from '@salesforce/schema/Job_Application__c.Rating__c';
import SOURCE from '@salesforce/schema/Job_Application__c.Source__c';
import URL from '@salesforce/schema/Job_Application__c.URL__c';
import PRIMARY_CONTACT from '@salesforce/schema/Job_Application__c.Primary_Contact__c'; 

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = [
    POSITION, 
    COMPANY_NAME, 
    LOCATION, 
    APPLICATION_DATE, 
    SALARY, 
    STATUS,
    DESCRIPTION,
    FOLLOWUP_DATE,
    NOTES,
    RATING,
    SOURCE,
    URL,
    PRIMARY_CONTACT
]

export default class EditForm extends NavigationMixin(LightningElement) {
    @api recordId;
    @track jobApplication;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredJobApplication({ error, data }) {
        if (data) {
            this.jobApplication = data;
        } else if (error) {
            this.showToast('Error', 'Error loading job application', 'error');
        }
    }

    handleSuccess() {
        this.showToast('Success', 'Job Application updated', 'success');
        
        this.navigateBackToDashboard();
    }

    navigateBackToDashboard() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Dashboard'  // Replace with your actual tab API name
            }
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}