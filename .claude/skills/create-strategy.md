---
name: create-strategy
description: Interactive YAML strategy configuration creation with comprehensive SME guidance following TopStepX canonical schema
---

# TopStepX Strategy Configuration - INTERACTIVE

**THIS IS AN INTERACTIVE SKILL** that guides you through creating a complete, production-ready TopStepX strategy YAML configuration using the AskUserQuestion tool.

**FOR DETAILED TECHNICAL QUESTIONS**: Invoke the `/strategy-sme` skill which contains all subject matter expert knowledge and can answer specific questions about YAML schema, exit policies, trailing policies, risk management, and more.

---

## Interactive Creation Workflow (MAIN)

**WHEN THIS SKILL IS INVOKED**: Follow this interactive workflow to create a complete strategy YAML configuration.

### Step 1: Gather Strategy Identity

Use AskUserQuestion to ask:

**Question 1: What is the strategy identity?**
- **Prompt**: "What's a unique identifier for this strategy? Use snake_case format like 'ES_VWAP_RSI_SCALPER_5M' or 'NQ_ORB_5M'"
- **Type**: Text input

**Question 2: Target market and timeframe?**
- **Options**:
  - "Micro E-mini S&P (MES) - 5m - Scalping/intraday"
  - "Micro E-mini Nasdaq (MNQ) - 5m - Scalping/intraday"
  - "Micro E-mini Russell (M2K) - 15m - Swing trading"
  - "Micro E-mini Dow (MYM) - 5m - Scalping/intraday"
  - "Custom timeframe (user specifies)"
- **Multiselect**: false

**Question 3: Which Python strategy plugin?**
- **Prompt**: "What's the full Python import path to the strategy plugin class? Example: 'topstepx_backend.strategy.plugins.es_vwap_rsi_scalper_5m.ESVWAPRSIScalper5m'"
- **Type**: Text input

**Question 4: Topstep account ID?**
- **Prompt**: "What's your Topstep account ID? (8-digit number)"
- **Type**: Text input (validate: positive integer)

### Step 2: Gather Exit Policy Configuration

Use AskUserQuestion to ask:

**Question 5: Which exit policy basis?**
- **Options**:
  - "R-Multiple - Risk-reward ratio (2R = target is 2x stop distance)"
  - "Units - Fixed ticks/points (direct control, scalping)"
  - "ATR - Average True Range (volatility-adaptive)"
  - "SMC - Smart Money Concepts (order blocks, structure)"
  - "Category - Preset profiles (scalper, swing, risk_on)"
  - "Custom - Mix different TP/SL calculations"
- **Multiselect**: false

Based on selection, ask basis-specific questions:

**If R-Multiple selected**:
- Ask: "What R-multiple for profit target? (e.g., 2.0 means target is 2x stop distance)"
  - Default: 2.0
  - Range: 0.5 - 10.0
- Ask: "How many ticks for stop loss?"
  - Default: 10
  - Range: 1 - 100

**If Units selected**:
- Ask: "How many ticks for take profit?"
  - Default: 20
  - Range: 1 - 500
- Ask: "How many ticks for stop loss?"
  - Default: 10
  - Range: 1 - 500
  - Note: Can be null for TP-only strategies

**If ATR selected**:
- Ask: "ATR period (bars)?"
  - Default: 14
  - Range: 5 - 200
- Ask: "ATR multiplier for distance?"
  - Default: 2.0
  - Range: 0.5 - 10.0
- Ask: "Price source for ATR?"
  - Options: "close", "hl2", "hlc3", "ohlc4"
  - Default: "close"

**If SMC selected**:
- Ask: "SMC mode?"
  - Options: "assist (suggest zones)", "enforce (require zones)"
- Ask: "Enable TP assistance?"
  - Default: true
- Ask: "Enable SL assistance?"
  - Default: true
- Ask: "TP buffer ticks beyond zone?"
  - Default: 2
