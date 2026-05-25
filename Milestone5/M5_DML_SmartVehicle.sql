-- ============================================================
-- Smart Vehicle Service Management System
-- Updated Complete DML & Operational Script
-- ============================================================

-- Create database if it doesn't exist to prevent catalog errors
CREATE DATABASE IF NOT EXISTS smart_vehicle_management_sytem;
USE smart_vehicle_management_sytem;

-- Disable constraints temporarily to safely refresh database tables
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. SPECIALIZATION
-- ============================================================
REPLACE INTO SPECIALIZATION (SpecID, SpecName, Description) VALUES 
(1, 'Engine Overhaul',       'Internal combustion engine repair and rebuilding'), 
(2, 'Electrical Systems',    'Wiring, battery, alternator, and ECU diagnostics'), 
(3, 'Tyres and Suspension',  'Tyre fitting, wheel alignment, shock absorbers'), 
(4, 'Air Conditioning',      'AC recharge, compressor repair, cabin cooling'), 
(5, 'Brakes',                'Brake pad replacement, disc skimming, fluid flush'), 
(6, 'Bodywork',              'Panel beating, dent removal, painting'), 
(7, 'General Maintenance',   'Routine servicing, oil changes, filter replacements');

-- ============================================================
-- 2. PART_CATEGORY
-- ============================================================
REPLACE INTO PART_CATEGORY (CategoryID, CategoryName, Description) VALUES 
(1, 'Engine Components', 'Pistons, camshafts, timing belts, gaskets'), 
(2, 'Brake System',      'Brake pads, discs, callipers, brake fluid'), 
(3, 'Electrical',        'Batteries, alternators, starter motors, fuses'), 
(4, 'Filters',           'Oil filters, air filters, fuel filters, cabin filters'), 
(5, 'Tyres and Wheels',  'Tyres, rims, valve stems, wheel nuts'), 
(6, 'Fluids',            'Engine oil, coolant, brake fluid, power steering fluid'), 
(7, 'Body Parts',        'Bumpers, mirrors, door handles, windscreens');

-- ============================================================
-- 3. SERVICE_TYPE
-- ============================================================
REPLACE INTO SERVICE_TYPE (ServiceTypeID, TypeName, Description) VALUES 
(1, 'Oil Change',              'Drain and replace engine oil and oil filter'), 
(2, 'Full Annual Service',     'Comprehensive 50-point vehicle inspection and service'), 
(3, 'Brake Inspection',        'Check and replace brake pads, discs, and fluid'), 
(4, 'Tyre Rotation',           'Rotate tyres to even wear; check pressure and tread'), 
(5, 'Engine Diagnostics',      'OBD-II scan and engine fault code analysis'), 
(6, 'Air Conditioning Service','AC recharge, leak test, and cabin filter replacement'), 
(7, 'Electrical Fault Check',  'Battery test, wiring inspection, ECU diagnostics');

-- ============================================================
-- 4. PAYMENT_METHOD
-- ============================================================
REPLACE INTO PAYMENT_METHOD (MethodID, MethodName) VALUES 
(1, 'Cash'), 
(2, 'Card'), 
(3, 'Bank Transfer'), 
(4, 'Online');

