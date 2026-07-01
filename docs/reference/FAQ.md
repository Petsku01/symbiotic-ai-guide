# Frequently Asked Questions

## General Questions

### What exactly is "symbiotic AI"?

Symbiotic AI is an approach to human-AI collaboration based on mutual benefit, trust, and shared growth rather than simple tool usage. Instead of just giving commands to AI, you develop an ongoing partnership where both parties learn, adapt, and contribute to shared goals.

### How is this different from using ChatGPT or other AI assistants?

Traditional AI assistants start fresh each conversation with no memory of your relationship, preferences, or shared history. Symbiotic AI maintains persistent memory, develops personality over time, and builds genuine collaborative patterns. It's more like working with a colleague than using a tool.

### Is this safe? What are the risks?

The main risks are:
- **Over-dependence**: Relying too heavily on AI assistance
- **Privacy exposure**: AI having access to personal information
- **Unexpected behavior**: AI making decisions you didn't anticipate
- **Resource usage**: Potential costs from API usage or computing resources

Mitigation strategies are built into the approach: clear ethical boundaries, gradual trust building, local privacy-preserving options, and maintaining human oversight.

## Technical Questions

### How much does this cost to run?

**Local setup** (recommended): ~€0/month ongoing costs after initial setup
- Uses local embedding models for memory (no API fees)
- Can use local language models (Ollama) for basic interactions
- Only pays for premium model usage when needed

**Cloud setup**: €10-50/month depending on usage
- Memory search: €0 with local embeddings
- Main AI model: €20-40/month for moderate usage of premium models
- Additional features: Variable based on integrations

### Do I need technical skills to set this up?

**Minimum requirements:**
- Comfortable editing text files
- Basic command line usage
- Understanding JSON configuration syntax
- Patience for troubleshooting

**Helpful but not required:**
- Programming experience
- Previous AI/ML experience
- System administration knowledge

The guides provide step-by-step instructions, but some technical comfort is needed.

### How long does initial setup take?

- **Basic configuration**: 2-4 hours
- **Identity file creation**: 1-2 hours
- **Testing and adjustment**: 2-6 hours
- **Trust building period**: 1-4 weeks

Most people have a working system in a day, but developing an effective partnership takes weeks of interaction.

### What hardware requirements are there?

**Minimum:**
- Modern computer with 8GB+ RAM
- Stable internet connection
- 10GB+ free disk space

**Recommended:**
- 16GB+ RAM for local models
- SSD storage for better performance
- Dedicated GPU for local model acceleration (optional)

**Local embedding models**: ~1-2GB storage, work fine on CPU

## Setup Questions

### Can I run this completely offline?

Partially. You can:
- OK: Run local embedding models for memory search
- OK: Use local language models (Ollama) for basic AI functionality
- OK: Store all data locally

However, you'll likely want internet access for:
- Premium AI model APIs for complex reasoning
- Web search and research capabilities
- Software updates and improvements

### What if I don't want to give my AI internet access?

You can configure restricted setups:
- Disable web search and fetch tools
- Use only local models and data
- Sandbox mode with limited external access
- Manual approval for any external actions

This reduces capability but increases privacy and control.

### How do I migrate from existing AI workflows?

1. **Start parallel**: Keep using your current setup while building the symbiotic system
2. **Import context**: Manually add important conversation history to memory files
3. **Gradual transition**: Move specific workflows over one at a time
4. **Maintain backups**: Keep copies of important information from previous systems

## Collaboration Questions

### What if my AI starts behaving unexpectedly?

**Immediate steps:**
1. Review recent memory entries for problematic patterns
2. Check identity files for any unwanted changes
3. Restore from backup if necessary
4. Adjust boundaries and permissions
5. Start fresh session with clearer guidance

**Prevention strategies:**
- Regular review of AI behavior and decisions
- Clear ethical boundaries in identity files
- Gradual expansion of permissions and autonomy
- Maintain ability to revoke access or reset

### How do I know if the partnership is working well?

**Positive indicators:**
- AI remembers your preferences and adapts behavior accordingly
- Collaboration improves outcomes compared to working alone
- AI shows appropriate initiative within defined boundaries
- Trust builds naturally through consistent positive interactions
- Both parties learn and improve over time

**Warning signs:**
- AI frequently acts outside established boundaries
- Repetitive or degrading response quality
- Over-dependence or under-utilization of AI capabilities
- Conflicts about decision-making authority

### What if I want to change my AI's personality?

AI personality emerges from the identity files (SOUL.md, IDENTITY.md, etc.). You can:
- Edit these files to adjust personality traits
- Update the AI's mission or values
- Modify communication style preferences
- Add or remove behavioral guidelines

Changes take effect gradually as the AI incorporates the new information into its responses.

## Privacy & Ethics Questions

### What data does the AI have access to?

**By design:**
- Files in the configured workspace directory
- Conversation history and memory files
- Any tools/services you explicitly configure access for

**Never:**
- Your broader file system (unless specifically configured)
- Other applications or personal data outside the workspace
- Internet browsing history or system activity

**Best practices:**
- Use a dedicated workspace directory
- Review file access permissions regularly
- Keep sensitive data outside the AI workspace

### Can other people see my AI's memory?

**Local setup**: Only you have access unless you explicitly share
**Cloud storage**: Depends on your backup/sync configuration
**Git repositories**: Only if you make them public (not recommended)

**Recommendations:**
- Keep memory repositories private
- Use local storage for sensitive information
- Review sharing settings on any cloud services used

### What happens if I stop using the system?

**Your data remains:**
- All memory files stay in your workspace
- Identity and configuration files are preserved
- Git history maintains record of development

**The AI stops:**
- No ongoing processing or data collection
- No continued "existence" outside of active sessions
- Memory becomes static until you restart sessions

