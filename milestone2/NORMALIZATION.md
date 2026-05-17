# NORMALIZATION.md
# Smart Vehicle Management System — Milestone 2
## ERD Design & Normalization

**Group Members:** Asim Ali | Tariq Jamil  
**Section:** BSCS 'A'  
**Version:** 1.2  
**Milestone:** 2 — ERD Design & Normalization

---

## Overview

This document formally applies **First Normal Form (1NF)**, **Second Normal Form (2NF)**, and **Third Normal Form (3NF)** to every table in the Smart Vehicle Management System database schema. For each table and each normal form, the analysis states:
- Whether a violation was found
- What change was made (or why no change was needed)
- The resulting structure

**Schema Evolution:**
| Version | Tables | Description |
|---------|--------|-------------|
| v1.0 | 6 | Initial schema: OWNER, VEHICLE, MECHANIC, SERVICE, INVENTORY, SERVICE_PARTS |
| v1.1 | 9 | Added INVOICE, PAYMENT, APPOINTMENT |
| v1.2 | 13 | Milestone 2: Extracted SPECIALIZATION, PART_CATEGORY, PAYMENT_METHOD, SERVICE_TYPE via 3NF |

---

## Normal Form Definitions

| Normal Form | Requirement | Violation Example | Fix |
|-------------|-------------|-------------------|-----|
| **1NF** | Every column must hold **atomic** (indivisible) values; no repeating groups or arrays | Storing `'Oil Change, Brake Check'` in one ServiceType cell | Split into separate rows or a linked lookup table |
| **2NF** | Must be in 1NF; every non-key attribute must depend on the **WHOLE** primary key (no partial dependency). Only applies to composite PKs. | In SERVICE_PARTS storing PartName — depends only on PartID, not on ServiceID | Move PartName to INVENTORY |
| **3NF** | Must be in 2NF; no non-key attribute may depend on **another non-key attribute** (no transitive dependency) | In MECHANIC storing SpecDescription that depends on Specialization, not MechanicID | Extract Specialization to its own lookup table |

---

## Normalization Analysis — Table by Table

---

### 1. OWNER

**Description:** Master registry of vehicle owners. Each row represents one unique customer.

| Normal Form | Finding | Action | Result |
|-------------|---------|--------|--------|
| **1NF** | OwnerID, Name, Phone, Address are all atomic single values. No multi-valued or repeating columns exist. | No change required. | ✅ Satisfies 1NF |
| **2NF** | OWNER has a single-column PK (OwnerID). Partial dependency requires a composite PK, which does not exist here. Name, Phone, Address all describe the owner uniquely identified by OwnerID. | No change required. | ✅ Satisfies 2NF |
| **3NF** | No non-key attribute depends on another non-key attribute. Phone and Address both depend directly and solely on OwnerID — not on each other. | No change required. | ✅ Satisfies 3NF |

**Final Schema:**
```
OWNER (OwnerID PK, Name, Phone UNIQUE, Address)
```

---

### 2. VEHICLE

**Description:** Records every registered automobile. PlateNumber carries a UNIQUE constraint representing the official registration plate.

| Normal Form | Finding | Action | Result |
|-------------|---------|--------|--------|
| **1NF** | PlateNumber, Model, Year, and OwnerID are all atomic. No arrays or comma-separated lists stored in any column. | No change required. | ✅ Satisfies 1NF |
| **2NF** | Single-column PK (VehicleID). All attributes — PlateNumber, Model, Year, OwnerID — are facts about the vehicle and depend entirely on VehicleID. | No change required. | ✅ Satisfies 2NF |
| **3NF** | No transitive dependencies exist. OwnerID is a FK pointer, not a derived attribute. Model and Year both describe the vehicle directly; neither depends on the other. | No change required. | ✅ Satisfies 3NF |

**Final Schema:**
```
VEHICLE (VehicleID PK, PlateNumber UNIQUE, Model, Year, OwnerID FK→OWNER)
```

---

### 3. MECHANIC ⚠️ Change Made

**Description:** Stores technician profiles. Originally included a free-text `Specialization VARCHAR` column.