-- ============================================================
-- 5. OWNER
-- ============================================================
REPLACE INTO OWNER (OwnerID, Name, Phone, Address) VALUES 
(1,  'Ahmed Raza',      '03001234567', 'House 12, Gulberg III, Lahore'), 
(2,  'Fatima Khan',     '03012345678', 'Flat 5, F-7/2, Islamabad'), 
(3,  'Muhammad Tariq',  '03023456789', 'Street 4, Hayatabad Phase 3, Peshawar'), 
(4,  'Sana Malik',      '03034567890', 'Plot 22, DHA Phase 2, Karachi'), 
(5,  'Bilal Hussain',   '03045678901', 'House 7, Johar Town, Lahore'), 
(6,  'Ayesha Siddiqui', '03056789012', 'Sector G-11/1, Islamabad'), 
(7,  'Usman Ghani',     '03067890123', 'University Road, Peshawar'), 
(8,  'Nadia Iqbal',     '03078901234', 'Block B, North Nazimabad, Karachi'), 
(9,  'Zubair Ahmad',    '03089012345', 'Model Town Extension, Lahore'), 
(10, 'Hina Baig',       '03090123456', 'E-7, Islamabad'), 
(11, 'Asad Mehmood',    '03101234567', 'Regi Model Town, Peshawar'), 
(12, 'Sobia Qureshi',   '03112345678', 'Clifton Block 4, Karachi'), 
(13, 'Imran Yousaf',    '03123456789', 'Wapda Town Phase 1, Lahore'), 
(14, 'Rabia Zafar',     '03134567890', 'Sector I-10/3, Islamabad'), 
(15, 'Kamran Sheikh',   '03145678901', 'Dalazak Road, Peshawar'), 
(16, 'Maryam Nawaz',    '03156789012', 'Gulshan-e-Iqbal Block 13, Karachi'), 
(17, 'Faisal Chaudhry', '03167890123', 'Canal Bank Road, Lahore'), 
(18, 'Sadia Rehman',    '03178901234', 'G-8/4, Islamabad'), 
(19, 'Zaheer Abbas',    '03189012345', 'Ring Road, Peshawar'), 
(20, 'Amna Tariq',      '03190123456', 'PECHS Block 2, Karachi');

-- ============================================================
-- 6. MECHANIC
-- ============================================================
REPLACE INTO MECHANIC (MechanicID, Name, SpecID) VALUES 
(1,  'Khalid Mehmood', 1), 
(2,  'Tariq Hussain',  2), 
(3,  'Nasir Ali',      3), 
(4,  'Arif Ullah',     4), 
(5,  'Jameel Ahmad',   5), 
(6,  'Pervez Khan',    6), 
(7,  'Sajid Iqbal',    7), 
(8,  'Waqas Rehman',   1), 
(9,  'Hamid Nawaz',    2), 
(10, 'Rizwan Bashir',  3);

-- ============================================================
-- 7. VEHICLE
-- ============================================================
REPLACE INTO VEHICLE (VehicleID, PlateNumber, Model, Year, OwnerID) VALUES 
(1,  'LHR-2018-001', 'Toyota Corolla GLi',   2018, 1), 
(2,  'ISB-2020-002', 'Honda Civic Oriel',    2020, 2), 
(3,  'PES-2019-003', 'Suzuki Cultus VXL',    2019, 3), 
(4,  'KHI-2021-004', 'Toyota Yaris ATIV',    2021, 4), 
(5,  'LHR-2017-005', 'Honda City Aspire',    2017, 5), 
(6,  'ISB-2022-006', 'Suzuki Alto VXL',      2022, 6), 
(7,  'PES-2016-007', 'Toyota Hilux Revo',    2016, 7), 
(8,  'KHI-2023-008', 'Honda BR-V S',         2023, 8), 
(9,  'LHR-2015-009', 'Suzuki Wagon R VXL',   2015, 9), 
(10, 'ISB-2019-010', 'Toyota Prado TXL',     2019, 10), 
(11, 'PES-2020-011', 'Honda CD70 Dream',     2020, 11), 
(12, 'KHI-2018-012', 'Suzuki Mehran VX',     2018, 12), 
(13, 'LHR-2021-013', 'Toyota Land Cruiser',  2021, 13), 
(14, 'ISB-2017-014', 'Honda Accord VTi-L',   2017, 14), 
(15, 'PES-2022-015', 'Suzuki Bolan VX',      2022, 15), 
(16, 'KHI-2016-016', 'Toyota Fortuner 2.7',  2016, 16), 
(17, 'LHR-2023-017', 'Honda Vezel RS',       2023, 17), 
(18, 'ISB-2020-018', 'Suzuki Swift DLX',     2020, 18), 
(19, 'PES-2019-019', 'Toyota Camry Grande',  2019, 19), 
(20, 'KHI-2021-020', 'Honda Fit GP5',        2021, 20);

