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

  dimension_group: release_date {
    type: time
    hidden: no
    timeframes: [
      date,
      day_of_week,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(fixversions.releaseDate AS TIMESTAMP) ;;
    view_label: "Issues"
  }

}
