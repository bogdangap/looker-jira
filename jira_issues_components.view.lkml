view: jira_issues_components {

  dimension: id {
    primary_key: yes
    sql: components.id;;
    hidden: yes
  }

  dimension: platform {
    sql: components.name;;
    view_label: "Issues"
  }
}
