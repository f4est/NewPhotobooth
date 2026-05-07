# NewPhotobooth implementation TODO

## Done
- Photo session flow: countdown, capture sequence, collage build, gallery, reset.
- Real webcam discovery and preview for Windows.
- Event archive and counters for collected, shared and printed media.
- Template editor with draggable and resizable slots.
- Collage rendering with selected template, slots and overlay.
- Windows printer discovery and direct printing with common booth photo sizes.
- QR download links through a local media server.
- Email and SMS delivery using configured SMTP and Twilio-compatible settings.
- Theme, language, sharing, print and main settings persistence.
- Self-service start, admin PIN lock and print limit.
- Dashboard and event media gallery.
- Guest email and phone entry for sending finished media.
- Windows printer-settings mode for printing through the driver defaults.
- Mirror, rotation and fullscreen controls for booth camera preview.
- Windows startup shortcut sync for self-service kiosk startup.
- Self-service sharing limit enforcement for QR, email and SMS.

## Next
- Add real video capture and GIF pipeline before exposing video/GIF controls.
- Add green screen/background compositing before exposing green screen controls.
- Add DSLR adapters behind the camera repository for Canon/Nikon/Sony SDKs.
- Add integration tests for booth start, print dispatch and sharing dispatch.
