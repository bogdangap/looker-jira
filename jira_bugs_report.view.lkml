view: jira_bugs_report {
  sql_table_name: prod.jira_bugs_report ;;

  measure: average_age_days {
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.average_age_days ;;
  }

  measure: count {
    type: sum
    sql: ${TABLE}.count ;;
  }

  measure: count_high {
    type: sum
    sql: ${TABLE}.count_high ;;
  }

  measure: count_highest {
    type: sum
    sql: ${TABLE}.count_highest ;;
  }

  measure: count_low {
    type: sum
    sql: ${TABLE}.count_low ;;
  }

  measure: count_lowest {
    type: sum
    sql: ${TABLE}.count_lowest ;;
  }

  measure: count_medium {
    type: sum
    sql: ${TABLE}.count_medium ;;
  }

  dimension_group: date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date ;;
  }

  measure: mean_age_days {
    type: sum
    sql: ${TABLE}.mean_age_days ;;
  }

  measure: quality_score_high {
    type: sum
    sql: ${TABLE}.quality_score_high ;;
  }

  measure: quality_score_highest {
    type: sum
    sql: ${TABLE}.quality_score_highest ;;
  }

  measure: quality_score_low {
    type: sum
    sql: ${TABLE}.quality_score_low ;;
  }

  measure: quality_score_lowest {
    type: sum
    sql: ${TABLE}.quality_score_lowest ;;
  }

  measure: quality_score_medium {
    type: sum
    sql: ${TABLE}.quality_score_medium ;;
  }

  measure: total_quality_score {
    type: sum
    sql: ${TABLE}.total_quality_score ;;
  }

}
