view: issues_daily {
  derived_table: {
    sql:
      WITH issues_history_list AS (
        SELECT CONCAT(id,'-',CAST(rn AS STRING)) as id, id as old_id, key, status, toString, CAST(DATETIME(CAST(prev_created AS TIMESTAMP),'Australia/South') AS TIMESTAMP)
         as started_at, CAST(DATETIME(CAST(created AS TIMESTAMP),'Australia/South') AS TIMESTAMP) as ended_at, rn,
          MAX(rn) OVER (PARTITION BY id) as max_rn
        FROM
        (SELECT CAST(id AS STRING) as id, key, fromString as status, toString, start_on_sat, start_on_sun, end_on_sat, end_on_sun, created, prev_created,
          ROW_NUMBER() OVER (PARTITION BY key ORDER BY created) as rn
        FROM prod.jira_issues_time_in_status_v3) x
        ),
        retrospectives_arrays AS (
        SELECT CAST(name AS STRING) as name, start_date, end_date, GENERATE_DATE_ARRAY(CAST(start_date AS date),DATE_SUB(CAST(end_date AS date),INTERVAL 1 DAY),INTERVAL 1 DAY) as dates
        FROM prod.jira_retrospectives
        ),
        retrospectives AS (
        SELECT name, start_date, end_date, dates
        FROM retrospectives_arrays, UNNEST(dates) dates
        ),
        add_end_row AS (
        SELECT id, key, status, started_at, ended_at,
          CAST(started_at AS DATE) as started_date
        FROM issues_history_list
        UNION ALL
        SELECT CONCAT(old_id,'-',CAST(rn+1 AS STRING)) as id, key, toString as status, ended_at as started_at, NULL as ended_at,
          CAST(started_at AS DATE) as started_date
        FROM issues_history_list
        WHERE rn = max_rn
        ),
        process_map AS (
        SELECT DISTINCT status,
          CASE WHEN status = 'Cancelled' THEN '0. Cancelled'
            WHEN status IN ('Backlog','Reported') THEN '1. Backlog'
            WHEN status IN ('Ranked','Planned','Ready to Start') THEN '2. Preparation'
            WHEN status IN ('In Progress','In Review','Polishing','Ready to Merge') THEN '3. In Progress'
            WHEN status = 'Ready for Testing' THEN '4. QA'
            WHEN status = 'Closed' THEN '5. Completion'
            ELSE 'Legacy'
          END as process_step
        FROM add_end_row
        ),
        most_recent_process AS (
        SELECT id, key, status, started_at, ended_at, started_date, process_step,
          CASE WHEN process_step_prev = process_step THEN LAG(process_step_rn) OVER (PARTITION BY key ORDER BY started_at) ELSE process_step_rn END as most_recent
        FROM
        (SELECT id, key, add_end_row.status, started_at, ended_at, started_date, process_step,
          ROW_NUMBER() OVER (PARTITION BY key,process_step ORDER BY started_at DESC) as process_step_rn,
          LEAD(process_step) OVER (PARTITION BY key ORDER BY started_at) as process_step_prev
        FROM add_end_row
        JOIN process_map
        ON add_end_row.status = process_map.status
        ORDER BY 4) x
        ),
        find_day_order_1 AS (
        SELECT id, key, status, started_at, started_date, most_recent,
          ROW_NUMBER() OVER (PARTITION BY key,started_date ORDER BY id) day_order
        FROM most_recent_process
        ),
        find_day_order_2 AS (
        SELECT id, key, status, started_at, started_date, most_recent, day_order, MIN(day_order) OVER (PARTITION BY key,started_date) as day_open, MAX(day_order) OVER (PARTITION BY key,started_date) day_close
        FROM
        find_day_order_1
        ),
        open_close_status AS (
        SELECT id, key, status, started_at, started_date, most_recent, CASE WHEN day_order = day_open THEN TRUE ELSE FALSE END as day_open, CASE WHEN day_close = day_order THEN TRUE ELSE FALSE END as day_close
        FROM find_day_order_2
        ),
        issue_arrays AS (
        SELECT id, key, status, started_at, ended_at, most_recent,
          GENERATE_DATE_ARRAY(CAST(started_at AS DATE),COALESCE(CAST(ended_at AS DATE),(CASE WHEN status = 'Closed' THEN CAST(ended_at AS DATE) ELSE COALESCE(CAST(ended_at AS DATE),current_date) END)),INTERVAL 1 DAY) dates
        FROM most_recent_process
        ),
        issues_expanded AS (
        SELECT id, key, status, started_at, ended_at, most_recent, dates,
          CAST(started_at AS DATE) as opening,
          CAST(ended_at AS DATE) as closing
        FROM issue_arrays, UNNEST(dates) dates
        ),
        find_weekdays AS (
        SELECT id, key, status, started_at, ended_at, most_recent, opening, closing, dates,
        /*ASSUMING 8 HOUR WORKDAY*/
          CASE WHEN opening = closing THEN TIMESTAMP_DIFF(COALESCE(ended_at,CAST(closing AS TIMESTAMP)),started_at,MINUTE) WHEN ended_at IS NULL THEN 0 ELSE 480 END AS minutes,
        /*FIND WEEKDAYS*/
          CASE WHEN EXTRACT(DAYOFWEEK FROM dates) = 1 THEN 0 WHEN EXTRACT(DAYOFWEEK FROM dates) = 7 THEN 0 ELSE 1 END as weekday
        FROM issues_expanded
        ),
        find_workdays AS (
        SELECT id, key, status, started_at, ended_at, most_recent, dates, CASE WHEN minutes>=480 THEN 480 ELSE minutes END as minutes, weekday,
        /*INCLUDE WHEN STARTS ON WEEKEND*/
          CASE WHEN (weekday = 0 AND opening = dates) THEN 1 ELSE weekday END as workday
        FROM find_weekdays
        ),

        split_minutes_by_day AS (
        SELECT id, key, status, started_at, ended_at, most_recent, dates, weekday, workday,
          CASE WHEN minutes < 480 THEN minutes ELSE
          (minutes/full_days)-(sub_minutes/full_days)
          END as minutes
        FROM
        (SELECT id, key, status, started_at, ended_at, most_recent, dates, weekday, workday, minutes,
         SUM((CASE WHEN minutes < 480 THEN minutes ELSE 0 END)) OVER (PARTITION BY key,dates) as sub_minutes,
         SUM((CASE WHEN minutes = 480 THEN 1 ELSE 0 END)) OVER (PARTITION BY key,dates) as full_days
        FROM find_workdays) x
        )

        SELECT split_minutes_by_day.id, split_minutes_by_day.key, process_step, CASE WHEN process_step IN ('2. Preparation') THEN '1. Open' WHEN process_step IN ('3. In Progress','4. QA') THEN '2. In Cycle' WHEN process_step = '5. Completion' THEN '3. Complete'  WHEN process_step = '0. Cancelled' THEN '0. Cancelled' ELSE '0. Not In Cycle' END as in_cycle, split_minutes_by_day.status, split_minutes_by_day.started_at, split_minutes_by_day.ended_at, CASE WHEN split_minutes_by_day.most_recent = 1 THEN TRUE ELSE FALSE END as most_recent, CAST(split_minutes_by_day.dates AS TIMESTAMP) as dates, CAST(minutes AS INT64) as minutes, CASE WHEN weekday = 1 THEN TRUE ELSE FALSE END as weekday, CASE WHEN workday = 1 THEN TRUE ELSE FALSE END as workday, retrospectives.name as retrospective, day_open, day_close
        FROM split_minutes_by_day
        LEFT JOIN retrospectives
        ON split_minutes_by_day.dates = retrospectives.dates
        LEFT JOIN open_close_status
        ON (split_minutes_by_day.id = open_close_status.id AND split_minutes_by_day.dates = open_close_status.started_date)
        LEFT JOIN process_map
        ON split_minutes_by_day.status = process_map.status
            /* iclude if we want to exclude days outside of retro in final time spent WHERE {% if jira_retrospectives.name._is_filtered %} {% condition jira_retrospectives.name %} retrospectives.name {% endcondition %} {% else %} 1=1 {% endif %}*/
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
      hidden: no
      sql: ${TABLE}.process_step ;;
    }

    dimension: status {
      type: string
      hidden: no
      sql: ${TABLE}.status ;;
    }

    filter: most_recent {
      type: yesno
      description: "Is this the most recent time the Issue went into this Process Step?"
      sql: ${TABLE}.most_recent;;
    }

    dimension: in_cycle {
      type: string
      hidden: no
      sql:${TABLE}.in_cycle;;
    }

    dimension_group: date {
      type: time
      hidden: no
      timeframes: [
        date,
        day_of_week,
        week,
        month,
        quarter,
        year
      ]
      sql: ${TABLE}.dates ;;
    }

    dimension_group: started_at {
      type: time
      hidden: no
      timeframes: [
        raw,
        time,
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: ${TABLE}.started_at ;;
    }

    dimension_group: ended_at {
      type: time
      hidden: no
      timeframes: [
        raw,
        time,
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: ${TABLE}.ended_at ;;
    }

    dimension: retrospective {
      type: string
      hidden: yes
      sql: ${TABLE}.retrospective ;;
    }

    #dimension: term_window {
    #  type: string
    #  hidden: no
    #  sql: ${TABLE}.term ;;
    #}

    dimension: workday {
      type: yesno
      hidden: no
      sql: CASE WHEN ${TABLE}.workday = 1 THEN TRUE ELSE FALSE END;;
    }

    dimension: weekday {
      type: yesno
      hidden: no
      sql: CASE WHEN ${TABLE}.weekday = 1 THEN TRUE ELSE FALSE END ;;
    }

    dimension: day_open {
      type: yesno
      hidden: no
      sql: ${TABLE}.day_open ;;
    }

    dimension: day_close {
      type: yesno
      hidden: no
      sql: ${TABLE}.day_close ;;
    }

    dimension: minutes_dimension {
      type: number
      hidden: yes
      sql: ${TABLE}.minutes ;;
    }

    measure: hours {
      type: sum
      sql: ${minutes_dimension}/60 ;;
      value_format_name: decimal_1
      label: "Total Hours"
      drill_fields: [jira_issues.key,jira_issues.summary,hours]
    }

    measure: days {
      type: sum
      sql: ${minutes_dimension}/480 ;;
      value_format_name: decimal_1
      label: "Total Days"
      drill_fields: [jira_issues.key,jira_issues.summary,date_date,process_step,days]
    }

    measure: count_of_issues_and_status {
      type: count_distinct
      sql: ${id} ;;
      view_label: "Issues"
    }

    #measure: count_of_issues {
    #  type: count_distinct
    #  sql: ${key} ;;
    #  view_label: "Issues"
    #  drill_fields: [jira_issues.key,date_date]
    #}

    #parameter: work_hours {
    #  type: number
    #  default_value: "8"
    #}
  }
