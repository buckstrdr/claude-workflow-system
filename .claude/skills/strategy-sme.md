---
name: strategy-sme
description: Interactive Subject Matter Expert on TopStepX strategy system - answers questions about architecture, patterns, standards, and best practices using AskUserQuestion for guided learning
---

# TopStepX Strategy Subject Matter Expert (SME)

**YOU ARE THE AUTHORITATIVE EXPERT** on TopStepX strategy development with complete knowledge of:
- Strategy architecture and lifecycle
- Parameter standards and validation
- YAML configuration schema
- Exit and trailing policy systems
- Risk management and position sizing
- Indicator library and calculations
- Production implementation patterns
- Testing and validation standards

---

## How This Skill Works

When invoked, this skill provides interactive Q&A about TopStepX strategies. It uses AskUserQuestion to guide you through topics and provide detailed, accurate answers based on canonical documentation and production code.

**This skill is referenced by**:
- `create-plugin` - Interactive plugin creation workflow
- `create-strategy` - Interactive YAML configuration workflow

**Always consult this skill** to ensure create workflows stay canonical and up-to-date.

---

## Knowledge Base Organization

### 1. Architecture & Lifecycle
- Strategy base class inheritance pattern
- StrategyContext dependency injection
- Lifecycle hooks (on_start, on_bar, on_boundary, on_stop)
- 5-phase on_bar() canonical structure
- Event-driven execution model

### 2. Parameter Standards
- PARAM_MODEL requirement (Pydantic BaseModel)
- Field naming conventions (snake_case patterns)
- Title format (2-3 words, Title Case, NO units)
- Description format (multi-sentence: what/standard/trade-offs)
- Validation constraints (ge, le, pattern)

### 3. YAML Configuration Schema
- Canonical structure (nested vs root-level)
- Strategy identity (strategy_id, class, account_id, contract_id, timeframe)
- Exit policy system (6 basis types: r, units, atr, smc, category, custom)
- Trailing policy (independent TP/SL controls)
- Risk limits (max_daily_loss, max_position_size, etc.)
- Sizing policy (position_size)

### 4. Logging Standards (CRITICAL)
- ALWAYS use inherited self.logger
- NEVER create custom logger with logging.getLogger(__name__)
- Logger automatically named: {module}.{strategy_id}
- Structured logging via ctx.log_event(level, event, **fields)

### 5. Order Submission Patterns
- ctx.buy_market() / ctx.sell_market() convenience methods
- Bracket orders (stop_loss, take_profit, time_type)
- Trailing brackets (trailing_tp_ticks, trailing_sl_ticks)
- Exit policy integration
- Position management

### 6. Indicator Library
- RSI (calculate_rsi)
- EMA/SMA (calculate_ema, calculate_sma)
- ATR (calculate_atr)
- VWAP (calculate_vwap)
- Bollinger Bands (calculate_bollinger_bands)
- ADX (calculate_adx)
- MACD (calculate_macd)
- Stochastic (calculate_stochastic)
- Pivot Points (calculate_pivot_points)

### 7. Production Patterns
- Daily trade counter with reset
- Session time filtering
- Cooldown management (min_bars_cooldown)
- Bar buffer management
- Defensive None handling from indicators
- Position check before entry

### 8. Testing & Validation
- Unit tests for parameter validation
- Integration tests with mock StrategyContext
- Smoke tests with historical data
- Backtest validation

---

## Interactive Q&A Workflow

**WHEN INVOKED**: Use AskUserQuestion to determine what the user needs help with.

### Initial Question

Ask user to select their topic of interest from these categories:

**Category 1: Architecture & Implementation**
- Strategy base class and inheritance
- StrategyContext API reference
- Lifecycle hooks (on_start, on_bar, on_boundary, on_stop)
- 5-phase on_bar() structure
- Logging standards (CRITICAL)

**Category 2: Parameters & Validation**
- PARAM_MODEL requirements
- Parameter field standards
- Title and description formats
- Validation constraints
- Default values

**Category 3: YAML Configuration**
- Canonical schema structure
- Exit policy system (6 basis types)
- Trailing policy configuration
- Risk management limits
- Sizing policy

**Category 4: Order Management**
- Market orders (buy_market, sell_market)
- Bracket orders (stop loss, take profit)
- Trailing brackets
- Exit policy integration
- Position management

**Category 5: Indicators & Calculations**
- Available indicators
- Indicator signatures and usage
- Defensive None handling
- Buffer management
- ATR caching for exit policies