| Normal Form | Finding | Action | Result |
|-------------|---------|--------|--------|
| **1NF** | MechanicID, Name, and Specialization are all atomic single values. | No change required. | ✅ Satisfies 1NF |
| **2NF** | Single-column PK (MechanicID). Name and Specialization both fully depend on MechanicID. | No change required. | ✅ Satisfies 2NF |
| **3NF** | **VIOLATION:** Specialization is a free-text string. If we ever store additional attributes of a specialization area (e.g., a description, skill level, or training certification), those attributes would depend on the Specialization value — not on MechanicID. This is a **transitive dependency**: `MechanicID → Specialization → SpecDescription`. | Extracted Specialization into a new `SPECIALIZATION(SpecID, SpecName, Description)` table. Replaced `Specialization VARCHAR` in MECHANIC with `SpecID INT FK`. | ✅ Satisfies 3NF |

**Change (3NF):** Replaced `VARCHAR Specialization` column with FK `SpecID` pointing to new `SPECIALIZATION` table.

**Final Schema:**
```
MECHANIC (MechanicID PK, Name, SpecID FK→SPECIALIZATION NULL)
```

---

### 4. SPECIALIZATION ⭐ New Table (3NF Extraction)

**Description:** New lookup table created during 3NF normalization of MECHANIC. Centralises the list of valid mechanic specialization areas.

**Why created:** To eliminate the potential transitive dependency in MECHANIC where specialization-related attributes would depend on the Specialization value (a non-key), not on MechanicID (the PK). Centralising specialization data also prevents string duplication across MECHANIC rows.

**Final Schema:**
```
SPECIALIZATION (SpecID PK, SpecName UNIQUE, Description)
```

**Seed Data:**
```sql
INSERT INTO SPECIALIZATION (SpecName) VALUES
  ('Engine Overhaul'), ('Electrical Systems'), ('Tyres and Suspension'),
  ('Air Conditioning'), ('Brakes'), ('Bodywork'), ('General Maintenance');
```

---

### 5. SERVICE

**Description:** Operational core — logs every service event. Contains two FKs (VehicleID, MechanicID) and a trigger-maintained TotalCost aggregate. A nullable ApptID FK was added in M2 as a backlink to the originating appointment.

| Normal Form | Finding | Action | Result |
|-------------|---------|--------|--------|
| **1NF** | ServiceID, VehicleID, ServiceDate, TotalCost, MechanicID are all atomic. No repeating groups. | No change required. | ✅ Satisfies 1NF |
| **2NF** | Single-column PK (ServiceID). Every attribute describes the service event as a whole — no partial dependency possible. | No change required. | ✅ Satisfies 2NF |
| **3NF** | TotalCost is computed from SERVICE_PARTS rows via a database trigger. It is a **trigger-maintained aggregate** of child rows — it depends on ServiceID (the PK), not on any other non-key column of SERVICE itself. This is an engineering pattern, not a transitive dependency. | TotalCost documented as trigger-maintained. Added optional ApptID FK backlink for traceability. | ✅ Satisfies 3NF |

**Final Schema:**
```
SERVICE (ServiceID PK, VehicleID FK→VEHICLE, ServiceDate, TotalCost,
         MechanicID FK→MECHANIC, ApptID FK→APPOINTMENT NULL)
```

---

### 6. INVENTORY ⚠️ Change Made

**Description:** Spare-parts catalogue and stock tracker. Originally had no category grouping — just PartName as a free-text field.

| Normal Form | Finding | Action | Result |
|-------------|---------|--------|--------|
| **1NF** | PartID, PartName, StockQuantity, UnitPrice are all atomic. No multi-valued columns. | No change required. | ✅ Satisfies 1NF |
| **2NF** | Single-column PK (PartID). All attributes describe the specific part identified by PartID. | No change required. | ✅ Satisfies 2NF |
| **3NF** | **VIOLATION (preventive):** If a `CategoryName` and `CategoryDescription` were stored directly in INVENTORY, `CategoryDescription` would depend on `CategoryName` (a non-key attribute), not on `PartID`. This is a textbook transitive dependency: `PartID → CategoryName → CategoryDescription`. Extracting the category now prevents this violation before it occurs. | Extracted `PART_CATEGORY(CategoryID, CategoryName, Description)`. Added `CategoryID FK` to INVENTORY. | ✅ Satisfies 3NF |

**Change (3NF):** Added `CategoryID FK` referencing new `PART_CATEGORY` table.

**Final Schema:**
```
INVENTORY (PartID PK, CategoryID FK→PART_CATEGORY, PartName, StockQuantity, UnitPrice)
```

---

### 7. PART_CATEGORY ⭐ New Table (3NF Extraction)

**Description:** New lookup table created during 3NF normalization of INVENTORY. Groups spare parts into named categories for streamlined reporting, procurement, and stock monitoring.

