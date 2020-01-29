view: jira_issues_statistics {
  view_label: "Statistics"
  sql_table_name: prod.jira_issues_statistics ;;

 dimension: unique_id {
   type: string
   primary_key: yes
   hidden: yes
   sql: CONCAT(${TABLE}.id,${TABLE}.status,CAST(${TABLE}.dates AS STRING)) ;;
 }

  dimension: id {
    type: string
    hidden: yes
    sql: ${TABLE}.id ;;
  }

 dimension: key {
   type: string
   hidden: yes
   sql: ${TABLE}.key ;;
 }

 #dimension: process_step {
#   type: string
#   hidden: no
#   sql: ${TABLE}.process_step ;;
# }

 dimension: status {
   type: string
   hidden: no
   sql: ${TABLE}.status ;;
 }

 dimension: most_recent {
   type: number
   description: "Is this the most recent time the Issue went into this Process Step?"
   sql: ${TABLE}.most_recent;;
 }

 dimension: in_cycle {
   type: string
   hidden: no
   sql:${TABLE}.in_cycle;;
 }

dimension: process_step {
  type: string
  sql: CASE WHEN ${status} = 'Cancelled' THEN '0. Cancelled'
    WHEN ${status} IN ('Backlog','Reported') THEN '1. Backlog'
    WHEN ${status} IN ('Ranked','Planned','Ready to Start','In Prep') THEN '2. Preparation'
    WHEN ${status} IN ('In Progress','In Review','Polishing','Ready to Merge','Building') THEN '3. In Progress'
    WHEN ${status} IN ('Ready for Testing','In Testing') THEN '4. QA'
    WHEN ${status} IN ('Holding','Limited Release','Removing Flag','Released') THEN '5. Product Release'
    WHEN ${status} IN ('Closed') THEN '6. Completion'
    ELSE 'Legacy' END;;
}

 dimension_group: date {
   type: time
   hidden: no
   timeframes: [
     date,
     day_of_week,
     week,
     month,
     day_of_month,
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

  dimension: story_points {
    type: string
    hidden: yes
    sql: ${TABLE}.story_points ;;
  }

 #dimension: term_window {
 #  type: string
 #  hidden: no
 #  sql: ${TABLE}.term ;;
 #}

  dimension: team {
    type: string
    sql: CASE WHEN ${TABLE}.team = 'dogtopus' THEN 'Dogtopus' WHEN ${TABLE}.team = 'quokka' THEN 'Quokka' WHEN ${TABLE}.team IS NULL THEN 'No Team' ELSE ${TABLE}.team END;;
    hidden: yes
  }

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

  dimension: day_order {
    type: yesno
    hidden: yes
    sql: ${TABLE}.day_order ;;
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
