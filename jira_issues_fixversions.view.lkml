view: jira_issues_fixversions {

  dimension: id {
    primary_key: yes
    sql: fixversions.id;;
  }

  dimension: name {
    description: "Name"
    sql: fixversions.name;;
  }

}
