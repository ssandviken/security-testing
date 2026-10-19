# OWASP Juice Shop — Vulnerability Demonstrations

Assumes Juice Shop is running in Docker (or Podman) at `http://localhost:3000`

   docker run --rm -v "$PWD\\logs:/juice-shop/logs" -p 127.0.0.1:3000:3000 bkimminich/juice-shop
      

<h3 style="background: red; padding: 1em;">Safety: Run these demonstrations only against the intentionally vulnerable Juice Shop instance in an isolated lab, and only on systems you own or have explicit authorization to test. Do not target production or third-party systems.</h3>


## Injection (SQL Injection)

### Challenge: Login as Admin Without Password
1. Go to `http://localhost:3000/#/login`
2. In the **Email** field enter:
   ```
   ' OR 1=1--
   ```
3. Enter any value in the **Password** field and click Login.
4. You are logged in as the first user in the database — which is the admin.

**Lesson:** User input must never be concatenated directly into SQL queries. Use parameterized queries / prepared statements.

---

### Challenge: Login as Any Known User
1. If you know a user's email (e.g., `jim@juice-sh.op`), enter:
   ```
   jim@juice-sh.op'--
   ```
   in the email field with any password.
2. You are logged in as that user with no password required.

---

### Challenge: Extract the Full User Table (via API)
1. Use the search endpoint:
   ```
   http://localhost:3000/rest/products/search?q='))--
   ```
2. Observe the SQL error leaking table/column structure.
3. Craft further payloads to extract data:
   ```
   http://localhost:3000/rest/products/search?q=')) UNION SELECT id,email,password,4,5,6,7,8,9 FROM Users--
   ```

**Lesson:** SQL errors should never be surfaced to the client. All input must be sanitized.

## Broken Access Control

### Challenge: Access the Score Board (Hidden Page)
The score board is not linked in the UI, but it exists.

1. Navigate to `http://localhost:3000/#/score-board`
2. The page loads — it was only hidden from the nav, not protected.

**Lesson:** Security through obscurity is not access control.

---

### Challenge: View Another User's Basket
1. Log in as any user (e.g., register a new account).
2. Add an item to your basket.
3. Open DevTools → Network tab.
4. Click the basket icon — observe a request to `/rest/basket/1` (or similar ID).
5. In the browser address bar or via `fetch()` in the console, request a different basket ID:
   ```js
   fetch('/rest/basket/1', { credentials: 'include' })
     .then(r => r.json()).then(console.log)
   ```
6. You receive another user's basket contents.

**Lesson:** IDs in URLs/APIs must be validated against the authenticated user's ownership (Insecure Direct Object Reference).

### Challenge: View Another User's Basket #2
1. Log in as any user.
2. Put some products into your shopping basket.
3. Inspect the Session Storage in your browser's developer tools to find a numeric bid value. 
4. Change the bid, e.g. by adding or subtracting 1 from its value.
5. Visit http://localhost:3000/#/basket to solve the challenge or just CTRL+R.


## Automatic scan using ZAP
1. Start ZAP using zap-swing.ps1 script. This will start the ZAP UI and make it available from your browser at 'http://localhost:8082/zap/'.
2. Create a new session and select "Automated scan"
3. Add "http://host.docker.internal:3000" in "URL to attack"
4. Click the "Attack" button to start the test.