**Final Schema:**
```
PART_CATEGORY (CategoryID PK, CategoryName UNIQUE, Description)
```

**Seed Data:**
```sql
INSERT INTO PART_CATEGORY (CategoryName) VALUES
  ('Engine Components'), ('Brake System'), ('Electrical'),
  ('Filters'), ('Tyres and Wheels'), ('Fluids'), ('Body Parts');
```

---

### 8. SERVICE_PARTS (Junction Table)

**Description:** Resolves the M:N relationship between SERVICE and INVENTORY using a composite PK. Critical to verify 2NF here since composite PKs are exactly where partial dependency violations occur.

| Normal Form | Finding | Action | Result |
|-------------|---------|--------|--------|
| **1NF** | QuantityUsed is atomic. ServiceID and PartID are single-valued FKs. No repeating groups. | No change required. | ✅ Satisfies 1NF |
| **2NF** | Composite PK (ServiceID, PartID). QuantityUsed tells how many units of **this part** were used in **this service** — it depends on **BOTH** keys together. Removing either FK key would make the row meaningless. No partial dependency exists. | No change required. | ✅ Satisfies 2NF — QuantityUsed depends on the full composite key |
| **3NF** | There is only one non-key attribute (QuantityUsed). Transitive dependency requires at least two non-key attributes — trivially satisfied with only one. | No change required. | ✅ Satisfies 3NF |

**Final Schema:**
```
SERVICE_PARTS (ServiceID PK+FK→SERVICE, PartID PK+FK→INVENTORY, QuantityUsed)
```

---

### 9. INVOICE (v1.1)

**Description:** Formal billing record per service. GrandTotal requires careful 3NF analysis since it appears derived from other columns.

| Normal Form | Finding | Action | Result |
|-------------|---------|--------|--------|
| **1NF** | All columns (InvoiceID, ServiceID, IssueDate, DueDate, Subtotal, TaxAmount, GrandTotal, Status, Notes) are atomic single values. | No change required. | ✅ Satisfies 1NF |
| **2NF** | Single-column PK (InvoiceID). ServiceID is a UNIQUE FK enforcing 1:1 with SERVICE — not a partial PK. All columns describe the specific invoice. | No change required. | ✅ Satisfies 2NF |
| **3NF** | **Potential concern:** `GrandTotal = Subtotal + TaxAmount` — appears derived from two non-key attributes. However, GrandTotal is retained as a **DB-engine generated column** or **trigger-maintained value**, not a user-entered attribute. The DB engine guarantees consistency. This is an accepted engineering pattern and does not constitute a normalization violation — it is equivalent to storing a materialised view column. | GrandTotal documented as trigger-computed / generated column. No structural change. | ✅ Satisfies 3NF |

**Final Schema:**
```
INVOICE (InvoiceID PK, ServiceID FK→SERVICE UNIQUE, IssueDate, DueDate,
         Subtotal, TaxAmount, GrandTotal [trigger-computed], Status ENUM, Notes)
```

---

### 10. PAYMENT (v1.1) ⚠️ Change Made

**Description:** Records every payment transaction. Originally used a MySQL `ENUM` type for PaymentMethod.

| Normal Form | Finding | Action | Result |
|-------------|---------|--------|--------|
| **1NF** | All columns are atomic. PaymentMethod ENUM stores a single string value per row. | No change required. | ✅ Satisfies 1NF |
| **2NF** | Single-column PK (PaymentID). All attributes describe the specific payment transaction. | No change required. | ✅ Satisfies 2NF |
| **3NF** | **VIOLATION:** PaymentMethod is an ENUM embedded in the schema DDL. If we ever add a method-level attribute (e.g., `ProcessingFeePercent` — 0% for Cash, 2% for Card), that attribute would depend on the method name — not on PaymentID. This creates a transitive dependency: `PaymentID → PaymentMethod → ProcessingFeePercent`. Extracting to a lookup table eliminates this risk and allows future extension without DDL changes. | Replaced ENUM `PaymentMethod` with FK `MethodID` referencing new `PAYMENT_METHOD` table. | ✅ Satisfies 3NF |

**Change (3NF):** Replaced `ENUM PaymentMethod` with `FK MethodID → PAYMENT_METHOD`.

**Final Schema:**
```
PAYMENT (PaymentID PK, InvoiceID FK→INVOICE, MethodID FK→PAYMENT_METHOD,
         Amount, PaymentDate, ReferenceNo)
```

---

