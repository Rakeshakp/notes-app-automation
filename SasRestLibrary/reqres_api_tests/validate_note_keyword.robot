*** Settings ***
Library           RESTLibrary
Library           Collections
Library           String
Library           OperatingSystem
Library           JSONLibrary
Library           OperatingSystem
Library           JSONLibrary
Library           String
Library            Collections
Resource          ../../Resources/variables/common_variables.robot

*** Keywords ***
Read Note Meta From File
    ${line}=    Get File    ${NOTE_META_FILE}
    ${line}=    Strip String    ${line}
    ${parts}=   Split String    ${line}    |
    ${length}=  Get Length    ${parts}
    Run Keyword If    ${length} < 3    Fail     note_meta.txt must contain title, description, and category

    ${title}=       Set Variable    ${parts[0]}
    ${description}=    Set Variable    ${parts[1]}
    ${category}=    Set Variable    ${parts[2]}

#    Log To Console      Title: ${title}
#    Log To Console      Description: ${description}
#    Log To Console      Category: ${category}

    RETURN    ${title}    ${description}    ${category}

Normalize String
    [Arguments]    ${text}
    ${text}=    Strip String    ${text}
    ${text}=    Replace String    ${text}    \n    ${EMPTY}
    ${text}=    Replace String    ${text}    \r    ${EMPTY}
    ${text}=    Convert To Lower Case    ${text}
    RETURN      ${text}

Find Note ID By Metadata
    [Arguments]    ${notes}    ${title}    ${description}    ${category}
    ${note_id}=    Set Variable    None
    ${title_norm}=    Normalize String    ${title}
    ${description_norm}=    Normalize String    ${description}
    ${category_norm}=    Normalize String    ${category}

    FOR    ${note}    IN    @{notes}
        ${t_norm}=    Normalize String    ${note['title']}
        ${d_norm}=    Normalize String    ${note['description']}
        ${c_norm}=    Normalize String    ${note['category']}

        Log To Console    Comparing: '${t_norm}' == '${title_norm}'
        Log To Console    Comparing: '${d_norm}' == '${description_norm}'
        Log To Console    Comparing: '${c_norm}' == '${category_norm}'

        ${match}=    Evaluate    '${t_norm}' == '${title_norm}' and '${d_norm}' == '${description_norm}' and '${c_norm}' == '${category_norm}'
        Run Keyword If    ${match}    Set Test Variable    ${note_id}    ${note['id']}
        Run Keyword If    ${match}    Exit For Loop
    END
    RETURN    ${note_id}

Get Notes List
    [Arguments]    ${headers}
    ${notes_url}=    Set Variable    ${BASE_URL}${GET_NOTES_ENDPOINT}
    ${response}=    Make HTTP Request
    ...    requestId=get_notes
    ...    url=${notes_url}
    ...    method=GET
    ...    requestHeaders=${headers}
    ...    responseVerificationType=none

    ${status}=    Set Variable    ${response.responseStatusCode}
    Run Keyword If    "${status}" != "200"    Fail    Failed to fetch notes. Status: ${status}

    ${raw_body}=    Set Variable    ${response.responseBody}
#    Log To Console    Raw notes body: ${raw_body}
    ${body}=    Evaluate    json.loads("""${raw_body}""")    json
    ${notes}=   Get From Dictionary    ${body}    data
    RETURN      ${notes}
