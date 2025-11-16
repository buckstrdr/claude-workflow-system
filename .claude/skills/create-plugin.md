---
name: create-plugin
description: Interactive Python strategy plugin creation with comprehensive subject matter expert guidance following TopStepX architecture patterns from real implementations
---

# TopStepX Strategy Plugin Creation - INTERACTIVE

**THIS IS AN INTERACTIVE SKILL** that guides you through creating a complete, production-ready TopStepX strategy plugin using the AskUserQuestion tool.

**FOR DETAILED TECHNICAL QUESTIONS**: Invoke the `/strategy-sme` skill which contains all subject matter expert knowledge and can answer specific questions about architecture, parameters, YAML config, indicators, patterns, and more.

---

## Interactive Creation Workflow (MAIN)

**WHEN THIS SKILL IS INVOKED**: Follow this interactive workflow to create a complete strategy plugin.

### Step 1: Gather Strategy Identity

Use AskUserQuestion to ask:

**Question 1: What is the strategy name and description?**
- **Prompt**: "What should we call this strategy? Please provide a descriptive name."
- **Example Answer**: "ES VWAP RSI Scalper 5m - Scalps ES using VWAP, RSI, and EMA confluence on 5-minute bars"

**Question 2: Target market and timeframe?**
- **Options**:
  - "Micro E-mini S&P (MES) - 5m"
  - "Micro E-mini Nasdaq (MNQ) - 5m"
  - "Micro E-mini Russell (M2K) - 15m"
  - "Micro E-mini Dow (MYM) - 5m"
  - Custom (user specifies)
- **Multiselect**: false

**Question 3: Strategy type?**
- **Options**:
  - "Momentum - Follow strong price moves with confirmation"
  - "Mean Reversion - Trade reversals at extremes"
  - "Trend Following - Ride established trends with filters"
  - "Scalping - Quick in/out on small moves"
  - "Opening Range Breakout - Trade breakouts from opening range"
- **Multiselect**: false

### Step 2: Gather Indicator Configuration

Use AskUserQuestion to ask:

**Question 4: Which indicators will you use?**
- **Options**:
  - "RSI - Relative Strength Index for momentum"
  - "EMA - Exponential Moving Average for trend"
  - "VWAP - Volume Weighted Average Price for intraday levels"
  - "ATR - Average True Range for volatility"
  - "Bollinger Bands - Volatility bands for extremes"
  - "ADX - Average Directional Index for trend strength"
  - "MACD - Moving Average Convergence Divergence"
  - "Stochastic - Oscillator for overbought/oversold"
- **Multiselect**: true (can select multiple)

For each selected indicator, ask:
- Period (default based on indicator type)
- Specific thresholds (e.g., RSI oversold/overbought levels)

### Step 3: Gather Entry/Exit Logic

Use AskUserQuestion to ask:

**Question 5: Long entry conditions?**
- **Prompt**: "Describe the conditions that should trigger a LONG entry. For example: 'RSI crosses below 30 AND price is above VWAP AND price is above EMA'"
- **Type**: Text input

**Question 6: Short entry conditions?**
- **Prompt**: "Describe the conditions that should trigger a SHORT entry. For example: 'RSI crosses above 70 AND price is below VWAP AND price is below EMA'"
- **Type**: Text input

**Question 7: Exit management?**
- **Options**:
  - "ATR-based - Stop loss and take profit based on ATR multiples"
  - "Fixed ticks - Fixed tick stops and targets"
  - "Exit policy from YAML - Use exit_policy configuration"
  - "Trailing stops - Trail stop loss as price moves favorably"
- **Multiselect**: false

If "ATR-based" selected:
- Ask for stop loss multiplier (default: 2.0)
- Ask for take profit multiplier (default: 3.0)

### Step 4: Gather Risk Parameters

Use AskUserQuestion to ask:

**Question 8: Risk management settings?**
- **Options**:
  - "Conservative - 3 trades/day, 5 bar cooldown, RTH only"
  - "Moderate - 5 trades/day, 3 bar cooldown, RTH only"
  - "Aggressive - 10 trades/day, 2 bar cooldown, extended hours"
  - "Custom - I'll specify each parameter"
- **Multiselect**: false

