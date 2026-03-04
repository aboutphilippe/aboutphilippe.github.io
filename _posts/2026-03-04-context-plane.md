---
layout: post
title: "Context Plane — A Point of View"
---

# Context Plane — A Point of View

Goal: introduce my perspective on context plane for AI agents, sketch an architecture I believe in, and share early findings and benchmarks.

---

## Why I care about context plane

AI agents need context. Not “more tokens” — **the right context**, for the right entity, at the right time. Today we often solve that by stuffing prompts, calling five APIs, or maintaining a separate “context service” that nobody wants to own. I think there’s a cleaner primitive: a **context plane** — a deterministic, read-optimized view of an entity’s timeline that agents can query with one mental model and one API.

This post is my hello world for that idea: what I mean by a context plane, what architecture I’m betting on, and what the numbers look like so far.

---

## What is a context plane?

A **context plane** is a snapshot of everything we know about an entity (a user, a company, a lead, an agent) in a form that’s easy to search and easy to materialize for an LLM. The entity has a **timeline**: immutable events, documents, messages, state changes. The plane is the read-optimized index over that timeline — so an agent can ask *“Give me the best context for user X”* or *“What do we know about account Y?”* without reaching into a dozen systems.

Two properties matter to me:

1. **Entity-first.** The primary key is the entity. Namespace per account, per user, per lead — not one giant corpus with filters after the fact. That matches how GTM and support and product teams actually think: “this account,” “this user.”
2. **Deterministic materialization.** Given a query (text, vector, filters, time window), we can produce a reproducible context bundle — e.g. a schema like `customer_context_v0` — that an agent consumes. No ad-hoc stitching at query time.

If that sounds like “search + entity-scoped index,” it is — with an opinion: the source of truth is **append-only timeline segments** and **immutable index shards**, not a live database. That leads to a specific architecture.

---

## An architecture I believe in

I want the system to be **object-storage-first** and **stateless at the query layer**. So:

- **Write path:** Ingest writes immutable segments (e.g. JSONL + zstd) per entity per day to object storage (S3 or local). An indexer (can be separate, can scale) builds BM25 and vector (HNSW) shards per tenant per day and writes them back to object storage. No primary database; object storage is the system of record.
- **Read path:** Query nodes are stateless. They load shards and segments into memory or local disk cache on demand. They can be restarted, scaled out, or rebuilt from object storage at any time. No coordination for “which node has which shard” — just cache fill and eviction.
- **Cold/warm economics:** Only a subset of entities are hot at any moment. Hot entities get fast, cached retrieval; cold ones are still queryable from object storage with higher latency. Cost scales with how much you cache, not with “index everything in RAM.”

Concretely:

```
Sources → Contextplane API → Immutable segments (JSONL + zstd) → Object storage
                                                                    ↓
                                    Indexer → BM25 + HNSW shards → Object storage
                                                                    ↓
Stateless query nodes ← load shards/segments into cache ←────────────┘
         ↓
Agent / App (query + entity context)
```

Storage layout stays simple and auditable:

- **Timeline segments:** `tenants/{tenant}/entities/{entity}/segments/{yyyy}/{mm}/{dd}/{id}.jsonl.zst`
- **Index shards:** `tenants/{tenant}/indexes/fulltext/{yyyy}/{mm}/{dd}/shard.json.zst` and same for `vector/`

Cheap append-only writes, lifecycle-friendly for S3, and easy to reason about for multi-tenant and compliance.

---

## Who is this for?

A good reference use case is what Vercel’s GTM team did with their corpus ([turbopuffer Vercel case study](https://turbopuffer.com/customers/vercel)): Gong, Slack, Salesforce per Salesforce account, so AI lead agents can search an account’s full history at runtime. One index per account, hybrid (BM25 + vector) search, agents with a search tool. Context plane target that same shape: **entity = account/user/lead**, **namespace per entity**, **hybrid search**, **cold/warm economics**. Internal tools, GTM, support, and product — anywhere “give me the best context for this entity” is the question.

---

## Early findings

I’ve been building and benchmarking an implementation in this direction. A few lessons so far.

**Warm path is in good shape.** For vector-only and text-only queries at modest QPS, latency is where I’d hope: single-digit to low tens of milliseconds (e.g. vector warm ~2.8 ms p50, text warm ~4.7 ms p50 at 10k docs, 40 QPS). Hybrid warm is a bit higher but still reasonable (~27 ms p50). So the core “load shard, run BM25 + vector, merge” path works.

**Cold and filter-heavy paths dominate the pain.** When shards aren’t cached or when we add heavy filters (e.g. many entity IDs, time ranges), tail latency blows up — e.g. hybrid cold p99 in the tens of seconds in early runs. That’s the main gap vs. “napkin math”: cache locality and filter evaluation cost. So the next bets are filter-first candidate reduction, better shard prefetch, and keeping hot loops SIMD-friendly (more below).

**Zero-cost abstractions can still hide cost.** I’ve been re-reading work like [turbopuffer’s post on zero-cost abstractions vs. SIMD](https://turbopuffer.com/blog/zero-cost): iterators that return one element per `next()` can prevent the compiler from vectorizing. The fix is batched iterators and tight loops over contiguous data. We don’t have an LSM-style merge iterator yet, but the lesson holds: **profile first**, then look at LLVM IR or flame graphs when the numbers don’t match the model. Mechanical sympathy beats trusting the abstraction.

---

## Benchmarks (early 2026)

All from a single machine, same benchmark harness; methodology in the repo. Summary:

| Scenario              | Dataset | p50    | p99      | Note                    |
|-----------------------|--------|--------|----------|-------------------------|
| Vector warm           | 10k, dim 64 | 2.80 ms | 15.17 ms | Strong baseline         |
| Text warm             | 10k    | 4.74 ms | 18.18 ms | Strong baseline         |
| Hybrid warm           | 10k    | 27.65 ms | 130.05 ms | Usable                  |
| Hybrid cold           | 10k    | 71.17 ms | **28.7 s** | Tail is the problem     |
| Vector (100k, 100d)   | glove-style | 2.54 ms | 18.94 ms | Scales okay             |
| Hybrid + filters (100k, 384d) | arxiv-style | 4.00 ms | 630 ms | Filter-heavy tail       |

So: **warm vector and text are in a good place**; **hybrid cold and filter-heavy workloads are where the work is**. No claim of parity with commercial search APIs — the goal is to be honest about the profile and improve from here (filter ordering, vector stage layout, shard prefetch, SIMD where it pays).

---

## What’s next

- Tighten the cold path and filter-first planning so p95/p99 under hybrid + filters improve without regressing the warm baseline.
- Keep the query node stateless and object-storage as source of truth; double down on cache layers and prefetch policy.
- Document one canonical end-to-end use case (ingest → index → query → entity context) and keep publishing methodology with every number.

---

## Wrapping up

A context plane, in my view, is the right primitive for “give me the best context for this entity”: entity-scoped, timeline-backed, hybrid search, with a read-optimized architecture that keeps object storage as truth and query nodes stateless. The architecture I’m betting on — immutable segments, daily shards, cold/warm caching — is already showing solid warm-path performance and clear bottlenecks in cold and filter-heavy regimes. If you’re building agents that need deterministic, entity-scoped context, I’d love to hear how you’re thinking about it — and if you want to try this shape, the repo and benchmarks are a good starting point.

---
