-- ============================================================
-- Smart Vehicle Management System
-- Version 1.2 — Fully Normalized Schema (Milestone 2)
-- Applied: 1NF, 2NF, 3NF
-- Authors : Asim Ali | Tariq Jamil | BSCS 'A'
-- ============================================================

-- Drop all tables in reverse dependency order (safe re-run)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS SERVICE_PARTS;
DROP TABLE IF EXISTS SERVICE;
DROP TABLE IF EXISTS INVOICE;
DROP TABLE IF EXISTS PAYMENT;
DROP TABLE IF EXISTS APPOINTMENT;
DROP TABLE IF EXISTS VEHICLE;
DROP TABLE IF EXISTS OWNER;
DROP TABLE IF EXISTS MECHANIC;
DROP TABLE IF EXISTS SPECIALIZATION;
DROP TABLE IF EXISTS INVENTORY;
DROP TABLE IF EXISTS PART_CATEGORY;
DROP TABLE IF EXISTS PAYMENT_METHOD;
DROP TABLE IF EXISTS SERVICE_TYPE;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- TIER 1 — Lookup / Reference Tables (no FK dependencies)
-- ============================================================

-- 1. SPECIALIZATION
--    Extracted from MECHANIC via 3NF normalization.
--    Centralises mechanic specialization area names.
CREATE TABLE SPECIALIZATION (
    SpecID      INT          NOT NULL AUTO_INCREMENT,
    SpecName    VARCHAR(100) NOT NULL,
    Description TEXT         NULL,
    PRIMARY KEY (SpecID),
    CONSTRAINT uq_spec_name UNIQUE (SpecName)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. PART_CATEGORY
--    Extracted from INVENTORY via 3NF normalization.
--    Groups spare parts into named categories.
CREATE TABLE PART_CATEGORY (
    CategoryID   INT          NOT NULL AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL,
    Description  TEXT         NULL,
    PRIMARY KEY (CategoryID),
    CONSTRAINT uq_cat_name UNIQUE (CategoryName)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. PAYMENT_METHOD
--    Extracted from PAYMENT ENUM via 3NF normalization.
--    Stores valid payment method names.
CREATE TABLE PAYMENT_METHOD (
    MethodID   INT         NOT NULL AUTO_INCREMENT,
    MethodName VARCHAR(50) NOT NULL,
    PRIMARY KEY (MethodID),
    CONSTRAINT uq_method_name UNIQUE (MethodName)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. SERVICE_TYPE
--    Extracted from APPOINTMENT via 3NF normalization.
--    Centralises service type names and descriptions.
CREATE TABLE SERVICE_TYPE (
    ServiceTypeID INT          NOT NULL AUTO_INCREMENT,
    TypeName      VARCHAR(100) NOT NULL,
    Description   TEXT         NULL,
    PRIMARY KEY (ServiceTypeID),
    CONSTRAINT uq_type_name UNIQUE (TypeName)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TIER 2 — Core Entity Tables
-- ============================================================

-- 5. OWNER
--    Master registry of vehicle owners.
--    No 1NF/2NF/3NF violations found — no changes from v1.0.
CREATE TABLE OWNER (
    OwnerID INT          NOT NULL AUTO_INCREMENT,
    Name    VARCHAR(100) NOT NULL,
    Phone   VARCHAR(20)  NOT NULL,
    Address VARCHAR(255) NULL,
    PRIMARY KEY (OwnerID),
    CONSTRAINT uq_owner_phone UNIQUE (Phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. MECHANIC
--    Garage technician profiles.
--    CHANGE (3NF): Replaced VARCHAR Specialization with FK SpecID.
CREATE TABLE MECHANIC (
    MechanicID INT          NOT NULL AUTO_INCREMENT,
    Name       VARCHAR(100) NOT NULL,
    SpecID     INT          NULL,
    PRIMARY KEY (MechanicID),
    CONSTRAINT fk_mech_spec
        FOREIGN KEY (SpecID) REFERENCES SPECIALIZATION(SpecID)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. VEHICLE
--    All registered automobiles.
--    No 1NF/2NF/3NF violations found — no changes from v1.0.
CREATE TABLE VEHICLE (
    VehicleID   INT          NOT NULL AUTO_INCREMENT,
    PlateNumber VARCHAR(20)  NOT NULL,
    Model       VARCHAR(100) NOT NULL,
    Year        YEAR         NOT NULL,
    OwnerID     INT          NOT NULL,
    PRIMARY KEY (VehicleID),
    CONSTRAINT uq_plate UNIQUE (PlateNumber),
    CONSTRAINT fk_veh_owner
        FOREIGN KEY (OwnerID) REFERENCES OWNER(OwnerID)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. INVENTORY
--    Spare-parts catalogue and stock tracker.
--    CHANGE (3NF): Added CategoryID FK; extracted PART_CATEGORY.
CREATE TABLE INVENTORY (
    PartID        INT            NOT NULL AUTO_INCREMENT,
    CategoryID    INT            NOT NULL,
    PartName      VARCHAR(150)   NOT NULL,
    StockQuantity INT            NOT NULL DEFAULT 0,
    UnitPrice     DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (PartID),
    CONSTRAINT chk_stock CHECK (StockQuantity >= 0),
    CONSTRAINT fk_inv_cat
        FOREIGN KEY (CategoryID) REFERENCES PART_CATEGORY(CategoryID)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TIER 3 — Transaction / Event Tables
-- ============================================================

-- 9. APPOINTMENT (v1.1 + M2 changes)
--    Service booking and scheduling.
--    CHANGE (3NF): Replaced VARCHAR ServiceType with FK ServiceTypeID.
--    NOTE: Created before SERVICE so SERVICE can hold ApptID backlink FK.
CREATE TABLE APPOINTMENT (
    ApptID        INT      NOT NULL AUTO_INCREMENT,
    VehicleID     INT      NOT NULL,
    MechanicID    INT      NULL,
    ApptDateTime  DATETIME NOT NULL,
    ServiceTypeID INT      NOT NULL,
    Status        ENUM('Scheduled','In Progress','Completed','Cancelled')
                           NOT NULL DEFAULT 'Scheduled',
    Notes         TEXT     NULL,
    PRIMARY KEY (ApptID),
    CONSTRAINT fk_appt_vehicle
        FOREIGN KEY (VehicleID) REFERENCES VEHICLE(VehicleID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_appt_mechanic
        FOREIGN KEY (MechanicID) REFERENCES MECHANIC(MechanicID)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_appt_stype
        FOREIGN KEY (ServiceTypeID) REFERENCES SERVICE_TYPE(ServiceTypeID)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 10. SERVICE
--     Operational core — logs every service event.
--     CHANGE (M2): Added optional ApptID FK backlink.
--     TotalCost is trigger-maintained (see triggers section).
CREATE TABLE SERVICE (
    ServiceID   INT           NOT NULL AUTO_INCREMENT,
    VehicleID   INT           NOT NULL,
    ServiceDate DATE          NOT NULL,
    TotalCost   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    MechanicID  INT           NOT NULL,
    ApptID      INT           NULL,
    PRIMARY KEY (ServiceID),
    CONSTRAINT fk_svc_vehicle
        FOREIGN KEY (VehicleID) REFERENCES VEHICLE(VehicleID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_svc_mechanic
        FOREIGN KEY (MechanicID) REFERENCES MECHANIC(MechanicID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_svc_appt
        FOREIGN KEY (ApptID) REFERENCES APPOINTMENT(ApptID)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 11. SERVICE_PARTS (Junction Table)
--     Resolves M:N between SERVICE and INVENTORY.
--     2NF verified: QuantityUsed depends on the FULL composite PK.
--     No changes from v1.0 — correctly designed from start.
CREATE TABLE SERVICE_PARTS (
    ServiceID    INT NOT NULL,
    PartID       INT NOT NULL,
    QuantityUsed INT NOT NULL,
    PRIMARY KEY (ServiceID, PartID),
    CONSTRAINT chk_qty CHECK (QuantityUsed > 0),
    CONSTRAINT fk_sp_service
        FOREIGN KEY (ServiceID) REFERENCES SERVICE(ServiceID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_sp_part
        FOREIGN KEY (PartID) REFERENCES INVENTORY(PartID)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TIER 4 — Financial Tables (v1.1)
-- ============================================================

-- 12. INVOICE (v1.1)
--     Formal billing record per service (1:1 with SERVICE).
--     GrandTotal is trigger-maintained — not a 3NF violation.
CREATE TABLE INVOICE (
    InvoiceID  INT           NOT NULL AUTO_INCREMENT,
    ServiceID  INT           NOT NULL,
    IssueDate  DATE          NOT NULL,
    DueDate    DATE          NOT NULL,
    Subtotal   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    TaxAmount  DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    GrandTotal DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    Status     ENUM('Pending','Paid','Overdue','Cancelled')
                             NOT NULL DEFAULT 'Pending',
    Notes      TEXT          NULL,
    PRIMARY KEY (InvoiceID),
    CONSTRAINT uq_invoice_service UNIQUE (ServiceID),
    CONSTRAINT fk_inv_service
        FOREIGN KEY (ServiceID) REFERENCES SERVICE(ServiceID)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 13. PAYMENT (v1.1 + M2 changes)
--     Payment transactions against invoices (supports instalments).
--     CHANGE (3NF): Replaced ENUM PaymentMethod with FK MethodID.
CREATE TABLE PAYMENT (
    PaymentID   INT           NOT NULL AUTO_INCREMENT,
    InvoiceID   INT           NOT NULL,
    MethodID    INT           NOT NULL,
    Amount      DECIMAL(10,2) NOT NULL,
    PaymentDate DATE          NOT NULL,
    ReferenceNo VARCHAR(100)  NULL,
    PRIMARY KEY (PaymentID),
    CONSTRAINT chk_pay_amount CHECK (Amount > 0),
    CONSTRAINT fk_pay_invoice
        FOREIGN KEY (InvoiceID) REFERENCES INVOICE(InvoiceID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pay_method
        FOREIGN KEY (MethodID) REFERENCES PAYMENT_METHOD(MethodID)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- SEED DATA — Lookup Tables
-- ============================================================

INSERT INTO SPECIALIZATION (SpecName, Description) VALUES
    ('Engine Overhaul',       'Internal combustion engine repair and rebuilding'),
    ('Electrical Systems',    'Wiring, battery, alternator, and ECU diagnostics'),
    ('Tyres and Suspension',  'Tyre fitting, wheel alignment, shock absorbers'),
    ('Air Conditioning',      'AC recharge, compressor repair, cabin cooling'),
    ('Brakes',                'Brake pad replacement, disc skimming, fluid flush'),
    ('Bodywork',              'Panel beating, dent removal, painting'),
    ('General Maintenance',   'Routine servicing, oil changes, filter replacements');

INSERT INTO PART_CATEGORY (CategoryName, Description) VALUES
    ('Engine Components', 'Pistons, camshafts, timing belts, gaskets'),
    ('Brake System',      'Brake pads, discs, callipers, brake fluid'),
    ('Electrical',        'Batteries, alternators, starter motors, fuses'),
    ('Filters',           'Oil filters, air filters, fuel filters, cabin filters'),
    ('Tyres and Wheels',  'Tyres, rims, valve stems, wheel nuts'),
    ('Fluids',            'Engine oil, coolant, brake fluid, power steering fluid'),
    ('Body Parts',        'Bumpers, mirrors, door handles, windscreens');

INSERT INTO PAYMENT_METHOD (MethodName) VALUES
    ('Cash'), ('Card'), ('Bank Transfer'), ('Online');

INSERT INTO SERVICE_TYPE (TypeName, Description) VALUES
    ('Oil Change',              'Drain and replace engine oil and oil filter'),
    ('Full Annual Service',     'Comprehensive 50-point vehicle inspection and service'),
    ('Brake Inspection',        'Check and replace brake pads, discs, and fluid'),
    ('Tyre Rotation',           'Rotate tyres to even wear; check pressure and tread'),
    ('Engine Diagnostics',      'OBD-II scan and engine fault code analysis'),
    ('Air Conditioning Service','AC recharge, leak test, and cabin filter replacement'),
    ('Electrical Fault Check',  'Battery test, wiring inspection, ECU diagnostics');

-- ============================================================
-- RECOMMENDED INDEXES
-- ============================================================

CREATE INDEX idx_vehicle_owner    ON VEHICLE(OwnerID);
CREATE INDEX idx_service_vehicle  ON SERVICE(VehicleID, ServiceDate);
CREATE INDEX idx_service_mechanic ON SERVICE(MechanicID);
CREATE INDEX idx_invoice_status   ON INVOICE(Status, DueDate);
CREATE INDEX idx_payment_invoice  ON PAYMENT(InvoiceID);
CREATE INDEX idx_appt_vehicle     ON APPOINTMENT(VehicleID, ApptDateTime);
CREATE INDEX idx_appt_mechanic    ON APPOINTMENT(MechanicID);
CREATE INDEX idx_inventory_cat    ON INVENTORY(CategoryID);

-- ============================================================
-- TRIGGERS
-- ============================================================

DELIMITER $$

-- Trigger 1: Auto-update SERVICE.TotalCost after a part is logged
CREATE TRIGGER trg_update_total_cost
AFTER INSERT ON SERVICE_PARTS
FOR EACH ROW
BEGIN
    UPDATE SERVICE
    SET    TotalCost = (
               SELECT COALESCE(SUM(sp.QuantityUsed * i.UnitPrice), 0)
               FROM   SERVICE_PARTS sp
               JOIN   INVENTORY     i  ON i.PartID    = sp.PartID
               WHERE  sp.ServiceID  = NEW.ServiceID
           )
    WHERE  ServiceID = NEW.ServiceID;
END$$

-- Trigger 2: Auto-update INVOICE.Subtotal when SERVICE.TotalCost changes
CREATE TRIGGER trg_update_invoice_subtotal
AFTER UPDATE ON SERVICE
FOR EACH ROW
BEGIN
    IF NEW.TotalCost <> OLD.TotalCost THEN
        UPDATE INVOICE
        SET    Subtotal   = NEW.TotalCost,
               GrandTotal = NEW.TotalCost + TaxAmount
        WHERE  ServiceID  = NEW.ServiceID;
    END IF;
END$$

-- Trigger 3: Auto-mark invoice as Paid when fully settled
CREATE TRIGGER trg_check_invoice_paid
AFTER INSERT ON PAYMENT
FOR EACH ROW
BEGIN
    DECLARE v_paid  DECIMAL(10,2);
    DECLARE v_grand DECIMAL(10,2);
    SELECT COALESCE(SUM(Amount), 0) INTO v_paid
      FROM PAYMENT WHERE InvoiceID = NEW.InvoiceID;
    SELECT GrandTotal INTO v_grand
      FROM INVOICE    WHERE InvoiceID = NEW.InvoiceID;
    IF v_paid >= v_grand THEN
        UPDATE INVOICE
        SET    Status    = 'Paid'
        WHERE  InvoiceID = NEW.InvoiceID;
    END IF;
END$$

-- Trigger 4: Auto-update INVENTORY stock when a part is consumed
CREATE TRIGGER trg_decrement_stock
AFTER INSERT ON SERVICE_PARTS
FOR EACH ROW
BEGIN
    UPDATE INVENTORY
    SET    StockQuantity = StockQuantity - NEW.QuantityUsed
    WHERE  PartID        = NEW.PartID;
END$$

-- Trigger 5: Mark APPOINTMENT as Completed when SERVICE is created with its ApptID
CREATE TRIGGER trg_complete_appointment
AFTER INSERT ON SERVICE
FOR EACH ROW
BEGIN
    IF NEW.ApptID IS NOT NULL THEN
        UPDATE APPOINTMENT
        SET    Status  = 'Completed'
        WHERE  ApptID  = NEW.ApptID
          AND  Status IN ('Scheduled','In Progress');
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- SAMPLE QUERIES (Business Use Cases)
-- ============================================================

-- 1. Pending invoices with owner and vehicle details
SELECT  o.Name AS OwnerName, v.PlateNumber, v.Model,
        i.InvoiceID, i.IssueDate, i.DueDate, i.GrandTotal
FROM    INVOICE i
JOIN    SERVICE s  ON s.ServiceID = i.ServiceID
JOIN    VEHICLE v  ON v.VehicleID = s.VehicleID
JOIN    OWNER   o  ON o.OwnerID   = v.OwnerID
WHERE   i.Status = 'Pending'
ORDER   BY i.DueDate ASC;

-- 2. Revenue per mechanic this month (with specialization)
SELECT  m.Name AS Mechanic, sp2.SpecName AS Specialization,
        SUM(p.Amount) AS TotalCollected
FROM    PAYMENT     p
JOIN    INVOICE     i   ON i.InvoiceID  = p.InvoiceID
JOIN    SERVICE     s   ON s.ServiceID  = i.ServiceID
JOIN    MECHANIC    m   ON m.MechanicID = s.MechanicID
LEFT JOIN SPECIALIZATION sp2 ON sp2.SpecID = m.SpecID
WHERE   p.PaymentDate >= DATE_FORMAT(NOW(), '%Y-%m-01')
GROUP   BY m.MechanicID
ORDER   BY TotalCollected DESC;

-- 3. Upcoming appointments next 7 days
SELECT  a.ApptDateTime, v.PlateNumber, o.Name AS Owner, o.Phone,
        m.Name AS Mechanic, st.TypeName AS ServiceType, a.Status
FROM    APPOINTMENT   a
JOIN    VEHICLE       v   ON v.VehicleID    = a.VehicleID
JOIN    OWNER         o   ON o.OwnerID      = v.OwnerID
LEFT JOIN MECHANIC    m   ON m.MechanicID   = a.MechanicID
JOIN    SERVICE_TYPE  st  ON st.ServiceTypeID = a.ServiceTypeID
WHERE   a.ApptDateTime BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 7 DAY)
  AND   a.Status IN ('Scheduled','In Progress')
ORDER   BY a.ApptDateTime ASC;

-- 4. Parts with low stock by category
SELECT  pc.CategoryName, i.PartName, i.StockQuantity, i.UnitPrice
FROM    INVENTORY     i
JOIN    PART_CATEGORY pc ON pc.CategoryID = i.CategoryID
WHERE   i.StockQuantity < 5
ORDER   BY pc.CategoryName, i.StockQuantity ASC;

-- 5. Full service history for a vehicle (by plate number)
SELECT  s.ServiceDate, s.TotalCost,
        m.Name AS Mechanic, sp2.SpecName AS Specialization,
        inv.InvoiceID, inv.Status AS InvoiceStatus,
        inv.GrandTotal
FROM    SERVICE   s
JOIN    MECHANIC  m    ON m.MechanicID  = s.MechanicID
LEFT JOIN SPECIALIZATION sp2 ON sp2.SpecID = m.SpecID
LEFT JOIN INVOICE inv  ON inv.ServiceID = s.ServiceID
WHERE   s.VehicleID = (
            SELECT VehicleID FROM VEHICLE WHERE PlateNumber = 'ABC-1234'
        )
ORDER   BY s.ServiceDate DESC;

-- ============================================================
-- END OF SCHEMA v1.2
-- Smart Vehicle Management System | Milestone 2
-- Asim Ali | Tariq Jamil | BSCS 'A'
-- ============================================================
