view: jira_issues_terms {
  derived_table: {
    sql:
      WITH terms_array AS (
      SELECT key, fields.labels as labels_array
      FROM  prod.jira_issues
      ),

      terms AS (
      SELECT key, UPPER(term) as term
      FROM terms_array
      CROSS JOIN UNNEST(labels_array) AS term
      WHERE term LIKE '%-t%'
      )

      SELECT key, term,
        CASE WHEN term_order = MIN(term_order) OVER (PARTITION BY key) THEN TRUE ELSE FALSE END as first_term,
        CASE WHEN term_order = MAX(term_order) OVER (PARTITION BY key) THEN TRUE ELSE FALSE END as last_term
      FROM
      (SELECT issues.key, labels_string, term, ROW_NUMBER() OVER (PARTITION BY issues.key ORDER BY term) as term_order
      FROM prod.jira_issues as issues
      JOIN terms
      ON issues.key = terms.key) x1
      ;;
        #persist_for: "24 hours"
        #indexes: ["key"]
    }

  dimension: id {
    primary_key: yes
    type: number
    sql: CONCAT(${TABLE}.key,${TABLE}.term) ;;
    hidden: yes
  }

  dimension: key {
    type: string
    sql: ${TABLE}.key ;;
    hidden: yes
  }

  dimension: term {
    type: string
    sql: ${TABLE}.term ;;
    view_label: "Issues"
    group_label: "Term"
  }

  dimension: first_term {
    type: yesno
    sql: ${TABLE}.first_term ;;
    view_label: "Issues"
    group_label: "Term"
  }

  dimension: last_term {
    type: yesno
    sql: ${TABLE}.last_term ;;
    view_label: "Issues"
    group_label: "Term"
  }

 }
