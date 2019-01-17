view: jira_issues_sprints {

  dimension: id {
    primary_key: yes
    sql: regexp_extract(sprints, 'name=(.*),goal');;
  }
}
