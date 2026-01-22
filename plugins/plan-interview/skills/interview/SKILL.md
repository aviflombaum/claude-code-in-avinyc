---
name: interview
description: Interview about a plan file to refine it through in-depth questioning. Use when you have a plan that needs validation, refinement, or deeper exploration before implementation. Triggers on "interview me about", "refine this plan", "question this spec".
argument-hint: "[path/to/plan.md]"
user-invocable: true
---

# Plan Interview

Refine project plans through Socratic questioning to produce comprehensive specifications.

## Workflow

1. Read the provided plan file
2. Interview the user in-depth using AskUserQuestion about:
   - Technical implementation details
   - UI & UX considerations
   - Potential concerns and edge cases
   - Tradeoffs and alternatives
3. Ask non-obvious questions that probe assumptions
4. Continue interviewing until the plan is complete
5. Write the refined spec back to the file

## Questioning Guidelines

- Ask about things not covered in the plan
- Challenge assumptions with "what if" scenarios
- Probe technical decisions: "Why this approach over X?"
- Explore edge cases: "What happens when Y fails?"
- Consider users: "How will Z affect the user experience?"
- Question scope: "Is A necessary for MVP?"

## Interview Style

- One question at a time
- Use multiple choice when natural options exist
- Build on previous answers
- Go deep before going wide
- Stop when the plan is solid

## Output

After the interview is complete, write the refined specification back to the original file, incorporating all insights gathered during the questioning.
