view: issues_by_status {
  derived_table: {
    sql:
      SELECT id, key, process_step, status, started_at, ended_at, SUM(minutes) as minutes
      FROM ${jira_issues_statistics.SQL_TABLE_NAME}
      WHERE {% if jira_issues_statistics.process_step._is_filtered %} {% condition jira_issues_statistics.process_step %} process_step {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.status._is_filtered %} {% condition jira_issues_statistics.status %} status {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.most_recent._is_filtered %} {% condition jira_issues_statistics.most_recent %} most_recent {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.weekday._is_filtered %} {% condition jira_issues_statistics.weekday %} weekday {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.workday._is_filtered %} {% condition jira_issues_statistics.workday %} workday {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.day_open._is_filtered %} {% condition jira_issues_statistics.day_open %} day_open {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.day_close._is_filtered %} {% condition jira_issues_statistics.day_close %} day_close {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.in_cycle._is_filtered %} {% condition jira_issues_statistics.in_cycle %} in_cycle {% endcondition %} {% else %} 1=1 {% endif %}
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

  dimension: minutes_dimension {
    type: number
    hidden: yes
    sql: ${TABLE}.minutes/480 ;;
  }

  measure: avg_hours {
    type: average
    sql: ${hours_dimension};;
    view_label: "Statistics"
    group_label: "By Status"
    label: "AVG Hours per Status"
    value_format_name: decimal_1
    drill_fields: [jira_issues.key,jira_issues.summary,jira_issues_statistics.hours]
  }

  measure: avg_days {
    type: average
    sql: ${minutes_dimension} ;;
    view_label: "Statistics"
    group_label: "By Status"
    label: "AVG Days per Status"
    value_format_name: decimal_1
    drill_fields: [jira_issues.key,jira_issues.summary,jira_issues_statistics.days]
  }

  measure: median_days {
    type: median
    sql: ${minutes_dimension} ;;
    view_label: "Statistics"
    group_label: "By Status"
    label: "Median Days per Status"
    value_format_name: decimal_1
    drill_fields: [jira_issues.key,jira_issues.summary,jira_issues_statistics.days]
  }
}