- Ask: "SL buffer ticks beyond zone?"
  - Default: 2

**If Category selected**:
- Ask: "Which category profile?"
  - Options: "scalper (quick in/out)", "swing (position trading)", "risk_on (aggressive)", "risk_off (conservative)"

**If Custom selected**:
- Ask: "How many custom legs?"
  - Default: 2
  - Range: 1 - 5
- For each leg:
  - Ask: "Leg type?" → Options: "fixed_take_profit", "fixed_stop_loss"
  - Ask: "Leg basis?" → Options: "r", "units", "atr", "smc", "category"

**Question 6: Which exit types?**
- **Options**:
  - "Fixed Take Profit - Static profit target"
  - "Fixed Stop Loss - Static stop loss"
  - "Trailing Take Profit - Dynamic profit target"
  - "Trailing Stop Loss - Dynamic stop loss"
- **Multiselect**: true (can select multiple)

**Question 7: Order time type?**
- **Options**:
  - "DAY order - Expires at end of trading day (recommended for intraday)"
  - "GTC order - Good Till Cancelled (for multi-day positions)"
- **Multiselect**: false

### Step 3: Gather Trailing Policy Configuration

Use AskUserQuestion to ask:

**Question 8: Enable trailing?**
- **Options**:
  - "Yes - Trail take profit and/or stop loss dynamically"
  - "No - Use fixed exits only"
- **Multiselect**: false

**If "Yes" selected**:

**Question 9: Take profit trailing settings?**
- Ask: "How many ticks to trail TP each step?"
  - Default: 2
  - Range: 0 - 20
  - Note: 0 = disable TP trailing
- Ask: "How many ticks must price move to trigger TP trail?"
  - Default: 4
  - Range: 1 - 50
- Ask: "After how many ticks profit should TP trailing activate?"
  - Default: 0 (immediately)
  - Range: 0 - 100
- Ask: "Minimum seconds between TP updates?"
  - Default: 1.0
  - Range: 0.5 - 10.0
- Ask: "Headroom ticks for TP? (exit on retrace from watermark)"
  - Default: null (disabled)
  - Range: 1 - 50 or null

**Question 10: Stop loss trailing settings?**
- Ask: "How many ticks to trail SL each step?"
  - Default: 2
  - Range: 0 - 20
  - Note: 0 or null = disable SL trailing
- Ask: "How many ticks must price move to trigger SL trail?"
  - Default: 4
  - Range: 1 - 50
- Ask: "After how many ticks profit should SL trailing activate?"
  - Default: 0 (immediately)
  - Range: 0 - 100
- Ask: "Minimum seconds between SL updates?"
  - Default: 1.0
  - Range: 0.5 - 10.0
- Ask: "Move SL to breakeven when trailing activates?"
  - Options: "Yes", "No"
  - Default: "No"

### Step 4: Gather Risk and Sizing Configuration

Use AskUserQuestion to ask:

**Question 11: Position sizing?**
- **Options**:
  - "Fixed 1 contract - Simple, always 1 contract (recommended for starting)"
  - "Fixed 2 contracts - Slightly larger, always 2 contracts"
  - "Fixed 3 contracts - Moderate size"
  - "Custom (user specifies)"
- **Multiselect**: false

**Question 12: Risk management settings?**
- **Options**:
  - "Conservative - $250 daily loss, 5 bars cooldown, 5 orders/min"
  - "Moderate - $500 daily loss, 3 bars cooldown, 10 orders/min"
  - "Aggressive - $1000 daily loss, 2 bars cooldown, 20 orders/min"
  - "Custom - I'll specify each parameter"
- **Multiselect**: false

If "Custom" selected:
- Ask: "Minimum bars cooldown between orders?" (MANDATORY)
  - Default: 5
  - Range: 1 - 50
  - Note: REQUIRED field, prevents order spam
- Ask: "Maximum daily loss (dollars)?"
  - Default: 500.0
  - Range: 100.0 - 5000.0