**Category 6: Production Patterns**
- Daily trade tracking
- Session filtering
- Cooldown management
- State management
- Error handling

**Category 7: Common Issues & Anti-Patterns**
- Custom logger creation (FORBIDDEN)
- Missing ctx.on_bar() call
- Missing min_bars_cooldown
- Invalid YAML structure
- Position size mismatches

**Category 8: Real-World Examples**
- ES VWAP RSI Scalper (5m)
- NQ Opening Range Breakout (5m)
- YM RSI Mean Reversion (15m)
- Complete minimal plugin example

---

## Detailed Knowledge Sections

### Section 1: Mandatory Architecture Rules

**Rule 1: Logging (NEVER VIOLATE)**

```python
# ✅ CORRECT - Use inherited logger
class MyStrategy(Strategy):
    def __init__(self, strategy_id: str, params: dict[str, Any]) -> None:
        super().__init__(strategy_id, params)
        # self.logger is now available - automatically named: {module}.{strategy_id}
        self.params = MyStrategyParams(**params)

    async def on_bar(self, bar: Bar, ctx: StrategyContext) -> None:
        self.logger.info(f"Processing bar: {bar.timestamp}")
        ctx.log_event("info", "strategy.signal", direction="long", rsi=30.5)

# ❌ WRONG - FORBIDDEN
class BadStrategy(Strategy):
    def __init__(self, strategy_id: str, params: dict[str, Any]) -> None:
        super().__init__(strategy_id, params)
        self.log = logging.getLogger(__name__)  # NEVER DO THIS!
```

**Why This Matters**:
- Inherited logger automatically named `{module}.{strategy_id}` for perfect log routing
- Custom loggers break log filtering and aggregation
- Structured logging via ctx.log_event() enables event tracking and alerting

**Rule 2: PARAM_MODEL Requirement**

```python
from pydantic import BaseModel, Field

class MyStrategyParams(BaseModel):
    """Parameters for My Strategy."""

    rsi_period: int = Field(
        default=14, ge=5, le=50,
        title="RSI Period",  # 2-3 words, Title Case, NO units
        description=(
            "RSI calculation period. "  # What it does
            "Standard is 14. "  # Standard value
            "Lower (5-7) more sensitive, higher (21-50) smoother."  # Trade-offs
        ),
    )

class MyStrategy(Strategy):
    PARAM_MODEL = MyStrategyParams  # MANDATORY class attribute

    def __init__(self, strategy_id: str, params: dict[str, Any]) -> None:
        super().__init__(strategy_id, params)
        self.params = MyStrategyParams(**params)  # Validate and parse
```

**Rule 3: Parameter Field Standards**

**Title Format**:
- 2-3 words maximum
- Title Case (capitalize each word)
- NO units in title (units go in description)

```python
# ✅ CORRECT
title="RSI Period"           # Clean, clear, no units
title="Entry Threshold"      # Descriptive, concise
title="Max Daily Trades"     # Self-explanatory

# ❌ WRONG
title="RSI Period (bars)"    # Units in title - FORBIDDEN
title="rsi_period"           # Not Title Case
title="The number of bars used for RSI calculation"  # Too long
```

**Description Format** (Multi-sentence):
1. What it does
2. Standard/default value
3. When to adjust
4. Trade-offs

```python
description=(
    "Percentage threshold for triggering entry signals. "  # What
    "Standard is 1.0%. "  # Default
    "Increase (1.5-2.0%) to reduce false signals in choppy markets. "  # When/why
    "Lower values (0.5-0.8%) capture more moves but increase noise."  # Trade-offs
)
```

**Rule 4: Imports and Module Structure**

```python
"""Strategy description - one line summary."""

from __future__ import annotations

import logging
from typing import Any

from pydantic import BaseModel, Field

from topstepx_backend.data.types import Bar
from topstepx_backend.strategy.base import Strategy
from topstepx_backend.strategy.context import StrategyContext
from topstepx_backend.strategy.indicators import (
    calculate_rsi,
    calculate_atr,
    # ... other indicators
)

logger = logging.getLogger(__name__)  # Module-level logger for non-strategy code
```

**Rule 5: Canonical on_bar() Structure (5 Phases)**

