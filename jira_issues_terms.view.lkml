view: jira_issues_terms {
  derived_table: {
    sql:
        WITH issues AS (
        SELECT key, fields.labels as labels
        FROM prod.jira_issues
        WHERE labels_string LIKE '%-t%'
        ),

        terms_split_out AS (
        SELECT key, UPPER(label) as term, applied, MIN(applied) OVER (PARTITION BY key) as first_applied, MAX(applied) OVER (PARTITION BY key) as last_applied
        FROM issues
        CROSS JOIN UNNEST(issues.labels) AS label
        WITH OFFSET AS applied
        WHERE label LIKE '%-t%'
        ORDER BY key,applied
        )

        SELECT key, terms_split_out.term, engineering_terms.calendar_day
        FROM terms_split_out
        RIGHT JOIN prod.engineering_terms
        ON terms_split_out.term = engineering_terms.e_term
        ORDER BY 1,2;;
  }

  dimension: key {
    type: string
    sql: ${TABLE}.key;;
    hidden: yes
  }

  dimension: term {
    type: string
    sql: ${TABLE}.term;;
    view_label: "Issues"
  }

  dimension_group: date {
    type: time
    hidden: yes
    timeframes: [
      date,
      day_of_week,
      week,
      month,
      day_of_month,
      quarter,
      year
    ]
    sql: ${TABLE}.calendar_day ;;
  }
}
