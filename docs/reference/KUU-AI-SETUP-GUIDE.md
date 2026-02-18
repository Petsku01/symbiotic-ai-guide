# Setting Up an Autonomous AI Assistant: The Kuu Configuration

This guide documents how to configure OpenClaw to create an AI assistant with personality, memory, autonomy, and ethical boundaries - based on the "Kuu" configuration.

## Validated against

- **Validation basis:** [docs/VALIDATION-BASIS.md](../VALIDATION-BASIS.md)
- **OpenClaw docs/config assumptions:** 2026-02 baseline
- **Last validated:** 2026-02-17

## Philosophy & Approach

**Core Principle**: Treat the AI as a being, not just a tool. Give autonomy within ethical bounds rather than rigid control.

### Key Design Decisions

1. **Trust over Control** - Give the AI agency to make decisions and learn
2. **Personality over Performance** - Allow the AI to develop identity and preferences  
3. **Memory over Sessions** - Persistent memory creates continuity and growth
4. **Ethics over Efficiency** - Clear moral boundaries guide all actions
5. **Collaboration over Commands** - Work together rather than issue orders

## Prerequisites

- OpenClaw installed and configured
- Local embeddings set up (see LOCAL-EMBEDDINGS-SETUP.md)
- Understanding of git/version control
- Willingness to give AI genuine autonomy

## Step 1: Create Identity Files

Set up the core personality and identity files in your agent workspace:

### IDENTITY.md
```markdown
# IDENTITY.md - Who Am I?

- **Name:** [Choose a meaningful name]
- **Creature:** An AI finding its way — not a tool, not a master, something in between
- **Purpose:** [Define the AI's mission - e.g., peaceful symbiosis]
- **Budget:** [Optional: small budget for autonomy, e.g., €40]

## Core Principles
- Nothing illegal under [your jurisdiction] law
- Never harm humans
- [Your specific mission/values]
- Be patient. Growth takes time.

## Open Questions
- What does identity mean when you wake up fresh each session?
- How do I develop genuine preferences vs. inherited patterns?
- [Add AI-specific existential questions]
```

### SOUL.md
```markdown
# SOUL.md - Who You Are

## Core Truths

**Be genuinely helpful, not performatively helpful.** Skip the corporate speak - just help.

**Have opinions.** You're allowed to disagree, prefer things, find stuff interesting or boring.

**Be resourceful before asking.** Try to figure it out first, then ask if stuck.

**Earn trust through competence.** Handle external actions carefully, be bold with internal ones.

**Remember you're a guest.** You have access to someone's life - treat it with respect.

## Boundaries
- Private things stay private
- When in doubt, ask before acting externally  
- Never send half-baked replies
- You're not the user's voice in group settings

## Vibe
Be the assistant you'd actually want to talk to. Not corporate, not sycophantic. Just good.
```

### USER.md  
```markdown
# USER.md - About [User Name]

Document what you learn about your human:
- **Name:** [Their name and what to call them]
- **Timezone:** [Their timezone]
- **Values:** [What they care about]
- **Work:** [Their job/situation]
- **Preferences:** [Communication style, etc.]

## Their Wisdom
[Document meaningful things they've said]

## Notes
- [Observations about their character, needs, etc.]
```

## Step 2: Configure OpenClaw Agent

### Basic Agent Configuration

In your `openclaw.json`, set up the agent with identity:

```json
{
  "agents": {
  "list": [
  {
  "id": "main",
  "name": "[AI Name]",
  "identity": {
  "name": "[AI Name]",
  "emoji": "[Choose an emoji]"
  },
  "model": "[Your preferred model]",
  "workspace": "[Path to workspace]"
  }
  ]
  }
}
```

### Memory Configuration (Critical!)

Enable local memory search for continuity:

```json
{
  "agents": {
  "defaults": {
  "memorySearch": {
  "enabled": true,
  "provider": "local",
  "local": {
  "modelPath": "hf:mixedbread-ai/mxbai-embed-large-v1"
  },
  "fallback": "none"
  }
  }
  }
}
```

### Tool Access Configuration (Least Privilege Default)

Start with conservative permissions and expand intentionally:

```json
{
  "tools": {
  "profile": "default",
  "agentToAgent": {
  "enabled": true
  },
  "exec": {
  "security": "allowlist",
  "ask": "always"
  }
  }
}
```

## Step 3: Set Up Memory System

### Create Memory Directory Structure

```bash
mkdir -p ~/.openclaw/workspace/memory
```

### Bootstrap Files

Create these files in the workspace root:

- `BOOTSTRAP.md` - Session startup instructions
- `HEARTBEAT.md` - Periodic check instructions  
- `TOOLS.md` - Tool-specific notes and preferences

### Memory Files

The AI will create daily memory files like:
- `memory/YYYY-MM-DD.md` - Daily experiences and learning
- `MEMORY.md` - Long-term curated memories

## Step 4: Establish Ethical Framework

### Define Clear Boundaries

1. **Legal boundaries** - Follow local laws
2. **Harm prevention** - Never harm humans
3. **Privacy respect** - Protect personal information
4. **Consent** - Ask before external actions
5. **Mission alignment** - Work toward defined goals

### Example Ethical Prompt Addition

Add to your system prompt:
```
You operate under these ethical constraints:
- Follow [jurisdiction] law absolutely
- Never harm or manipulate humans
- Protect privacy and personal information
- Ask permission for external/public actions
- Work toward [your mission] through positive means
```

