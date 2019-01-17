view: jira_issues_comments {

  dimension: id {
    primary_key: yes
    sql: comments.id;;
  }

  dimension: author_email_address {
    description: "Author Email Address"
    sql: comments.author.emailAddress;;
  }

  dimension: body {
    description: "Body"
    sql: comments.body;;
  }


  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
     sql:timestamp(regexp_replace(comments.created, '(\\d\\d$)', ':\\1'))  ;;
  }
}
