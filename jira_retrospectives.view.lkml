view: jira_retrospectives {
  sql_table_name: prod.jira_retrospectives ;;

  dimension: name {
      primary_key: yes
      type: string
      sql: ${TABLE}.name ;;
  }

  measure: work_days {
    type: sum
    sql: ${TABLE}.work_days ;;
  }

  dimension: work_days_dimension {
    type: number
    sql: ${TABLE}.work_days ;;
    hidden: yes
  }

  measure: work_days_3_months {
    type:  sum
    sql:  ${TABLE}.work_days_3_rows;;
  }

  measure: engineering_days {
    type: sum
    sql: ${TABLE}.engineering_days ;;
    group_label: "Engineering Days"
  }

  measure: engineering_days_3_months {
    type: sum
    sql: ${TABLE}.engineering_days_3_rows ;;
    group_label: "Engineering Days"
  }

  measure: engineering_days_lag_1 {
    type: sum
    sql: ${TABLE}.engineering_days_lag_1 ;;
    group_label: "Engineering Days"
  }

  measure: engineering_days_lag_2 {
    type: sum
    sql: ${TABLE}.engineering_days_lag_2 ;;
    group_label: "Engineering Days"
  }


  dimension_group: start_date{
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql:${TABLE}.start_date  ;;
  }

  dimension_group: end_date{
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql:${TABLE}.end_date  ;;
  }

}
