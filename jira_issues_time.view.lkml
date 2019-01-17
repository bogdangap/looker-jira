view: jira_issues_time {
  sql_table_name: prod.jira_issues_time_in_status ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  measure: time_in_cycle_average {
    type: average
    sql: ${TABLE}.time_in_cycle ;;
    value_format: "#,##0"
    group_label: "Time in Product Cycle"
  }

  measure: time_in_cycle_median {
    type: median
    sql: ${TABLE}.time_in_cycle ;;
    group_label: "Time in Product Cycle"
  }

  measure: time_in_cycle_min {
    type: min
    sql: ${TABLE}.time_in_cycle ;;
    group_label: "Time in Product Cycle"
  }

  measure: time_in_cycle_max {
    type: max
    sql: ${TABLE}.time_in_cycle ;;
    group_label: "Time in Product Cycle"
  }


  measure: time_in_status_average {
    type: average
    value_format: "#,##0"
    sql: ${TABLE}.time_in_status ;;
  }

  measure: time_in_status_median {
    type: median
    sql: ${TABLE}.time_in_status ;;
  }

  measure: time_in_status_min {
    type: min
    sql: ${TABLE}.time_in_status ;;
  }

  measure: time_in_status_max {
    type: max
    sql: ${TABLE}.time_in_status ;;
  }


  measure: time_in_eng_cycle_average {
    type: average
    sql: ${TABLE}.time_in_eng_cycle ;;
    value_format: "#,##0"
    group_label: "Time in Engineering Cycle"
  }

  measure: time_in_eng_cycle_median {
    type: median
    sql: ${TABLE}.time_in_eng_cycle ;;
    group_label: "Time in Engineering Cycle"
  }

  measure: time_in_eng_cycle_min {
    type: min
    sql: ${TABLE}.time_in_eng_cycle ;;
    group_label: "Time in Engineering Cycle"
  }

  measure: time_in_eng_cycle_max {
    type: max
    sql: ${TABLE}.time_in_eng_cycle ;;
    group_label: "Time in Engineering Cycle"
  }


  measure: time_in_waiting_average {
    type: average
    sql: ${TABLE}.time_in_waiting ;;
    value_format: "#,##0"
    group_label: "Time in Waiting"
  }

  measure: time_in_waiting_median {
    type: median
    sql: ${TABLE}.time_in_waiting ;;
    group_label: "Time in Waiting"
  }

  measure: time_in_waiting_min {
    type: min
    sql: ${TABLE}.time_in_waiting ;;
    group_label: "Time in Waiting"
  }

  measure: time_in_waiting_max {
    type: max
    sql: ${TABLE}.time_in_waiting ;;
    group_label: "Time in Waiting"
  }


  measure: time_in_cycle_min_formatted {
    type:  string
    sql:concat(cast(floor(${time_in_cycle_min}/10080) as string),"w ", cast(floor(mod(${time_in_cycle_min},10080)/1440) as string),"d ",
    cast(floor(mod(mod(${time_in_cycle_min},10080),1440)/60) as string),"h ", cast(mod(mod(mod(${time_in_cycle_min},10080),1440),60) as string), "m");;
    group_label: "Time in Product Cycle"
    view_label: ""
    label: "Min Time in Product Cycle"
  }

  measure: time_in_cycle_max_formatted {
    type:  string
    sql:concat(cast(floor(${time_in_cycle_max}/10080) as string),"w ", cast(floor(mod(${time_in_cycle_max},10080)/1440) as string),"d ",
      cast(floor(mod(mod(${time_in_cycle_max},10080),1440)/60) as string),"h ", cast(mod(mod(mod(${time_in_cycle_max},10080),1440),60) as string), "m");;
    group_label: "Time in Product Cycle"
    view_label: ""
    label: "Max Time in Product Cycle"
  }

  measure: time_in_cycle_average_formatted {
    type:  string
    sql:concat(cast(floor(${time_in_cycle_average}/10080) as string),"w " , cast(floor(mod(cast (floor(${time_in_cycle_average}) as int64),10080)/1440) as string),"d ",
      cast(floor(mod(mod(cast(floor(${time_in_cycle_average}) as int64),10080),1440)/60) as string),"h ",cast(mod(mod(mod(cast(floor(${time_in_cycle_average}) as int64),10080),1440),60) as string), "m");;
    group_label: "Time in Product Cycle"
    view_label: ""
    label: "Average Time in Product Cycle"
  }

  measure: time_in_cycle_median_formatted {
    type:  string
    sql:concat(cast(floor(${time_in_cycle_median}/10080) as string),"w " , cast(floor(mod(cast (floor(${time_in_cycle_median}) as int64),10080)/1440) as string),"d ",
    cast(floor(mod(mod(cast(floor(${time_in_cycle_median}) as int64),10080),1440)/60) as string),"h ",cast(mod(mod(mod(cast(floor(${time_in_cycle_median}) as int64),10080),1440),60) as string), "m");;
    group_label: "Time in Product Cycle"
    view_label: ""
    label: "Median Time in Product Cycle"
  }

  measure: time_in_eng_cycle_min_formatted {
    type:  string
    sql:concat(cast(floor(${time_in_eng_cycle_min}/10080) as string),"w ", cast(floor(mod(${time_in_eng_cycle_min},10080)/1440) as string),"d ",
      cast(floor(mod(mod(${time_in_eng_cycle_min},10080),1440)/60) as string),"h ", cast(mod(mod(mod(${time_in_eng_cycle_min},10080),1440),60) as string), "m");;
    group_label: "Time in Engineering Cycle"
    view_label: ""
    label: "Median Time in Eng Cycle"
  }

  measure: time_in_eng_cycle_max_formatted {
    type:  string
    sql:concat(cast(floor(${time_in_eng_cycle_max}/10080) as string),"w ", cast(floor(mod(${time_in_eng_cycle_max},10080)/1440) as string),"d ",
      cast(floor(mod(mod(${time_in_eng_cycle_max},10080),1440)/60) as string),"h ", cast(mod(mod(mod(${time_in_eng_cycle_max},10080),1440),60) as string), "m");;
    group_label: "Time in Engineering Cycle"
    view_label: ""
    label: "Max Time in Eng Cycle"
  }

  measure: time_in_eng_cycle_average_formatted {
    type:  string
    sql:concat(cast(floor(${time_in_eng_cycle_average}/10080) as string),"w " , cast(floor(mod(cast (floor(${time_in_eng_cycle_average}) as int64),10080)/1440) as string),"d ",
      cast(floor(mod(mod(cast(floor(${time_in_eng_cycle_average}) as int64),10080),1440)/60) as string),"h ",cast(mod(mod(mod(cast(floor(${time_in_eng_cycle_average}) as int64),10080),1440),60) as string), "m");;
    group_label: "Time in Engineering Cycle"
    view_label: ""
    label: "Avg Time in Eng Cycle"
  }

  measure: time_in_eng_cycle_median_formatted {
    type:  string
    sql:concat(cast(floor(${time_in_eng_cycle_median}/10080) as string),"w " , cast(floor(mod(cast (floor(${time_in_eng_cycle_median}) as int64),10080)/1440) as string),"d ",
      cast(floor(mod(mod(cast(floor(${time_in_eng_cycle_median}) as int64),10080),1440)/60) as string),"h ",cast(mod(mod(mod(cast(floor(${time_in_eng_cycle_median}) as int64),10080),1440),60) as string), "m");;
    group_label: "Time in Engineering Cycle"
    view_label: ""
    label: "Median Time in Eng Cycle"
  }


  measure: time_in_waiting_min_formatted {
    type:  string
    sql:concat(cast(floor(${time_in_waiting_min}/10080) as string),"w ", cast(floor(mod(${time_in_waiting_min},10080)/1440) as string),"d ",
      cast(floor(mod(mod(${time_in_waiting_min},10080),1440)/60) as string),"h ", cast(mod(mod(mod(${time_in_waiting_min},10080),1440),60) as string), "m");;
    group_label: "Time in Waiting"
    view_label: ""
    label: "Min Time in Waiting"
  }

  measure: time_in_waiting_max_formatted {
    type:  string
    sql:concat(cast(floor(${time_in_waiting_max}/10080) as string),"w ", cast(floor(mod(${time_in_waiting_max},10080)/1440) as string),"d ",
      cast(floor(mod(mod(${time_in_waiting_max},10080),1440)/60) as string),"h ", cast(mod(mod(mod(${time_in_waiting_max},10080),1440),60) as string), "m");;
    group_label: "Time in Waiting"
    view_label: ""
    label: "Max Time in Waiting"
  }

  measure: time_in_waiting_average_formatted {
    type:  string
    sql:concat(cast(floor(${time_in_waiting_average}/10080) as string),"w " , cast(floor(mod(cast (floor(${time_in_waiting_average}) as int64),10080)/1440) as string),"d ",
      cast(floor(mod(mod(cast(floor(${time_in_waiting_average}) as int64),10080),1440)/60) as string),"h ",cast(mod(mod(mod(cast(floor(${time_in_waiting_average}) as int64),10080),1440),60) as string), "m");;
    group_label: "Time in Waiting"
    view_label: ""
    label: "Avg Time in Waiting"
  }

  measure: time_in_waiting_median_formatted {
    type:  string
    sql:concat(cast(floor(${time_in_waiting_median}/10080) as string),"w " , cast(floor(mod(cast (floor(${time_in_waiting_median}) as int64),10080)/1440) as string),"d ",
      cast(floor(mod(mod(cast(floor(${time_in_waiting_median}) as int64),10080),1440)/60) as string),"h ",cast(mod(mod(mod(cast(floor(${time_in_waiting_median}) as int64),10080),1440),60) as string), "m");;
    group_label: "Time in Waiting"
    view_label: ""
    label: "Mean Time in Waiting"
  }




}
