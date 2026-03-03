// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/log;

listener http:Listener httpListener = new (9090);

http:Service mockService = service object {
    resource function post responses(@http:Payload CreateResponse payload)
        returns Response|http:BadRequest {

        // Validate the request payload
        if payload.model.toString() == "" {
            return http:BAD_REQUEST;
        }

        // Mock response
        Response response = {
            id: "resp-mock00000",
            'object: "response",
            created_at: 1723091495,
            model: "gpt-4o-mini-2024-07-18",
            status: "completed",
            instructions: (),
            metadata: (),
            tool_choice: "auto",
            tools: [],
            output: [
                {
                    id: "msg-mock00000",
                    'type: "message",
                    role: "assistant",
                    status: "completed",
                    content: [
                        {
                            'type: "output_text",
                            text: "Test response received! How can I assist you today?",
                            annotations: [],
                            logprobs: []
                        }
                    ]
                }
            ],
            'error: (),
            incomplete_details: (),
            usage: {
                input_tokens: 13,
                output_tokens: 11,
                total_tokens: 24,
                input_tokens_details: {cached_tokens: 0},
                output_tokens_details: {reasoning_tokens: 0}
            }
        };
        return response;
    }

    resource function get responses/[string response_id]()
        returns Response|http:NotFound {

        if response_id == "" {
            return http:NOT_FOUND;
        }

        Response response = {
            id: response_id,
            'object: "response",
            created_at: 1723091495,
            model: "gpt-4o-mini-2024-07-18",
            status: "completed",
            instructions: (),
            metadata: (),
            tool_choice: "auto",
            tools: [],
            output: [
                {
                    id: "msg-mock00000",
                    'type: "message",
                    role: "assistant",
                    status: "completed",
                    content: [
                        {
                            'type: "output_text",
                            text: "Test response retrieved successfully.",
                            annotations: [],
                            logprobs: []
                        }
                    ]
                }
            ],
            'error: (),
            incomplete_details: (),
            usage: {
                input_tokens: 13,
                output_tokens: 11,
                total_tokens: 24,
                input_tokens_details: {cached_tokens: 0},
                output_tokens_details: {reasoning_tokens: 0}
            }
        };
        return response;
    }

    resource function delete responses/[string response_id]()
        returns http:Ok|http:NotFound {

        if response_id == "" {
            return http:NOT_FOUND;
        }
        return http:OK;
    }
};

function init() returns error? {
    if isLiveServer {
        log:printInfo("Skipping mock server initialization as the tests are running on live server");
        return;
    }

    log:printInfo("Initiating mock server...");
    check httpListener.attach(mockService, "/");
    check httpListener.'start();
}
