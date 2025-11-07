*** Settings ***
Library    RESTLibrary
Library    OperatingSystem
Library    JSONLibrary
Library    Collections
Library    String
Resource   ../../Resources/variables/common_variables.robot

*** Keywords ***
Get Parsed Notes List
    ${notes_json}=    Execute RC    <<<rc, get_all_notes, body, $.data>>>
    ${notes}=         Evaluate    json.loads("""${notes_json}""")    json
    RETURN    ${notes}

Filter Completed Notes
    [Arguments]    ${notes}
    ${completed}=    Create List
    FOR    ${note}    IN    @{notes}
        ${status}=    Get From Dictionary    ${note}    completed
        Run Keyword If    '${status}' == 'True'    Append To List    ${completed}    ${note}
    END
    RETURN    ${completed}
