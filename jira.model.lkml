connection: "happyco_bq"

# include all the views
include: "*.view"

datagroup: jira_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: jira_default_datagroup



explore: bugs_time {
    from:  jira_issues

  sql_always_where: bugs_time.fields.status.name = 'Closed'
  AND bugs_time.fields.issuetype.name  IN ('Bug')
  AND (bugs_time.labels_string NOT LIKE '%internal\\_tools%' OR bugs_time.labels_string IS NULL);;

  join: jira_retrospectives {
    view_label: "Retrospectives"
    sql_on: bugs_time.fields.resolutiondate is not null
           and ${jira_retrospectives.start_date_date} <= ${bugs_time.resolution_date_date}
          AND ${jira_retrospectives.end_date_date} > ${bugs_time.resolution_date_date};;
    type:  inner
    relationship: many_to_one
  }

  join: jira_issues_time {
    view_label: "Time in Status"
    sql_on:  ${bugs_time.id}= ${jira_issues_time.id} ;;
    type: inner
    relationship: one_to_many
  }
}

explore: completed_issues {

  from: jira_issues

  sql_always_where: completed_issues.fields.status.name = 'Closed'
  AND completed_issues.fields.issuetype.name  IN ('Story', 'Technical Story')
  AND (completed_issues.labels_string NOT LIKE '%internal\\_tools%' OR completed_issues.labels_string IS NULL);;

  join: jira_retrospectives {
    view_label: "Retrospectives"
    sql_on: completed_issues.fields.resolutiondate is not null
           and ${jira_retrospectives.start_date_date} <= ${completed_issues.resolution_date_date}
          AND ${jira_retrospectives.end_date_date} > ${completed_issues.resolution_date_date};;
    type:  inner
    relationship: many_to_one
  }

  join: jira_issues_time {
    view_label: "Time in Status"
    sql_on:  ${completed_issues.id}= ${jira_issues_time.id} ;;
    type: inner
    relationship: one_to_many
  }
}





explore: jira_issues {

  from: jira_issues

  join: jira_issues_comments {
    view_label: "Comments"
    sql: LEFT JOIN UNNEST(jira_issues.fields.comment.comments) as comments;;
    relationship: one_to_many
  }

  join: jira_issues_components {
    view_label: "Components"
    sql: LEFT JOIN UNNEST(jira_issues.fields.components) as components;;
    relationship: one_to_many
  }

  join: jira_issues_fixversions {
    view_label: "FixVersions"
    sql:  LEFT JOIN UNNEST(jira_issues.fields.fixversions) as fixversions ;;
    relationship: one_to_many
  }

  join: jira_issues_workloads {
    view_label: "Workloads"
    sql:  LEFT JOIN UNNEST(jira_issues.fields.worklog.worklogs) as workloads ;;
    relationship: one_to_many
  }

  join: jira_issues_sprints {
    view_label: "Sprints"
    sql:  LEFT JOIN UNNEST(jira_issues.fields.customfield_10016) as sprints ;;
    relationship: one_to_many
  }

  join: jira_issues_subissues {
    view_label: "SubIssues"
    sql_on: jira_issues_subissues.fields.parent.id =  jira_issues.id  ;;
    relationship: one_to_many
    type:  left_outer
  }


  join: jira_retrospectives {
    view_label: "Retrospectives"
    sql_on: jira_issues.fields.resolutiondate is not null
           and ${jira_retrospectives.start_date_date} <= ${jira_issues.resolution_date_date}
          AND ${jira_retrospectives.end_date_date} > ${jira_issues.resolution_date_date};;
    type:  inner
    relationship: many_to_one
  }

}