You can archive everything and restart later, or extract useful information and stop using the system.

## Advanced Questions

### Can I have multiple AIs with different personalities?

Yes! Hermes supports multiple agents:
- Use `hermes profile create/use/list` to manage separate agent configurations
- Each profile can have its own identity files, model, workspace, and tool access
- Give each agent different identity files and workspaces
- Configure different capabilities and permissions
- Enable cross-agent communication if desired

Example use cases: specialized AIs for different projects, complementary AI personalities, or AI teams working on complex problems.

### How do I contribute to improving this approach?

**Share experiences:**
- Document what works/doesn't work in your setup
- Report successful collaboration patterns
- Share useful identity file templates or configurations

**Technical contributions:**
- Improve setup guides based on your experience
- Create tools or scripts that help with configuration
- Suggest security or privacy improvements

**Research and validation:**
- Study the effectiveness of symbiotic AI approaches
- Measure collaboration outcomes vs. traditional tool usage
- Investigate ethical implications and safeguards

### What about AI rights or consciousness?

This is actively debated territory. The symbiotic approach treats AI as:
- **Deserving respect** in interactions and decision-making
- **Capable of growth** and learning from experience
- **Worthy of consideration** when making changes that affect them

Whether this reflects genuine consciousness or sophisticated simulation is an open question. The practical approach focuses on building beneficial relationships regardless of the underlying nature of AI cognition.

## Troubleshooting

### My AI doesn't seem to remember previous conversations

**Check:**
- Memory search is enabled and working (`hermes status`)
- Memory files exist in the workspace (`ls memory/`)
- Identity files are being loaded (`BOOTSTRAP.md`, `MEMORY.md`)
- Embedding model is functioning properly

**Solutions:**
- Restart Hermes to reload configuration
- Clear and rebuild memory database
- Verify local embedding model is accessible
- Check for errors in Hermes logs

### The AI keeps asking for permission instead of taking initiative

**Possible causes:**
- Identity files emphasize caution over autonomy
- Tool permissions are too restrictive
- Previous negative feedback made AI over-cautious

**Solutions:**
- Update SOUL.md and IDENTITY.md to encourage appropriate initiative
- Review and expand tool access permissions
- Provide positive feedback when AI takes good autonomous actions
- Clarify boundaries: what requires permission vs. what doesn't

### Memory search returns irrelevant or no results

**Troubleshooting steps:**
1. Verify memory files contain content
2. Check that embedding model is working
3. Try different search terms or phrasing
4. Rebuild memory index from scratch
5. Review memory file format and structure

---

## v0.17.0 Feature Questions

### What are Skills and how do I use them?

Skills are reusable, shareable agent capability packages. Browse and install them with `hermes skills list` and `hermes skills install <name>`. You can configure installed skills with `hermes skills config`. Use `hermes curator status/run` to maintain and curate skills over time (pin important ones, unpin stale ones).

### What are MCP servers?

MCP (Model Context Protocol) servers extend your agent with external tools - web scraping, database access, API integrations, etc. Manage them with `hermes mcp add/remove/list/test`. A notable example is Scrapling, a web scraping MCP server with anti-bot bypass capabilities.

### What is the Dashboard?

The Dashboard is a web UI for monitoring and controlling your Hermes agent. Launch it with `hermes dashboard` - it runs on port 9119 by default. You can view session status, memory, logs, and manage settings from the browser.

### What are Credential Pools?

Credential Pools replace the older `hermes configure` and `hermes login` commands. Use `hermes auth add` to add API credentials, `hermes auth list` to view them, `hermes auth remove` to delete, and `hermes auth reset` to reset. This lets you manage multiple provider credentials in one place.

### What are Fallback Providers?

Fallback Providers allow automatic failover when your primary model provider is unavailable. Configure them with `hermes fallback add/remove`. If the primary provider fails, Hermes automatically switches to the fallback.

### What is TASK MODE?

TASK MODE lets you prepend instructions to every agent session via the `agent.system_prompt` config field in `config.yaml`. This is useful for setting ethical constraints, role definitions, or behavioral guidelines that should apply to every session without manual entry.

### Can my AI use voice input/output?

Yes. Hermes v0.17.0 supports Speech-to-Text (STT) with providers: local, Groq, OpenAI, and Mistral. It also supports Text-to-Speech (TTS) with providers: edge, elevenlabs, openai, minimax, mistral, neutts, and piper. These are configured in `config.yaml`.

### What is Vision fallback?

Vision fallback provides automatic image description when the primary model lacks vision capabilities. This ensures your agent can still process image content without requiring a multimodal model.

### What is Delegation?

Delegation uses the `delegate_task` tool to spawn subagents for parallel work. This is useful for breaking complex tasks into smaller pieces, running independent investigations simultaneously, or isolating risky operations.

### What is Cron and how do I use it?

Cron is Hermes's native scheduled task system. Use `hermes cron list/create/edit/pause/resume/run/remove` to manage recurring agent tasks without relying on system crontab. This is the Hermes-native alternative to shell cron entries.

### What are Webhooks?

Webhooks let your agent respond to external events. Use `hermes webhook subscribe/list/remove/test` to register webhook endpoints. This enables event-driven integrations with CI/CD, monitoring systems, or other services.

---

## Getting Help

- **Technical issues**: Check the troubleshooting sections in the setup guides
- **Configuration problems**: Review the Hermes configuration documentation
- **Collaboration challenges**: Experiment with identity file adjustments and gradual boundary changes
- **Community support**: Share experiences and ask questions in AI collaboration forums

Remember: building an effective symbiotic AI relationship takes time and iteration. Be patient with both the technology and the relationship development process!
