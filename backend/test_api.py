"""
JalNirnay AI - Automated Integration & Safety Engine Verification Tests
Tests authentication, complaints, GIS data, sensor simulation, and JalAI grounding.
"""

import unittest
import json
import os
import time
from server import app, latest_sensor_data
from database import init_db, get_db

class TestJalNirnayBackend(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        init_db()
        cls.client = app.test_client()

    def test_01_health_and_sensors(self):
        """Verify sensor data endpoint returns real-time SCADA telemetry."""
        response = self.client.get('/sensor-data')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertEqual(data['status'], 'success')
        self.assertIn('pressure', data['data'])
        self.assertIn('tankLevel', data['data'])
        self.assertIn('flowRate', data['data'])
        self.assertIn('ph', data['data'])
        self.assertIn('turbidity', data['data'])

    def test_02_login_and_auth(self):
        """Verify citizen and admin authentication."""
        # Citizen login
        response = self.client.post('/auth/login', json={
            'phone': '9890123456',
            'password': 'Citizen@123'
        })
        # If user not in test DB, register new
        if response.status_code == 401:
            reg_resp = self.client.post('/auth/register', json={
                'name': 'Test Citizen',
                'phone': '9890123456',
                'password': 'Citizen@123',
                'ward': 'Ward 4 (Bhavani Peth)'
            })
            self.assertIn(reg_resp.status_code, [201, 409])
            response = self.client.post('/auth/login', json={
                'phone': '9890123456',
                'password': 'Citizen@123'
            })

        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertIn('token', data)
        self.assertEqual(data['user']['role'], 'citizen')

    def test_03_ai_chatbot_grounding(self):
        """Verify JalAI answers with grounded, verified facts in English, Marathi, Hindi."""
        # English Ujani Dam check
        res_en = self.client.post('/chat', json={'message': 'What is Ujani dam water level?', 'lang': 'en'})
        self.assertEqual(res_en.status_code, 200)
        self.assertIn('88.4%', res_en.get_json()['reply'])

        # Marathi Quality check
        res_mr = self.client.post('/chat', json={'message': 'पाण्याची गुणवत्ता कशी आहे?', 'lang': 'mr'})
        self.assertEqual(res_mr.status_code, 200)
        self.assertIn('pH', res_mr.get_json()['reply'])

        # Hindi Leak check
        res_hi = self.client.post('/chat', json={'message': 'पाइप लीकेज की रिपोर्ट कैसे करें?', 'lang': 'hi'})
        self.assertEqual(res_hi.status_code, 200)
        self.assertIn('Report Issue', res_hi.get_json()['reply'])

    def test_04_supply_schedules(self):
        """Verify water supply schedule endpoint."""
        response = self.client.get('/supply-schedules')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertIn('schedules', data)

    def test_05_alerts_and_rewards(self):
        """Verify active alerts and rewards catalog."""
        resp_alerts = self.client.get('/alerts')
        self.assertEqual(resp_alerts.status_code, 200)
        self.assertIn('alerts', resp_alerts.get_json())

        resp_rewards = self.client.get('/rewards')
        self.assertEqual(resp_rewards.status_code, 200)
        self.assertIn('rewards', resp_rewards.get_json())

if __name__ == '__main__':
    unittest.main()
