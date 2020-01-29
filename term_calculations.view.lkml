view: term_calculations {
view_label: "Terms"
derived_table: {
  sql:
SELECT calendar_day, term_day_number, term_week_number, days_in_term, MAX(days_passed) OVER (PARTITION BY term) as days_passed
FROM
(SELECT calendar_day, term, term_day_number, term_week_number, MAX(term_day_number) OVER (PARTITION BY term) as days_in_term, CASE WHEN calendar_day <= CAST(current_date AS TIMESTAMP) THEN term_day_number ELSE NULL END as days_passed
FROM
(SELECT calendar_day, week, term, CASE WHEN term IS NOT NULL THEN DENSE_RANK() OVER (PARTITION BY term ORDER BY calendar_day) ELSE NULL END as term_day_number, CASE WHEN term IS NOT NULL THEN DENSE_RANK() OVER (PARTITION BY term ORDER BY week) ELSE NULL END as term_week_number
FROM
(SELECT calendar_day, FORMAT_TIMESTAMP('%F', TIMESTAMP_TRUNC(CAST(calendar_day AS TIMESTAMP), WEEK(MONDAY))) AS week, term, e_term
FROM prod.engineering_terms) x
ORDER BY 1,2) x1) x2
      ;;

  #persist_for: "24 hours"
  #indexes: ["id","dates"]
  }


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

  dimension: term_week_number {
    type: number
    sql: ${TABLE}.term_week_number ;;
    group_label: "Term Calendar"
  }

  dimension: term_day_number {
    type: number
    sql: ${TABLE}.term_day_number ;;
    group_label: "Term Calendar"
  }

  dimension: days_in_term {
    type: number
    sql: ${TABLE}.days_in_term ;;
    group_label: "Term Calendar"
  }

  dimension: days_completed {
    type: number
    sql: ${TABLE}.days_passed ;;
    group_label: "Term Calendar"
  }

  dimension: current_week {
    type: number
    sql: CASE WHEN FORMAT_TIMESTAMP('%F', TIMESTAMP_TRUNC(CAST(current_date AS TIMESTAMP), WEEK(MONDAY))) = ${calendar_day_week} THEN ${term_week_number} ELSE NULL END ;;
    group_label: "Term Calendar"
  }

}
