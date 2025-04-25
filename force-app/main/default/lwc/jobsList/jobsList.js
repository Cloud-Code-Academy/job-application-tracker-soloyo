import { LightningElement, wire, track } from 'lwc';

import { refreshApex } from '@salesforce/apex';
import getAllJobs from '@salesforce/apex/JobsListController.getAllJobs';

import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import POSITION from '@salesforce/schema/Job_Application__c.Position__c';
import COMPANY_NAME from '@salesforce/schema/Job_Application__c.Company_Name__c';
import APPLICATION_DATE from '@salesforce/schema/Job_Application__c.Application_Date__c';
import SALARY from '@salesforce/schema/Job_Application__c.Salary__c';
import STATUS from '@salesforce/schema/Job_Application__c.Status__c';
import INTERVIEW_DATE from '@salesforce/schema/Job_Application__c.Interview_Date__c';
import URL from '@salesforce/schema/Job_Application__c.URL__c';

const columns = [
    { label: 'Position', fieldName: POSITION.fieldApiName, editable: false },
    { label: 'Company', fieldName: COMPANY_NAME.fieldApiName, editable: false },
    { label: 'Salary', fieldName: SALARY.fieldApiName, editable: true },
    { label: 'Application Date', fieldName: APPLICATION_DATE.fieldApiName, type: 'date', editable: false },
    { label: 'Schedule Interview', fieldName: INTERVIEW_DATE.fieldApiName, type: 'date', editable: true },
    { label: 'URL', fieldName: 'URL__c', type: URL.fieldApiName, editable: false },
    { label: 'Status', fieldName: STATUS.fieldApiName, editable: true },
];

export default class JobsList extends LightningElement {
    statusOptions;
    draftValues = [];
    columns = columns;
    @track allJobs = [];
    @track isLoading = true;
    @track wiredAllJobsResults;

    @wire(getAllJobs)
    wiredAllJobs({ error, data }) {
        this.wiredAllJobsResults = data;

        console.log('Data:', data);

        if (data) {
            this.isLoading = false;

            this.allJobs = data.map(jobsList => {
                return {
                    ...jobsList
                };
            });
        } else if (error) {
            console.error('Error fetching recent applications:', error);
        }
    }

    async handleSave(e) {
        const records = e.detail.draftValues.slice().map((draftValue) => {
            const fields = Object.assign({}, draftValue);
            return { fields };
        });
        
        this.draftValues = [];
    
        try {          
            const recordUpdatePromises = records.map((record) => updateRecord(record));
            await Promise.all(recordUpdatePromises);
            
            this.dispatchEvent(
                new ShowToastEvent({
                title: "Success",
                message: "Job Application Updated",
                variant: "success"
                })
            );
          
            await refreshApex(this.wiredAllJobsResults);
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                title: "Error updating or reloading Job Application",
                message: error.body.message,
                variant: "error"
                })
            );
        }
    }
}   