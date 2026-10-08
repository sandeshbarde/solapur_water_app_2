import os
import json
import time
import uuid
import sqlite3
from werkzeug.security import generate_password_hash
from database import get_db, init_db

def seed_database():
    init_db()
    conn = get_db()
    cursor = conn.cursor()

    admin_pwd = os.environ.get('ADMIN_DEFAULT_PASSWORD', 'Admin@Solapur2026')
    admin_hash = generate_password_hash(admin_pwd)

    # 1. Seed Default Admin & Sample Officer & Citizen
    cursor.execute("SELECT id FROM users WHERE phone = ?", ('9876543210',))
    if not cursor.fetchone():
        cursor.execute('''
        INSERT INTO users (id, name, email, phone, password_hash, role, ward, consumer_number, points, level, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', ('USR-ADMIN-001', 'SMC Water Admin', 'admin@smc.gov.in', '9876543210', admin_hash, 'admin', 'Central Solapur', 'ADMIN-001', 9999, 10, int(time.time())))
        print("Admin user seeded: 9876543210")

    # Sample Citizen
    citizen_hash = generate_password_hash('Citizen@123')
    cursor.execute("SELECT id FROM users WHERE phone = ?", ('9890123456',))
    if not cursor.fetchone():
        cursor.execute('''
        INSERT INTO users (id, name, email, phone, password_hash, role, ward, consumer_number, points, level, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', ('USR-CITIZEN-001', 'Aniket Joshi', 'aniket.solapur@gmail.com', '9890123456', citizen_hash, 'citizen', 'Ward 4 (Bhavani Peth)', 'SLP-W4-8842', 340, 3, int(time.time())))
        print("Sample citizen seeded: 9890123456")

    # 2. Seed Wards / Supply Schedules
    schedules = [
        ('SCH-01', 'Ward 1 (Ashok Chowk)', 'Ashok Chowk & Navi Peth', '06:00 AM - 08:30 AM', 2.5, 'Daily', 'on_time'),
        ('SCH-02', 'Ward 2 (Saat Rasta)', 'Saat Rasta & Civil Lines', '07:30 AM - 10:00 AM', 2.5, 'Mon, Wed, Fri', 'on_time'),
        ('SCH-03', 'Ward 3 (Jule Solapur)', 'Sector 1 to 4 & D-Mart Area', '05:30 AM - 08:00 AM', 2.5, 'Daily', 'on_time'),
        ('SCH-04', 'Ward 4 (Bhavani Peth)', 'Bhavani Peth Old Market', '08:00 AM - 10:30 AM', 2.5, 'Tue, Thu, Sat', 'on_time'),
        ('SCH-05', 'Ward 5 (MIDC Area)', 'Chincholi MIDC Phase 1', '06:00 PM - 09:00 PM', 3.0, 'Daily', 'delayed'),
    ]

    for s in schedules:
        cursor.execute("SELECT id FROM supply_schedules WHERE id = ?", (s[0],))
        if not cursor.fetchone():
            cursor.execute('''
            INSERT INTO supply_schedules (id, ward, area_name, supply_time, duration_hours, days, status, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (s[0], s[1], s[2], s[3], s[4], s[5], s[6], int(time.time())))

    # 3. Seed Initial Alerts
    alerts = [
        ('ALT-01', 'Ujani Dam Level at 88.4%', 'Water storage adequate for summer supply. SMC pipeline maintenance scheduled for Friday.', 'info', 'All Wards', 'Chief Water Engineer', int(time.time()), 1),
        ('ALT-02', 'Pipeline Maintenance in Ward 5', 'Brief 2-hour pressure reduction in MIDC area due to automated valve recalibration.', 'warning', 'Ward 5 (MIDC Area)', 'SMC SCADA Cell', int(time.time()) - 3600, 1),
    ]

    for a in alerts:
        cursor.execute("SELECT id FROM alerts WHERE id = ?", (a[0],))
        if not cursor.fetchone():
            cursor.execute('''
            INSERT INTO alerts (id, title, message, description, severity, type, ward_number, ward, issued_by, created_at, timestamp, active)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (a[0], a[1], a[2], a[2], a[3], a[3], 1, a[4], a[5], a[6], a[6], a[7]))

    # 4. Seed Rewards Catalog
    rewards = [
        ('REW-01', '10% Off Solapur Property/Water Tax', 300, '10% Rebate', 'Tax Rebate', 'Valid on next annual municipal tax assessment bill.', int(time.time()) + 86400 * 90),
        ('REW-02', 'Free Domestic Water Quality Testing Kit', 200, 'Free Kit', 'Utility Voucher', 'Collect test kit from SMC Ward Office or get home delivery.', int(time.time()) + 86400 * 90),
        ('REW-03', 'Tree Plantation in Your Name (SMC Green Solapur)', 150, 'Green Certificate', 'Civic Action', 'SMC parks department will plant a native tree in your ward.', int(time.time()) + 86400 * 180),
        ('REW-04', '₹100 City Bus (SMT) Smart Card Topup', 100, '₹100 Top-up', 'Transport', 'Instant recharge voucher for Solapur city bus travel.', int(time.time()) + 86400 * 60),
    ]

    for r in rewards:
        cursor.execute("SELECT id FROM rewards WHERE id = ?", (r[0],))
        if not cursor.fetchone():
            cursor.execute('''
            INSERT INTO rewards (id, title, points_required, discount_value, category, description, expires_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', r)

    # 5. Seed Sample Properties (Housing, Hotel, Industry)
    cursor.execute("SELECT id FROM users WHERE phone = '9890123456'")
    citizen_row = cursor.fetchone()
    cid = citizen_row[0] if citizen_row and citizen_row[0] is not None else 1
    if cid:
        sample_props = [
            (
                'PROP-HSG-01', cid, 'housing', 'Shree Siddheshwar Co-op Housing Society',
                'Plot 42, Near D-Mart, Jule Solapur', 'Ward 3 (Jule Solapur)',
                json.dumps({'societyName': 'Shree Siddheshwar CHS', 'totalFlats': 48, 'occupiedFlats': 44, 'avgFamilySize': 4, 'meterNumber': 'MTR-JLE-8821', 'tankCapacityLiters': 45000, 'dailyAvgConsumptionLiters': 18500}),
                json.dumps([
                    {'month': 'Jan', 'liters': 540000, 'cost': 8100},
                    {'month': 'Feb', 'liters': 510000, 'cost': 7650},
                    {'month': 'Mar', 'liters': 565000, 'cost': 8475},
                    {'month': 'Apr', 'liters': 590000, 'cost': 8850},
                ]),
                json.dumps([{'billNo': 'BILL-2026-03', 'amount': 8475, 'dueDate': '15 Apr 2026', 'status': 'Paid'}]),
                json.dumps([]),
                json.dumps([]),
                int(time.time()), int(time.time())
            ),
            (
                'PROP-HTL-01', cid, 'hotel', 'Balaji Grand Residency & Dining',
                'Old Pune Naka, Solapur', 'Ward 2 (Saat Rasta)',
                json.dumps({'hotelName': 'Balaji Grand Residency', 'totalRooms': 36, 'occupancyRatePct': 75.0, 'kitchenUsageLiters': 4200, 'laundryUsageLiters': 3800, 'tankerTripsThisMonth': 2, 'licenseNumber': 'HTL-SMC-2024-91'}),
                json.dumps([
                    {'month': 'Jan', 'liters': 240000, 'cost': 12000},
                    {'month': 'Feb', 'liters': 230000, 'cost': 11500},
                    {'month': 'Mar', 'liters': 255000, 'cost': 12750},
                ]),
                json.dumps([{'billNo': 'BILL-HTL-2603', 'amount': 12750, 'dueDate': '20 Apr 2026', 'status': 'Pending'}]),
                json.dumps([{'requestId': 'REQ-TNK-01', 'type': 'Emergency Tanker (10kL)', 'status': 'Dispatched', 'date': '02 Apr 2026'}]),
                json.dumps([]),
                int(time.time()), int(time.time())
            ),
            (
                'PROP-IND-01', cid, 'industry', 'Solapur Textile Processors Pvt Ltd',
                'Plot C-14, Chincholi MIDC Phase 2', 'Ward 5 (MIDC Area)',
                json.dumps({'unitName': 'Solapur Textile Processors', 'licenseNumber': 'MPCB-IND-2023-4412', 'processWaterDailyLiters': 48000, 'dischargeVolumeDailyLiters': 42000, 'etpStatus': 'Fully Operational (ZLD)', 'primarySource': 'SMC Industrial Pipeline + Recycled ETP'}),
                json.dumps([
                    {'month': 'Jan', 'liters': 1400000, 'cost': 70000},
                    {'month': 'Feb', 'liters': 1350000, 'cost': 67500},
                    {'month': 'Mar', 'liters': 1440000, 'cost': 72000},
                ]),
                json.dumps([{'billNo': 'BILL-IND-991', 'amount': 72000, 'dueDate': '25 Apr 2026', 'status': 'Paid'}]),
                json.dumps([]),
                json.dumps([]),
                int(time.time()), int(time.time())
            )
        ]

        for p in sample_props:
            cursor.execute("SELECT id FROM properties WHERE id = ?", (p[0],))
            if not cursor.fetchone():
                cursor.execute('''
                INSERT INTO properties (id, user_id, property_type, name, address, ward, ward_number, consumer_number, metadata, details_json, usage_history, bills, requests, documents, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (p[0], p[1], p[2], p[3], p[4], p[5], 1, f"MTR-{p[0]}", p[6], p[6], p[7], p[8], p[9], p[10], p[11], p[12]))

    # 6. Seed Sample Complaints with Full Status History
    complaints = [
        (
            'CMP-2026-8801', cid, 'Pipe Leakage', 'Major drinking water pipeline burst near Ashok Chowk bus stop. Water overflowing on main road.',
            'Ward 1 (Ashok Chowk)', 'Near Bus Stop, Ashok Chowk, Solapur', 17.6635, 75.9120, 'inProgress', 'high',
            'Er. Ramesh Patil (SMC Ward 1)', 'Repair crew dispatched with excavator. Expected resolution in 3 hours.',
            json.dumps([{'url': '/uploads/sample_leak.jpg', 'name': 'leak_photo.jpg', 'type': 'image/jpeg', 'size': 142000}]),
            json.dumps([
                {'status': 'pending', 'timestamp': int(time.time()) - 7200, 'note': 'Complaint registered by citizen'},
                {'status': 'inProgress', 'timestamp': int(time.time()) - 3600, 'note': 'Assigned to Er. Ramesh Patil (SMC Ward 1). Repair team on site.'}
            ]),
            int(time.time()) - 7200, int(time.time()) - 3600
        ),
        (
            'CMP-2026-8802', cid, 'Water Contamination', 'Yellowish water with mild odor observed in morning supply in Bhavani Peth area.',
            'Ward 4 (Bhavani Peth)', 'Lane 3, Bhavani Peth', 17.6570, 75.9010, 'pending', 'high',
            None, None,
            json.dumps([]),
            json.dumps([{'status': 'pending', 'timestamp': int(time.time()) - 1800, 'note': 'Complaint logged into SMC Central SCADA system'}]),
            int(time.time()) - 1800, int(time.time()) - 1800
        )
    ]

    for c in complaints:
        cursor.execute("SELECT id FROM complaints WHERE id = ?", (c[0],))
        if not cursor.fetchone():
            cursor.execute('''
            INSERT INTO complaints (id, user_id, user_name, user_phone, title, category, description, ward_number, ward, address, latitude, longitude, status, priority, officer_assigned, assigned_officer, admin_notes, officer_note, attachments, timeline, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (c[0], c[1], 'Citizen', '9890123456', c[2], c[2], c[3], 1, c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[10], c[11], c[11], c[12], c[13], c[14], c[15]))

    conn.commit()
    conn.close()
    print("Seed process completed successfully!")

if __name__ == '__main__':
    seed_database()
