view: issues_by_status {
  derived_table: {
    sql:
      SELECT id, key, process_step, status, started_at, ended_at, SUM(minutes) as minutes, SUM(days_in_work_minutes) as days_in_work_minutes
      FROM ${issues_daily.SQL_TABLE_NAME}
      WHERE {% if issues_daily.process_step._is_filtered %} {% condition issues_daily.process_step %} process_step {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if issues_daily.status._is_filtered %} {% condition issues_daily.status %} status {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if issues_daily.most_recent._is_filtered %} {% condition issues_daily.most_recent %} most_recent {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if issues_daily.weekday._is_filtered %} {% condition issues_daily.weekday %} weekday {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if issues_daily.workday._is_filtered %} {% condition issues_daily.workday %} workday {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if issues_daily.day_open._is_filtered %} {% condition issues_daily.day_open %} day_open {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if issues_daily.day_close._is_filtered %} {% condition issues_daily.day_close %} day_close {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if issues_daily.in_cycle._is_filtered %} {% condition issues_daily.in_cycle %} in_cycle {% endcondition %} {% else %} 1=1 {% endif %}
      /* iclude if we want to exclude days outside of retro in final time spent AND {% if jira_retrospectives.name._is_filtered %} {% condition jira_retrospectives.name %} retrospective {% endcondition %} {% else %} 1=1 {% endif %}*/
      GROUP BY 1,2,3,4,5,6
      ;;

  #persist_for: "24 hours"
  #indexes: ["id","dates"]
  }


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
    hidden: yes
    sql: ${TABLE}.process_step ;;
  }

  dimension: status {
    type: string
    hidden: yes
    sql: ${TABLE}.status ;;
  }

  dimension: hours_dimension {
    type: number
    sql: ${TABLE}.minutes/60;;
    hidden: yes
  }

  dimension: days_in_work_minutes {
    type: number
    hidden: yes
    sql: ${TABLE}.days_in_work_minutes/480 ;;
  }

  measure: avg_hours {
    type: average
    sql: ${hours_dimension};;
    view_label: "Issues Daily"
    group_label: "By Status"
    label: "AVG Hours per Status"
    value_format_name: decimal_1
    drill_fields: [jira_issues.key,jira_issues.summary,issues_daily.hours]
  }

  measure: avg_days {
    type: average
    sql: ${days_in_work_minutes} ;;
    view_label: "Issues Daily"
    group_label: "By Status"
    label: "AVG Days per Status"
    value_format_name: decimal_1
    drill_fields: [jira_issues.key,jira_issues.summary,issues_daily.days]
  }

  measure: median_days {
    type: median
    sql: ${days_in_work_minutes} ;;
    view_label: "Issues Daily"
    group_label: "By Status"
    label: "Median Days per Status"
    value_format_name: decimal_1
    drill_fields: [jira_issues.key,jira_issues.summary,issues_daily.days]
  }
}