If "Custom" selected:
- Max daily trades (default: 5)
- Min bars cooldown (default: 5)
- Session filter enabled (default: true)
- Session hours if enabled (default: 9:30-16:00 ET)

**Question 9: Position sizing?**
- **Options**:
  - "Fixed 1 contract - Simple, always trade 1 contract"
  - "Fixed 2 contracts - Slightly larger, always 2 contracts"
  - "Dynamic based on volatility - Adjust size based on ATR"
- **Multiselect**: false

### Step 5: Generate Complete Plugin Code

Based on all answers, generate the complete strategy plugin with:

1. **File naming**: `{symbol}_{indicators}_{timeframe}.py`
   - Example: `es_vwap_rsi_scalper_5m.py`

2. **Class naming**: `{Symbol}{Indicators}{Timeframe}` (PascalCase)
   - Example: `ESVWAPRSIScalper5m`

3. **Complete structure**:
   - Imports
   - PARAM_MODEL with all parameters (following canonical standards from strategy-sme)
   - Strategy class with:
     - `__init__` method
     - `on_bar` method (5-phase structure from strategy-sme)
     - `on_start` method
     - `on_stop` method
   - Lowercase export

4. **Code generation rules**:
   - Use inherited `self.logger` (NEVER create custom logger)
   - Call `ctx.on_bar()` as first line in on_bar()
   - Follow 5-phase on_bar() structure:
     1. State updates (bar buffer, daily reset)
     2. Pre-flight checks (min bars, session, limits, cooldown, position)
     3. Indicator calculation (with None handling)
     4. Signal generation (clear boolean logic)
     5. Order execution (update state on success)
   - All parameters use Field() with title (2-3 words, Title Case, NO units) and description (multi-sentence)
   - Handle None returns from all indicators
   - Check position before entering
   - Update state on successful orders
   - Use structured logging via ctx.log_event()

5. **Reference canonical patterns from strategy-sme**:
   - For detailed logging standards: `/strategy-sme` → Architecture
   - For parameter standards: `/strategy-sme` → Parameters
   - For on_bar() structure: `/strategy-sme` → Production Patterns
   - For indicator usage: `/strategy-sme` → Indicators

### Step 6: Generate YAML Configuration (Optional)

After generating the plugin code, ask:

**Question 10: Should I generate a YAML configuration for this strategy?**
- **Options**:
  - "Yes - Generate complete YAML config"
  - "No - I'll create it manually later"
- **Multiselect**: false

If "Yes":
- Generate complete YAML config following canonical schema (reference strategy-sme)
- Include exit_policy, trailing_policy, sizing_policy (all NESTED in params)
- Include risk section (SEPARATE from params)
- Include min_bars_cooldown (MANDATORY in params)

### Step 7: Generate Test Scaffold (Optional)

After generating plugin and optional YAML, ask:

**Question 11: Should I generate a test scaffold?**
- **Options**:
  - "Yes - Generate unit tests and smoke test script"
  - "No - I'll write tests later"
- **Multiselect**: false

If "Yes":
- Generate `tests/strategy/plugins/test_{filename}.py` with:
  - Test initialization
  - Test parameter validation
  - Test on_bar logic (skeleton)
- Generate `dev/smoke/test_{strategy_id}_smoke.py` for backtesting

### Step 8: Summary and Next Steps

After code generation, provide:

1. **Files created**:
   - Plugin file location
   - YAML config location (if generated)
   - Test file location (if generated)

2. **Verification checklist**:
   - [ ] Plugin imports successfully: `python -c "from topstepx_backend.strategy.plugins.{module} import {ClassName}"`
   - [ ] YAML validates: Load config and check for errors
   - [ ] Tests pass: `pytest tests/strategy/plugins/test_{filename}.py`

3. **Next steps**:
   - "Run `make openapi && make types` to update API schema and frontend types"
   - "Test strategy with: `python -m topstepx_backend`"
   - "For detailed technical questions, invoke `/strategy-sme`"

4. **Offer additional help**:
   - "Would you like me to:"
     - "Explain any part of the generated code?"
     - "Create additional test cases?"
     - "Customize the entry/exit logic further?"
     - "Generate documentation for this strategy?"

---

## Reference Knowledge

**The following sections contain comprehensive SME knowledge for reference. For interactive Q&A on these topics, use `/strategy-sme` skill.**

---

