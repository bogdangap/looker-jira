view: stream_filter {
  derived_table: {
    sql:
      SELECT DISTINCT stream, stream as stream_filter
      FROM prod.jira_streams
      UNION ALL
      SELECT DISTINCT stream, 'All Streams' as stream_filter
      FROM prod.jira_streams
      UNION ALL
      SELECT DISTINCT stream, CONCAT('20',REPLACE(SUBSTR(stream,1,4),'-','-T'),' Streams') as stream_filter
      FROM prod.jira_streams

      ;;
        #persist_for: "24 hours"
    }

    dimension: stream {
      primary_key: yes
      type: string
      sql: CONCAT(REPLACE(SUBSTR(${TABLE}.stream,1,4),'-','.'),' ',SUBSTR(${TABLE}.stream,6)) ;;
      hidden: yes
    }

    dimension: stream_filter {
      view_label: "Issues"
      type: string
      sql: ${TABLE}.stream_filter ;;
    }

  }
