import { LightningElement, wire, track } from 'lwc';

import getAllJobs from '@salesforce/apex/JobController.getAllJobs';

export default class JobsList extends LightningElement {
    @track allJobs = [];
    @track isLoading = true;
    @track wiredAllJobsResults;

    @wire(getAllJobs)
    wiredAllJobs({ error, data }) {
        this.wiredAllJobsResults = data;

        if (data) {
            this.isLoading = false;
            const options = {
                weekday: "long",
                year: "numeric",
                month: "long",
                day: "numeric",
            };

            this.allJobs = data.map(jobsList => {
                const appliedDate = new Date(jobsList.Application_Date__c);
                const applicationSalary = jobsList.Salary__c ? new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(jobsList.Salary__c) : "Not specified!";

                return {
                    ...jobsList,
                    formattedDate: appliedDate.toLocaleDateString("en-GB", options),
                    formattedSalary: applicationSalary
                };
            });
        } else if (error) {
            console.error('Error fetching recent applications:', error);
        }
    }
}   