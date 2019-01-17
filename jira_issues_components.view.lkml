view: jira_issues_components {

  dimension: id {
    primary_key: yes
    sql: components.id;;
  }

  dimension: name {
    description: "Name"
    sql: components.name;;
  }
}
