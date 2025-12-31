# vasm-scasm Fix: Labels on Section-Switching Directives

## Problem
vasm-scasm was rejecting labels on lines with section-switching directives:

```
error 83: label definition not allowed here
>ZS.END  .ED
```

## Root Cause
When parsing a line like `ZS.END .ED`:
1. Parser creates label `ZS.END` in current section (dummy section)
2. Parser then processes `.ED` directive
3. `.ED` switches back to previous section
4. vasm core tries to move label to new section
5. Sections have different flags → error 83

## Solution
Process section-switching directives **before** creating label atoms.

Modified `syntax/scasm/syntax.c` parse() function (around line 3055):
1. Parse label name
2. **Look ahead** to check if next token is `.ED`, `.EP`, `.PH`, `.DUMMY`, or `.SE`
3. If yes, **process directive FIRST** (switches sections)
4. Then create label in correct (new) section

## Implementation
```c
/* SCASM FIX: Check if next token is a section-switching directive */
char *lookahead = skip(s);
if ((dotdirs && *lookahead == '.') || (!dotdirs && *lookahead)) {
  char *dir = lookahead + (dotdirs ? 1 : 0);
  if ((!strnicmp(dir,"ED",2) && ...) ||
      (!strnicmp(dir,"EP",2) && ...) ||
      (!strnicmp(dir,"DUMMY",5) && ...) ||
      (!strnicmp(dir,"PH",2) && ...) ||
      (!strnicmp(dir,"SE",2) && ...)) {
    /* Process directive first */
    if (handle_directive(lookahead)) {
      s = skip(lookahead);
      /* skip past directive name */
    }
  }
}

/* Now create label in correct section */
label = new_labsym(current_section,labname);
add_atom(0,new_label_atom(label));
```

## Test Results
**Before Fix:**
```
error 83 in line 48: label definition not allowed here
>ZS.END  .ED

error 83 in line 604: label definition not allowed here
>DS.END  .ED
```

**After Fix:**
```
✓ ZS.END  .ED - assembles correctly
✓ DS.END  .ED - assembles correctly
✓ All A2osX ASM.S directives work
```

## Impact
- ✅ Fixes A2osX ASM.S assembly
- ✅ Allows SCASM idiom: `LABEL .ED` / `LABEL .EP`
- ✅ No performance impact (lookahead is fast)
- ✅ Backward compatible (doesn't break existing code)

## Committed
- vasm-ext commit: 911052b
- File: `syntax/scasm/syntax.c`
- Date: 2025-12-31