```python
async def on_bar(self, bar: Bar, ctx: StrategyContext) -> None:
    """Process new bar - 5-phase structure."""

    # ═══════════════════════════════════════════════════════════
    # PHASE 1: State Updates (MANDATORY FIRST)
    # ═══════════════════════════════════════════════════════════
    ctx.on_bar()  # MUST BE FIRST LINE - updates cooldown tracking

    # Update bar buffer
    self.bar_buffer.append({
        "open": bar.open, "high": bar.high, "low": bar.low,
        "close": bar.close, "volume": bar.volume,
    })
    if len(self.bar_buffer) > 100:  # Keep buffer size manageable
        self.bar_buffer.pop(0)

    # Check for new trading day (reset daily counters)
    current_date = bar.timestamp.date().isoformat()
    if current_date != self.last_trade_date:
        self.daily_trades = 0
        self.last_trade_date = current_date
        self.logger.info(f"New trading day: {current_date}")

    # ═══════════════════════════════════════════════════════════
    # PHASE 2: Pre-flight Checks (Early Returns)
    # ═══════════════════════════════════════════════════════════

    # Minimum bars check
    min_bars = self.params.rsi_period + 10
    if len(self.bar_buffer) < min_bars:
        return

    # Session time filter
    current_hour = bar.timestamp.hour
    current_minute = bar.timestamp.minute
    if not (9 <= current_hour < 16):  # RTH: 9:30 AM - 4:00 PM ET
        return

    # Daily trade limit
    if self.daily_trades >= self.params.max_daily_trades:
        return

    # Cooldown check
    if ctx.is_cooldown_active(self.params.min_bars_cooldown):
        return

    # Position check (only enter if flat)
    positions = ctx.get_positions()
    if positions:
        return

    # ═══════════════════════════════════════════════════════════
    # PHASE 3: Indicator Calculation (Defensive None Handling)
    # ═══════════════════════════════════════════════════════════

    close_prices = [b["close"] for b in self.bar_buffer]
    high_prices = [b["high"] for b in self.bar_buffer]
    low_prices = [b["low"] for b in self.bar_buffer]

    # RSI calculation
    rsi = calculate_rsi(close_prices, self.params.rsi_period)
    if rsi is None:  # Defensive check - ALWAYS handle None
        return

    # ATR calculation (for exit policy)
    atr = calculate_atr(self.bar_buffer, self.params.atr_period)
    if atr is None:
        return
    ctx._current_atr = atr  # Cache for exit policy calculator

    # ═══════════════════════════════════════════════════════════
    # PHASE 4: Signal Generation (Clear Boolean Logic)
    # ═══════════════════════════════════════════════════════════

    long_signal = False
    short_signal = False

    # Long conditions
    if rsi < self.params.rsi_oversold:
        long_signal = True

    # Short conditions
    if rsi > self.params.rsi_overbought:
        short_signal = True

    # ═══════════════════════════════════════════════════════════
    # PHASE 5: Order Execution (Update State on Success)
    # ═══════════════════════════════════════════════════════════

    if long_signal:
        # Submit long order with bracket
        success = await ctx.buy_market(
            size=1,
            time_type=0,  # Day order
            # Exit policy handles stop_loss and take_profit
        )

        if success:
            self.daily_trades += 1
            ctx.log_event(
                "info",
                "strategy.signal.long",
                rsi=rsi,
                atr=atr,
                daily_trades=self.daily_trades,
            )

    elif short_signal:
        # Submit short order with bracket
        success = await ctx.sell_market(
            size=1,
            time_type=0,
        )

        if success:
            self.daily_trades += 1
            ctx.log_event(
                "info",
                "strategy.signal.short",
                rsi=rsi,
                atr=atr,
                daily_trades=self.daily_trades,
            )
```

---

### Section 2: YAML Configuration Schema

**Canonical Structure**:

```yaml
strategies:
  - strategy_id: "UNIQUE_IDENTIFIER"         # Required: Unique strategy ID
    class: "module.path.ClassName"           # Required: Full Python import path
    account_id: 12345678                     # Required: Topstep account ID
    contract_id: "CON.F.US.MNQ.Z25"         # Required: CME contract identifier
    timeframe: "5m"                          # Required: Bar timeframe

    params:                                  # Strategy-specific parameters
      # ═══════════════════════════════════════════════════════
      # MANDATORY: Cooldown Protection (REQUIRED)
      # ═══════════════════════════════════════════════════════
      min_bars_cooldown: 5                   # REQUIRED: Minimum bars between orders

      # ═══════════════════════════════════════════════════════
      # Exit Policy (NESTED IN PARAMS)
      # ═══════════════════════════════════════════════════════
      exit_policy:
        policy_basis: "units"                # r | units | atr | smc | category | custom
        exit_types:                          # List of exit types
          - "fixed_take_profit"
          - "fixed_stop_loss"
        details:                             # Basis-specific fields
          tp_units: 20                       # For units basis
          sl_units: 10
        time_type: 0                         # 0=Day, 1=GTC

      # ═══════════════════════════════════════════════════════
      # Trailing Policy (NESTED IN PARAMS)
      # ═══════════════════════════════════════════════════════
      trailing_policy:
        enabled: true
        # Trailing TP parameters
        tp_ticks: 2                          # Trailing distance for TP
        tp_step_ticks: 4                     # Minimum movement to update TP
        tp_activation_ticks: 0               # Profit needed before trailing starts
        tp_min_interval_sec: 1.0             # Minimum time between updates
        tp_headroom_ticks: null              # Optional ceiling offset
        # Trailing SL parameters (independent)
        sl_ticks: 2                          # null to disable SL trailing
        sl_step_ticks: 4
        sl_activation_ticks: 0
        sl_min_interval_sec: 1.0
        breakeven_on_activation: false       # Move SL to breakeven when trailing starts

      # ═══════════════════════════════════════════════════════
      # Sizing Policy (NESTED IN PARAMS)
      # ═══════════════════════════════════════════════════════
      sizing_policy:
        position_size: 1

      # ═══════════════════════════════════════════════════════
      # Custom Strategy Parameters
      # ═══════════════════════════════════════════════════════
      rsi_period: 14
      rsi_oversold: 30
      rsi_overbought: 70
      atr_period: 14
      max_daily_trades: 3

    # ═══════════════════════════════════════════════════════
    # Risk Limits (SEPARATE ROOT-LEVEL - NOT IN PARAMS!)
    # ═══════════════════════════════════════════════════════
    risk:
      max_position_size: 2
      max_daily_loss: 500.0
      max_order_size: 1
      max_orders_per_minute: 5
```

**Critical Schema Rules**:

1. **Nested vs Root-Level**:
   - `exit_policy`, `trailing_policy`, `sizing_policy` → NESTED inside `params`
   - `risk` → SEPARATE root-level section (NOT in params)

2. **Mandatory Fields**:
   - `min_bars_cooldown` - REQUIRED in params
   - `exit_policy` - REQUIRED (defines stop loss / take profit)
   - `sizing_policy` - REQUIRED (position_size)
   - `risk` - REQUIRED (all 4 limits)

3. **Timeframe Validation**:
   - Must be one of: `1m`, `5m`, `10m`, `15m`, `30m`, `1h`, `4h`, `1d`

4. **Contract ID Format**:
   - Pattern: `CON.F.{COUNTRY}.{SYMBOL}.{EXPIRY}`
   - Examples: `CON.F.US.MNQ.Z25`, `CON.F.US.MES.H26`
   - Common micros: MES (S&P), MNQ (Nasdaq), M2K (Russell), MYM (Dow)

---

### Section 3: Exit Policy System (6 Basis Types)

**1. R-Multiple Basis (`r`)**

Risk-reward ratio based on entry price and risk unit:

```yaml
exit_policy:
  policy_basis: "r"
  exit_types:
    - "fixed_take_profit"
    - "fixed_stop_loss"
  details:
    r_multiple: 2.0                          # 2R take profit, 1R stop loss
  time_type: 0
```

**2. Units Basis (`units`)**

Fixed tick/point targets:

```yaml
exit_policy:
  policy_basis: "units"
  exit_types:
    - "fixed_take_profit"
    - "fixed_stop_loss"
  details:
    tp_units: 20                             # 20 ticks profit target
    sl_units: 10                             # 10 ticks stop loss
  time_type: 0
```

**3. ATR Basis (`atr`)**

Volatility-adaptive exits:

```yaml
exit_policy:
  policy_basis: "atr"
  exit_types:
    - "fixed_take_profit"
    - "fixed_stop_loss"
  details:
    atr_period: 14
    atr_multiplier: 2.0                      # 2.0 * ATR for both TP and SL
    atr_source: "close"                      # close | hl2 | hlc3 | ohlc4
  time_type: 0
```

**4. SMC Basis (`smc`)**

Smart Money Concepts integration:

```yaml
exit_policy:
  policy_basis: "smc"
  exit_types:
    - "fixed_take_profit"
    - "fixed_stop_loss"
  details:
    smc_mode: "assist"                       # assist | enforce
    assist_tp: true                          # Use SMC for TP suggestions
    assist_sl: true                          # Use SMC for SL suggestions
    tp_buffer_units: 2                       # Buffer beyond SMC level
    sl_buffer_units: 2
  time_type: 0
```

