view: jira_streams {
  sql_table_name: prod.jira_streams ;;

  dimension: key {
    type: string
    sql: ${TABLE}.key ;;
    hidden: yes
  }

  dimension: stream {
    type: string
    sql: CONCAT(REPLACE(SUBSTR(${TABLE}.stream,1,4),'-','.'),' ',SUBSTR(${TABLE}.stream,6)) ;;
    view_label: "Issues"
  }

  #measure: count {
  #  type: count
  #  group_label: "Issues"
  #  label: "Streams"
    #drill_fields: []
  #}
}
