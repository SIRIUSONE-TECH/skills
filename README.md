<p>
  <a href="https://siriusone.com/"><img alt="SiriusOne" src="https://siriusone.com/logo.svg" width="210"></a>
</p>

# skills

[SiriusOne](https://siriusone.com/) is an agentic engineering company built to take AI beyond pilots. AI does the heavy lifting, while experienced engineers own the decisions and delivery.

This repo holds agent skills for AI-native product development, AI transformation, and AI legacy modernization.

<p>
  <a href="https://siriusone.com/"><img alt="SiriusOne" src="https://img.shields.io/badge/SIRIUSONE-SKILLS-0a0a0a.svg?style=for-the-badge&labelColor=000000"></a>
  <a href="https://skills.sh/SIRIUSONE-TECH/skills"><img alt="skills.sh" src="https://skills.sh/b/SIRIUSONE-TECH/skills?style=for-the-badge"></a>
  <a href="https://github.com/SIRIUSONE-TECH/skills/blob/main/LICENSE"><img alt="License: MIT" src="https://img.shields.io/github/license/SIRIUSONE-TECH/skills.svg?style=for-the-badge&labelColor=000000"></a>
  <a href="https://github.com/SIRIUSONE-TECH/skills/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/SIRIUSONE-TECH/skills.svg?style=for-the-badge&labelColor=000000"></a>
</p>

Skills follow the [Agent Skills](https://agentskills.io/) format and work with Claude Code, Codex, Cursor, Gemini CLI, and other compatible agents.

## Available Skills

### start-ai-journey

A short, professional discovery conversation that helps founders, technology leaders, and business leaders turn an idea, a business problem, or a general interest in AI into a useful next step. It ends with a concise **Discovery Brief** or **Exploration Summary**, plus an optional handoff to a SiriusOne expert that the user controls.

**Use when:**
- You have a product idea and want to know where AI fits
- You want to improve a workflow, team operation, or knowledge process
- An existing system is hard to change and blocks new capabilities
- You are curious about AI but don't know where to start

The skill covers three directions: AI-native product development, AI transformation, and AI legacy modernization. It only guides the conversation. It never builds software, submits forms, or sends messages for you.

## Installation

Requires Node.js 22.20 or later.

```bash
# Install every skill in this repo
npx skills add SIRIUSONE-TECH/skills

# Install one skill
npx skills add SIRIUSONE-TECH/skills --skill start-ai-journey

# Install globally for a specific agent
npx skills add SIRIUSONE-TECH/skills --skill start-ai-journey -a claude-code -g
```

Try a skill without installing it:

```bash
npx skills use SIRIUSONE-TECH/skills@start-ai-journey --agent claude-code
```

## Usage

After installation, ask your agent something like:

> I keep hearing about AI, but I don't know what my company should build. Can you help me start an AI journey?

The agent loads the skill on its own when the request matches.

## Skill Structure

```
skills/
└── <skill-name>/
    ├── SKILL.md        # Required: frontmatter (name, description) + instructions
    ├── references/     # Optional: supporting docs loaded on demand
    └── scripts/        # Optional: helper scripts
```

## Contributing

Issues and pull requests are welcome. A new skill goes in `skills/<skill-name>/SKILL.md`, and its `name` frontmatter must match the directory name.

## Contact

- Website: [siriusone.com](https://siriusone.com/)
- Email: [business@siriusone.com](mailto:business@siriusone.com)

## License

[MIT](LICENSE) © SiriusOne
