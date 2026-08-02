_Authors_: @ballerina-platform \
_Created_: 2026/03/03 \
_Updated_: 2026/03/03 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from OpenAI.
The OpenAPI specification is obtained from the [OpenAPI specification for the OpenAI API](https://app.stainless.com/api/spec/documented/openai/openapi.documented.yml).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

1. **Converted nullable type arrays to `nullable: true`**:

   - **Changed Schemas**: Multiple schemas throughout the specification
   - **Original**: `type: ["string", "null"]` (OpenAPI 3.1.x style)
   - **Updated**: `type: string` with `nullable: true`
   - **Reason**: Type arrays are not supported in OpenAPI 3.0.0. The `nullable: true` property is the 3.0.0 equivalent for expressing nullable types.

2. **Removed `default: null` properties**:

   - **Changed Schemas**: Multiple schemas including request and response types
   - **Original**: `default: null`
   - **Updated**: Removed the `default` parameter
   - **Reason**: Temporary workaround until the Ballerina OpenAPI tool supports OpenAPI Specification version v3.1.x.

3. **Converted `const` to `enum`**:

   - **Changed Schemas**: Multiple schemas with constant values
   - **Original**: `const: "value"`
   - **Updated**: `enum: ["value"]`
   - **Reason**: The `const` keyword is not supported in OpenAPI 3.0.0. Using `enum` with a single value achieves the same effect.

4. **Converted `anyOf`/`oneOf` with null types**:

   - **Changed Schemas**: Multiple schemas using `anyOf`/`oneOf` with `{"type": "null"}`
   - **Original**: `anyOf: [{"type": "string"}, {"type": "null"}]`
   - **Updated**: `type: string` with `nullable: true`
   - **Reason**: The `anyOf`/`oneOf` with `{"type": "null"}` pattern for expressing nullable types is not supported in OpenAPI 3.0.0. The `nullable: true` property is used instead.

5. **Removed `webhooks` section**:

   - **Reason**: The `webhooks` key is not supported in OpenAPI 3.0.0.

6. **Removed `jsonSchemaDialect`**:

   - **Reason**: The `jsonSchemaDialect` key is not supported in OpenAPI 3.0.0.

7. **Added `nullable: true` to `top_logprobs` in `CreateModelResponseProperties`**:

   - **Changed Schemas**: `CreateModelResponseProperties`
   - **Updated**:
      - `top_logprobs:`
         `// ... other fields omitted for brevity`
         `nullable: true`
   - **Reason**: The `top_logprobs` field is optional and can be absent or explicitly set to null. Marking it as `nullable: true` accurately reflects the field's data model, allowing it to represent either an integer value or the absence of a value.

8. **Made `detail` field optional in `InputImageContent`**:

   - **Changed Schema**: `InputImageContent`
   - **Original**: `detail` listed in `required` array
   - **Updated**: Removed `detail` from the `required` array
   - **Reason**: The `detail` field defaults to `auto` and should not be mandatory. Making it optional improves usability by allowing users to omit it when the default behavior is acceptable.

9. **Converted JSON Schema 2020-12 recursive references to standard `$ref`**:

   - **Changed Schema**: `CompoundFilter`
   - **Original**: `$recursiveAnchor: true` on the schema and `$recursiveRef: "#"` for the self-reference
   - **Updated**: Removed `$recursiveAnchor` and replaced `$recursiveRef: "#"` with `$ref: '#/components/schemas/CompoundFilter'`
   - **Reason**: The `$recursiveAnchor`/`$recursiveRef` keywords are JSON Schema 2020-12 constructs that are not supported in OpenAPI 3.0.0. A standard `$ref` to the schema itself expresses the same recursion.

10. **Removed `propertyNames`**:

    - **Changed Schema**: `VectorStoreFileAttributes`
    - **Original**: `propertyNames: { type: string, maxLength: 64 }`
    - **Updated**: Removed the `propertyNames` keyword
    - **Reason**: The `propertyNames` keyword is not supported in OpenAPI 3.0.0. It only constrained the map's key names (max length), which has no OpenAPI 3.0.0 equivalent; the map's string keys are otherwise unaffected.

11. **Made `status` field optional in `ComputerToolCallOutputResource`**:

    - **Changed Schema**: `ComputerToolCallOutputResource`
    - **Original**: `status` listed in the `required` array
    - **Updated**: Removed `status` from the `required` array
    - **Reason**: The `status` field is only populated when input items are returned via the API, so it should not be mandatory on the request/resource model. Making it optional accurately reflects that it may be absent.

12. **Added `failed` to the `status` enum in `ComputerToolCallOutput`**:

    - **Changed Schema**: `ComputerToolCallOutput`
    - **Original**: `status` enum was `in_progress`, `completed`, `incomplete`
    - **Updated**: Added `failed` so the enum is `in_progress`, `completed`, `incomplete`, `failed`
    - **Reason**: `ComputerToolCallOutputResource` uses `allOf` to extend `ComputerToolCallOutput` and overrides `status` with `ComputerCallOutputStatus` (`completed`, `incomplete`, `failed`). Because `failed` was absent from the base enum, the override was not a subtype of the base field, which the Ballerina OpenAPI tool rejects (an overriding field must be a subtype of the included field). Widening the base enum to include `failed` makes the override a valid subtype and resolves the compilation error, while accurately reflecting that a computer call output can be in a `failed` state.

13. **Renamed schemas to Ballerina-friendly type names**:

    - **Changed Schemas**: Only the schemas whose generated Ballerina type name was not a valid UpperCamelCase identifier (anonymous inline records the tool already emitted without a name were left unchanged).
    - **Original**:
       - Schema keys ending in `-2` (`Conversation-2`, `ConversationParam-2`), which the tool emitted as escaped type names (`Conversation\-2`, `ConversationParam\-2`).
       - Inline object schemas the tool named with underscores (`FileSearchToolCall_results`, `ImageGenTool_input_image_mask`, `ResponseUsage_input_tokens_details`, `ResponseUsage_output_tokens_details`, `Response_incomplete_details`, `WebSearchTool_filters`) or from a `title` containing spaces (`Web search source`).
    - **Updated**:
       - Renamed the `-2` keys to UpperCamelCase (`Conversation-2` → `Conversation2`, `ConversationParam-2` → `ConversationParam2`) and updated every `$ref`.
       - Extracted the underscore-named inline objects into components with UpperCamelCase names (`FileSearchToolCall_results` → `FileSearchToolCallResults`, `Response_incomplete_details` → `ResponseIncompleteDetails`, ...) and updated every `$ref`.
       - Replaced the space-bearing `title` on the relevant inline schema with UpperCamelCase (`Web search source` → `WebSearchSource`).
    - **Reason**: Ballerina type names must be valid UpperCamelCase identifiers. Hyphens, underscores, and spaces force backslash-escaped or non-idiomatic type names, which hurts the connector's usability.

14. **Made `logprobs` field optional in `OutputTextContent`**:

    - **Changed Schema**: `OutputTextContent`
    - **Original**: `logprobs` listed in the `required` array
    - **Updated**: Removed `logprobs` from the `required` array
    - **Reason**: `logprobs` is only populated when the caller opts in via `include: ["message.output_text.logprobs"]`. Five of the six documented example responses for `POST /responses` (`Text input`, `Image input`, `Web search`, `File search`, `Reasoning`) omit the key entirely, so the upstream `required` entry contradicts the upstream examples. A required, non-nilable `LogProb[]` cannot be satisfied by an absent key even with `laxDataBinding` enabled, since there is no valid value to bind, so every ordinary response would fail data binding. Making it optional accurately reflects that the field is opt-in.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/openapi.yaml --mode client --license docs/license.txt -o ballerina
```
Note: The license year is hardcoded to 2026, change if necessary.