- Ask: "Maximum order size (contracts)?"
  - Default: 5
  - Range: 1 - 20
  - Note: Must be >= position_size
- Ask: "Maximum orders per minute?"
  - Default: 10
  - Range: 1 - 60
- Ask: "Maximum position size (total contracts)?"
  - Default: 2
  - Range: 1 - 20
  - Note: Must be >= position_size

### Step 5: Gather Strategy-Specific Parameters

Use AskUserQuestion to ask:

**Question 13: Does this strategy have custom parameters?**
- **Options**:
  - "Yes - I have strategy-specific parameters (indicators, thresholds, session filters)"
  - "No - Use defaults from plugin PARAM_MODEL"
- **Multiselect**: false

If "Yes" selected:
- Ask: "How many custom parameters?"
  - Default: 5
  - Range: 1 - 20

For each custom parameter:
- Ask: "Parameter name (snake_case)?"
  - Examples: "rsi_period", "ema_period", "vwap_period", "session_start_hour"
- Ask: "Parameter type?"
  - Options: "int", "float", "bool", "str"
- Ask: "Default value?"
- Ask: "Description (optional)?"

**Common parameter suggestions**:
- Indicator periods: `rsi_period`, `ema_period`, `atr_period`, `bb_period`, `vwap_period`
- Indicator thresholds: `rsi_oversold`, `rsi_overbought`, `adx_threshold`, `bb_std_dev`
- Session filters: `session_start_hour`, `session_start_minute`, `session_end_hour`, `session_end_minute`
- Trade limits: `max_daily_trades`, `bar_buffer_size`

### Step 6: Generate Complete YAML Configuration

Based on all answers, generate the complete YAML configuration with:

1. **File location**: `topstepx_backend/strategy/configs/strategies.yaml`

2. **Complete structure**:
   ```yaml
   strategies:
     - strategy_id: "{user_input}"
       class: "{user_input}"
       account_id: {user_input}
       contract_id: "{derived_from_market_selection}"
       timeframe: "{derived_from_market_selection}"

       params:
         # MANDATORY: Cooldown (REQUIRED)
         min_bars_cooldown: {user_input}

         # Exit policy (NESTED in params)
         exit_policy:
           policy_basis: "{user_selection}"
           exit_types:
             - "{user_selections}"
           details:
             {basis-specific fields from Step 2}
           time_type: {0 or 1}

         # Trailing policy (NESTED in params)
         trailing_policy:
           enabled: {true or false}
           {if enabled, include all TP/SL settings from Step 3}

         # Sizing policy (NESTED in params)
         sizing_policy:
           position_size: {user_input}

         # Custom parameters (if any)
         {custom_params from Step 5}

       # Risk limits (SEPARATE ROOT-LEVEL - NOT IN PARAMS!)
       risk:
         max_position_size: {user_input}
         max_daily_loss: {user_input}
         max_order_size: {user_input}
         max_orders_per_minute: {user_input}
   ```

3. **Configuration generation rules**:
   - exit_policy, trailing_policy, sizing_policy → NESTED inside `params`
   - risk → SEPARATE root-level section (NOT in params)
   - min_bars_cooldown → MANDATORY in params
   - Follow canonical YAML schema (reference strategy-sme for details)
   - Validate all cross-field constraints (position_size <= max_order_size, etc.)
   - Use proper YAML indentation (2 spaces)

4. **Reference canonical schema from strategy-sme**:
   - For exit policy details: `/strategy-sme` → YAML Configuration → Exit Policy
   - For trailing policy: `/strategy-sme` → YAML Configuration → Trailing Policy
   - For risk management: `/strategy-sme` → YAML Configuration → Risk Management
   - For validation rules: `/strategy-sme` → YAML Configuration → Validation

### Step 7: Validation Checklist

After generating configuration, provide:

**Validation Steps**:
1. **YAML syntax**: Check indentation (2 spaces), no tabs, proper list formatting
2. **Required fields**: All mandatory fields present (strategy_id, class, account_id, contract_id, timeframe, params.min_bars_cooldown, exit_policy, sizing_policy, risk)
3. **Cross-field validation**:
   - `position_size <= max_order_size`
   - `position_size <= max_position_size`
   - If trailing exit types selected: `trailing_policy.enabled = true`
   - Units basis: At least one of `tp_units` or `sl_units` specified
4. **Plugin exists**: Verify plugin file exists and imports successfully
   ```bash
   python -c "from {class_path} import {ClassName}"
   ```
5. **Backend starts**: Test backend loads configuration without errors
   ```bash
   python -m topstepx_backend
   grep "ValidationError" data/logs/topstepx.log
   ```
6. **API check**: Verify strategy appears in API
   ```bash
   curl http://localhost:8000/strategies | jq 'map({strategy_id, contract_id})'
   ```

### Step 8: Summary and Next Steps

After configuration generation, provide:

**Files Generated**:
- Configuration: `topstepx_backend/strategy/configs/strategies.yaml`
- Location: Append to existing strategies.yaml file

**Next Steps**:
1. "Copy the generated YAML to `topstepx_backend/strategy/configs/strategies.yaml`"
2. "Ensure plugin PARAM_MODEL matches custom parameters"
3. "Run backend: `python -m topstepx_backend`"
4. "Check for errors: `grep '{strategy_id}' data/logs/topstepx.log`"
5. "Test with paper trading first before live"
6. "For detailed questions about YAML schema, invoke `/strategy-sme`"

**Offer Additional Help**:
- "Would you like me to:"
  - "Explain any part of the configuration in detail?"
  - "Create a different exit policy basis?"
  - "Adjust risk parameters?"
  - "Generate matching PARAM_MODEL code for the plugin?"
  - "Create comprehensive tests for this configuration?"

---

## Reference Knowledge

**The following sections contain essential YAML schema reference. For interactive Q&A on these topics, use `/strategy-sme` skill.**

---

## Canonical YAML Schema (Quick Reference)

**Authoritative structure all strategies must follow:**

```yaml
strategies:
  - strategy_id: "UNIQUE_ID"              # Required: Unique strategy identifier
    class: "module.path.ClassName"        # Required: Full Python import path
    account_id: 12345678                  # Required: Topstep account ID
    contract_id: "CON.F.US.MNQ.Z25"      # Required: CME contract ID
    timeframe: "5m"                       # Required: 1m, 5m, 10m, 15m, 30m, 1h, 4h, 1d

    params:                               # Strategy-specific parameters
      # ══════════════════════════════════════════════
      # MANDATORY: Cooldown Protection (REQUIRED)
      # ══════════════════════════════════════════════
      min_bars_cooldown: 5                # REQUIRED: Minimum bars between orders

      # ══════════════════════════════════════════════
      # Exit Policy (NESTED in params)
      # ══════════════════════════════════════════════
      exit_policy:
        policy_basis: "units"             # r | units | atr | smc | category | custom
        exit_types:                       # At least one required
          - "fixed_take_profit"
          - "fixed_stop_loss"
        details:                          # Basis-specific fields
          tp_units: 20
          sl_units: 10
        time_type: 0                      # 0 = DAY, 1 = GTC

      # ══════════════════════════════════════════════
      # Trailing Policy (NESTED in params, optional)
      # ══════════════════════════════════════════════
      trailing_policy:
        enabled: true                     # false to disable all trailing
        tp_ticks: 2                       # Ticks to trail TP each step
        tp_step_ticks: 4                  # Ticks price must move to trigger
        tp_activation_ticks: 0            # Profit threshold to activate
        tp_min_interval_sec: 1.0          # Min seconds between updates
        tp_headroom_ticks: null           # Optional: Exit on retrace
        sl_ticks: 2                       # Ticks to trail SL (null = disable)
        sl_step_ticks: 4
        sl_activation_ticks: 0
        sl_min_interval_sec: 1.0
        breakeven_on_activation: false    # Move SL to entry when activates

      # ══════════════════════════════════════════════
      # Sizing Policy (NESTED in params)
      # ══════════════════════════════════════════════
      sizing_policy:
        position_size: 1                  # Number of contracts per entry

      # ══════════════════════════════════════════════
      # Custom Strategy Parameters
      # ══════════════════════════════════════════════
      rsi_period: 14
      rsi_oversold: 30
      rsi_overbought: 70
      # ... more custom params

    # ══════════════════════════════════════════════════
    # Risk Limits (SEPARATE ROOT-LEVEL - NOT IN PARAMS!)
    # ══════════════════════════════════════════════════
    risk:
      max_position_size: 2                # Max total contracts
      max_daily_loss: 500.0               # Max $ loss per day
      max_order_size: 1                   # Max contracts per single order
      max_orders_per_minute: 5            # Rate limiting
```