-- ============================================================
-- 8. INVENTORY
-- ============================================================
REPLACE INTO INVENTORY (PartID, CategoryID, PartName, StockQuantity, UnitPrice) VALUES 
(1,  1, 'Timing Belt - Toyota Corolla',   15,  2500.00), 
(2,  2, 'Brake Pads Set - Honda Civic',   30,  1800.00), 
(3,  3, 'Car Battery 65Ah - GS',          20,  8500.00), 
(4,  4, 'Oil Filter - Suzuki Cultus',     50,   350.00), 
(5,  5, 'Tyre 175/65R14 - Bridgestone',   25,  7200.00), 
(6,  6, 'Engine Oil 5W-30 4L - Castrol',  40,  2200.00), 
(7,  7, 'Front Bumper - Toyota Yaris',     8, 12000.00), 
(8,  1, 'Head Gasket - Honda City',       12,  3500.00), 
(9,  2, 'Brake Disc - Suzuki Alto',       18,  2800.00), 
(10, 3, 'Alternator 70A - Toyota',        10,  9500.00), 
(11, 4, 'Air Filter - Honda Civic',       35,   450.00), 
(12, 5, 'Tyre 195/55R15 - Yokohama',      20,  9000.00), 
(13, 6, 'Coolant 1L - Toyota',            60,   650.00), 
(14, 7, 'Side Mirror - Honda City',       14,  3200.00), 
(15, 1, 'Camshaft - Suzuki Mehran',        6,  6500.00), 
(16, 2, 'Brake Fluid DOT4 500ml',         45,   380.00), 
(17, 3, 'Starter Motor - Toyota',          9,  7800.00), 
(18, 4, 'Fuel Filter - Honda',            28,   550.00), 
(19, 6, 'Power Steering Fluid 1L',        38,   700.00), 
(20, 7, 'Windscreen - Suzuki Swift',       5, 18000.00);

-- ============================================================
-- 9. APPOINTMENT
-- ============================================================
REPLACE INTO APPOINTMENT (ApptID, VehicleID, MechanicID, ApptDateTime, ServiceTypeID, Status, Notes) VALUES 
(1,  1,  1,    '2026-04-01 09:00:00', 1, 'Completed', 'Please check engine noise'), 
(2,  2,  2,    '2026-04-03 10:30:00', 2, 'Completed', 'Brakes feel soft'), 
(3,  3,  3,    '2026-04-05 11:00:00', 3, 'Completed', 'Tyre rotation due'), 
(4,  4,  4,    '2026-04-08 09:30:00', 4, 'Completed', 'AC not cooling properly'), 
(5,  5,  5,    '2026-04-10 14:00:00', 5, 'Completed', 'Routine annual service'), 
(6,  6,  6,    '2026-04-12 10:00:00', 1, 'Completed', 'Oil change required'), 
(7,  7,  7,    '2026-04-15 11:30:00', 7, 'Completed', 'Engine light on'), 
(8,  8,  8,    '2026-04-18 09:00:00', 2, 'Completed', 'Battery check'), 
(9,  9,  9,    '2026-04-20 15:00:00', 3, 'Completed', 'Suspension noise'), 
(10, 10, 10,   '2026-04-22 10:00:00', 5, 'Completed', 'Full annual service'), 
(11, 11, NULL, '2026-05-20 09:00:00', 1, 'Scheduled', 'Oil change overdue'), 
(12, 12, NULL, '2026-05-22 10:30:00', 3, 'Scheduled', 'Check tyre pressure'), 
(13, 13, 1,    '2026-05-25 11:00:00', 2, 'Scheduled', 'Brake inspection'), 
(14, 14, 2,    '2026-05-28 14:00:00', 7, 'Scheduled', 'Electrical fault'), 
(15, 15, NULL, '2026-06-01 09:30:00', 6, 'Scheduled', 'AC service needed');

