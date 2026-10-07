# BeOff — Android Technical Constraints & Limitations

## 1. Network-Level vs UI-Level Filtering

Android's sandboxing security model strictly enforces boundaries between installed applications.

### What BeOff CAN do via Android `VpnService`:
- Capture all DNS resolution requests across all applications on the device.
- Sinkhole ad, tracker, and malware domains to $0.0.0.0$ before any TCP connection is established.
- Eliminate network payloads and block data connections to unapproved hosts.

### What BeOff CANNOT do universally across third-party apps:
- `VpnService` cannot arbitrarily inspect the encrypted TLS/HTTPS DOM inside third-party apps like Instagram, TikTok, or YouTube.
- BeOff cannot universally blur native video rendering frames inside proprietary third-party apps without using an intrusive Accessibility Service or rooting the device.

---

## 2. Accessibility Service Policy

- BeOff explicitly avoids using Android Accessibility Services as a deceptive spying workaround.
- Google Play policies strictly prohibit using Accessibility Services for content blocking in third-party applications without explicit accessibility justifications.
- In V1, deeper UI protection is centered around supported browser/web environments where DOM and image pre-rendering can be safely managed.

---

## 3. Co-existing VPN Applications

- Android allows only ONE active `VpnService` connection at any time.
- If the user connects to an external VPN or corporate tunnel, Android will pause BeOff's local VPN service.
- BeOff detects this state change gracefully and updates the Dashboard status to inform the user.
