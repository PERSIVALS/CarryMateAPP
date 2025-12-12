#!/usr/bin/env python3
"""
Raspberry Pi MQTT Bridge untuk CarryMate Robot
- Subscribe: carrymate/mobile/command (terima perintah dari mobile)
- Publish: carrymate/robot/telemetry (kirim data sensor ke mobile)
"""

import json
import time
import random
import paho.mqtt.client as mqtt

# Konfigurasi MQTT
BROKER = "broker.hivemq.com"
PORT = 1883
COMMAND_TOPIC = "carrymate/mobile/command"
TELEMETRY_TOPIC = "carrymate/robot/telemetry"

# State robot (simulasi - ganti dengan sensor & motor asli)
robot_state = {
    "battery": 85.0,
    "range": 1.5,
    "weight": 5.0,
    "calories": 107,
    "steps": 1075,
    "mode": "AUTOMATIC",
}

def on_connect(client, userdata, flags, rc):
    print(f"✓ Connected to MQTT broker: {BROKER} (code {rc})")
    client.subscribe(COMMAND_TOPIC)
    print(f"✓ Subscribed to: {COMMAND_TOPIC}")

def on_message(client, userdata, msg):
    """Handle incoming commands from mobile app"""
    try:
        payload = json.loads(msg.payload.decode())
        command = payload.get("command")
        hold = payload.get("hold", False)
        timestamp = payload.get("timestamp")
        
        print(f"\n>>> Command received: {command} (hold={hold}) at {timestamp}")
        
        # Handle commands
        if command == "MODE_MANUAL":
            robot_state["mode"] = "MANUAL"
            print("   → Switched to MANUAL mode")
            
        elif command == "MODE_AUTOMATIC":
            robot_state["mode"] = "AUTOMATIC"
            print("   → Switched to AUTOMATIC mode")
            
        elif command in ["UP", "DOWN", "LEFT", "RIGHT"]:
            if robot_state["mode"] == "MANUAL":
                # TODO: Implement motor control
                print(f"   → Moving {command}")
                # Example: control_motor(command, active=hold)
                
                # Simulate range change
                if command == "UP":
                    robot_state["range"] += 0.1
                elif command == "DOWN":
                    robot_state["range"] -= 0.1
                robot_state["range"] = max(0, min(10, robot_state["range"]))
            else:
                print(f"   ⚠ Ignoring {command} - robot in AUTOMATIC mode")
        
    except Exception as e:
        print(f"✗ Error processing command: {e}")

def publish_telemetry(client):
    """Publish telemetry data to mobile app"""
    # Simulate sensor readings (replace with real sensor data)
    robot_state["battery"] = max(0, robot_state["battery"] - 0.01)  # drain
    robot_state["steps"] += random.randint(0, 2)
    robot_state["calories"] = int(robot_state["steps"] * 0.1)
    
    telemetry = {
        "battery": round(robot_state["battery"], 1),
        "range": round(robot_state["range"], 1),
        "weight": round(robot_state["weight"], 1),
        "calories": robot_state["calories"],
        "steps": robot_state["steps"],
        "timestamp": time.time(),
    }
    
    payload = json.dumps(telemetry)
    client.publish(TELEMETRY_TOPIC, payload, qos=0)
    print(f"📡 Telemetry sent: battery={telemetry['battery']}%, range={telemetry['range']}m, steps={telemetry['steps']}")

def main():
    print("=" * 60)
    print("CarryMate Robot - Raspberry Pi MQTT Bridge")
    print("=" * 60)
    
    # Setup MQTT client
    client = mqtt.Client(client_id=f"carrymate-robot-{int(time.time())}")
    client.on_connect = on_connect
    client.on_message = on_message
    
    print(f"Connecting to {BROKER}:{PORT}...")
    client.connect(BROKER, PORT, 60)
    
    # Start loop in background thread
    client.loop_start()
    
    try:
        print("\n✓ Ready! Listening for commands and sending telemetry...\n")
        while True:
            publish_telemetry(client)
            time.sleep(2)  # Send telemetry every 2 seconds
            
    except KeyboardInterrupt:
        print("\n\n✓ Shutting down gracefully...")
        client.loop_stop()
        client.disconnect()
        print("✓ Disconnected. Bye!")

if __name__ == "__main__":
    main()