### 11. PAYMENT_METHOD ⭐ New Table (3NF Extraction)

**Description:** New lookup table created during 3NF normalization of PAYMENT. Centralises valid payment method names and allows future extension without DDL changes.

**Final Schema:**
```
PAYMENT_METHOD (MethodID PK, MethodName UNIQUE)
```

**Seed Data:**
```sql
INSERT INTO PAYMENT_METHOD (MethodName) VALUES
  ('Cash'), ('Card'), ('Bank Transfer'), ('Online');
```

---

### 12. APPOINTMENT (v1.1) ⚠️ Change Made

**Description:** Service booking and scheduling table. Originally stored `ServiceType` as a free-text `VARCHAR(100)`.

| Normal Form | Finding | Action | Result |
|-------------|---------|--------|--------|
| **1NF** | All columns are atomic single values. No arrays or repeating groups. | No change required. | ✅ Satisfies 1NF |
| **2NF** | Single-column PK (ApptID). All attributes describe the booking identified by ApptID. | No change required. | ✅ Satisfies 2NF |
| **3NF** | **VIOLATION:** ServiceType VARCHAR could acquire dependent attributes (e.g., `EstimatedDuration`, `RequiredTools`, `SkillLevel`). Those attributes would depend on the ServiceType value — not on ApptID. Transitive dependency: `ApptID → ServiceType → EstimatedDuration`. Extracting to a lookup table eliminates this now. | Extracted `SERVICE_TYPE(ServiceTypeID, TypeName, Description)` table. Added `ServiceTypeID FK` to APPOINTMENT. | ✅ Satisfies 3NF |

**Change (3NF):** Replaced `VARCHAR ServiceType` with `FK ServiceTypeID → SERVICE_TYPE`.

**Final Schema:**
```
APPOINTMENT (ApptID PK, VehicleID FK→VEHICLE, MechanicID FK→MECHANIC NULL,
             ApptDateTime, ServiceTypeID FK→SERVICE_TYPE, Status ENUM, Notes)
```

---

### 13. SERVICE_TYPE ⭐ New Table (3NF Extraction)

**Description:** New lookup table created during 3NF normalization of APPOINTMENT. Centralises valid service type names and enables future extension (e.g., adding EstimatedDuration) without violating 3NF.

**Final Schema:**
```
SERVICE_TYPE (ServiceTypeID PK, TypeName UNIQUE, Description)
```

**Seed Data:**
```sql
INSERT INTO SERVICE_TYPE (TypeName) VALUES
  ('Oil Change'), ('Full Annual Service'), ('Brake Inspection'),
  ('Tyre Rotation'), ('Engine Diagnostics'),
  ('Air Conditioning Service'), ('Electrical Fault Check');
```

---

## Step 2 — Redundancy & Duplicate Check

| Table | Check Performed | Finding | Action |
|-------|----------------|---------|--------|
| OWNER | Duplicate owners with same Phone | UNIQUE constraint on Phone prevents duplicates | No change — constraint sufficient |
| VEHICLE | Duplicate plates | UNIQUE on PlateNumber prevents duplicates | No change — constraint sufficient |
| MECHANIC | Specialization stored as free text — same value repeated for multiple mechanics (e.g., 'Engine' stored for 10 different rows) | Redundant string storage | Extracted to SPECIALIZATION lookup table (3NF) |
| SERVICE | TotalCost appears in both SERVICE and derivable from SERVICE_PARTS | TotalCost retained as trigger-maintained aggregate — acceptable engineering pattern | Documented as trigger-maintained; no structural redundancy |
| INVENTORY | No CategoryName stored in original — only PartName | No overlap found; PartName is specific to each part | Extracted PART_CATEGORY to allow grouping without redundancy |
| SERVICE_PARTS | PartName or UnitPrice could have been duplicated here | Neither PartName nor UnitPrice is stored here — both remain in INVENTORY | No issue — proper FK design from start |
| INVOICE | GrandTotal = Subtotal + TaxAmount — could be seen as redundant | Retained as DB-computed/trigger value — not user-maintained redundancy | Documented as generated column; no structural change |
| PAYMENT | PaymentMethod ENUM repeated across rows as identical strings ('Card' stored 500 times) | Redundant string storage across rows | Extracted to PAYMENT_METHOD lookup table (3NF) |
| APPOINTMENT | ServiceType VARCHAR repeated across rows ('Oil Change' stored in every booking row) | Redundant string storage | Extracted to SERVICE_TYPE lookup table (3NF) |

