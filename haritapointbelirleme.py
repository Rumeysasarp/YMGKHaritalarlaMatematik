import sys
sys.path.append('/opt/homebrew/lib/python3.11/site-packages')
import cv2
import json

# Harita görselini yükle
image = cv2.imread('/Users/zehraoner/Desktop/harita.png')

# Görseli gri tonlamaya çevir ve beyaz bölgeleri bul
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
_, thresh = cv2.threshold(gray, 200, 255, cv2.THRESH_BINARY)

# Beyaz alanların konturlarını bul
contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

# Her konturun merkezi koordinatlarını al
regions = []
for contour in contours:
    M = cv2.moments(contour)
    if M['m00'] != 0:
        cx = int(M['m10'] / M['m00'])  # Merkez X koordinatı
        cy = int(M['m01'] / M['m00'])  # Merkez Y koordinatı
        regions.append({"x": cx, "y": cy})

# JSON olarak kaydet
with open("regions.json", "w") as f:
    json.dump(regions, f)
 
print("Bölgeler JSON dosyasına kaydedildi.")
