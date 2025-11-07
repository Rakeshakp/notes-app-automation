*** Settings ***
Library    DateTime
Library    RESTLibrary
Library    JSONLibrary
Library    Collections
Library    String

*** Keywords ***
Get Notes Created Today
    [Arguments]    ${request_id}
    ${notes_json}=    Execute RC    <<<rc, ${request_id}, body, $.data>>>
    ${notes}=         Evaluate    json.loads("""${notes_json}""")    json
    ${today}=         Evaluate    str(__import__('datetime').datetime.now().date())    modules=datetime
    ${today_notes}=   Create List

    FOR    ${note}    IN    @{notes}
        ${created_at}=    Set Variable    ${note['created_at']}
        ${note_date}=     Evaluate    '${created_at}'[:10]
        Run Keyword If    '${note_date}' == '${today}'    Append To List    ${today_notes}    ${note}
    END
    RETURN    ${today_notes}
Log Notes Summary
    [Arguments]    ${notes}
    ${count}=    Get Length    ${notes}
    Log    Total Notes Created Today: ${count}

    FOR    ${note}    IN    @{notes}
        Log    Title: ${note['title']}
        Log    Description: ${note['description']}
        Log    Category: ${note['category']}
        Log    Created At: ${note['created_at']}
    END
