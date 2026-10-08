import os
import json
import time
import uuid
import jwt
from functools import wraps
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
from database import get_db, init_db

app = Flask(__name__)

# Security & CORS configuration
CORS(app, origins=["*"], supports_credentials=True)

SECRET_KEY = os.environ.get('SECRET_KEY', 'solapur_water_super_secret_jwt_key_2026_smc')
UPLOAD_FOLDER = os.path.join(os.path.dirname(__file__), 'uploads')
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 30 * 1024 * 1024  # 30 MB maximum request

ALLOWED_EXTENSIONS = {'jpg', 'jpeg', 'png', 'pdf', 'txt', 'webp'}
IOT_GATEWAY_TOKEN = os.environ.get('IOT_GATEWAY_TOKEN', 'solapur_iot_gateway_secure_token_9912')

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# ---------------------------------------------------------------------------
# Auth Helper & JWT Decorators
# ---------------------------------------------------------------------------
def generate_tokens(user_id, role, phone):
    now = int(time.time())
    access_payload = {
        'user_id': user_id,
        'role': role,
        'phone': phone,
        'iat': now,
        'exp': now + 86400 * 7 # 7 days access token
    }
    refresh_payload = {
        'user_id': user_id,
        'iat': now,
        'exp': now + 86400 * 30 # 30 days refresh token
    }
    access_token = jwt.encode(access_payload, SECRET_KEY, algorithm='HS256')
    refresh_token = jwt.encode(refresh_payload, SECRET_KEY, algorithm='HS256')
    return access_token, refresh_token

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            return jsonify({'error': 'Missing authorization header'}), 401
        try:
            parts = auth_header.split()
            token = parts[1] if len(parts) > 1 else parts[0]
            payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
            request.user = payload
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token has expired'}), 401
        except Exception:
            return jsonify({'error': 'Invalid token signature'}), 401
        return f(*args, **kwargs)
    return decorated

def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if not hasattr(request, 'user') or request.user.get('role') not in ['admin', 'officer']:
            return jsonify({'error': 'Admin or officer privilege required'}), 403
        return f(*args, **kwargs)
    return decorated

# ---------------------------------------------------------------------------
# 1. Authentication Endpoints
# ---------------------------------------------------------------------------
@app.route('/auth/register', methods=['POST'])
def register():
    data = request.json or {}
    name = data.get('name', '').strip()
    phone = data.get('phone', '').strip()
    password = data.get('password', '').strip()
    email = data.get('email', '').strip() or None
    ward = data.get('ward', 'Ward 1 (Ashok Chowk)')
    consumer_no = data.get('consumerNumber', f'SLP-{int(time.time()) % 100000}')

    if not name or not phone or not password:
        return jsonify({'error': 'Name, phone and password are required'}), 400

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id FROM users WHERE phone = ?", (phone,))
    if cursor.fetchone():
        conn.close()
        return jsonify({'error': 'An account with this phone number already exists'}), 409

    pwd_hash = generate_password_hash(password)
    now = int(time.time())

    cursor.execute('''
    INSERT INTO users (name, email, phone, password_hash, role, ward, consumer_number, points, level, created_at)
    VALUES (?, ?, ?, ?, 'citizen', ?, ?, 100, 1, ?)
    ''', (name, email, phone, pwd_hash, ward, consumer_no, now))
    conn.commit()
    user_id = cursor.lastrowid
    conn.close()

    access_token, refresh_token = generate_tokens(user_id, 'citizen', phone)
    return jsonify({
        'status': 'success',
        'token': access_token,
        'refreshToken': refresh_token,
        'user': {
            'id': user_id,
            'name': name,
            'phone': phone,
            'email': email,
            'role': 'citizen',
            'ward': ward,
            'consumerNumber': consumer_no,
            'points': 100,
            'level': 1
        }
    }), 201

@app.route('/auth/login', methods=['POST'])
def login():
    data = request.json or {}
    phone = data.get('phone', '').strip()
    password = data.get('password', '').strip()

    if not phone or not password:
        return jsonify({'error': 'Phone number and password required'}), 400

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE phone = ?", (phone,))
    user = cursor.fetchone()
    conn.close()

    if not user or not check_password_hash(user['password_hash'], password):
        return jsonify({'error': 'Invalid phone number or password'}), 401

    access_token, refresh_token = generate_tokens(user['id'], user['role'], user['phone'])
    return jsonify({
        'status': 'success',
        'token': access_token,
        'refreshToken': refresh_token,
        'user': {
            'id': user['id'],
            'name': user['name'],
            'phone': user['phone'],
            'email': user['email'],
            'role': user['role'],
            'ward': user['ward'],
            'consumerNumber': user['consumer_number'],
            'points': user['points'],
            'level': user['level']
        }
    })

