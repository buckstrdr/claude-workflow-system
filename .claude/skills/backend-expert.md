---
name: backend-expert
description: Interactive backend architecture expert - uses guided questions to help you explore and understand how the TopStepX backend works, including services, API routes, orchestrator, strategies, and data flow
---

# Backend Expert - Interactive Architecture Guide

## What This Skill Does

This skill acts as your interactive guide to the TopStepX backend architecture. Instead of searching blindly, it uses structured questions (via AskUserQuestion tool) to guide you to the exact information you need about how components work and wire together.

## When to Use

- When you need to understand a specific service or component
- When tracing how data flows through the system
- When figuring out where functionality lives
- When understanding API endpoint implementation
- When exploring strategy execution or order processing
- When learning how components are wired together

## How to Use

Simply run:
```
/backend-expert
```

The skill will guide you through interactive questions to find exactly what you're looking for.

## Backend Architecture Overview

The backend is organized into these main areas:

```
topstepx_backend/
├── api/routes/          # FastAPI endpoints (REST API)
├── services/            # Business logic services
├── orchestrator/        # Core engine & lifecycle management
├── strategy/            # Strategy framework & execution
├── persistence/         # Database (TimescaleDB)
├── market_data/         # Market data handling
├── networking/          # WebSocket communication
├── core/                # Core types & utilities
├── auth/                # Authentication
├── smc/                 # Smart Money Concepts
├── analytics/           # Analytics & reporting
└── tests/               # Test suite
```

## The Process

**IMPORTANT:** AskUserQuestion tool accepts maximum 4 options per question. Use cascading questions to drill down.

### Step 1: Initial Discovery

Ask what broad area they want to explore (max 4 options):

```json
{
  "question": "What aspect of the backend do you want to explore?",
  "header": "Area",
  "multiSelect": false,
  "options": [
    {
      "label": "API & Services",
      "description": "REST endpoints and business logic services"
    },
    {
      "label": "Core Engine",
      "description": "Orchestrator, lifecycle, and system coordination"
    },
    {
      "label": "Strategy System",
      "description": "Strategy framework, execution, and plugins"
    },
    {
      "label": "Data & Communication",
      "description": "Market data, WebSocket, persistence, networking"
    }
  ]
}
```

### Step 2: Drill Down Based on Selection

#### If "API & Services" selected:

```json
{
  "question": "Which area of API & Services?",
  "header": "Component",
  "multiSelect": false,
  "options": [
    {
      "label": "API Endpoints",
      "description": "Explore REST API routes in api/routes/"
    },
    {
      "label": "Order Services",
      "description": "Order service, submission, risk, idempotency"
    },
    {
      "label": "Market Services",
      "description": "Market data bridge, subscriptions, quotes"
    },
    {
      "label": "Support Services",
      "description": "Brackets, contracts, account store, analytics"
    }
  ]
}
```

Then drill deeper:
- **API Endpoints** → Orders, Positions, Strategies, Dashboard
- **Order Services** → order_service.py, order_submission_service.py, order_risk_middleware.py, order_idempotency_service.py
- **Market Services** → market_data_bridge.py, market_subscription_service.py
- **Support Services** → bracket_engine.py, contract_service.py, account_store.py, analytics_service.py

#### If "Core Engine" selected:

```json
{
  "question": "What aspect of the core engine?",
  "header": "Engine",
  "multiSelect": false,
  "options": [
    {
      "label": "Main Orchestrator",
      "description": "Engine initialization and main loop"
    },
    {
      "label": "Lifecycle Management",
      "description": "Startup, shutdown, and lifecycle coordination"
    },
    {
      "label": "Composition",
      "description": "How components wire together (compose.py, factories)"
    },
    {
      "label": "Task Supervision",
      "description": "Background tasks, schedulers, health checks"
    }
  ]
}
```

Key files to explore:
- **orchestrator/main.py** - Entry point and orchestrator class
- **orchestrator/engine.py** - Core engine logic
- **orchestrator/lifecycle.py** - Lifecycle management
- **orchestrator/compose.py** - Dependency injection and composition
- **orchestrator/factories.py** - Factory functions for creating components
- **orchestrator/task_supervisor.py** - Task supervision and error handling

#### If "Strategy System" selected:

```json
{
  "question": "What about strategies do you want to explore?",
  "header": "Strategy",
  "multiSelect": false,
  "options": [
    {
      "label": "Strategy Framework",
      "description": "Base classes, interfaces, plugin system"
    },
    {
      "label": "Strategy Execution",
      "description": "How strategies process data and generate signals"
    },
    {
      "label": "Strategy Lifecycle",
      "description": "Loading, initialization, starting, stopping"
    },
    {
      "label": "Creating Strategies",
      "description": "How to build new strategy plugins"
    }
  }
}
```

