# plan-interview

Refine project plans through in-depth Socratic questioning.

## Installation

```bash
/plugin install plan-interview@claude-code-in-avinyc
```

## Usage

```bash
/plan-interview:interview path/to/plan.md
```

## What It Does

Takes a plan file and interviews you in-depth about:
- Technical implementation details
- UI & UX considerations
- Potential concerns and edge cases
- Tradeoffs and alternatives

## Questioning Style

- One question at a time
- Uses multiple choice when natural options exist
- Builds on previous answers
- Goes deep before going wide
- Stops when the plan is solid

## Question Types

- **Technical**: "Why this approach over X?"
- **Edge cases**: "What happens when Y fails?"
- **UX**: "How will Z affect the user experience?"
- **Scope**: "Is A necessary for MVP?"
- **Assumptions**: "What if" scenarios

## Output

After the interview is complete, writes the refined specification back to the original file with all insights incorporated.

## When to Use

- Before starting implementation on a new feature
- When a plan feels incomplete
- To validate assumptions before coding
- When you need to think through edge cases

## Natural Language

- "Interview me about this plan"
- "Refine this spec with questions"
- "Help me think through this feature"

## License

MIT
