view: issues_by_cycle {
  derived_table: {
    sql:
      SELECT key, CASE WHEN process_step IN ('1. Backlog','2. Preparation') THEN '1. Open' WHEN process_step IN ('3. In Progress','4. QA') THEN '2. In Cycle' WHEN process_step = '5. Completion' THEN '3. Complete'  WHEN process_step = '0. Cancelled' THEN '0. Cancelled' ELSE '0. Not In Cycle' END as in_cycle, MIN(started_at) as started_at, MAX(ended_at) as ended_at, SUM(minutes) as minutes, SUM(days_in_work_minutes) as days_in_work_minutes
      FROM ${jira_issues_statistics.SQL_TABLE_NAME}
      WHERE {% if jira_issues_statistics.process_step._is_filtered %} {% condition jira_issues_statistics.process_step %} process_step {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.most_recent._is_filtered %} {% condition jira_issues_statistics.most_recent %} most_recent {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.weekday._is_filtered %} {% condition jira_issues_statistics.weekday %} weekday {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.workday._is_filtered %} {% condition jira_issues_statistics.workday %} workday {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.day_open._is_filtered %} {% condition jira_issues_statistics.day_open %} day_open {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.day_close._is_filtered %} {% condition jira_issues_statistics.day_close %} day_close {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.in_cycle._is_filtered %} {% condition jira_issues_statistics.in_cycle %} in_cycle {% endcondition %} {% else %} 1=1 {% endif %}
      /* iclude if we want to exclude days outside of retro in final time spent AND {% if jira_retrospectives.name._is_filtered %} {% condition jira_retrospectives.name %} retrospective {% endcondition %} {% else %} 1=1 {% endif %}*/
      GROUP BY 1,2
      ;;

  #persist_for: "24 hours"
  #indexes: ["id","dates"]
    }

  dimension: id {
    type: string
    primary_key: yes
    hidden: yes
    sql: CONCAT(${TABLE}.key,${TABLE}.in_cycle) ;;
  }
  dimension: key {
    type: string
    hidden: yes
    sql: ${TABLE}.key ;;
  }

  dimension: in_cycle {
    type: string
    hidden: yes
    sql:${TABLE}.in_cycle;;
  }

  dimension: hours_dimension {
    type: number
    sql: ${TABLE}.minutes/60;;
    hidden: yes
  }

  dimension: days_in_work_minutes {
    type: number
    hidden: yes
    sql: ${TABLE}.days_in_work_minutes/480;;
  }

  measure: days_in_cycle {
    type:sum
    sql: CASE WHEN ${in_cycle} = '2. In Cycle' THEN ${days_in_work_minutes} ELSE null END ;;
    view_label: "Statistics"
    group_label: "By Cycle"
    label: "Days In Active Cycle"
    value_format_name: decimal_1
    drill_fields: [jira_issues.link,jira_issues.summary,jira_issues_statistics.process_step,jira_issues_statistics.days]
  }

  measure: avg_hours {
    type: average
    sql: ${hours_dimension} ;;
    view_label: "Statistics"
    group_label: "By Cycle"
    label: "AVG Hours per Cycle"
    value_format_name: decimal_1
    drill_fields: [jira_issues.link,jira_issues.summary,jira_issues_statistics.hours]
  }

  measure: avg_days {
    type: average
    sql: ${days_in_work_minutes} ;;
    view_label: "Statistics"
    group_label: "By Cycle"
    label: "AVG Days per Cycle"
    value_format_name: decimal_1
    drill_fields: [jira_issues.link,jira_issues.summary,jira_issues_statistics.process_step,jira_issues_statistics.days]
  }

  measure: median_days {
    type: median
    sql: ${days_in_work_minutes} ;;
    view_label: "Statistics"
    group_label: "By Cycle"
    label: "Median Days per Cycle"
    value_format_name: decimal_1
    drill_fields: [jira_issues.link,jira_issues.summary,jira_issues_statistics.process_step,jira_issues_statistics.days]
  }

  measure: avg_days_in_active_cycle {
    type: average
    sql: CASE WHEN ${in_cycle} = '2. In Cycle' THEN ${days_in_work_minutes} ELSE NULL END ;;
    view_label: "Statistics"
    group_label: "By Cycle"
    label: "AVG Days in Active Cycle"
    value_format_name: decimal_1
    drill_fields: [jira_issues.link,jira_issues.summary,jira_issues_statistics.process_step,jira_issues_statistics.days]
  }

  measure: median_days_in_active_cycle {
    type: median
    sql: CASE WHEN ${in_cycle} = '2. In Cycle' THEN ${days_in_work_minutes} ELSE NULL END ;;
    view_label: "Statistics"
    group_label: "By Cycle"
    label: "Median Days in Active Cycle"
    value_format_name: decimal_1
    drill_fields: [jira_issues.link,jira_issues.summary,jira_issues_statistics.process_step,jira_issues_statistics.days]
  }

  measure: percentile_days_in_active_cycle_25 {
    type: percentile
    percentile: 25
    sql: CASE WHEN ${in_cycle} = '2. In Cycle' THEN ${days_in_work_minutes} ELSE NULL END ;;
    view_label: "Statistics"
    group_label: "By Cycle"
    label: "Days in Active Cycle 25th Percentile"
    value_format_name: decimal_1
    drill_fields: [jira_issues.link,jira_issues.summary,jira_issues_statistics.process_step,jira_issues_statistics.days]
  }

  measure: percentile_days_in_active_cycle_75 {
    type: percentile
    percentile: 75
    sql: CASE WHEN ${in_cycle} = '2. In Cycle' THEN ${days_in_work_minutes} ELSE NULL END ;;
    view_label: "Statistics"
    group_label: "By Cycle"
    label: "Days in Active Cycle 75th Percentile"
    value_format_name: decimal_1
    drill_fields: [jira_issues.link,jira_issues.summary,jira_issues_statistics.process_step,jira_issues_statistics.days]
  }
}
