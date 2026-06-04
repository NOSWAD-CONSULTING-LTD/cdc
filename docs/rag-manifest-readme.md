# RAG Manifest

`docs/rag-manifest.jsonl` is a JSON Lines manifest for simple retrieval-augmented generation and agent evaluation.

Each line is one retrievable project source. The manifest does not store embeddings; it stores stable metadata that an agent or indexing job can use to decide which file to retrieve or chunk.

## Fields

| Field | Meaning |
| --- | --- |
| `chunk_id` | Stable identifier for this retrievable source. |
| `path` | Project-relative path to the source file. |
| `title` | Human-readable title. |
| `content_type` | Source category, such as documentation, cypher-validation, ontology, or agent-evaluation. |
| `summary` | Short human-readable summary of the source. |
| `retrieval_text` | Compact retrieval-oriented text containing likely search terms and answer context. |
| `answers` | Example questions this source can help answer. |
| `tags` | Retrieval tags for filtering or ranking. |
| `source_priority` | Ranking hint. `1` is highest priority for agent grounding. |

## Usage

For a lightweight agent:

1. Load the JSONL file line by line.
2. Match the user question against `title`, `summary`, `retrieval_text`, `answers`, and `tags`.
3. Retrieve the referenced `path`.
4. Use the retrieved document together with graph query results.
5. Cite the document path and graph query template used.

For a fuller RAG pipeline, index `summary` and `retrieval_text` first, then chunk the referenced source files separately.

## Limitations

The manifest is a retrieval aid, not a source of regulatory truth. The underlying project remains demo/reference architecture data and is not a validated GxP system.
