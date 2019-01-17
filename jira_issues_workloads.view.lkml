view: jira_issues_workloads {
  dimension: id {
    primary_key: yes
    sql: workloads.id;;
  }


  measure: timeSpentSeconds {
    type:  sum
    sql: workloads.timeSpentSeconds;;
  }
}
