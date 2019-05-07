view: jira_issues_fixversions {

  dimension: id {
    primary_key: yes
    sql: fixversions.id;;
    hidden: yes
  }

  dimension: release {
    sql: fixversions.name;;
    view_label: "Issues"
  }

}