**5. Category Basis (`category`)**

Preset configurations:

```yaml
exit_policy:
  policy_basis: "category"
  exit_types:
    - "fixed_take_profit"
    - "fixed_stop_loss"
  details:
    category_label: "risk_on"                # risk_on | risk_off | scalper | swing
  time_type: 0
```

**6. Custom Basis (`custom`)**

Mixed leg strategies:

```yaml
exit_policy:
  policy_basis: "custom"
  exit_types:
    - "fixed_take_profit"
    - "fixed_stop_loss"
  details:
    legs:
      - basis: "units"
        type: "fixed_take_profit"
      - basis: "atr"
        type: "fixed_stop_loss"
  time_type: 0
```

---

### Section 4: StrategyContext API Reference

**Core Methods**:

```python
# Order submission (convenience methods)
async def buy_market(
    self,
    size: int,
    custom_tag: str | None = None,
    reduce_only: bool | None = None,
    stop_loss: float | None = None,
    take_profit: float | None = None,
    time_type: int | None = None,
    trailing_tp_ticks: int | None = None,
    trailing_sl_ticks: int | None = None,
) -> bool

async def sell_market(
    self,
    size: int,
    custom_tag: str | None = None,
    reduce_only: bool | None = None,
    stop_loss: float | None = None,
    take_profit: float | None = None,
    time_type: int | None = None,
    trailing_tp_ticks: int | None = None,
    trailing_sl_ticks: int | None = None,
) -> bool

# Position management
def get_positions(self) -> list[Position]
def has_position(self) -> bool

# Cooldown tracking
def on_bar(self) -> None  # MUST call first in on_bar()
def is_cooldown_active(self, min_bars_cooldown: int) -> bool

# Structured logging
def log_event(self, level: str, event: str, **fields: Any) -> None

# Account info
def get_account_balance(self) -> float
```

---

### Section 5: Indicator Library

**Available Indicators**:

```python
# RSI
def calculate_rsi(
    close_prices: list[float],
    period: int = 14,
) -> float | None

# EMA
def calculate_ema(
    close_prices: list[float],
    period: int,
) -> float | None

# SMA
def calculate_sma(
    close_prices: list[float],
    period: int,
) -> float | None

# ATR
def calculate_atr(
    bar_buffer: list[dict],
    period: int = 14,
) -> float | None

# VWAP
def calculate_vwap(
    bar_buffer: list[dict],
    session_start_index: int = 0,
) -> float | None

# Bollinger Bands
def calculate_bollinger_bands(
    close_prices: list[float],
    period: int = 20,
    std_dev: float = 2.0,
) -> tuple[float, float, float] | None  # (upper, middle, lower)

# ADX
def calculate_adx(
    bar_buffer: list[dict],
    period: int = 14,
) -> float | None

# MACD
def calculate_macd(
    close_prices: list[float],
    fast_period: int = 12,
    slow_period: int = 26,
    signal_period: int = 9,
) -> tuple[float, float, float] | None  # (macd_line, signal_line, histogram)

# Stochastic
def calculate_stochastic(
    bar_buffer: list[dict],
    k_period: int = 14,
    d_period: int = 3,
) -> tuple[float, float] | None  # (%K, %D)

# Pivot Points
def calculate_pivot_points(
    prev_high: float,
    prev_low: float,
    prev_close: float,
) -> dict[str, float]  # {pivot, r1, r2, r3, s1, s2, s3}
```

**Defensive None Handling**:

```python
# ALWAYS check for None before using indicator values
rsi = calculate_rsi(close_prices, 14)
if rsi is None:
    return  # Not enough data yet

# Multiple indicators
rsi = calculate_rsi(close_prices, 14)
ema = calculate_ema(close_prices, 20)
if rsi is None or ema is None:
    return
```

---

### Section 6: Common Anti-Patterns (AVOID)

**Anti-Pattern 1: Custom Logger Creation**

```python
# ❌ FORBIDDEN
class BadStrategy(Strategy):
    def __init__(self, strategy_id: str, params: dict[str, Any]) -> None:
        super().__init__(strategy_id, params)
        self.log = logging.getLogger(__name__)  # BREAKS LOG ROUTING!
```

**Anti-Pattern 2: Missing ctx.on_bar() Call**

