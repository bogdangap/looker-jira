view: current_e_term {
  derived_table: {
    sql:
      WITH current_terms AS (
        SELECT e_term, past_e_terms, past_e_terms = 0 as current_term
        FROM
        (SELECT e_term, (ROW_NUMBER() OVER (ORDER BY e_term DESC))-1 as past_e_terms
        FROM
        (SELECT DISTINCT e_term
        FROM prod.engineering_terms
        WHERE CAST(calendar_day AS DATE) <= current_date
        AND e_term IS NOT NULL) x1) x2
      )

      SELECT e_term, e_term as e_term_filter, past_e_terms, current_term
      FROM current_terms

      UNION ALL

      SELECT  e_term, 'Current Term' as e_term_filter, past_e_terms, current_term
      FROM current_terms
      WHERE past_e_terms = 0
      ;;
        #persist_for: "24 hours"
    }

  dimension: e_term {
    view_label: "Terms"
    primary_key: yes
    type: string
    sql: ${TABLE}.e_term ;;
    hidden: yes
  }

  dimension: past_e_terms_filter {
    view_label: "Terms"
    type: number
    sql: ${TABLE}.past_e_terms ;;
  }

  dimension: current_term {
    view_label: "Terms"
    type: yesno
    sql: ${TABLE}.current_term IS TRUE;;
    hidden: yes
  }

  dimension: e_term_filter {
    view_label: "Terms"
    type: string
    sql: ${TABLE}.e_term_filter ;;
  }

  }
