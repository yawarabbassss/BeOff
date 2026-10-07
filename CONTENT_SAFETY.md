# BeOff — Content Safety Engine & Visual Classification

## 1. Purpose

The Content Safety Engine is designed to protect young users and families from exposure to explicit adult content, nudity, and suggestive media while browsing the web, without collecting or uploading private photos or videos.

---

## 2. On-Device Classification Pipeline

```
Visual Frame / Image
         │
         ▼
In-Memory Byte Stream (No disk write)
         │
         ▼
Downsampled to 224x224 RGB_565 (Low memory footprint)
         │
         ▼
On-Device Analyzer (Chrominance / Spatial YCbCr Heuristics & ML Model)
         │
         ▼
Classification Categories:
  • SAFE
  • SUGGESTIVE
  • NUDITY
  • EXPLICIT
  • UNKNOWN
         │
         ▼
Sensitivity Thresholds Applied (Low, Medium, High, Strict Child)
         │
         ▼
Take Action:
  • Safe -> Reveal
  • Suggestive / Nudity -> Blur with Safe Placeholder
  • Explicit -> Strong Block & Hide
         │
         ▼
Immediate Memory Deallocation & Garbage Collection (Zero frames retained)
```

---

## 3. Sensitivity Modes

- **Strict / Child Mode**: Aggressive filtering (threshold 0.30) that blocks suggestive imagery, pornographic hosts, and enforces SafeSearch.
- **High Sensitivity**: Standard family protection (threshold 0.45) blurring nudity and explicit content.
- **Medium Sensitivity**: Balanced protection (threshold 0.60) reducing false positives on art, medical, and anatomy contexts.
- **Low Sensitivity**: Minimal filter (threshold 0.75) for confirmed hardcore adult sites only.

---

## 4. Video Protection Strategy

For supported web views, BeOff samples keyframes at scene intervals rather than processing every frame continuously, preventing battery drain and overheating.