---

## Exit Policy Basis Types (Quick Reference)

**Six basis types with different calculation methods:**

### 1. R-Multiple (`r`)
**Purpose**: Risk-reward ratio targeting
```yaml
exit_policy:
  policy_basis: "r"
  details:
    r_multiple: 2.0    # 2:1 reward:risk
    sl_units: 10       # Stop loss in ticks
```

### 2. Units (`units`)
**Purpose**: Fixed tick/point targets
```yaml
exit_policy:
  policy_basis: "units"
  details:
    tp_units: 20       # +20 ticks target
    sl_units: 10       # -10 ticks stop
```

### 3. ATR (`atr`)
**Purpose**: Volatility-adaptive exits
```yaml
exit_policy:
  policy_basis: "atr"
  details:
    atr_period: 14
    atr_multiplier: 2.0
    atr_source: "close"
```

### 4. SMC (`smc`)
**Purpose**: Smart Money Concepts (order blocks, structure)
```yaml
exit_policy:
  policy_basis: "smc"
  details:
    smc_mode: "assist"
    assist_tp: true
    assist_sl: true
    tp_buffer_units: 2
    sl_buffer_units: 2
```

### 5. Category (`category`)
**Purpose**: Preset profiles
```yaml
exit_policy:
  policy_basis: "category"
  details:
    category_label: "scalper"  # scalper | swing | risk_on | risk_off
```

### 6. Custom (`custom`)
**Purpose**: Mix different calculations
```yaml
exit_policy:
  policy_basis: "custom"
  details:
    legs:
      - basis: "atr"
        type: "fixed_take_profit"
      - basis: "units"
        type: "fixed_stop_loss"
```

---

## Common Configuration Patterns (Quick Reference)

### Pattern 1: Conservative Scalper
```yaml
strategy_id: "ES_SCALPER_5M"
contract_id: "CON.F.US.MES.Z25"
timeframe: "5m"

params:
  min_bars_cooldown: 3
  exit_policy:
    policy_basis: "units"
    exit_types: ["fixed_take_profit", "fixed_stop_loss"]
    details:
      tp_units: 10
      sl_units: 5
    time_type: 0

  trailing_policy:
    enabled: true
    tp_ticks: 1
    tp_step_ticks: 2
    tp_activation_ticks: 0
    sl_ticks: null  # Don't trail SL

  sizing_policy:
    position_size: 1

risk:
  max_position_size: 1
  max_daily_loss: 250.0
  max_order_size: 1
  max_orders_per_minute: 5
```