-- ============================================================
-- 10. SERVICE
-- ============================================================
REPLACE INTO SERVICE (ServiceID, VehicleID, ServiceDate, TotalCost, MechanicID, ApptID) VALUES 
(1,  1,  '2026-04-01', 7100.00, 1,  1), 
(2,  2,  '2026-04-03', 2080.00, 2,  2), 
(3,  3,  '2026-04-05', 28800.00, 3,  3), 
(4,  4,  '2026-04-08', 3500.00, 4,  4), 
(5,  5,  '2026-04-10', 3000.00, 5,  5), 
(6,  6,  '2026-04-12', 4750.00, 1,  6), 
(7,  7,  '2026-04-15', 8500.00, 7,  7), 
(8,  8,  '2026-04-18', 9500.00, 2,  8), 
(9,  9,  '2026-04-20', 5600.00, 3,  9), 
(10, 10, '2026-04-22', 12050.00, 5, 10);

-- ============================================================
-- 11. SERVICE_PARTS
-- ============================================================
REPLACE INTO SERVICE_PARTS (ServiceID, PartID, QuantityUsed) VALUES 
(1, 1, 1), (1, 6, 2), 
(2, 2, 1), (2, 16, 1), 
(3, 5, 4), 
(4, 6, 1), (4, 13, 2), 
(5, 4, 1), (5, 11, 1), (5, 6, 1), 
(6, 4, 1), (6, 6, 2), 
(7, 3, 1), 
(8, 10, 1), 
(9, 9, 2), 
(10, 4,  1), (10, 11, 1), (10, 6,  1), (10, 2,  1);

-- ============================================================
-- 12. INVOICE
-- ============================================================
REPLACE INTO INVOICE (InvoiceID, ServiceID, IssueDate, DueDate, Subtotal, TaxAmount, GrandTotal, Status, Notes) VALUES 
(1,  1,  '2026-04-01', '2026-05-01',  7100.00,  1136.00,  8236.00, 'Paid',    'Timing belt and oil change'), 
(2,  2,  '2026-04-03', '2026-05-03',  2080.00,   332.80,  2412.80, 'Paid',    'Brake pads and fluid'), 
(3,  3,  '2026-04-05', '2026-05-05', 28800.00,  4608.00, 33408.00, 'Paid',    '4 tyres replaced'), 
(4,  4,  '2026-04-08', '2026-05-08',  3500.00,   560.00,  4060.00, 'Paid',    'Oil change and coolant'), 
(5,  5,  '2026-04-10', '2026-05-10',  3000.00,   480.00,  3480.00, 'Paid',    'Full filter and oil service'), 
(6,  6,  '2026-04-12', '2026-05-12',  4750.00,   760.00,  5510.00, 'Paid',    'Oil and filter change'), 
(7,  7,  '2026-04-15', '2026-05-15',  8500.00,  1360.00,  9860.00, 'Pending', 'Battery replacement'), 
(8,  8,  '2026-04-18', '2026-05-18',  9500.00,  1520.00, 11020.00, 'Pending', 'Alternator replacement'), 
(9,  9,  '2026-04-20', '2026-05-20',  5600.00,   896.00,  6496.00, 'Overdue', 'Two brake discs'), 
(10, 10, '2026-04-22', '2026-05-22', 12050.00,  1928.00, 13978.00, 'Pending', 'Complete annual service');

-- ============================================================
-- 13. PAYMENT
-- ============================================================
REPLACE INTO PAYMENT (PaymentID, InvoiceID, MethodID, Amount, PaymentDate, ReferenceNo) VALUES 
(1, 1, 2, 8236.00,  '2026-04-02', 'CARD-TXN-20260402-001'), 
(2, 2, 1, 2412.80,  '2026-04-04', 'CASH-RCP-20260404-002'), 
(3, 3, 4, 33408.00, '2026-04-06', 'ONLN-TXN-20260406-003'), 
(4, 4, 3, 4060.00,  '2026-04-09', 'BNK-TRF-20260409-004'), 
(5, 5, 2, 3480.00,  '2026-04-11', 'CARD-TXN-20260411-005'), 
(6, 6, 1, 5510.00,  '2026-04-13', 'CASH-RCP-20260413-006'), 
(7, 9, 2, 3000.00,  '2026-04-21', 'CARD-TXN-20260421-007');