---

## Final Schema Summary (v1.2 — All 13 Tables)

| # | Table | Highest NF | PK Type | New in M2? | Changes from M1 |
|---|-------|-----------|---------|-----------|----------------|
| 1 | OWNER | 3NF | Single (OwnerID) | No | None |
| 2 | VEHICLE | 3NF | Single (VehicleID) | No | None |
| 3 | MECHANIC | 3NF | Single (MechanicID) | No | Replaced VARCHAR Specialization with FK SpecID |
| 4 | **SPECIALIZATION** | 3NF | Single (SpecID) | **Yes** | Extracted from MECHANIC |
| 5 | SERVICE | 3NF | Single (ServiceID) | No | Added optional ApptID FK backlink |
| 6 | INVENTORY | 3NF | Single (PartID) | No | Added CategoryID FK |
| 7 | **PART_CATEGORY** | 3NF | Single (CategoryID) | **Yes** | Extracted from INVENTORY |
| 8 | SERVICE_PARTS | 3NF | Composite (SvcID, PartID) | No | None |
| 9 | INVOICE | 3NF | Single (InvoiceID) | No | GrandTotal documented as trigger-computed |
| 10 | PAYMENT | 3NF | Single (PaymentID) | No | Replaced ENUM PaymentMethod with FK MethodID |
| 11 | **PAYMENT_METHOD** | 3NF | Single (MethodID) | **Yes** | Extracted from PAYMENT ENUM |
| 12 | APPOINTMENT | 3NF | Single (ApptID) | No | Replaced VARCHAR ServiceType with FK ServiceTypeID |
| 13 | **SERVICE_TYPE** | 3NF | Single (ServiceTypeID) | **Yes** | Extracted from APPOINTMENT |

---

## Updated Relationships (v1.2)

| Relationship | Cardinality | FK Location | Version |
|-------------|-------------|-------------|---------|
| OWNER → VEHICLE | 1 : M | VEHICLE.OwnerID | v1.0 |
| VEHICLE → SERVICE | 1 : M | SERVICE.VehicleID | v1.0 |
| MECHANIC → SERVICE | 1 : M | SERVICE.MechanicID | v1.0 |
| SERVICE ↔ INVENTORY | M : N | SERVICE_PARTS (junction) | v1.0 |
| SERVICE → INVOICE | 1 : 1 | INVOICE.ServiceID (UNIQUE) | v1.1 |
| INVOICE → PAYMENT | 1 : M | PAYMENT.InvoiceID | v1.1 |
| VEHICLE → APPOINTMENT | 1 : M | APPOINTMENT.VehicleID | v1.1 |
| MECHANIC → APPOINTMENT | 1 : M (opt.) | APPOINTMENT.MechanicID (NULL) | v1.1 |
| APPOINTMENT → SERVICE | 1 : 1 (opt.) | SERVICE.ApptID (NULL) | **M2** |
| SPECIALIZATION → MECHANIC | 1 : M | MECHANIC.SpecID | **M2 — 3NF** |
| PART_CATEGORY → INVENTORY | 1 : M | INVENTORY.CategoryID | **M2 — 3NF** |
| PAYMENT_METHOD → PAYMENT | 1 : M | PAYMENT.MethodID | **M2 — 3NF** |
| SERVICE_TYPE → APPOINTMENT | 1 : M | APPOINTMENT.ServiceTypeID | **M2 — 3NF** |

---

## Git Commit Message

```
M2: Applied 2NF and 3NF normalization, updated ERD and schema

- Reviewed all 9 tables for 1NF, 2NF, 3NF compliance with full justification
- Extracted SPECIALIZATION from MECHANIC (3NF transitive dependency prevention)
- Extracted PART_CATEGORY from INVENTORY (3NF future dependency prevention)
- Extracted PAYMENT_METHOD from PAYMENT ENUM (3NF data centralization)
- Extracted SERVICE_TYPE from APPOINTMENT (3NF transitive dependency prevention)
- Added ApptID FK backlink in SERVICE for end-to-end appointment traceability
- Updated ERD to 13 tables (v1.2); all relationships and cardinalities verified
- Added NORMALIZATION.md with full per-table 1NF/2NF/3NF analysis
- Added seed data INSERT statements for all 4 new lookup tables
- Added ALTER TABLE statements for all modified tables
```

---

*Smart Vehicle Management System | Milestone 2 | Asim Ali & Tariq Jamil | BSCS 'A'*
