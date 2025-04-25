import { LightningElement, wire, track, api } from 'lwc';

import getApplicationStats from '@salesforce/apex/DashboardController.getApplicationStats';
import getUpcomingInterviews from '@salesforce/apex/DashboardController.getUpcomingInterviews';
import getRecentApplications from '@salesforce/apex/DashboardController.getRecentApplications';
import getPendingTasks from '@salesforce/apex/DashboardController.getPendingTasks';
import completedTask from '@salesforce/apex/DashboardController.completedTask';

import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Dashboard extends NavigationMixin(LightningElement) {
    @api recordId;

    @track appliedCount = 0;
    @track interviewCount = 0;
    @track offerCount = 0;
    @track totalCount = 0;
    @track recentApplications = [];
    @track upcomingInterviews = [];
    @track pendingTasks = [];
    @track jobAlerts = [];
    @track wiredTasksResult; // Store the result of the wired method for refreshApex
    @track wiredApplicationStatsResult; // Store the result of the wired method for refreshApex

    @wire(getApplicationStats)
    wiredApplicationStats({ error, data }) {
        this.wiredApplicationStatsResult = data; // Store the result for refreshApex
        if (data) {
            this.appliedCount = data.applied || this.appliedCount;
            this.interviewCount = data.interviews || this.interviewCount;
            this.offerCount = data.offers || this.offerCount;
            this.totalCount = data.total || this.totalCount;
        } else if (error) {
            console.error('Error fetching application stats:', error);
        }
    }

    @wire(getRecentApplications)
    wiredRecentApplications({ error, data }) {
        if (data) {
            const options = {
                weekday: "long",
                year: "numeric",
                month: "long",
                day: "numeric",
            };

            this.recentApplications = data.map(application => {
                const appliedDate = new Date(application.Application_Date__c);
                const applicationSalary = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(application.Salary__c);

                return {
                    ...application,
                    formattedDate: appliedDate.toLocaleDateString("en-GB", options),
                    formattedSalary: applicationSalary
                };
            });
        } else if (error) {
            console.error('Error fetching recent applications:', error);
        }
    }

    @wire(getUpcomingInterviews)
    wiredInterviews({ error, data }) {
        if (data) {
            const options = {
                weekday: "long",
                year: "numeric",
                month: "long",
                day: "numeric"
            };

            this.upcomingInterviews = data.map(interview => {
                const startDate = new Date(interview.StartDateTime);
                const endDate = new Date(interview.EndDateTime);

                return {
                    ...interview,
                    formattedDate: startDate.toLocaleDateString("en-GB", options),
                    formattedStartTime: Intl.DateTimeFormat('en-US', {
                        hour: '2-digit',
                        minute: '2-digit',
                        hour12: true,
                        timeZone: 'UTC',
                    }).format(startDate),
                    formattedEndTime: Intl.DateTimeFormat('en-US', {
                        hour: '2-digit',
                        minute: '2-digit',
                        hour12: true,
                        timeZone: 'UTC',
                    }).format(endDate)
                };
            });
        } else if (error) {
            console.error('Error fetching upcoming interviews:', error);
        }
    }

    @wire(getPendingTasks)    
    wiredTasks({ error, data }) {
        this.wiredTasksResult = data; // Store the result for refreshApex
        if (data) {
            const options = {
                weekday: "long",
                year: "numeric",
                month: "long",
                day: "numeric",
            };

            this.pendingTasks = data.map(task => {
                const dueDate = task.ActivityDate ? new Date(task.ActivityDate) : null;

                return {
                    ...task,
                    formattedDueDate: dueDate ? dueDate.toLocaleDateString("en-GB", options) : 'No due date'
                };
            });
        }
        else if (error) {
            console.error('Error fetching pending tasks:', error);
        }
    }

    jobAPICall() {
        const lastCallTS = localStorage.getItem('lastAPICall');
        const lastCallData = localStorage.getItem('lastAPICallData');
        const now = new Date();
        const today = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();

        // date options for formatting
        const options = {
            weekday: "long",
            year: "numeric",
            month: "long",
            day: "numeric"
        };

        let jobApi = "https://jooble.org/api/";
        let jobApiKey = "f1b033ba-59d0-4f64-b46b-802ac1e0c85b";
        let params = {
            keywords: "salesforce developer",
            location: "remote",
            resultonpage: "5"
        };
        let myHeaders = new Headers();

        myHeaders.append("Content-Type", "application/json");

        let requestOptions = {
            method: 'POST',
            headers: myHeaders,
            body: JSON.stringify(params)
        };

        if (!lastCallTS || new Date(parseInt(lastCallTS, 10)) < today) {
            fetch(jobApi + jobApiKey, requestOptions)
                .then(response => {
                    if (!response.ok) {
                        throw new Error(`HTTP error! status: ${response.status}`);
                    }
                    return response.json();
                })
                .then(data => {
                    this.jobAlerts = data.jobs.map(job => {
                        const jobDate = new Date(job.updated);
                        
                        return {
                            ...job,
                            formattedDate: jobDate.toLocaleDateString("en-GB", options),
                            formattedSalary: job.salary ? new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(job.salary) : 'Not specified'
                        };
                    });
                    
                    localStorage.setItem('lastAPICall', now.getTime());
                    localStorage.setItem('lastAPICallData', JSON.stringify(data));
                })
                .catch(error => console.error('API call failed:', error));
        } else {
            if (lastCallData) {
                const data = JSON.parse(lastCallData);
                this.jobAlerts = data.jobs.map(job => {
                    const jobDate = new Date(job.updated);

                    return {
                        ...job,
                        formattedDate: jobDate.toLocaleDateString("en-GB", options),
                        formattedSalary: job.salary ? new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(job.salary) : 'Not specified'
                    };
                });
            }
        }
    }

    connectedCallback() {
        sessionStorage.removeItem('selectedJobData');
        this.jobAPICall();
    }

    navigateToAddScreen(e) {
        const jobIndex = e.currentTarget.dataset.jobIndex;
        const selectedJob = this.jobAlerts[jobIndex];

        sessionStorage.setItem('selectedJobData', JSON.stringify(selectedJob));

        const componentAddDefinition = {
            componentDef: 'c:addJobForm'
        }

        const encodedAddComponentDef = btoa(JSON.stringify(componentAddDefinition));

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedAddComponentDef
            }
        });
    }

    navigateToEditScreen(e) {
        const rID = e.target.value;

        const componentDefinition = {
            componentDef: 'c:editForm',
            attributes: {
                recordId: rID
            }
        }

        const encodedComponentDef = btoa(JSON.stringify(componentDefinition));

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedComponentDef
            }
        });
    }

    handleTaskCompletion(event) {
        const taskId = event.target.dataset.id;
        const isCompleted = event.target.checked;
        
        if (isCompleted) {
            completedTask({ taskId })
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Task marked as completed',
                            variant: 'success'
                        })
                    );

                    return refreshApex(this.wiredTasksResult);
                })
                .catch(error => {
                    console.error('Error completing task:', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'An error occurred while completing the task',
                            variant: 'error'
                        })
                    );
                });
        }
    }
}