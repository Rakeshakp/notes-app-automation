*** Settings ***
Library    RESTLibrary
Library    Collections
Library    JSONLibrary
Library    String


*** Keywords ***
Get Parsed Notes List
    ${notes_json}=    Execute RC    <<<rc, get_all_notes, body, $.data>>>
    Should Not Be Empty    ${notes_json}     API response body is empty or malformed
    ${notes}=    Evaluate    __import__('json').loads(r'''${notes_json}''')    json
    RETURN    ${notes}

Group Notes By Category Using RC
    ${notes_json}=    Execute RC    <<<rc, get_all_notes, body, $.data>>>
    ${notes}=         Evaluate    __import__('json').loads(r'''${notes_json}''')    json
    ${category_map}=  Create Dictionary

    FOR    ${note}    IN    @{notes}
        ${category}=    Set Variable    ${note['category']}

        IF    '${category}' not in ${category_map}
            Set To Dictionary    ${category_map}    ${category}    1
        ELSE
            ${current}=     Get From Dictionary    ${category_map}    ${category}
            ${new_count}=   Evaluate    int(${current}) + 1
            Set To Dictionary    ${category_map}    ${category}    ${new_count}
        END
    END
    RETURN    ${category_map}