### Pattern 2: Trend Rider
```yaml
strategy_id: "NQ_TREND_15M"
contract_id: "CON.F.US.MNQ.Z25"
timeframe: "15m"

params:
  min_bars_cooldown: 10
  exit_policy:
    policy_basis: "atr"
    exit_types: ["fixed_take_profit", "fixed_stop_loss"]
    details:
      atr_period: 14
      atr_multiplier: 3.0
      atr_source: "close"
    time_type: 0

  trailing_policy:
    enabled: true
    tp_ticks: 4
    tp_step_ticks: 8
    tp_activation_ticks: 16
    sl_ticks: 2
    sl_step_ticks: 4
    sl_activation_ticks: 10
    breakeven_on_activation: true

  sizing_policy:
    position_size: 1

risk:
  max_position_size: 2
  max_daily_loss: 500.0
  max_order_size: 1
  max_orders_per_minute: 5
```

### Pattern 3: Risk-Reward Optimizer
```yaml
strategy_id: "YM_MEAN_REVERSION_15M"
contract_id: "CON.F.US.MYM.Z25"
timeframe: "15m"

params:
  min_bars_cooldown: 5
  exit_policy:
    policy_basis: "r"
    exit_types: ["fixed_take_profit", "fixed_stop_loss"]
    details:
      r_multiple: 3.0  # 3:1 reward:risk
      sl_units: 15     # TP auto-calculated: 45 ticks
    time_type: 0

  trailing_policy:
    enabled: false  # Simple fixed exits

  sizing_policy:
    position_size: 1

risk:
  max_position_size: 1
  max_daily_loss: 500.0
  max_order_size: 1
  max_orders_per_minute: 5
```

---

## Critical Validation Rules (Quick Reference)

**Schema Structure**:
- `exit_policy`, `trailing_policy`, `sizing_policy` → NESTED inside `params`
- `risk` → SEPARATE root-level section (NOT in params)
- `min_bars_cooldown` → MANDATORY in params

**Cross-Field Validation**:
- `position_size <= max_order_size` (REQUIRED)
- `position_size <= max_position_size` (REQUIRED)
- If trailing exit types selected: `trailing_policy.enabled = true`
- Units basis: At least one of `tp_units` or `sl_units` specified

**Valid Values**:
- `timeframe`: `1m`, `5m`, `10m`, `15m`, `30m`, `1h`, `4h`, `1d`
- `policy_basis`: `r`, `units`, `atr`, `smc`, `category`, `custom`
- `time_type`: `0` (DAY) or `1` (GTC)
- `contract_id`: `CON.F.{COUNTRY}.{SYMBOL}.{EXPIRY}`

**Common Mistakes to Avoid**:
```yaml
# ❌ WRONG - risk nested in params
params:
  risk:
    max_daily_loss: 500.0

# ✅ CORRECT - risk at root level
params:
  # ... strategy params
risk:
  max_daily_loss: 500.0
```

```yaml
# ❌ WRONG - missing min_bars_cooldown
params:
  exit_policy: {...}
  # Missing min_bars_cooldown!

# ✅ CORRECT - min_bars_cooldown present
params:
  min_bars_cooldown: 5  # MANDATORY
  exit_policy: {...}
```

---

## Summary

**This skill provides an interactive workflow for creating TopStepX strategy YAML configurations using AskUserQuestion.**

**For detailed technical questions during configuration creation:**
- Invoke `/strategy-sme` for comprehensive YAML schema knowledge
- Topics: Exit Policies (all 6 basis types), Trailing Policies, Risk Management, Validation

**Key Schema Rules (NEVER VIOLATE)**:
1. exit_policy, trailing_policy, sizing_policy → NESTED in params
2. risk → SEPARATE root-level (NOT in params)
3. min_bars_cooldown → MANDATORY in params
4. Follow canonical YAML schema exactly
5. Validate cross-field constraints (position_size, max_order_size, etc.)
6. Use proper YAML indentation (2 spaces, no tabs)

**Interactive workflow ensures:**
- Canonical schema compliance
- All required fields present
- Cross-field validation
- Production-ready configuration
- Complete validation checklist

**Start the workflow by invoking this skill. It will guide you through all steps using AskUserQuestion.**