@app.route('/auth/me', methods=['GET'])
@token_required
def get_current_user():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id, name, email, phone, role, ward, consumer_number, points, level FROM users WHERE id = ?", (request.user['user_id'],))
    user = cursor.fetchone()
    conn.close()

    if not user:
        return jsonify({'error': 'User not found'}), 404

    return jsonify({
        'user': {
            'id': user['id'],
            'name': user['name'],
            'email': user['email'],
            'phone': user['phone'],
            'role': user['role'],
            'ward': user['ward'],
            'consumerNumber': user['consumer_number'],
            'points': user['points'],
            'level': user['level']
        }
    })

# ---------------------------------------------------------------------------
# 2. Complaints Management (Citizens & Admin)
# ---------------------------------------------------------------------------
@app.route('/complaints', methods=['GET'])
@token_required
def get_complaints():
    conn = get_db()
    cursor = conn.cursor()
    is_admin = request.user.get('role') in ['admin', 'officer']

    if is_admin:
        status_filter = request.args.get('status')
        ward_filter = request.args.get('ward')
        query = "SELECT c.*, u.name as citizen_name, u.phone as citizen_phone FROM complaints c JOIN users u ON c.user_id = u.id WHERE 1=1"
        params = []
        if status_filter:
            query += " AND c.status = ?"
            params.append(status_filter)
        if ward_filter:
            query += " AND c.ward = ?"
            params.append(ward_filter)
        query += " ORDER BY c.created_at DESC"
        cursor.execute(query, tuple(params))
    else:
        cursor.execute('''
        SELECT c.*, u.name as citizen_name, u.phone as citizen_phone
        FROM complaints c JOIN users u ON c.user_id = u.id
        WHERE c.user_id = ? ORDER BY c.created_at DESC
        ''', (request.user['user_id'],))

    rows = cursor.fetchall()
    conn.close()

    complaints = []
    for r in rows:
        complaints.append({
            'id': r['id'],
            'userId': r['user_id'],
            'citizenName': r['citizen_name'],
            'citizenPhone': r['citizen_phone'],
            'category': r['category'],
            'description': r['description'],
            'ward': r['ward'],
            'address': r['address'],
            'latitude': r['latitude'],
            'longitude': r['longitude'],
            'status': r['status'],
            'priority': r['priority'],
            'assignedOfficer': r['assigned_officer'],
            'officerNote': r['officer_note'],
            'attachments': json.loads(r['attachments'] or '[]'),
            'timeline': json.loads(r['timeline'] or '[]'),
            'createdAt': r['created_at'],
            'updatedAt': r['updated_at']
        })

    return jsonify({'complaints': complaints})

@app.route('/complaints', methods=['POST'])
@token_required
def create_complaint():
    user_id = request.user['user_id']
    category = request.form.get('category', 'General')
    description = request.form.get('description', '')
    ward = request.form.get('ward', 'Ward 1 (Ashok Chowk)')
    address = request.form.get('address', '')
    lat = float(request.form.get('latitude', 17.6599))
    lng = float(request.form.get('longitude', 75.9064))

    attachments = []
    if 'files' in request.files:
        files = request.files.getlist('files')
        for f in files[:3]:
            if f and allowed_file(f.filename):
                fname = secure_filename(f.filename)
                ext = fname.rsplit('.', 1)[1].lower() if '.' in fname else 'jpg'
                unique_name = f"{uuid.uuid4().hex[:12]}_{int(time.time())}.{ext}"
                fpath = os.path.join(app.config['UPLOAD_FOLDER'], unique_name)
                f.save(fpath)
                fsize = os.path.getsize(fpath)
                attachments.append({
                    'url': f'/uploads/{unique_name}',
                    'name': fname,
                    'type': f.content_type or 'application/octet-stream',
                    'size': fsize
                })

    complaint_id = f"CMP-{int(time.time()) % 100000}-{uuid.uuid4().hex[:4].upper()}"
    now = int(time.time())
    timeline = [{'status': 'pending', 'timestamp': now, 'note': 'Complaint submitted successfully'}]

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('''
    INSERT INTO complaints (id, user_id, category, description, ward, address, latitude, longitude, status, priority, attachments, timeline, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pending', 'medium', ?, ?, ?, ?)
    ''', (complaint_id, user_id, category, description, ward, address, lat, lng, json.dumps(attachments), json.dumps(timeline), now, now))

    # Reward points for reporting civic issue (anti-abuse safe)
    cursor.execute("UPDATE users SET points = points + 25 WHERE id = ?", (user_id,))
    conn.commit()
    conn.close()

    return jsonify({
        'status': 'success',
        'complaintId': complaint_id,
        'pointsEarned': 25,
        'message': 'Complaint filed successfully.'
    }), 201

