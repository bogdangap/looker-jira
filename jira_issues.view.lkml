view: jira_issues {
  sql_table_name: prod.jira_issues ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: expand {
    hidden: yes
    type: string
    sql: ${TABLE}.expand ;;
  }

  dimension: fields {
    hidden: yes
    sql: ${TABLE}.fields ;;
  }

  dimension: key {
    type: string
    sql: ${TABLE}.key ;;
  }

  dimension: self {
    hidden:  yes
    type: string
    sql: ${TABLE}.self ;;
  }


  dimension: summary {
     type: string
     sql: ${TABLE}.fields.summary ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.fields.description ;;
  }

  dimension_group: updated {
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
    sql:timestamp(regexp_replace(${TABLE}.fields.updated, '(\\d\\d$)', ':\\1'))  ;;
  }

  dimension_group: created {
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
    sql:timestamp(regexp_replace(${TABLE}.fields.created, '(\\d\\d$)', ':\\1'))  ;;
  }


  dimension: creator_email_address {
    type: string
    sql: ${TABLE}.fields.creator.emailAddress ;;
  }

  dimension: priority_name {
    type: string
    sql: ${TABLE}.fields.priority.name ;;
  }

  dimension: project_key {
    type: string
    sql: ${TABLE}.fields.project.key ;;
  }

  dimension_group: resolution_date {
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
    sql:timestamp(regexp_replace(${TABLE}.fields.resolutiondate, '(\\d\\d$)', ':\\1'))  ;;
  }

  dimension: resolution_name {
    type: string
    sql: ${TABLE}.fields.resolution.name ;;
  }

  dimension: status_category_name {
    type: string
    sql: ${TABLE}.fields.status.statusCategory.name;;
  }

  dimension: assignee_email_address {
    type: string
    sql: ${TABLE}.fields.assignee.emailAddress ;;
  }

  dimension: status_name {
    type: string
    sql: ${TABLE}.fields.status.name ;;
  }

  dimension: reporter_email_address {
    type: string
    sql: ${TABLE}.fields.reporter.emailAddress ;;
  }

  dimension: issue_type_name {
    type: string
    sql: ${TABLE}.fields.issuetype.name ;;
  }


  dimension: story_points {
    type: string
    sql: ${TABLE}.fields.customfield_10021 ;;
  }


  dimension: labels_string {
    type: string
    sql: ${TABLE}.labels_string ;;
  }

  measure: story_points_sum {
    type: sum
    sql: ${TABLE}.fields.customfield_10021 ;;
    group_label: "Story Points"
  }

  measure: story_points_sum_3_months{
    sql: sum(sum(${TABLE}.fields.customfield_10021)) OVER (ORDER BY ${jira_retrospectives.name} ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) ;;
    group_label: "Story Points"
  }

  measure: story_points_sum_2_months{
    sql: sum(sum(${TABLE}.fields.customfield_10021)) OVER (ORDER BY ${jira_retrospectives.name} ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) ;;
    group_label: "Story Points"
  }

  measure: story_points_sum_lag{
    sql: lag(sum(${TABLE}.fields.customfield_10021)) OVER (ORDER BY ${jira_retrospectives.name}) ;;
    hidden: yes
    group_label: "Story Points"
  }

  measure: time_spent{
    type:  sum
    sql:${TABLE}.fields.aggregatetimespent ;;
  }

  measure: expedited{
    type:  sum
    sql: case when ${TABLE}.fields.priority.name = 'Highest' then 1 else 0 end ;;
  }

  measure: count {
    type: count
    #drill_fields: [id]
  }

  measure: days_logged_on_completed_stories {
    sql:round(${time_spent}/28800,2);;
  }

  measure: points_per_cycle_day {
    sql:if(${jira_retrospectives.work_days}!=0, round(${story_points_sum}/${jira_retrospectives.work_days},2), null);;
    group_label: "Calculated Statistics"
  }

  measure: points_per_cycle_day_3_months {
    sql:if(${jira_retrospectives.work_days_3_months}!=0,round(${story_points_sum_3_months}/${jira_retrospectives.work_days_3_months},2), null);;
    group_label: "Calculated Statistics"
  }

  measure: points_per_logged_day {
    sql: if(${time_spent}!=0, round(${story_points_sum}/${time_spent}*28800,2), null) ;;
    group_label: "Calculated Statistics"
  }

  measure: points_per_engineering_day {
    sql: if(${jira_retrospectives.engineering_days}!=0,round(${story_points_sum}/${jira_retrospectives.engineering_days},2),0) ;;
    group_label: "Calculated Statistics"
  }

  measure: points_per_engineering_day_3_months {
    sql: if(${jira_retrospectives.engineering_days_lag_2}!=0, round(${story_points_sum_3_months}/${jira_retrospectives.engineering_days_3_months},2) ,
        if(${jira_retrospectives.engineering_days_lag_1}!=0,round(${story_points_sum_2_months}/${jira_retrospectives.engineering_days_3_months},2),
        if(${jira_retrospectives.engineering_days}!=0,round(${story_points_sum}/${jira_retrospectives.engineering_days},2),0))) ;;
    group_label: "Calculated Statistics"
  }

}
