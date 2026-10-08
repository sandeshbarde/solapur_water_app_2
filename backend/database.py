import sqlite3
import os
import json
import time
from werkzeug.security import generate_password_hash

DB_PATH = os.path.join(os.path.dirname(__file__), 'solapur_water.db')

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn

def init_db():
    conn = get_db()
    cursor = conn.cursor()

    # Users Table
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        phone TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'citizen', -- 'citizen', 'admin', 'officer'
        ward TEXT,
        consumer_number TEXT,
        points INTEGER DEFAULT 120,
        level INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL
    )
    ''')

    # Complaints Table
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS complaints (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        ward TEXT NOT NULL,
        address TEXT,
        latitude REAL,
        longitude REAL,
        status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'inProgress', 'resolved', 'rejected'
        priority TEXT DEFAULT 'medium',
        assigned_officer TEXT,
        officer_note TEXT,
        attachments TEXT, -- JSON array of file objects
        timeline TEXT, -- JSON array of status history objects
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
    )
    ''')

    # Sensor Readings & Latest Cache
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS sensor_readings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        pressure REAL,
        tank_level REAL,
        flow_rate REAL,
        rainfall REAL,
        ph REAL,
        turbidity REAL,
        chlorine REAL,
        tds REAL,
        timestamp INTEGER NOT NULL
    )
    ''')

    # Properties Table (Housing, Hotel, Industry)
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS properties (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        property_type TEXT NOT NULL, -- 'housing', 'hotel', 'industry'
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        ward TEXT NOT NULL,
        metadata TEXT NOT NULL, -- JSON specific to type
        usage_history TEXT, -- JSON array of historical entries
        bills TEXT, -- JSON array of bills
        requests TEXT, -- JSON array of service requests
        documents TEXT, -- JSON array of uploaded verification docs
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
    )
    ''')

    # Alerts Table
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS alerts (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'info', -- 'critical', 'warning', 'info'
        ward TEXT,
        issued_by TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        active INTEGER DEFAULT 1
    )
    ''')

    # Water Supply Schedule Table
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS supply_schedules (
        id TEXT PRIMARY KEY,
        ward TEXT NOT NULL,
        area_name TEXT NOT NULL,
        supply_time TEXT NOT NULL,
        duration_hours REAL NOT NULL,
        days TEXT NOT NULL, -- e.g. "Mon, Wed, Fri" or "Daily"
        status TEXT NOT NULL DEFAULT 'on_time', -- 'on_time', 'delayed', 'cancelled'
        updated_at INTEGER NOT NULL
    )
    ''')

    # Rewards / Points Catalog Table
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS rewards (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        points_required INTEGER NOT NULL,
        discount_value TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        expires_at INTEGER
    )
    ''')

    # Reward Redemptions History
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS redemptions (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        reward_id TEXT NOT NULL,
        reward_title TEXT NOT NULL,
        points_spent INTEGER NOT NULL,
        coupon_code TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
    )
    ''')

    conn.commit()
    conn.close()
    print("SQLite Database initialized successfully.")

if __name__ == '__main__':
    init_db()
