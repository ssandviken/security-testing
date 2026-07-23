# OWASP Juice Shop — Vulnerability Demonstrations

Assumes Juice Shop is running at `http://localhost:3000`

   docker run --rm -v "$PWD\\logs:/juice-shop/logs" -p 127.0.0.1:3000:3000 bkimminich/juice-shop
      

---

## 1. Broken Access Control

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


---

### Challenge: Admin Page Access
1. Navigate to `http://localhost:3000/#/administration`
2. If not logged in as admin you are redirected — but the API is still open.
3. Log in as admin (see Injection section below for credentials bypass).
4. The administration panel lists all users and their emails.

---

## 2. Security Misconfiguration

### Challenge: Exposed `/ftp` Directory
1. Navigate to `http://localhost:3000/ftp`
2. A directory listing is served — this should never be publicly accessible.
3. Download `acquisitions.md` or `coupons_2013.md`.

**Lesson:** Directory listing must be disabled in production. Sensitive files should never be in a web-accessible directory.

---

### Challenge: Exposed Swagger / API Docs
1. Navigate to `http://localhost:3000/api-docs`
2. The full REST API is documented and exposed publicly, including admin endpoints.

**Lesson:** Internal API documentation should be disabled or protected in production environments.

---

### Challenge: Default or Weak JWT Secret
1. Log in and capture the JWT from the `Authorization` header in DevTools → Network.
2. Paste the token at [https://jwt.io](https://jwt.io).
3. The token is signed with a weak/default secret (`secret` or similar).
4. Try forging a token with `"role": "admin"` — in some Juice Shop versions this works.

**Lesson:** Use strong, random secrets for JWT signing. Never use default values.

---

## 3. Injection (SQL Injection)

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

---

## 4. Sensitive Data Exposure

### Challenge: Find User Credentials in the Database Dump
1. Navigate to `http://localhost:3000/ftp/` (see Security Misconfiguration above).
2. Download the exposed backup/dump files.

---

### Challenge: Passwords Stored as Unsalted MD5 Hashes
1. After extracting user data via SQL injection (see above), the `password` field contains MD5 hashes.
2. Copy a hash and look it up at [https://crackstation.net](https://crackstation.net).
3. Common passwords (e.g., `admin123`) resolve instantly.

**Lesson:** Passwords must be hashed with a slow, salted algorithm such as bcrypt, scrypt, or Argon2.

---

### Challenge: Intercepting Sensitive Data in HTTP Responses
1. Log in and open DevTools → Network.
2. Inspect the `/rest/user/whoami` or profile API response.
3. Sensitive fields (email, internal IDs) are returned even when not needed by the UI.

**Lesson:** APIs should return only the minimum data required (principle of least privilege). Sensitive fields should be masked or omitted.

---

## 5. Cross-Site Scripting (XSS)

### Challenge: Reflected XSS via Search
1. In the Juice Shop search bar, enter:
   ```
   <iframe src="javascript:alert('XSS')">
   ```
2. The script executes — the search term is reflected into the DOM without sanitization.

**Lesson:** All user-supplied output rendered in HTML must be escaped. Use a Content Security Policy (CSP).

---

### Challenge: Stored XSS via Product Review
1. Navigate to any product page.
2. Submit a review containing:
   ```html
   <script>alert('Stored XSS')</script>
   ```
3. Reload the page — the script executes every time the review is displayed.

**Lesson:** Stored XSS is more dangerous than reflected XSS because it affects every user who views the content. Sanitize and encode all stored user input on output.

---

### Challenge: DOM-Based XSS
1. Navigate to:
   ```
   http://localhost:3000/#/search?q=<script>alert('DOM XSS')</script>
   ```
2. The Angular frontend reads from the URL fragment and writes it unsafely to the DOM.

**Lesson:** Client-side code must sanitize values read from the URL, localStorage, or any untrusted source before writing to the DOM (`innerHTML`, `document.write`, etc.).

---

## 6. Dependency Vulnerabilities

### Challenge: Identify Vulnerable Libraries
1. Open DevTools → Sources (or Network → JS files).
2. Look for included libraries with version numbers (e.g., `angular.min.js`, `jquery-x.y.z.js`).
3. Search those versions at [https://security.snyk.io](https://security.snyk.io) or run:
   ```bash
   docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
     aquasec/trivy image bkimminich/juice-shop
   ```
4. Trivy will report dozens of known CVEs in the image's OS packages and Node.js dependencies.

---

### Challenge: Inspect `package.json` for Known-Vulnerable Packages
1. Navigate to `http://localhost:3000/ftp/package.json.bak` — if available.
2. Alternatively, exec into the container:
   ```bash
   docker exec -it <container_id> cat /juice-shop/package.json
   ```
3. Run an audit:
   ```bash
   docker exec -it <container_id> npm audit
   ```
4. Observe the list of high/critical severity vulnerabilities in transitive dependencies.

**Lesson:** Regularly audit and update dependencies. Use tools like `npm audit`, Dependabot, Snyk, or Trivy in your CI/CD pipeline.


### Challenge: Broken access control - Put an additional product into another user’s shopping basket
1. Find your Basket ID: Log in and add a product to your own basket. Capture the resulting POST /api/BasketItems request in your proxy to determine your BasketId and your valid Authorization Bearer token.
2. Determine the Target Basket ID: Determine the target's basket ID (typically 2 if yours is 1, based on the official walkthroughs).
3. Draft the Payload: Construct a POST request to /api/BasketItems that utilizes HTTP Parameter Pollution by duplicating the BasketId parameter in the JSON body.Your JSON body should look like this:
```json
{
  "ProductId": 1,
  "BasketId": "1",
  "quantity": 1,
  "BasketId": "2"
}
```
4. Send the intercepted request. The server will validate against BasketId: "1" (yours) but process the item into BasketId: "2".

---

## Quick Reference — Useful URLs

| URL | Purpose |
|-----|---------|
| `http://localhost:3000/#/score-board` | Hidden score board |
| `http://localhost:3000/ftp/` | Exposed file directory |
| `http://localhost:3000/api-docs` | Exposed Swagger docs |
| `http://localhost:3000/#/administration` | Admin panel |
| `http://localhost:3000/rest/products/search?q=test` | Injectable search endpoint |
| `https://help.owasp-juice.shop/appendix/solutions.html` | Challenge Solutions |