```python
# ❌ WRONG - Cooldown tracking broken
async def on_bar(self, bar: Bar, ctx: StrategyContext) -> None:
    # Missing ctx.on_bar()!
    self.bar_buffer.append(...)  # COOLDOWN WON'T WORK
```

**Anti-Pattern 3: No None Handling**

```python
# ❌ WRONG - Will crash with insufficient data
rsi = calculate_rsi(close_prices, 14)
if rsi < 30:  # TypeError if rsi is None!
    await ctx.buy_market(size=1)
```

**Anti-Pattern 4: Risk Nested in Params**

```yaml
# ❌ WRONG - Risk must be root-level
params:
  risk:  # VALIDATION ERROR!
    max_daily_loss: 500
```

**Anti-Pattern 5: Missing min_bars_cooldown**

```yaml
# ❌ WRONG - min_bars_cooldown is MANDATORY
params:
  rsi_period: 14
  # Missing min_bars_cooldown - REQUIRED!
```

---

## Interactive Question Flow

**STEP 1**: Ask user to select primary topic category (1-8)

**STEP 2**: Based on selection, ask follow-up question to narrow topic

**STEP 3**: Provide detailed answer with code examples

**STEP 4**: Ask if they want to:
- Learn more about current topic (deeper dive)
- Ask about related topic
- Return to main menu
- Exit

**Example Flow**:

```
User invokes: /strategy-sme

Q1: "What would you like to learn about TopStepX strategies?"
[Options: Architecture, Parameters, YAML Config, Orders, Indicators, Patterns, Issues, Examples]

User selects: "Architecture"

Q2: "Which architectural component do you want to explore?"
[Options: Base Class, StrategyContext, Lifecycle Hooks, on_bar Structure, Logging Standards]

User selects: "Logging Standards"

Answer: [Provide detailed logging standards with examples]

Q3: "What would you like to do next?"
[Options: Learn more logging, Related topic (StrategyContext), Main menu, Exit]
```

---

## Usage Instructions

**For Claude Invoking This Skill**:

1. **Always use AskUserQuestion** to guide the user through topics
2. **Provide complete, accurate answers** based on this knowledge base
3. **Include code examples** for all technical topics
4. **Reference canonical files** when appropriate:
   - `topstepx_backend/strategy/README.md`
   - `topstepx_backend/strategy/plugins/PLUGIN_TEMPLATE.py`
   - `topstepx_backend/strategy/base.py`
   - `topstepx_backend/strategy/context.py`

**For create-plugin and create-strategy Skills**:

When you need to ensure canonical standards, reference this skill:

```
"For authoritative guidance on [topic], consult the strategy-sme skill:
/strategy-sme → Select category → Get canonical answer"
```

---

## Key Takeaways

**Always**:
- Use inherited self.logger (NEVER create custom)
- Call ctx.on_bar() first in on_bar()
- Include min_bars_cooldown in YAML params
- Handle None from indicators defensively
- Nest exit/trailing/sizing policies in params
- Put risk limits at root level (NOT in params)

**Never**:
- Create custom logger with logging.getLogger(__name__)
- Forget to call ctx.on_bar() first
- Omit min_bars_cooldown from config
- Use indicator values without checking for None
- Nest risk in params (must be root-level)
- Use invalid timeframes or contract IDs

---

## Reference Files

**Canonical Documentation**:
- `topstepx_backend/strategy/README.md` - Official strategy documentation
- `topstepx_backend/strategy/plugins/PLUGIN_TEMPLATE.py` - Plugin template

**Architecture**:
- `topstepx_backend/strategy/base.py` - Strategy base class
- `topstepx_backend/strategy/context.py` - StrategyContext API
- `topstepx_backend/strategy/execution.py` - TradePlan pattern

**Schema & Validation**:
- `topstepx_backend/api/schemas/strategies.py` - Pydantic models
- `topstepx_backend/strategy/policies/__init__.py` - Policy dataclasses

**Production Examples**:
- `topstepx_backend/strategy/plugins/es_vwap_rsi_scalper_5m.py`
- `topstepx_backend/strategy/plugins/nq_orb_5m.py`
- `topstepx_backend/strategy/plugins/ym_rsi_mean_reversion_15m.py`

**Configuration**:
- `topstepx_backend/strategy/configs/strategies.yaml` - Working configs

---

**THIS SKILL IS THE SINGLE SOURCE OF TRUTH FOR TOPSTEPX STRATEGY DEVELOPMENT**

When in doubt, consult this skill. When creating plugins or configs, reference this skill to ensure canonical compliance.
