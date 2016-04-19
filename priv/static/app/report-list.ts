/**
 * Created by eric on 18/04/16.
 */
import {Component} from 'angular2/core';
import {Report} from './report';

@Component({
  selector: 'report-list',
  templateUrl: '/app/report-list.html'
})

export class ReportList {
  reports: Array<Report> = [];

  addReport(id, name, broadcast_id, status){
    const report = new Report(id.value, name.value, broadcast_id.value, status.value);
    this.reports.push(report);
  }

  cancelReport(report){
    const index = this.reports.indexOf(report);
    console.log(index);
    this.reports.splice(index, 1);
  }
}
