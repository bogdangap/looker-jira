view: current_e_term {
  derived_table: {
    sql:
      SELECT e_term/*, term*/
        FROM engineering_terms
        WHERE CAST(calendar_day AS DATE) = current_date
      ;;
        #persist_for: "24 hours"
        #indexes: ["key"]
    }

    dimension: e_term {
      primary_key: yes
      type: string
      sql: ${TABLE}.e_term ;;
      hidden: yes
    }
  }