## Table of Contents (Reference)

1. [Critical Reference Files](#critical-reference-files)
2. [Architecture Overview](#architecture-overview)
3. [Mandatory Architecture Rules](#mandatory-architecture-rules)
4. [Strategy Base Class](#strategy-base-class)
5. [StrategyContext API Reference](#strategycontext-api-reference)
6. [Parameter Definition Standards](#parameter-definition-standards)
7. [Canonical on_bar() Structure](#canonical-on_bar-structure)
8. [Lifecycle Hooks](#lifecycle-hooks)
9. [Indicator Library](#indicator-library)
10. [Order Submission Patterns](#order-submission-patterns)
11. [Real-World Examples](#real-world-examples)
12. [Testing and Validation](#testing-and-validation)
13. [Common Patterns and Anti-Patterns](#common-patterns-and-anti-patterns)
14. [Complete Implementation Checklist](#complete-implementation-checklist)

---

## Critical Reference Files

**CONSULT BEFORE GENERATING CODE:**
- `topstepx_backend/strategy/README.md` - Canonical schema & configuration rules
- `topstepx_backend/strategy/plugins/PLUGIN_TEMPLATE.py` - Official template with parameter guidelines
- `topstepx_backend/strategy/base.py` - Strategy base class & logger inheritance
- `topstepx_backend/strategy/context.py` - StrategyContext API (complete reference)
- `topstepx_backend/strategy/execution.py` - TradePlan pattern & place_order() helper
- `topstepx_backend/strategy/indicators.py` - Available indicators with signatures
- `topstepx_backend/strategy/policies/` - Exit policy calculators and trailing brackets

**REAL IMPLEMENTATIONS (study these patterns):**
- `topstepx_backend/strategy/plugins/es_vwap_rsi_scalper_5m.py` - VWAP + RSI + EMA scalping
- `topstepx_backend/strategy/plugins/nq_orb_5m.py` - Opening Range Breakout with state tracking
- `topstepx_backend/strategy/plugins/ym_rsi_mean_reversion_15m.py` - RSI mean reversion with crossover

---

## Architecture Overview

### Component Hierarchy

```
Strategy (ABC)
  ├── PARAM_MODEL: BaseModel (Pydantic parameter validation)
  ├── self.logger: logging.Logger (inherited, auto-named)
  ├── self.strategy_id: str (unique identifier)
  ├── self.params: PARAM_MODEL instance (validated parameters)
  └── Lifecycle methods:
      ├── async on_start(ctx: StrategyContext)
      ├── async on_bar(bar: Bar, ctx: StrategyContext)  ← MAIN LOGIC
      ├── async on_boundary(timeframe: str, ctx: StrategyContext)
      └── async on_stop(ctx: StrategyContext)
```

### Data Flow

```
Bar arrives → on_bar() → State updates → Pre-flight checks → Indicators →
Signal generation → Order submission → State tracking
```

### Key Principles

1. **Inheritance over Composition**: Strategies inherit from `Strategy` base class
2. **Dependency Injection**: All external dependencies injected via `StrategyContext`
3. **Immutable Parameters**: Parameters validated once at init, never modified
4. **Stateful Execution**: Strategies maintain internal state (bar buffer, trade counters, etc.)
5. **Event-Driven**: Reacts to bars, doesn't poll or loop
6. **Fail-Safe**: Early returns on invalid conditions, defensive programming

---

## Mandatory Architecture Rules

### 1. Logging (NEVER VIOLATE)

**CRITICAL**: All strategies inherit `self.logger` from `Strategy` base class. NEVER create a custom logger.

```python
# ✅ CORRECT - Use inherited logger
class MyStrategy(Strategy):
    def __init__(self, strategy_id: str, params: dict[str, Any]) -> None:
        super().__init__(strategy_id, params)
        # self.logger is now available - automatically named: {module}.{strategy_id}

    async def on_bar(self, bar: Bar, ctx: StrategyContext) -> None:
        self.logger.info(f"Signal: {signal}")  # Use inherited logger
        self.logger.debug(f"Calculation: RSI={rsi:.2f}")
        ctx.log_event("info", "strategy.signal", price=bar.close)  # Structured logging

# ❌ WRONG - FORBIDDEN PATTERNS
self.log = logging.getLogger(__name__)  # NEVER DO THIS!
logger = logging.getLogger(__name__)  # NEVER DO THIS!
```

**Logger Naming Convention**: Automatically set to `{module}.{strategy_id}` by base class.

**Logging Levels**:
- `self.logger.info()` - Important events (signals, orders, lifecycle events)
- `self.logger.debug()` - Detailed diagnostics (calculations, position checks, rejection reasons)
- `self.logger.warning()` - Recoverable issues (missing indicators, unexpected states)
- `self.logger.error()` - Errors that prevent execution

**Structured Event Logging**:
```python
ctx.log_event("info", "strategy.signal.long",
              price=float(bar.close),
              rsi=float(rsi),
              ema=float(ema))
```

### 2. PARAM_MODEL Requirement

**CRITICAL**: Every strategy MUST have a `PARAM_MODEL` class attribute pointing to a Pydantic BaseModel.

```python
from pydantic import BaseModel, Field

class MyStrategyParams(BaseModel):
    """Parameters for MyStrategy."""
    rsi_period: int = Field(default=14, ge=3, le=50)
    max_daily_trades: int = Field(default=5, ge=1, le=20)

class MyStrategy(Strategy):
    PARAM_MODEL = MyStrategyParams  # MANDATORY class attribute

    def __init__(self, strategy_id: str, params: dict[str, Any]) -> None:
        super().__init__(strategy_id, params)
        self.params = MyStrategyParams(**params)  # Validate on init
```

### 3. Parameter Field Standards

**MANDATORY**: All parameters must use `Field()` with proper title and description.

```python
# ✅ CORRECT Parameter Definition
rsi_period: int = Field(
    default=14,  # Sensible default that works out of the box
    ge=3,  # Minimum value validation
    le=50,  # Maximum value validation
    title="RSI Period",  # 2-3 words, Title Case, NO units in title
    description=(
        "Period for RSI calculation. "  # What it does
        "Standard value is 14. "  # Standard/recommended value
        "Lower values (3-7) are more sensitive and better for scalping, "  # Trade-offs
        "higher values (14-21) provide stronger confirmation but lag more."
    ),
)

# ✅ CORRECT Boolean Parameter
session_filter: bool = Field(
    default=True,
    title="Session Filter",
    description=(
        "Only trade during regular trading hours (RTH: 9:30-16:00 ET). "
        "Disable for strategies that work in extended hours or 24-hour markets."
    ),
)

# ✅ CORRECT Float Parameter with Percentage
rsi_oversold: float = Field(
    default=30.0,
    ge=10.0,
    le=40.0,
    title="RSI Oversold",
    description=(
        "RSI threshold for long entry signals. "
        "Standard value is 30. "
        "Lower values (10-20) generate fewer signals but stronger reversals, "
        "higher values (30-40) generate more signals but weaker reversals."
    ),
)

# ❌ WRONG - No Field(), no validation
rsi_period: int = 14  # Missing Field(), title, description

# ❌ WRONG - Units in title
rsi_period: int = Field(default=14, title="RSI Period (bars)")  # Don't include units

# ❌ WRONG - Vague description
rsi_period: int = Field(default=14, title="RSI Period",
                       description="RSI period")  # Too brief, no context
```

**Parameter Naming Convention**:
- Use snake_case: `rsi_period`, `max_daily_trades`, `atr_stop_multiplier`
- Pattern: `{concept}_{measurement}_{unit}` (e.g., `atr_stop_multiplier`, `session_start_hour`)
- Boolean flags: `{action}_enabled`, `{feature}_filter` (e.g., `session_filter`, `trailing_enabled`)

**Parameter Grouping** (in BaseModel):
```python
class MyStrategyParams(BaseModel):
    """Parameters for MyStrategy."""

    # Indicator Settings
    rsi_period: int = Field(...)
    rsi_oversold: float = Field(...)
    rsi_overbought: float = Field(...)

    # Risk Management
    max_daily_trades: int = Field(...)
    min_bars_cooldown: int = Field(...)

    # Entry/Exit
    atr_period: int = Field(...)
    atr_stop_multiplier: float = Field(...)
    atr_target_multiplier: float = Field(...)

    # Position Sizing
    position_size: int = Field(...)

    # Session Filter
    session_filter: bool = Field(...)
    session_start_hour: int = Field(...)
    session_end_hour: int = Field(...)
```

### 4. Imports and Module Structure

**Standard imports for all strategies:**

```python
from __future__ import annotations  # Allow forward references

import logging
from typing import Any
from datetime import datetime

from pydantic import BaseModel, Field

from topstepx_backend.data.types import Bar
from topstepx_backend.strategy.base import Strategy
from topstepx_backend.strategy.context import StrategyContext
from topstepx_backend.strategy.indicators import (
    calculate_rsi,
    calculate_ema,
    calculate_atr,
    calculate_vwap,
    # ... other indicators as needed
)

logger = logging.getLogger(__name__)  # Module-level logger for module operations
```

**CRITICAL**: The module-level `logger` is for module-level operations. The strategy instance uses `self.logger` inherited from base class.

### 5. File Naming and Export

**File naming**: `{symbol}_{indicators}_{timeframe}.py` (snake_case)
- Examples: `es_vwap_rsi_scalper_5m.py`, `nq_orb_5m.py`, `ym_rsi_mean_reversion_15m.py`

**Class naming**: `{Symbol}{Indicators}{Timeframe}` (PascalCase)
- Examples: `ESVWAPRSIScalper5m`, `NQOpeningRangeBreakout5m`, `YMRSIMeanReversion15m`

**Export (at bottom of file)**:
```python
# Lowercase export matching filename (without .py)
es_vwap_rsi_scalper_5m = ESVWAPRSIScalper5m
```

---

## Strategy Base Class

### Base Class Definition (`topstepx_backend/strategy/base.py`)

```python
from abc import ABC, abstractmethod
import logging
from typing import Any, TYPE_CHECKING

if TYPE_CHECKING:
    from topstepx_backend.data.types import Bar
    from topstepx_backend.strategy.context import StrategyContext

class Strategy(ABC):
    """Abstract base class for all trading strategies."""

    def __init__(self, strategy_id: str, params: dict[str, Any]) -> None:
        """Initialize strategy with ID and parameters.

        Args:
            strategy_id: Unique identifier for this strategy instance
            params: Dictionary of parameters (validated by PARAM_MODEL)
        """
        self.strategy_id = strategy_id
        self.params = params
        # CRITICAL: Logger is created here and automatically named
        self.logger = logging.getLogger(f"{self.__class__.__module__}.{strategy_id}")
        self._running = False
        self._initialized = False

    @abstractmethod
    async def on_bar(self, bar: Bar, ctx: "StrategyContext") -> None:
        """Main strategy logic - called for each bar.

        MUST call ctx.on_bar() as first line to increment cooldown counter.
        """
        pass

    async def on_start(self, ctx: "StrategyContext") -> None:
        """Called once when strategy starts. Override to log initial state."""
        pass

    async def on_boundary(self, timeframe: str, ctx: "StrategyContext") -> None:
        """Called when timeframe boundary crossed (optional)."""
        pass

    async def on_stop(self, ctx: "StrategyContext") -> None:
        """Called once when strategy stops. Override to log final state."""
        pass
```

### Inheriting from Strategy

```python
class MyStrategy(Strategy):
    """My custom strategy implementation."""

    PARAM_MODEL = MyStrategyParams  # MANDATORY

    def __init__(self, strategy_id: str, params: dict[str, Any]) -> None:
        super().__init__(strategy_id, params)  # ← Inherits self.logger!

        # Validate and store params
        self.params = MyStrategyParams(**params)

        # Initialize strategy state
        self.bar_buffer: list[dict[str, Any]] = []
        self.daily_trades: int = 0
        self.last_trade_date: str | None = None

        # DO NOT create logger here - already inherited as self.logger

    async def on_bar(self, bar: Bar, ctx: StrategyContext) -> None:
        ctx.on_bar()  # MUST be first line
        # ... strategy logic
```

---

## StrategyContext API Reference

**For complete StrategyContext documentation, invoke `/strategy-sme` and select "Order Management" or "Architecture".**

### Core Methods

```python
# Cooldown tracking
ctx.on_bar()  # MUST be first line in on_bar()
ctx.is_cooldown_active(min_bars_cooldown: int) -> bool

# Market orders with brackets
await ctx.buy_market(size, stop_loss=None, take_profit=None, time_type=0, ...)
await ctx.sell_market(size, stop_loss=None, take_profit=None, time_type=0, ...)

# Limit orders
await ctx.buy_limit(size, price, time_in_force="DAY", ...)
await ctx.sell_limit(size, price, time_in_force="DAY", ...)

# Position management
position = ctx.risk_manager.get_strategy_position(strategy_id, account_id, contract_id)

# Structured logging
ctx.log_event(level, event, **fields)
```

---

## Canonical on_bar() Structure

**ALL strategies MUST follow this 5-phase structure:**

```python
async def on_bar(self, bar: Bar, ctx: StrategyContext) -> None:
    """Main strategy logic - called for each bar.

    Five-phase structure:
    1. State updates (bar buffer, cooldown, daily reset)
    2. Pre-flight checks (min bars, session, limits, position)
    3. Indicator calculation (RSI, EMA, ATR, etc.)
    4. Signal generation (long/short conditions)
    5. Order execution (submit orders, update state)
    """

    # ═══════════════════════════════════════════════════════════
    # PHASE 1: State Updates
    # ═══════════════════════════════════════════════════════════

    # MANDATORY: Increment cooldown counter (MUST be first line)
    ctx.on_bar()

    # Update bar buffer
    self.bar_buffer.append({
        "open": bar.open,
        "high": bar.high,
        "low": bar.low,
        "close": bar.close,
        "volume": bar.volume,
        "bar_time": bar.bar_time,
    })

    # Maintain buffer size (pop oldest if exceeded)
    if len(self.bar_buffer) > self.params.bar_buffer_size:
        self.bar_buffer.pop(0)

    # Daily reset check (reset counters at start of new trading day)
    current_date = bar.bar_time.strftime("%Y-%m-%d")
    if current_date != self.last_trade_date:
        self.daily_trades = 0
        self.last_trade_date = current_date
        self.logger.info(f"Daily reset: {current_date}")
        ctx.log_event("info", "strategy.daily_reset", date=current_date)

    # ═══════════════════════════════════════════════════════════
    # PHASE 2: Pre-flight Checks (Early Returns)
    # ═══════════════════════════════════════════════════════════

    # Check minimum bars for indicator calculation
    min_bars = max(self.params.rsi_period, self.params.ema_period, self.params.atr_period) + 1
    if len(self.bar_buffer) < min_bars:
        self.logger.debug(f"Insufficient bars: {len(self.bar_buffer)}/{min_bars}")
        return

    # Session filter (trade only during specified hours)
    if self.params.session_filter:
        current_hour = bar.bar_time.hour
        current_minute = bar.bar_time.minute
        current_time_minutes = current_hour * 60 + current_minute
        session_start = self.params.session_start_hour * 60 + self.params.session_start_minute
        session_end = self.params.session_end_hour * 60 + self.params.session_end_minute

        if not (session_start <= current_time_minutes < session_end):
            self.logger.debug(f"Outside session: {current_hour}:{current_minute:02d}")
            return

    # Check daily trade limit
    if self.daily_trades >= self.params.max_daily_trades:
        self.logger.debug(f"Daily trade limit reached: {self.daily_trades}/{self.params.max_daily_trades}")
        return

    # Check cooldown (prevent order spam)
    if ctx.is_cooldown_active(self.params.min_bars_cooldown):
        self.logger.debug(f"Cooldown active: {ctx.bars_since_last_order}/{self.params.min_bars_cooldown}")
        return

    # Check current position (only enter when flat)
    current_position = ctx.risk_manager.get_strategy_position(
        ctx.strategy_id, ctx.account_id, ctx.contract_id
    )
    if current_position != 0:
        self.logger.debug(f"Already in position: {current_position}")
        return

    # ═══════════════════════════════════════════════════════════
    # PHASE 3: Indicator Calculation
    # ═══════════════════════════════════════════════════════════

    # Extract price data
    close_prices = [b["close"] for b in self.bar_buffer]

    # Calculate RSI
    rsi = calculate_rsi(close_prices, self.params.rsi_period)
    if rsi is None:
        self.logger.debug("RSI calculation returned None")
        return

    # Calculate EMA
    ema = calculate_ema(close_prices, self.params.ema_period)
    if ema is None:
        self.logger.debug("EMA calculation returned None")
        return

    # Calculate ATR (for stop loss and take profit)
    atr = calculate_atr(self.bar_buffer, self.params.atr_period)
    if atr is None:
        self.logger.debug("ATR calculation returned None")
        return

    # Cache ATR for exit policy calculations
    ctx._current_atr = atr

    # Current price
    current_price = bar.close

    self.logger.debug(
        f"Indicators: RSI={rsi:.2f}, EMA={ema:.2f}, ATR={atr:.2f}, Price={current_price:.2f}"
    )

    # ═══════════════════════════════════════════════════════════
    # PHASE 4: Signal Generation
    # ═══════════════════════════════════════════════════════════

    # Define long signal conditions
    long_signal = (
        rsi < self.params.rsi_oversold and  # RSI oversold
        current_price > ema  # Price above EMA (uptrend confirmation)
    )

    # Define short signal conditions
    short_signal = (
        rsi > self.params.rsi_overbought and  # RSI overbought
        current_price < ema  # Price below EMA (downtrend confirmation)
    )

    # ═══════════════════════════════════════════════════════════
    # PHASE 5: Order Execution
    # ═══════════════════════════════════════════════════════════

    # Execute long signal
    if long_signal:
        stop_loss = current_price - (atr * self.params.atr_stop_multiplier)
        take_profit = current_price + (atr * self.params.atr_target_multiplier)

        self.logger.info(
            f"LONG signal: Price={current_price:.2f}, RSI={rsi:.2f}, "
            f"SL={stop_loss:.2f}, TP={take_profit:.2f}"
        )

        success = await ctx.buy_market(
            size=self.params.position_size,
            stop_loss=stop_loss,
            take_profit=take_profit,
            time_type=0,  # DAY order
        )

        if success:
            self.daily_trades += 1
            ctx.log_event(
                "info",
                "strategy.signal.long",
                price=float(current_price),
                rsi=float(rsi),
                ema=float(ema),
                atr=float(atr),
                stop_loss=float(stop_loss),
                take_profit=float(take_profit),
            )

    # Execute short signal
    elif short_signal:
        stop_loss = current_price + (atr * self.params.atr_stop_multiplier)
        take_profit = current_price - (atr * self.params.atr_target_multiplier)

        self.logger.info(
            f"SHORT signal: Price={current_price:.2f}, RSI={rsi:.2f}, "
            f"SL={stop_loss:.2f}, TP={take_profit:.2f}"
        )

        success = await ctx.sell_market(
            size=self.params.position_size,
            stop_loss=stop_loss,
            take_profit=take_profit,
            time_type=0,  # DAY order
        )

        if success:
            self.daily_trades += 1
            ctx.log_event(
                "info",
                "strategy.signal.short",
                price=float(current_price),
                rsi=float(rsi),
                ema=float(ema),
                atr=float(atr),
                stop_loss=float(stop_loss),
                take_profit=float(take_profit),
            )
```

---

## Indicator Library

**For complete indicator documentation with examples, invoke `/strategy-sme` and select "Indicators".**

### Available Indicators

```python
from topstepx_backend.strategy.indicators import (
    # Momentum
    calculate_rsi,  # Relative Strength Index
    calculate_macd,  # Moving Average Convergence Divergence
    calculate_stochastic,  # Stochastic Oscillator

    # Trend
    calculate_ema,  # Exponential Moving Average
    calculate_sma,  # Simple Moving Average
    calculate_adx,  # Average Directional Index

    # Volatility
    calculate_atr,  # Average True Range
    calculate_bollinger_bands,  # Bollinger Bands

    # Volume
    calculate_vwap,  # Volume Weighted Average Price

    # Support/Resistance
    calculate_pivot_points,  # Standard pivot points
)
```

**All indicators return `None` if insufficient data. ALWAYS handle None returns.**

---

## Complete Implementation Checklist

### Code Structure
- [ ] Imports correct (no unused imports)
- [ ] PARAM_MODEL class attribute set
- [ ] Uses inherited self.logger (NEVER creates custom logger)
- [ ] All lifecycle methods present (on_start, on_bar, on_stop)
- [ ] Lowercase export at bottom of file
- [ ] Type hints on all functions and methods
- [ ] Proper async/await syntax throughout

### Parameters
- [ ] All parameters use Field() with title + description
- [ ] Title: 2-3 words, Title Case, NO units
- [ ] Description: Multi-sentence with what/standard/trade-offs
- [ ] Validation constraints appropriate (ge, le, pattern)
- [ ] Sensible defaults that work out of the box
- [ ] Parameters grouped logically with comments

### on_bar() Structure
- [ ] Follows 5-phase structure exactly
- [ ] ctx.on_bar() called first (Phase 1)
- [ ] Bar buffer maintained with size limit (Phase 1)
- [ ] Daily reset logic implemented (Phase 1)
- [ ] Minimum bars check before indicators (Phase 2)
- [ ] Session filter applied if needed (Phase 2)
- [ ] Daily trade limit enforced (Phase 2)
- [ ] Cooldown check using ctx.is_cooldown_active() (Phase 2)
- [ ] Position check prevents multiple entries (Phase 2)
- [ ] Indicators calculated with None handling (Phase 3)
- [ ] ATR cached for exit policy (Phase 3)
- [ ] Clear signal generation logic (Phase 4)
- [ ] Orders submitted via ctx methods (Phase 5)
- [ ] State updated on successful orders (Phase 5)

### Logging and Events
- [ ] Structured logging via ctx.log_event()
- [ ] on_start() logs initial parameters
- [ ] on_stop() logs final statistics
- [ ] Signal events logged with relevant data
- [ ] Debug logging for rejected signals

### Testing
- [ ] Unit tests for parameter validation
- [ ] Unit tests for strategy initialization
- [ ] Integration tests with mock context
- [ ] Smoke tests with historical data (optional)

---

## Common Patterns and Anti-Patterns

### ✅ CORRECT Patterns

**1. Use inherited logger**
```python
self.logger.info("Message")
```

**2. Call ctx.on_bar() first**
```python
async def on_bar(self, bar: Bar, ctx: StrategyContext) -> None:
    ctx.on_bar()  # FIRST LINE
    # ... rest of logic
```

**3. Handle None returns from indicators**
```python
rsi = calculate_rsi(prices, period)
if rsi is None:
    return  # Early return
```

**4. Check position before entering**
```python
current_position = ctx.risk_manager.get_strategy_position(...)
if current_position != 0:
    return
```

**5. Update state on successful orders**
```python
success = await ctx.buy_market(...)
if success:
    self.daily_trades += 1
```

### ❌ ANTI-PATTERNS (Avoid These)

**1. Creating custom logger**
```python
# ❌ WRONG
self.log = logging.getLogger(__name__)
```

**2. Forgetting ctx.on_bar()**
```python
# ❌ WRONG - Cooldown won't work
async def on_bar(self, bar: Bar, ctx: StrategyContext) -> None:
    # Missing ctx.on_bar()
    ...
```

**3. Not handling None from indicators**
```python
# ❌ WRONG - Will crash if None
rsi = calculate_rsi(prices, period)
if rsi < 30:  # Error if rsi is None!
    ...
```

**4. Entering without checking position**
```python
# ❌ WRONG - Can enter multiple times
if signal:
    await ctx.buy_market(...)  # No position check!
```

**5. Not updating state after orders**
```python
# ❌ WRONG - daily_trades never increments
await ctx.buy_market(...)
# Missing: self.daily_trades += 1
```

---

## Summary

**This skill provides an interactive workflow for creating TopStepX strategy plugins using AskUserQuestion.**

**For detailed technical questions during plugin creation:**
- Invoke `/strategy-sme` for comprehensive SME knowledge
- Topics: Architecture, Parameters, YAML Config, Indicators, Patterns, Anti-Patterns

**Key Architecture Rules (NEVER VIOLATE)**:
1. Use inherited `self.logger` (NEVER create custom logger)
2. PARAM_MODEL is MANDATORY (Pydantic BaseModel)
3. Call `ctx.on_bar()` first in on_bar() method
4. Follow 5-phase on_bar() structure
5. Handle None returns from all indicators
6. Check position before entering trades
7. Update state on successful orders
8. Use structured logging via ctx.log_event()

**Interactive workflow ensures:**
- Canonical compliance (logging, parameters, structure)
- Production-ready code generation
- Complete testing scaffolds
- YAML configuration generation
- Proper documentation

**Start the workflow by invoking this skill. It will guide you through all steps using AskUserQuestion.**
