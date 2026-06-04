// Agent user setup for the CDC Neo4j demo.
// Run this with the admin demo account after the Neo4j container is started.
//
// Neo4j Community supports separate users, but not role management / RBAC.
// The Python and Laravel agents also use cypher-shell --access-mode read.
// For server-enforced read-only permissions, use Neo4j Enterprise and grant a
// reader role or equivalent least-privilege privileges to this user.

CREATE USER cdc_agent_reader IF NOT EXISTS
SET PASSWORD 'cdc-agent-reader-password'
CHANGE NOT REQUIRED;

SHOW USERS
YIELD user, roles, passwordChangeRequired, suspended, home
WHERE user = 'cdc_agent_reader'
RETURN user, roles, passwordChangeRequired, suspended, home;
