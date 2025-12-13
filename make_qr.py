import qrcode

# Data JSON satu baris, lebih aman untuk diparse
data = "carrymate://pair?device=robot123&broker=broker.hivemq.com&port=1883&telemetry=carrymate/robot/telemetry&command=carrymate/mobile/command"

# Buat QR code
qr = qrcode.QRCode(
    version=1,  # ukuran QR, 1 paling kecil
    error_correction=qrcode.constants.ERROR_CORRECT_L,
    box_size=10,
    border=4,
)
qr.add_data(data)
qr.make(fit=True)

# Render jadi gambar
img = qr.make_image(fill_color="black", back_color="white")

# Simpan ke file
img.save("carrymate_qr.png")