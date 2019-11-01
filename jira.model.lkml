connection: "happyco_bq"

# include all the views
include: "*.view"

datagroup: jira_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: jira_default_datagroup


explore: jira_issues_statistics {
  from:  jira_issues_statistics

  fields: [

    ALL_FIELDS*,
    #hides access AND queryability
    #-jira_issues.count,
  ]

  join: jira_issues {
    view_label: "Issues"
    sql_on: ${jira_issues_statistics.key} = ${jira_issues.key};;
    type: inner
    relationship: many_to_one
  }
  join: jira_retrospectives {
    view_label: "Retrospectives"
    sql_on: (${jira_issues_statistics.retrospective} = ${jira_retrospectives.name} AND ${jira_issues_statistics.team} = ${jira_retrospectives.team});;
    type: left_outer
    relationship: many_to_one
  }
  #NEW RETRO JOIN!?!?!?
  #join: jira_retrospectives {
  #  view_label: "Retrospectives"
  #  sql_on: (${jira_issues_statistics.retrospective} = ${jira_retrospectives.name} AND ${jira_issues.team} = ${jira_retrospectives.team});;
  #  type: left_outer
  #  relationship: many_to_one
  #}
  join: issues_by_status {
    sql_on: (${jira_issues_statistics.key} = ${issues_by_status.key} AND ${jira_issues_statistics.status} = ${issues_by_status.status});;
    type: left_outer
    relationship: many_to_one
  }
  join: issues_by_process {
    sql_on: (${jira_issues_statistics.key} = ${issues_by_process.key} AND ${jira_issues_statistics.process_step} = ${issues_by_process.process_step});;
    type: left_outer
    relationship: many_to_one
  }
  join: issues_by_cycle {
    sql_on: (${jira_issues_statistics.key} = ${issues_by_cycle.key} AND ${jira_issues_statistics.in_cycle} = ${issues_by_cycle.in_cycle});;
    type: left_outer
    relationship: many_to_one
  }
  join: issues_by_story_points {
    sql_on: (${jira_issues.story_points} = ${issues_by_story_points.story_points});;
    type: inner
    relationship: many_to_one
  }
  join: issues_total {
    sql_on: ${jira_issues_statistics.key} = ${issues_total.key};;
    type: left_outer
    relationship: many_to_one
  }
  join: issues_age {
    sql_on: (${jira_issues_statistics.key} = ${issues_age.key} AND
    {% if jira_issues_statistics.date_week._in_query %}
      CAST(${jira_issues_statistics.date_date} AS DATE)
      {% elsif jira_issues_statistics.date_week._in_query %}
      DATE_TRUNC(CAST(${jira_issues_statistics.date_date} AS DATE), WEEK)
      {% elsif jira_issues_statistics.date_month._in_query %}
      DATE_TRUNC(CAST(${jira_issues_statistics.date_date} AS DATE), MONTH)
      {% elsif jira_issues_statistics.date_quarter._in_query %}
      DATE_TRUNC(CAST(${jira_issues_statistics.date_date} AS DATE), QUARTER)
      {% elsif jira_issues_statistics.date_year._in_query %}
      DATE_TRUNC(CAST(${jira_issues_statistics.date_date} AS DATE), YEAR)
      {% else %}
      CAST(${jira_issues_statistics.date_date} AS DATE)
      {% endif %}
     = ${issues_age.date})
    ;;
    type: inner
    relationship: many_to_one
  }
  join: jira_issues_components {
    view_label: "Components"
    sql: LEFT JOIN UNNEST(${jira_issues.fields}.components) as components;;
    relationship: one_to_many
  }
  join: jira_issues_versions {
    view_label: "Versions"
    sql:  LEFT JOIN UNNEST(${jira_issues.fields}.versions) as versions ;;
    relationship: one_to_many
  }

  join: jira_issues_terms {
    view_label: "Retrospectives"
    sql_on: (${jira_issues_statistics.key} = ${jira_issues_terms.key} AND ${jira_issues_statistics.date_date} = ${jira_issues_terms.date_date});;
    type: left_outer
    relationship: many_to_one
  }

  join: engineering_terms {
    sql_on: ${jira_issues_statistics.date_date} = ${engineering_terms.calendar_day_date};;
    type: left_outer
    relationship: many_to_one
  }

  join: current_e_term {
    sql_on: ${engineering_terms.e_term} = ${current_e_term.e_term};;
    type: inner
    relationship: many_to_one
  }
}

explore: jira_issues {

  from: jira_issues
  view_label: "Issues"

  join: jira_issues_comments {
    view_label: "Comments"
    sql: LEFT JOIN UNNEST(jira_issues.fields.comment.comments) as comments;;
    relationship: one_to_many
  }

  join: jira_issues_components {
    view_label: "Components"
    sql: LEFT JOIN UNNEST(jira_issues.fields.components) as components;;
    relationship: one_to_many
  }

  join: jira_issues_versions {
    view_label: "Versions"
    sql:  LEFT JOIN UNNEST(jira_issues.fields.versions) as versions ;;
    relationship: one_to_many
  }

  join: jira_issues_workloads {
    view_label: "Workloads"
    sql:  LEFT JOIN UNNEST(jira_issues.fields.worklog.worklogs) as workloads ;;
    relationship: one_to_many
  }

  join: jira_issues_sprints {
    view_label: "Sprints"
    sql:  LEFT JOIN UNNEST(jira_issues.fields.customfield_10016) as sprints ;;
    relationship: one_to_many
  }

  join: jira_issues_subissues {
    view_label: "SubIssues"
    sql_on: jira_issues_subissues.fields.parent.id =  jira_issues.id  ;;
    relationship: one_to_many
    type:  left_outer
  }

  join: jira_retrospectives {
    view_label: "Retrospectives"
    sql_on: jira_issues.fields.resolutiondate is not null
           AND ${jira_retrospectives.start_date_date} <= ${jira_issues.resolution_date_date}
          AND ${jira_retrospectives.end_date_date} > ${jira_issues.resolution_date_date}
           AND ${jira_retrospectives.team}=${jira_issues.team};;
    type:  inner
    relationship: many_to_one
  }

  join: jira_issues_time {
    view_label: "Time in Status"
    sql_on:  ${jira_issues.id}= ${jira_issues_time.id} ;;
    type: inner
    relationship: one_to_many
  }

}