Key files:
- **strategy/** - Strategy framework directory
- **orchestrator/strategies.py** - Strategy orchestration
- Look for BaseStrategy or Strategy base classes

#### If "Data & Communication" selected:

```json
{
  "question": "Which data/communication system?",
  "header": "System",
  "multiSelect": false,
  "options": [
    {
      "label": "Market Data",
      "description": "Market data handling, quotes, bars, subscriptions"
    },
    {
      "label": "WebSocket/Networking",
      "description": "Real-time communication layer"
    },
    {
      "label": "Persistence",
      "description": "TimescaleDB integration and data storage"
    },
    {
      "label": "Data Flows",
      "description": "Trace how data moves through the system"
    }
  }
}
```

### Step 3: Explore the Component

Once the user has narrowed down to a specific component:

1. **Find the files:**
   ```python
   # Use Grep to find the component
   await Grep(pattern="class OrderService", path="topstepx_backend")
   ```

2. **Read the implementation:**
   ```python
   await Read(file_path="topstepx_backend/services/order_service.py")
   ```

3. **Find dependencies and usage:**
   ```python
   # Find where it's imported
   await Grep(pattern="from.*order_service import", path="topstepx_backend")

   # Find where it's instantiated
   await Grep(pattern="OrderService\\(", path="topstepx_backend")
   ```

4. **Show related components:**
   - Read the actual code
   - Show key methods with line numbers
   - Identify dependencies (what it imports)
   - Identify dependents (what imports it)
   - Show how it's wired in compose.py or factories.py

### Step 4: Trace Data Flow

If exploring data flow, trace through the system:

**Market Data Flow:**
```
Broker → networking/connection
       → market_data/handlers
       → market_data_bridge (services/)
       → strategies (via orchestrator)
       → WebSocket → Frontend
```

**Order Flow:**
```
Frontend/Strategy → api/routes/orders.py
                  → order_service.py
                  → order_submission_service.py
                  → order_risk_middleware.py
                  → order_idempotency_service.py
                  → networking/broker_connection
                  → Broker
                  → (fills back) → position updates → WebSocket → Frontend
```

For each step in the flow:
- Show the file and line number
- Show the key function/method
- Explain what happens at this step
- Show how data is transformed

### Step 5: Follow-Up

After showing the information, ask:

```json
{
  "question": "What would you like to do next?",
  "header": "Next",
  "multiSelect": false,
  "options": [
    {
      "label": "Related Component",
      "description": "Explore a dependency or related component"
    },
    {
      "label": "Trace Data Flow",
      "description": "Follow the data through the system"
    },
    {
      "label": "See Usage",
      "description": "Find where/how this is used"
    },
    {
      "label": "New Search",
      "description": "Start over with a new component"
    }
  ]
}
```

## Presentation Format

When presenting findings, use this format:

```markdown
## [Component Name]

**Location:** `topstepx_backend/path/to/file.py:123`

**Purpose:** Brief description of what it does

**Key Methods:**
- `method_name()` (line 45) - What it does
- `other_method()` (line 78) - What it does

**Dependencies:**
- Imports: List what it imports
- Used by: List what uses it

**Wiring:**
- Show how it's created in compose.py or factories.py
- Show how it's injected into other components

**Code Snippet:**
```python
# Show relevant code with line numbers
```
```

## Example Session

```
User: /backend-expert
Skill: What aspect of the backend do you want to explore?
  → User selects: API & Services

Skill: Which area of API & Services?
  → User selects: Order Services

Skill: Which order service?
  → User selects: Order Service (order_service.py)

Skill: [Finds and reads topstepx_backend/services/order_service.py]

## OrderService

**Location:** topstepx_backend/services/order_service.py:25

**Purpose:** Core order processing service - handles order submission, tracking, and lifecycle

**Key Methods:**
- submit_order() (line 45) - Submits new orders
- modify_order() (line 78) - Modifies existing orders
- cancel_order() (line 102) - Cancels orders

**Dependencies:**
- Imports: order_submission_service, order_risk_middleware, order_idempotency_service
- Used by: api/routes/orders.py, orchestrator strategies

**Wiring:**
- Created in: orchestrator/compose.py:123
- Injected into: Orchestrator via dependency injection

Skill: What would you like to do next?
  → User can explore related components, trace data flow, etc.
```

## Tips

- Start broad, then drill down with cascading questions
- Always show file paths with line numbers
- Use Grep and Read tools to explore actual code
- Trace dependencies by finding imports and instantiations
- Show how components are wired in compose.py/factories.py
- Offer follow-up options to continue exploring
