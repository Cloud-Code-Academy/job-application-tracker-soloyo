import { LightningElement, wire, track, api } from 'lwc';
import getApplicationStats from '@salesforce/apex/DashboardController.getApplicationStats';
//import getUpcomingInterviews from '@salesforce/apex/DashboardController.getUpcomingInterviews';
import getRecentApplications from '@salesforce/apex/DashboardController.getRecentApplications';
import getPendingTasks from '@salesforce/apex/DashboardController.getPendingTasks';
import completedTask from '@salesforce/apex/DashboardController.completedTask';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Dashboard extends LightningElement {
    @api recordId; 

    @track appliedCount = 0;
    @track interviewCount = 0;
    @track offerCount = 0;
    @track totalCount = 0;
    @track recentApplications = [];
    @track upcomingInterviews = [];
    @track pendingTasks = [];

    navigateToRecord() {
        console.log('Record ID:', this.recordId);
    }

    @wire(getApplicationStats)
    wiredApplicationStats({ error, data }) {
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

    /*@wire(getUpcomingInterviews)
    wiredInterviews({ error, data }) {
        console.log('Upcoming Interviews:', data);
        if (data) {
            this.upcomingInterviews = data.map(interview => {
                const startDate = new Date(interview.startDate);

                return {
                    ...interview,
                    formattedDate: startDate.toLocaleDateString(),
                    formattedTime: startDate.toLocateTimeString([], { hour: '2-digit', minute: '2-digit' })
                };
            });
        } else if (error) {
            console.error('Error fetching upcoming interviews:', error);
        }
    }*/

    @wire(getPendingTasks)
    wiredTasks({ error, data }) {
        if (data) {
            console.log('Pending Tasks:', data);
            this.pendingTasks = data.map(task => {
                const dueDate = task.ActivityDate ? new Date(task.ActivityDate) : null;

                return {
                    ...task,
                    formattedDueDate: dueDate ? dueDate.toLocaleDateString() : 'No due date'
                };
            });
        }
        else if (error) {
            console.error('Error fetching pending tasks:', error);
        }
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