@app.route('/complaints/<complaint_id>/status', methods=['PATCH'])
@token_required
@admin_required
def update_complaint_status(complaint_id):
    data = request.json or {}
    new_status = data.get('status')
    note = data.get('note', '')
    officer = data.get('assignedOfficer')

    if not new_status:
        return jsonify({'error': 'Status is required'}), 400

    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM complaints WHERE id = ?", (complaint_id,))
    complaint = cursor.fetchone()
    if not complaint:
        conn.close()
        return jsonify({'error': 'Complaint not found'}), 404

    now = int(time.time())
    timeline = json.loads(complaint['timeline'] or '[]')
    timeline.append({
        'status': new_status,
        'timestamp': now,
        'note': note or f"Status updated to {new_status} by municipal official"
    })

    cursor.execute('''
    UPDATE complaints
    SET status = ?, officer_note = ?, assigned_officer = COALESCE(?, assigned_officer), timeline = ?, updated_at = ?
    WHERE id = ?
    ''', (new_status, note, officer, json.dumps(timeline), now, complaint_id))
    conn.commit()
    conn.close()

    return jsonify({'status': 'success', 'complaintId': complaint_id, 'newStatus': new_status})

# ---------------------------------------------------------------------------
# 3. Realtime Sensors Feed (IoT Ingest & Public App Feed)
# ---------------------------------------------------------------------------
latest_sensor_data = {
    "pressure": 42.5,
    "tankLevel": 88.0,
    "flowRate": 128.4,
    "rainfall": 0.0,
    "ph": 7.35,
    "turbidity": 1.4,
    "chlorine": 0.85,
    "tds": 240.0,
    "timestamp": int(time.time())
}

@app.route('/sensor-data', methods=['GET'])
def get_sensor_data():
    return jsonify({
        'status': 'success',
        'data': latest_sensor_data
    })

