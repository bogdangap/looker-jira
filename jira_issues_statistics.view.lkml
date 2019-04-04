view: jira_issues_statistics {
  view_label: "Statistics"
  sql_table_name: prod.jira_issues_statistics ;;

 dimension: id {
   type: string
   primary_key: yes
   hidden: yes
   sql: ${TABLE}.id ;;
 }

 dimension: key {
   type: string
   hidden: yes
   sql: ${TABLE}.key ;;
 }

 dimension: process_step {
   type: string
   hidden: no
   sql: ${TABLE}.process_step ;;
 }

 dimension: status {
   type: string
   hidden: no
   sql: ${TABLE}.status ;;
 }

 filter: most_recent {
   type: yesno
   description: "Is this the most recent time the Issue went into this Process Step?"
   sql: ${TABLE}.most_recent IS TRUE;;
 }

 dimension: in_cycle {
   type: string
   hidden: no
   sql:${TABLE}.in_cycle;;
 }

 dimension_group: date {
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
   sql: ${TABLE}.dates ;;
 }

 dimension_group: started_at {
   type: time
   hidden: no
   timeframes: [
     raw,
     time,
     date,
     week,
     month,
     quarter,
     year
   ]
   sql: ${TABLE}.started_at ;;
 }

 dimension_group: ended_at {
   type: time
   hidden: no
   timeframes: [
     raw,
     time,
     date,
     week,
     month,
     quarter,
     year
   ]
   sql: ${TABLE}.ended_at ;;
 }

 dimension: retrospective {
   type: string
   hidden: yes
   sql: ${TABLE}.retrospective ;;
 }

 #dimension: term_window {
 #  type: string
 #  hidden: no
 #  sql: ${TABLE}.term ;;
 #}

 dimension: workday {
   type: yesno
   hidden: no
   sql:${TABLE}.workday IS TRUE;;
  description: "Exclude Weekends except weekend days where a status was started"
 }

 dimension: weekday {
   type: yesno
   hidden: no
   sql: ${TABLE}.weekday IS TRUE;;
  description: "Exclude Weekends"
 }

 dimension: day_open {
   type: yesno
   hidden: no
   sql: ${TABLE}.day_open ;;
 }

 dimension: day_close {
   type: yesno
   hidden: no
   sql: ${TABLE}.day_close ;;
 }

 dimension: minutes_dimension {
   type: number
   hidden: yes
   sql: ${TABLE}.minutes ;;
 }

 measure: hours {
   type: sum
   sql: ${minutes_dimension}/60 ;;
   value_format_name: decimal_1
   label: "Total Hours"
   drill_fields: [jira_issues.key,jira_issues.summary,hours]
 }

 measure: days {
   type: sum
   sql: ${minutes_dimension}/480 ;;
   value_format_name: decimal_1
   label: "Total Days"
   drill_fields: [jira_issues.key,jira_issues.summary,date_date,process_step,days]
 }

 measure: count_of_issues_and_status {
   type: count_distinct
   sql: ${id} ;;
   view_label: "Issues"
 }
}
