# RAG Manifest

`docs/rag-manifest.jsonl` is a JSON Lines manifest for controlled retrieval support.

Each line is one retrievable project source. The manifest does not store embeddings; it stores stable metadata that an indexing job, evaluator, or CDC evidence agent can use to decide which file to retrieve or chunk.

## Scope

The manifest supports the CDC manufacturing evidence agent. It provides controlled explanatory context for CDC answers, such as glossary definitions, CDE interpretation, ontology relationship meaning, query-pack context, evidence limitations, and how to read graph answers.

The CDC agent uses selected graph evidence and supporting context to answer approved CDC manufacturing questions.

## Fields

| Field | Meaning |
| --- | --- |
| `chunk_id` | Stable identifier for this retrievable source. |
| `path` | Project-relative path to the source file. |
| `title` | Human-readable title. |
| `content_type` | Source category used for filtering or ranking retrieval records. Current examples include `handbook`, `glossary`, `semantic-model`, `logical-model`, `canonical-model`, `information-architecture`, `integration-model`, `provenance-evidence-model`, `ontology`, `controlled-vocabulary`, `machine-readable-ontology`, `conceptual-model`, `catalog`, `cypher`, `cypher-seed`, `cypher-validation`, `cypher-security`, `script`, `diagram`, `diagram-source`, `application-doc`, `agent-registry`, `commercial-guide`, `guide`, `documentation`, and `validation`. |
| `summary` | Short human-readable summary of the source. |
| `retrieval_text` | Compact retrieval-oriented text containing likely search terms and answer context. |
| `answers` | Example retrieval intents this source can support. These are not automatically approved CDC agent questions. |
| `tags` | Retrieval tags for filtering or ranking. |
| `source_priority` | Ranking hint. `1` is highest priority for agent grounding. |

## Usage

For a lightweight CDC evidence agent:

1. Load the JSONL file line by line.
2. Match the user question against `title`, `summary`, `retrieval_text`, `answers`, and `tags`.
3. Retrieve the referenced `path`.
4. Use the retrieved document as supporting context together with graph query results.
5. Cite the document path and graph query template used.

For a fuller RAG pipeline, index `summary` and `retrieval_text` first, then chunk the referenced source files separately.

## Limitations

The manifest is a retrieval aid, not a source of regulatory truth and not an approval list for open-ended architecture questions. The underlying project remains demo/reference architecture data and is not a validated GxP system.