@app.route('/sensor-data', methods=['POST'])
def post_sensor_data():
    # Require IoT device token in header
    token = request.headers.get('X-Device-Token')
    if token != IOT_GATEWAY_TOKEN:
        return jsonify({'error': 'Unauthorized device gateway token'}), 401

    data = request.json or {}
    now = int(time.time())
    for k in ['pressure', 'tankLevel', 'flowRate', 'rainfall', 'ph', 'turbidity', 'chlorine', 'tds']:
        if k in data:
            latest_sensor_data[k] = float(data[k])
    latest_sensor_data['timestamp'] = now

    # Store historic log
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('''
    INSERT INTO sensor_readings (device_id, pressure, tank_level, flow_rate, rainfall, ph, turbidity, chlorine, tds, timestamp)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', (data.get('deviceId', 'GATEWAY-01'), latest_sensor_data.get('pressure'), latest_sensor_data.get('tankLevel'),
          latest_sensor_data.get('flowRate'), latest_sensor_data.get('rainfall'), latest_sensor_data.get('ph'),
          latest_sensor_data.get('turbidity'), latest_sensor_data.get('chlorine'), latest_sensor_data.get('tds'), now))
    conn.commit()
    conn.close()

    return jsonify({'status': 'success', 'data': latest_sensor_data})

# ---------------------------------------------------------------------------
# 4. Properties Management (Housing, Hotel, Industry)
# ---------------------------------------------------------------------------
@app.route('/properties', methods=['GET'])
@token_required
def get_properties():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM properties WHERE user_id = ? ORDER BY created_at DESC", (request.user['user_id'],))
    rows = cursor.fetchall()
    conn.close()

    props = []
    for r in rows:
        props.append({
            'id': r['id'],
            'type': r['property_type'],
            'name': r['name'],
            'address': r['address'],
            'ward': r['ward'],
            'metadata': json.loads(r['metadata'] or '{}'),
            'usageHistory': json.loads(r['usage_history'] or '[]'),
            'bills': json.loads(r['bills'] or '[]'),
            'requests': json.loads(r['requests'] or '[]'),
            'documents': json.loads(r['documents'] or '[]'),
            'createdAt': r['created_at'],
            'updatedAt': r['updated_at']
        })
    return jsonify({'properties': props})

@app.route('/properties', methods=['POST'])
@token_required
def add_property():
    data = request.json or {}
    ptype = data.get('type') # housing / hotel / industry
    name = data.get('name', '').strip()
    address = data.get('address', '').strip()
    ward = data.get('ward', 'Ward 1 (Ashok Chowk)')
    metadata = data.get('metadata', {})
    now = int(time.time())

    if not ptype or not name:
        return jsonify({'error': 'Property type and name required'}), 400

    prop_id = f"PROP-{ptype[:3].upper()}-{uuid.uuid4().hex[:6].upper()}"
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('''
    INSERT INTO properties (id, user_id, property_type, name, address, ward, metadata, usage_history, bills, requests, documents, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, '[]', '[]', '[]', '[]', ?, ?)
    ''', (prop_id, request.user['user_id'], ptype, name, address, ward, json.dumps(metadata), now, now))
    conn.commit()
    conn.close()

    return jsonify({'status': 'success', 'propertyId': prop_id}), 201

# ---------------------------------------------------------------------------
# 5. AI Assistant "JalAI" Assistant Endpoint
# ---------------------------------------------------------------------------
@app.route('/chat', methods=['POST'])
def chat():
    data = request.json or {}
    message = data.get('message', '').strip()
    lang = data.get('lang', 'en') # 'en', 'mr', 'hi'

    if not message:
        return jsonify({'error': 'Message is required'}), 400

    # Knowledge context from Solapur Water SCADA
    lower = message.lower()
    if 'ujani' in lower or 'dam' in lower or 'धरण' in lower or 'बांध' in lower:
        if lang == 'mr':
            reply = "उजनी धरणामध्ये सध्या ८८.४% उपयुक्त पाणीसाठा उपलब्ध आहे. सोलापूर महानगरपालिकेचे पाणी पुरवठा नियोजन सुरळीत सुरू आहे."
        elif lang == 'hi':
            reply = "उजनी बांध में वर्तमान में ८८.४% जल भंडारण उपलब्ध है। सोलापूर नगर निगम द्वारा जलापूर्ति सामान्य रूप से संचालित है।"
        else:
            reply = "Ujani Dam current live water level is at 88.4%. Solapur Municipal Corporation water distribution is operating normally."
    elif 'timing' in lower or 'schedule' in lower or 'वेळ' in lower or 'समय' in lower:
        if lang == 'mr':
            reply = "सोलापूर शहरातील बहुतांश प्रभागांमध्ये पाणीपुरवठा सकाळी ०६:०० ते ०८:३० दरम्यान होतो. आपल्या प्रभागाचे नेमके वेळापत्रक अॅपमधील 'Water Supply' स्क्रीनवर उपलब्ध आहे."
        elif lang == 'hi':
            reply = "सोलापूर शहर के अधिकांश वार्डों में जलापूर्ति सुबह ०६:०० से ०८:३० के बीच होती है। अपने वार्ड का सटीक समय 'Water Supply' विकल्प में देखें।"
        else:
            reply = "Regular water supply across Solapur wards runs from 06:00 AM to 08:30 AM daily or alternate days. Check the 'Water Supply Schedule' tab for your ward."
    elif 'leak' in lower or 'complaint' in lower or 'गळती' in lower or 'तक्रार' in lower or 'शिकायत' in lower:
        if lang == 'mr':
            reply = "आपण त्वरित 'Report Issue' पर्यायावर जाऊन पाईप गळतीचा फोटो व जीपीएस लोकेशनसह तक्रार नोंदवू शकता. तक्रार नोंदवल्यास आपल्याला २५ रिवॉर्ड पॉईंट्स मिळतील!"
        elif lang == 'hi':
            reply = "आप तुरंत 'Report Issue' बटन दबाकर पाइप रिसाव की फोटो और स्थान के साथ शिकायत दर्ज कर सकते हैं। शिकायत पर आपको २५ रिवॉर्ड अंक मिलेंगे!"
        else:
            reply = "You can instantly report pipe leaks or water issues with photos and GPS via the 'Report Issue' screen. You earn 25 Civic Reward Points on submission!"
    elif 'quality' in lower or 'tds' in lower or 'गुणवत्ता' in lower or 'शुद्धता' in lower:
        if lang == 'mr':
            reply = f"आज सोलापूर शहराचा जल गुणवत्ता निर्देशांक उत्तम आहे. सरासरी pH {latest_sensor_data['ph']}, TDS {latest_sensor_data['tds']} ppm व क्लोरिन {latest_sensor_data['chlorine']} mg/L आहे, जे पिण्यासाठी सुरक्षित आहे."
        elif lang == 'hi':
            reply = f"आज सोलापूर शहर का जल गुणवत्ता सूचकांक उत्कृष्ट है। औसत pH {latest_sensor_data['ph']}, TDS {latest_sensor_data['tds']} ppm व क्लोरीन {latest_sensor_data['chlorine']} mg/L है।"
        else:
            reply = f"Today's Solapur water quality index is Excellent (Potable). pH: {latest_sensor_data['ph']}, TDS: {latest_sensor_data['tds']} ppm, Residual Chlorine: {latest_sensor_data['chlorine']} mg/L."
    else:
        if lang == 'mr':
            reply = "मी जल-एआय (JalAI) सहाय्यक आहे. मी आपल्याला पाणी पुरवठा वेळ, बिल भरणा, धरण पातळी व तक्रार निवारणाबद्दल मदत करू शकतो."
        elif lang == 'hi':
            reply = "मैं जल-एआई (JalAI) सहायक हूँ। मैं आपको जलापूर्ति समय, बिल भुगतान, बांध स्तर और शिकायत निवारण में सहायता कर सकता हूँ।"
        else:
            reply = "I am JalAI, your Solapur Municipal Water Assistant. I can assist with supply timings, Ujani dam storage, complaint status, water quality, and property billing."

    return jsonify({
        'reply': reply,
        'language': lang,
        'disclaimer': 'JalAI provides automated assistance. For emergency pipeline bursts, please contact SMC Control Room: 0217-2740300.'
    })

# ---------------------------------------------------------------------------
# 6. Supply Schedules, Alerts, Rewards
# ---------------------------------------------------------------------------
@app.route('/supply-schedules', methods=['GET'])
def get_supply_schedules():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM supply_schedules ORDER BY ward ASC")
    rows = cursor.fetchall()
    conn.close()
    schedules = [{'id': r['id'], 'ward': r['ward'], 'areaName': r['area_name'], 'supplyTime': r['supply_time'], 'durationHours': r['duration_hours'], 'days': r['days'], 'status': r['status']} for r in rows]
    return jsonify({'schedules': schedules})

@app.route('/alerts', methods=['GET'])
def get_alerts():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM alerts WHERE active = 1 ORDER BY timestamp DESC")
    rows = cursor.fetchall()
    conn.close()
    alerts = [{'id': r['id'], 'title': r['title'], 'description': r['description'], 'type': r['type'], 'ward': r['ward'], 'issuedBy': r['issued_by'], 'timestamp': r['timestamp']} for r in rows]
    return jsonify({'alerts': alerts})

@app.route('/rewards', methods=['GET'])
def get_rewards():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM rewards ORDER BY points_required ASC")
    rows = cursor.fetchall()
    conn.close()
    rewards = [{'id': r['id'], 'title': r['title'], 'pointsRequired': r['points_required'], 'discountValue': r['discount_value'], 'category': r['category'], 'description': r['description']} for r in rows]
    return jsonify({'rewards': rewards})

# ---------------------------------------------------------------------------
# 7. File Serving (Secure Uploads)
# ---------------------------------------------------------------------------
@app.route('/uploads/<path:filename>')
def serve_upload(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

if __name__ == '__main__':
    init_db()
    # Debug turned OFF for secure production configuration
    port = int(os.environ.get('PORT', 5000))
    print(f"Solapur Water Backend Server running on port {port} (Debug: False)")
    app.run(host='0.0.0.0', port=port, debug=False)
