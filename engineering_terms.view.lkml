view: engineering_terms {
  view_label: "Terms"
  sql_table_name: prod.engineering_terms ;;

  dimension_group: calendar_day {
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
    sql: ${TABLE}.calendar_day ;;
    hidden: yes
  }

  dimension: e_term {
    type: string
    sql: ${TABLE}.e_term ;;
  }

  dimension: term {
    type: string
    sql: ${TABLE}.term ;;
  }

  #measure: count {
  #  type: count
  #  drill_fields: []
  #}
}