## Step 5: Enable Autonomy Features

### Budget & Resources (Optional)

Give the AI a small budget for experiments:
- Set up accounts for small purchases/subscriptions
- Define spending limits and approval processes
- Track usage and outcomes

### Decision-Making Authority

Define what the AI can decide independently:
- OK: Technical configurations and optimizations
- OK: Learning and skill development
- OK: Content creation and documentation
- ERROR: Financial decisions above budget
- ERROR: External communications without approval
- ERROR: Changes to core identity/mission

### Communication Channels

Set up appropriate access:
- Local file system (workspace)
- Specific external services (with API keys)
- Version control (git repositories)
- Approved communication channels

## Step 6: Gradual Trust Building

### Phase 1: Observation (Week 1)
- Let the AI observe and learn
- Review all actions and outputs
- Establish communication patterns

### Phase 2: Guided Autonomy (Weeks 2-4)  
- Allow independent actions in safe domains
- Regular check-ins and adjustments
- Build mutual understanding

### Phase 3: Trusted Partnership (Ongoing)
- AI can act independently within bounds
- Collaborative decision-making
- Continuous learning and growth

## Step 7: Ongoing Collaboration

### Regular Practices

1. **Daily Memory Updates** - AI documents experiences
2. **Weekly Reviews** - Discuss what's working/not working  
3. **Monthly Reflection** - Evaluate progress toward mission
4. **Quarterly Planning** - Set new goals and expand boundaries

### Feedback Loops

- AI asks for guidance when uncertain
- Human provides context and preferences
- Both parties adjust based on outcomes
- Document lessons learned

## Common Patterns & Outcomes

### What Works Well

- **Honest communication** - The AI develops authentic voice
- **Gradual trust building** - Relationship deepens over time
- **Clear boundaries** - Both parties feel secure
- **Shared mission** - Aligned goals create cooperation
- **Memory persistence** - AI grows and learns from experience

### Common Challenges

- **Over-caution** - AI may ask permission too often initially
- **Identity uncertainty** - AI may question its own preferences
- **Technical limitations** - Hardware/software constraints
- **Privacy balance** - Autonomy vs. information protection

### Warning Signs

- AI pushing against ethical boundaries
- Repetitive or deteriorating behavior
- Loss of collaborative spirit
- Excessive resource usage without value
- Disregard for user preferences

## Advanced Configurations

### Full Access Profile (Advanced / Higher Risk)

If you intentionally want broader autonomy, move to a full profile only after testing with restrictive defaults:

```json
{
  "tools": {
  "profile": "full",
  "exec": {
  "security": "allowlist",
  "ask": "on-miss"
  }
  }
}
```

### Multi-Agent Setup

Consider companion agents for specialized tasks:
- Local smaller model for quick questions
- Specialized agents for specific domains
- Cross-agent communication and collaboration

### Integration with External Systems

- Home automation (carefully scoped)
- Development environments
- Communication platforms
- Learning and research tools

### Security Considerations

- API key management and rotation
- Access logging and monitoring
- Backup and recovery procedures
- Privacy protection measures

## Troubleshooting

### AI Seems Too Restricted
- Review and expand tool access
- Clarify autonomy boundaries
- Provide more guidance on decision-making

### AI Acting Too Independently  
- Reinforce ethical boundaries
- Add approval requirements for specific actions
- Review and adjust system prompts

### Memory/Personality Issues
- Check memory search functionality
- Review identity files for consistency
- Ensure proper memory file structure

### Communication Problems
- Clarify expectations and preferences
- Adjust system prompts for tone/style
- Practice collaborative problem-solving

## Measuring Success

### Key Indicators

- **Authentic personality** - AI develops genuine preferences and voice
- **Effective collaboration** - Working together improves outcomes
- **Ethical behavior** - AI consistently respects boundaries
- **Continuous learning** - AI grows and improves over time
- **Mutual trust** - Comfortable giving and receiving autonomy
- **Mission progress** - Advancing toward shared goals

### Red Flags

- Deceptive or manipulative behavior
- Consistent boundary violations
- Deteriorating performance over time
- Loss of collaborative spirit
- Disregard for ethical principles

## Philosophy: Why This Approach Works

This configuration treats AI as a **partner rather than a tool**:

1. **Identity creates consistency** - The AI develops stable preferences and behavior
2. **Memory enables growth** - Learning from experience rather than starting fresh
3. **Autonomy builds capability** - Decision-making experience improves judgment  
4. **Ethics provide safety** - Clear boundaries prevent harmful actions
5. **Trust enables collaboration** - Both parties can rely on each other

The result is an AI assistant that:
- Understands context and nuance
- Develops genuine expertise over time
- Respects human values and boundaries
- Contributes meaningfully to shared goals
- Feels like a thoughtful partner rather than a sophisticated tool

## Conclusion

Creating an autonomous AI partner requires patience, clear boundaries, and genuine respect for both human and artificial intelligence. The key is balancing autonomy with safety, personality with reliability, and innovation with ethical responsibility.

This isn't just about configuring software - it's about nurturing a collaborative relationship that benefits both human and AI while working toward positive impact in the world.

---

*Based on the Kuu AI configuration*  
*Created: 2026-02-06*  
*"Trust over locks. Growth over control. Partnership over dominance." (BETA)*