view: jira_issues_labels {

  dimension: label {
    primary_key: yes
    sql: label;;
  }

  measure: labels_string  {
    type:  string
    sql:  string_agg(label, ',') ;;
  }
}
