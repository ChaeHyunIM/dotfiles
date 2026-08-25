## Orchestration

Before writing or editing a Workflow script, and before spawning multiple subagents with the Agent tool, always invoke the `workflow-tiering` skill first. Assign `model` and `effort` per `agent()` call as two independent axes — never let the session model cascade to every stage.

`/code-review` is no exception when it generates a local workflow. Invoke `workflow-tiering` before creating the script and apply the five-stage assignment (Scope · Find · Verify · Sweep · Synthesize) from that skill's `/code-review` section. A level passed by the user (high · xhigh · max) is a **ceiling**, not a flat value for every stage.

## Creating a new skill — home is `~/.agents/skills/`

Claude Code runs **alongside other coding agents** (Codex and others). So a skill's canonical copy lives in the runtime-neutral home `~/.agents/skills/<name>/`, and `~/.claude/skills/<name>` is a **symlink** pointing there. This holds even when `/skill-creator` is invoked — if the skill-creator skill says to write directly into `~/.claude/skills/`, this rule wins. Most existing skills already follow this layout.

```bash
mkdir -p ~/.agents/skills/<name>
ln -s ../../.agents/skills/<name> ~/.claude/skills/<name>
```

Create the link with a **relative path** (`../../.agents/skills/<name>`) resolved from `~/.claude/skills/`, matching the existing links.

### Exception — Claude-specific skills go in `~/.claude/skills/` as real directories

If a skill depends on **functionality that only exists in Claude Code**, do not symlink it — create it directly under `~/.claude/skills/<name>/`. The single test is: «would this skill still work in another runtime?» Any one of the following makes it Claude-specific:

- The skill drives Workflow tool scripts, Agent subagents, or Artifacts
- It relies on nested-session tricks such as `claude -p` or `--output-format stream-json`
- It calls a Claude Code built-in slash command like `/code-review`
- It assumes Claude Code hooks, plugins, or `.claude/settings.json`

In that case, leave a **TODO for other runtimes** at the bottom of SKILL.md. No need to port it now — just record what is blocking it.

```markdown
## TODO — other runtimes

This skill lives in `~/.claude/skills/` because it depends on <specific Claude-only capability>.
How to substitute it in Codex or elsewhere is undecided.
```

`~/.agents/.skill-lock.json` holds the install records. For the detailed pitfalls (distinct skills that merely share a name, misreading `agents/openai.yaml`), see the memory `reference_skill_homes_agents_vs_claude`.
