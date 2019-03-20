view: issues_by_story_points {
  derived_table: {
    sql:
      SELECT issues_by_cycle.key, CAST(jira_issues.fields.customfield_10021 AS STRING) as story_points, in_cycle, days_in_work_minutes/480 as days
      FROM ${issues_by_cycle.SQL_TABLE_NAME} as issues_by_cycle
      JOIN prod.jira_issues as jira_issues
      ON issues_by_cycle.key = jira_issues.key
      WHERE {% if jira_issues.status_name._is_filtered %} {% condition jira_issues.status_name %} fields.status.name {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues.issue_type_name._is_filtered %} {% condition jira_issues.issue_type_name %} fields.issuetype.name {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues.labels_string._is_filtered %} {% condition jira_issues.labels_string %} labels_string {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues.resolution_date_date._is_filtered %} {% condition jira_issues.resolution_date_date %} timestamp(regexp_replace(fields.resolutiondate, '(\\d\\d$)', ':\\1')) {% endcondition %} {% else %} 1=1 {% endif %}

      ;;

  #persist_for: "24 hours"
  #indexes: ["id","dates"]
    }

 #dimension: id {
 #  type: string
 #  primary_key: yes
 #  hidden: yes
 #  sql: CONCAT(${TABLE}.key,${TABLE}.in_cycle) ;;
 #}

 #dimension: key {
 #  type: string
 #  hidden: yes
 #  sql: ${TABLE}.key ;;
 #}

  dimension: story_points {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.story_points ;;
  }

 dimension: in_cycle {
   type: string
   hidden: yes
   sql:${TABLE}.in_cycle;;
 }

 #dimension: active_days {
 #  type: number
 #  hidden: yes
 #  sql:CASE WHEN ${in_cycle} = '2. In Cycle' THEN ${TABLE}.days_in_work_minutes ELSE null END ;;
 #}

  measure: active_stddev {
    label: "Days in Active Cycle Std Dev."
    type: number
    hidden: no
    sql:STDDEV_POP(CASE WHEN ${in_cycle} = '2. In Cycle' THEN ${TABLE}.days ELSE NULL END);;
  }
  #measure: stddev_distinct {
  #  type: number
  #  hidden: no
  #  sql:STDDEV_POP(DISTINCT ${active_days});;
  #}
  }