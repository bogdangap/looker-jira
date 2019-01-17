view: jira_issues_subissues {
  sql_table_name: prod.jira_issues ;;

  dimension: id {
    primary_key: yes
    sql:id;;
  }

  dimension: key {
    sql: ${TABLE}.key;;
  }
}