-- Reactivate integrity constraints now that structural seed arrays match
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- OPERATIONAL ACTIONS (Temporarily disabling safe updates)
-- ============================================================
SET SQL_SAFE_UPDATES = 0;

-- Replenish critical diagnostic and engine stock volumes
UPDATE INVENTORY  
SET StockQuantity = StockQuantity + 15  
WHERE StockQuantity < 15;

-- Purge legacy unserviced test scheduling metrics
DELETE FROM APPOINTMENT  
WHERE Status = 'Scheduled' AND ApptDateTime < '2026-05-01';

-- Re-enable target protection parameters safely
SET SQL_SAFE_UPDATES = 1;

-- ============================================================
-- VALIDATION METRICS & QUERIES
-- ============================================================

-- Audit Row counts utilizing safe escaped string parameters
SELECT 'SPECIALIZATION' AS TableName, COUNT(*) AS `Rows` FROM SPECIALIZATION 
UNION ALL SELECT 'PART_CATEGORY',   COUNT(*) FROM PART_CATEGORY  
UNION ALL SELECT 'SERVICE_TYPE',    COUNT(*) FROM SERVICE_TYPE   
UNION ALL SELECT 'PAYMENT_METHOD',  COUNT(*) FROM PAYMENT_METHOD 
UNION ALL SELECT 'OWNER',           COUNT(*) FROM OWNER          
UNION ALL SELECT 'MECHANIC',        COUNT(*) FROM MECHANIC       
UNION ALL SELECT 'VEHICLE',         COUNT(*) FROM VEHICLE        
UNION ALL SELECT 'INVENTORY',       COUNT(*) FROM INVENTORY      
UNION ALL SELECT 'APPOINTMENT',     COUNT(*) FROM APPOINTMENT    
UNION ALL SELECT 'SERVICE',         COUNT(*) FROM SERVICE        
UNION ALL SELECT 'SERVICE_PARTS',   COUNT(*) FROM SERVICE_PARTS  
UNION ALL SELECT 'INVOICE',         COUNT(*) FROM INVOICE        
UNION ALL SELECT 'PAYMENT',         COUNT(*) FROM PAYMENT;

-- Integrity check: Missing vehicle registry references
SELECT  
    COUNT(*) - COUNT(VehicleID) AS Null_VehicleID, 
    COUNT(*) - COUNT(PlateNumber) AS Null_PlateNo, 
    COUNT(*) - COUNT(OwnerID) AS Null_OwnerLink 
FROM VEHICLE LIMIT 0, 400;

-- Integrity check: Balanced settlement evaluations
SELECT  
    COUNT(*) - COUNT(InvoiceID) AS Null_InvoiceID, 
    COUNT(*) - COUNT(GrandTotal) AS Null_Totals, 
    COUNT(*) - COUNT(Status) AS Null_StatusField 
FROM INVOICE LIMIT 0, 400;

-- Executive KPI breakdown: Recent system transformations
SELECT  
    o.Name AS Customer, 
    v.PlateNumber AS VehiclePlate, 
    v.Model AS CarModel, 
    s.ServiceDate AS DateServiced, 
    i.GrandTotal AS InvoiceAmount, 
    i.Status AS PaymentStatus 
FROM OWNER o 
JOIN VEHICLE v ON o.OwnerID = v.OwnerID 
JOIN SERVICE s ON v.VehicleID = s.VehicleID 
JOIN INVOICE i ON s.ServiceID = i.ServiceID 
ORDER BY s.ServiceDate DESC 
LIMIT 5;