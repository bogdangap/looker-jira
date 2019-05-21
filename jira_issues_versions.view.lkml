view: jira_issues_versions {

  dimension: id {
    primary_key: yes
    sql: versions.id;;
    hidden: yes
  }

  dimension: release {
    sql: versions.name;;
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
    sql: CAST(versions.releaseDate AS TIMESTAMP) ;;
    view_label: "Issues"
  }

}
