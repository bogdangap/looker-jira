view: issues_age {
  derived_table: {
    sql:
      WITH jira_statistics AS (
      SELECT id, key, dates, age
      FROM ${jira_issues_statistics.SQL_TABLE_NAME}
      WHERE {% if jira_issues_statistics.process_step._is_filtered %} {% condition jira_issues_statistics.process_step %} process_step {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.status._is_filtered %} {% condition jira_issues_statistics.status %} status {% endcondition %} {% else %} 1=1 {% endif %}
      /* iclude if we want to exclude days outside of retro in final time spent AND {% if jira_retrospectives.name._is_filtered %} {% condition jira_retrospectives.name %} retrospective {% endcondition %} {% else %} 1=1 {% endif %}*/
      AND {% if jira_issues_statistics.weekday._is_filtered %} {% condition jira_issues_statistics.weekday %} weekday {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.workday._is_filtered %} {% condition jira_issues_statistics.workday %} workday {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.day_open._is_filtered %} {% condition jira_issues_statistics.day_open %} day_open {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.day_close._is_filtered %} {% condition jira_issues_statistics.day_close %} day_close {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.in_cycle._is_filtered %} {% condition jira_issues_statistics.in_cycle %} in_cycle {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.date_date._is_filtered %} {% condition jira_issues_statistics.date_date %} dates {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.date_week._is_filtered %} {% condition jira_issues_statistics.date_week %} dates {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.date_month._is_filtered %} {% condition jira_issues_statistics.date_month %} dates {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.date_quarter._is_filtered %} {% condition jira_issues_statistics.date_quarter %} dates {% endcondition %} {% else %} 1=1 {% endif %}
      AND {% if jira_issues_statistics.date_year._is_filtered %} {% condition jira_issues_statistics.date_year %} dates {% endcondition %} {% else %} 1=1 {% endif %}
      ),

      find_age AS (
      SELECT key,
      {% if jira_issues_statistics.date_week._in_query %}
      CAST(dates AS DATE)
      {% elsif jira_issues_statistics.date_week._in_query %}
      DATE_TRUNC(CAST(dates AS DATE), WEEK)
      {% elsif jira_issues_statistics.date_month._in_query %}
      DATE_TRUNC(CAST(dates AS DATE), MONTH)
      {% elsif jira_issues_statistics.date_quarter._in_query %}
      DATE_TRUNC(CAST(dates AS DATE), QUARTER)
      {% elsif jira_issues_statistics.date_year._in_query %}
      DATE_TRUNC(CAST(dates AS DATE), YEAR)
      {% else %}
      CAST(dates AS DATE)
      {% endif %} as dates,
      MAX(age) as age
      FROM jira_statistics
      GROUP BY 1,2
      )

      SELECT key, dates, age
      FROM find_age

      ;;

  #persist_for: "24 hours"
  #indexes: ["id","dates"]
    }

    dimension: id {
      type: string
      hidden: yes
      primary_key: yes
      sql: CONCAT(${TABLE}.key,CAST(${TABLE}.dates AS STRING)) ;;
    }

    dimension: key {
      type: string
      hidden: yes
      sql: ${TABLE}.key ;;
    }

  dimension: date {
    type: date_raw
    hidden: yes
    sql: ${TABLE}.dates ;;
  }

    dimension: age_dimension {
      type: number
      hidden: yes
      sql: ${TABLE}.age ;;
    }

    measure: avg_age_by_date {
      type: average
      sql:${age_dimension}  ;;
      value_format_name: decimal_1
      drill_fields: [key,date,age_dimension]
    }

    measure: median_age_by_date {
      type: median
      sql:${age_dimension};;
      value_format_name: decimal_1
      drill_fields: [key,date,age_dimension]
    }


  }
