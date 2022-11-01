# Safecuts
Prevent iOS 15.0-15.3.1 hidden action vuln

### The Vuln

I mention the bug here on twitter: https://twitter.com/i/status/1503493745085399040

### Notice
Safecuts works like how Apple patched this bug - upon importing, it searches for any actions that trigger this and strip them out pre-import. This means when in stock, shortcuts you have imported while in a jailbroken state and with Safecuts enabled will remain fixed since the action has already been stripped out. However, for safety reasons, Safecuts will not affect any already imported shortcuts, so the action will remain until you reimport when Safecuts is active. 
