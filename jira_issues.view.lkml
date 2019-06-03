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

  dimension: key_url {
    sql: CONCAT('https://happyco.atlassian.net/browse/',(CAST(${key} AS STRING)),'/') ;;
    hidden: yes
  }

  dimension: link {
    sql: ${key_url} ;;
    html: <a href="{{ value }}" target="_blank">{{ key }} <img src="https://storage.googleapis.com/happyco-downloadable-assets/bi/public/external-link.png" style=" width: 8px; height: 8px; display: inline-block;" /></a> ;;
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

  dimension: age_dimension {
    type: duration_day
    description: "Time in days since an Issue was created"
    sql_start: ${created_raw} ;;
    #sql_end: COALESCE(${resolution_date_raw},CAST(current_date AS TIMESTAMP));;
    sql_end: CAST(current_date AS TIMESTAMP);;
    hidden: yes
  }

  dimension: open_age_dimension {
    type: duration_day
    description: "Time in days from Issue created to Resolved"
    sql_start: ${created_raw} ;;
    sql_end: COALESCE(${resolution_date_raw},CAST(current_date AS TIMESTAMP));;
    hidden: yes
  }

  measure: age {
    type: sum
    description: "Time in days since an Issue was created"
    sql: ${age_dimension} ;;
    group_label: "Age"

  }

  measure: open_age {
    type: sum
    description: "Time in days since an Issue was created"
    sql: ${open_age_dimension} ;;
    group_label: "Age"

  }

  measure: avg_age {
    description: "Average Time in days since an Issue was created"
    type: average
    sql: ${age_dimension} ;;
    value_format_name: decimal_1
    group_label: "Age"
  }

  measure: median_age {
    type: median
    description: "Median Time in days since an Issue was created"
    sql: ${age_dimension} ;;
    value_format_name: decimal_1
    group_label: "Age"
  }

  measure: avg_open_age {
    description: "Average time in days from Issue created to Resolved"
    type: average
    sql: ${open_age_dimension} ;;
    value_format_name: decimal_1
    group_label: "Age"
  }

  measure: median_open_age {
    type: median
    description: "Median time in days from Issue created to Resolved"
    sql: ${open_age_dimension} ;;
    value_format_name: decimal_1
    group_label: "Age"
  }

  dimension: creator_email_address {
    type: string
    sql: ${TABLE}.fields.creator.emailAddress ;;
  }

  dimension: priority_name {
    type: string
    sql: ${TABLE}.fields.priority.name ;;
  }

  dimension: priority_number {
    type: string
    sql: CASE WHEN ${priority_name} = "Highest" THEN "1"
              WHEN ${priority_name} = "High" THEN "2"
              WHEN ${priority_name} = "Medium" THEN "3"
              WHEN ${priority_name} = "Low" THEN "4"
              WHEN ${priority_name} = "Lowest" THEN "5"
              ELSE "5" END
              ;;
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
    label: "Current Status"
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
    sql: CAST(${TABLE}.fields.customfield_10021 AS STRING);;
  }

  dimension: labels_string {
    type: string
    sql: ${TABLE}.labels_string ;;
  }

  dimension: term {
    type: string
    sql: CASE
    WHEN ${labels_string} LIKE '%2019-t1%' THEN '2019-T1'
    WHEN ${labels_string} LIKE '%2019-t2%' THEN '2019-T2'
    WHEN ${labels_string} LIKE '%2019-t3%' THEN '2019-T3'
    WHEN ${labels_string} LIKE '%2019-t4%' THEN '2019-T4'
    WHEN ${labels_string} LIKE '%2019-t5%' THEN '2019-T5'
  ELSE NULL END ;;
  }

  dimension: team {
    type: string
    sql: CASE
          WHEN ${labels_string} LIKE '%team_quokka%' THEN 'Quokka'
          WHEN ${labels_string} LIKE '%team_dogtopus%' THEN 'Dogtopus'
        ELSE NULL END ;;
  }

  measure: story_points_sum {
    type: sum
    sql: ${TABLE}.fields.customfield_10021 ;;
    group_label: "Story Points"
    drill_fields: [key,summary,status_name,updated_date,resolution_date_date,story_points_sum]
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
    drill_fields: [key,link,summary]
  }

  measure: days_logged_on_completed_stories {
    type: number
    sql:round(${time_spent}/28800,2);;
  }

  measure: points_per_cycle_day {
    type: number
    sql:if(${jira_retrospectives.work_days}!=0, round(${story_points_sum}/${jira_retrospectives.work_days},2), null);;
    group_label: "Calculated Statistics"
  }

  measure: points_per_cycle_day_3_months {
    type: number
    sql:if(${jira_retrospectives.work_days_3_months}!=0,round(${story_points_sum_3_months}/${jira_retrospectives.work_days_3_months},2), null);;
    group_label: "Calculated Statistics"
  }

  measure: points_per_logged_day {
    type: number
    sql: if(${time_spent}!=0, round(${story_points_sum}/${time_spent}*28800,2), null) ;;
    group_label: "Calculated Statistics"
  }

  measure: points_per_engineering_day {
    type: number
    sql: if(${jira_retrospectives.engineering_days}!=0,round(${story_points_sum}/${jira_retrospectives.engineering_days},2),0) ;;
    group_label: "Calculated Statistics"
  }

  measure: points_per_engineering_day_3_months {
    type  :  number
    sql: if(${jira_retrospectives.engineering_days_lag_2}!=0, round(${story_points_sum_3_months}/${jira_retrospectives.engineering_days_3_months},2) ,
        if(${jira_retrospectives.engineering_days_lag_1}!=0,round(${story_points_sum_2_months}/${jira_retrospectives.engineering_days_3_months},2),
        if(${jira_retrospectives.engineering_days}!=0,round(${story_points_sum}/${jira_retrospectives.engineering_days},2),0))) ;;
    group_label: "Calculated Statistics"
  }

  dimension: priority_multiplier_dimension {
    type: number
    sql: CASE WHEN ${priority_name} = "Highest" THEN 8
              WHEN ${priority_name} = "High" THEN 5
              WHEN ${priority_name} = "Medium" THEN 3
              WHEN ${priority_name} = "Low" THEN 2
              WHEN ${priority_name} = "Lowest" THEN 1
              ELSE 1 END;;
    hidden: no
  }

  measure: quality_score {
    type: sum
    sql: ${priority_multiplier_dimension} ;;
    hidden: no
    drill_fields: [key,link,summary,priority_number,status_name,updated_date,quality_score]
  }

}
