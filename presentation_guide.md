# FoodSaver — Complete Presentation Guide for Teacher

> [!NOTE]
> This guide is written as if **you built every part of this project yourself**. Speak naturally, refer to "I" and "we decided", and use the technical details below as your script. The guide covers the full journey — from the initial idea to deployment.

---

## 1. How I Started — The Idea & Problem Statement

**What to say:**

"So the project basically started when I was thinking about a real-world problem that technology could solve. I came across a statistic that India wastes nearly **40% of the food it produces**, and at the same time, around **190 million people** in the country go to bed hungry every night. That contradiction really struck me.

I noticed that the actual problem isn't food scarcity — it's **logistics**. There is food available. Restaurants discard it every night after events, weddings, hotel buffets. But there is zero organized system to redirect that food to someone who actually needs it.

Existing apps or NGO efforts were mostly WhatsApp-group based — completely manual, untracked, and unverified. I thought: **what if I build a proper platform for this?** Like a food rescue marketplace — where restaurants post their surplus and NGOs can claim it in real time, with a verifiable chain of custody.

That became **FoodSaver**."

---

## 2. Planning the Project — What I Decided to Build

**What to say:**

"Before writing a single line of code, I sat down and planned out the core workflows. The first thing I had to figure out was: **who are the users?**

I identified three distinct roles:

1. **Donors** — Restaurants, hotels, event organizers who have surplus food.
2. **Claimants** — NGOs, orphanages, and shelter homes who need food.
3. **Volunteers** — Field workers employed by the NGOs who physically go and pick up the food.

Each of these roles needs a completely different interface and different permissions. So I knew from the start that **Role-Based Access Control (RBAC)** was going to be the backbone of this project.

I also realized one critical problem: how do you ensure that the food is actually handed over to the right person? What stops a random person from showing up and claiming the food? That problem inspired the **OTP verification system** — which ended up becoming the most interesting technical piece of the whole project."

---

## 3. Tech Stack — What I Used and Why

**What to say:**

"Now, for the technology choices:"

| Layer | Technology | Why I Chose It |
|---|---|---|
| **Backend** | Django (Python) | Built-in authentication, admin panel, ORM, and security best practices out of the box. Perfect for a data-heavy app. |
| **Frontend** | HTML + Tailwind CSS | Utility-first CSS let me build responsive, mobile-friendly UIs very fast without writing large CSS files. |
| **Database (Dev)** | SQLite | Zero setup for local development. Django uses it by default. |
| **Database (Production)** | PostgreSQL via Supabase | Industry-standard relational DB, fully compatible with Django's ORM. Free tier on Supabase. |
| **Maps** | Leaflet.js + OpenStreetMap | Free, open-source, no API key needed. NGOs can see food on an interactive map. |
| **AI** | Google Gemini API | Used for the analytics module to analyze donation patterns. |
| **Deployment** | Vercel | Serverless deployment, free tier, continuous deployment from GitHub. |
| **Static Files** | WhiteNoise | Serves CSS/JS/images efficiently in serverless environments without a separate CDN. |

**What to say:**

"I chose **Django** because I wanted a backend framework that already had authentication, admin, and database management built in. This let me focus on the actual product logic instead of reinventing the wheel.

For deployment, I used **Vercel** with a cloud **Supabase PostgreSQL** database. The tricky part here was that Vercel is serverless — it doesn't have a persistent file system, so I had to configure **WhiteNoise** to serve static files directly from memory, and store media through the database settings carefully."

---

## 4. Project Structure — How I Organized the Code

**What to say:**

"I followed Django's standard **app-based modular structure**. I split the project into two main Django apps:"

```
FoodSaver/
│
├── foodsaver/           # Main Django project settings
│   ├── settings.py      # All config: DB, Auth, Static files, Installed apps
│   └── urls.py          # Root URL dispatcher
│
├── listings/            # Everything related to food listings & claims
│   ├── models.py        # Listing, Claim, PickupAssignment, PickupOTP
│   ├── views.py         # Business logic for all listing operations
│   ├── urls.py          # URL patterns for listings
│   ├── forms.py         # Form classes
│   └── signals.py       # Auto-generates OTP when assignment is created
│
├── users/               # Authentication, roles, volunteers
│   ├── models.py        # Custom User model + Volunteer model
│   ├── views.py         # Login, register, dashboards, volunteer portal
│   └── urls.py          # URL patterns for users
│
├── analytics/           # AI-powered analytics module (Gemini)
│
├── templates/           # All HTML templates
│   ├── base.html        # Master layout (navbar, sidebar, dark mode)
│   ├── index.html       # Landing page
│   ├── listings/        # Donor dashboard, claimant dashboard, create listing
│   └── users/           # Login, register, volunteer portal
│
└── static/              # CSS, JS, images
```

**What to say:**

"Separating `listings` and `users` into their own Django apps was a deliberate decision. It keeps the code modular — the user management logic doesn't mix with the food-listing logic. If I ever wanted to add a new app, like a payments module, it would slot in without breaking anything."

---

## 5. The Database Design — My Models

**What to say:**

"Let me walk through the database design, because this is where the real architecture lives."

### 5.1 Custom User Model

"I extended Django's built-in `AbstractUser` to add fields specific to FoodSaver. In `users/models.py`:"

```python
class User(AbstractUser):
    role = models.CharField(choices=['donor', 'claimant', 'volunteer', 'admin'])
    is_verified = models.BooleanField(default=False)
    latitude = models.FloatField(null=True)
    longitude = models.FloatField(null=True)
    address = models.TextField()
    restaurant_license = models.CharField(...)   # For Donors
    ngo_registration = models.CharField(...)     # For Claimants
    institution_name = models.CharField(...)
    trust_score = models.FloatField(default=5.0)
```

"Every user has a **role** field. When they register, they choose whether they are a Donor or Claimant. The role controls what they see and what they can do. The `is_verified` flag means an admin has to manually verify NGOs and restaurants before they can transact — preventing fake accounts.

I also store **geo-coordinates** directly on the user model so the map can show their location. And the **trust_score** starts at 5.0 and decreases if a donor repeatedly rejects an NGO's claims — it's an accountability mechanism."

### 5.2 Volunteer Model

"I made `Volunteer` a separate model — it is NOT a `User` who logs in like other roles. A Volunteer is an employee of an NGO. The NGO creates and manages their volunteers inside the platform."

```python
class Volunteer(models.Model):
    ngo = models.ForeignKey(User, related_name='volunteers')  # The NGO that owns them
    user = models.OneToOneField(User, null=True, blank=True)  # Optional login account
    name = models.CharField(max_length=100)
    volunteer_id = models.CharField(unique=True)  # Auto-generated: VOL-001-0001
    phone = models.CharField(max_length=15)
    status = models.CharField(choices=['active', 'inactive'])
```

"When a new volunteer is saved, the `save()` method automatically generates a unique ID like `VOL-003-0001`. This is a clean way to give every volunteer a trackable ID without manual input."

### 5.3 Listing Model

```python
class Listing(models.Model):
    donor       → ForeignKey(User)
    food_type   → 'cooked', 'raw', 'packaged'
    quantity_kg → FloatField
    description → TextField
    expiry_time → DateTimeField
    status      → 'active', 'claimed', 'completed', 'expired'
    created_at  → auto timestamp
```

"A listing's `status` changes as the process moves forward. When it is first created, it is `active` — visible to all NGOs. Once an NGO claims it, it moves to `claimed`. After OTP verification, it becomes `completed`. If no one claims it before `expiry_time`, it becomes `expired`."

### 5.4 Claim Model

```python
class Claim(models.Model):
    listing   → ForeignKey(Listing)
    claimant  → ForeignKey(User)  # The NGO
    status    → 'pending', 'approved', 'rejected', 'completed'
    claimed_at → timestamp
```

"This is the bridge between a Listing and an NGO. When an NGO clicks Claim, a Claim object is created with `status='pending'`. The Donor then either approves or rejects it."

### 5.5 PickupAssignment Model

```python
class PickupAssignment(models.Model):
    claim     → ForeignKey(Claim)
    volunteer → ForeignKey(Volunteer)
    assigned_at → timestamp
    status    → 'assigned', 'picked_up', 'delivered'
```

"Once a claim is approved, the NGO assigns a specific volunteer to go pick up the food. This model records that assignment."

### 5.6 PickupOTP Model — The Security Layer

```python
class PickupOTP(models.Model):
    assignment  → OneToOneField(PickupAssignment)
    code        → CharField(max_length=6)   # e.g. "482931"
    is_verified → BooleanField(default=False)
    verified_at → DateTimeField
```

"This is the most important model. Every `PickupAssignment` has exactly **one OTP** attached. It's a secure 6-digit code that only the assigned volunteer knows. The Donor verifies this code at the time of handover."

---

## 6. The OTP System — How I Built the Security Mechanism

**What to say:**

"This is the part I'm most proud of. Let me explain exactly how it works end-to-end."

**The Signal:**

"In `listings/signals.py`, I used Django's **signal system**. A signal is an event listener — it watches for specific events in the database and runs a function when that event happens."

```python
@receiver(post_save, sender=PickupAssignment)
def create_pickup_otp(sender, instance, created, **kwargs):
    if created:
        code = f"{secrets.randbelow(1000000):06d}"
        PickupOTP.objects.create(assignment=instance, code=code)
```

"The moment a `PickupAssignment` is saved to the database for the first time, this signal fires **automatically**. It generates a cryptographically secure 6-digit number using Python's `secrets` module — which is specifically designed for security tokens — and saves it as a `PickupOTP` linked to that assignment.

I used `secrets.randbelow()` instead of Python's `random` module because `random` is NOT cryptographically secure. `secrets` uses the OS-level random number generator, making it much harder to predict."

**The Verification Flow (JS + Django):**

"On the Donor's dashboard, I built an AJAX-based OTP verification form. When the Donor types the 6-digit code and clicks Verify, JavaScript sends an async `fetch()` request to the backend:"

```javascript
const response = await fetch('/users/volunteer/pickup/' + assignmentId + '/verify-otp/', {
    method: 'POST',
    headers: { 'X-CSRFToken': getCookie('csrftoken') },
    body: 'otp_code=' + encodeURIComponent(otpCode),
});
```

"Notice I'm also including the **CSRF token** in the header. Django has CSRF protection enabled by default — any POST request without this token gets rejected with a 403 error. So I read the token from the browser cookie using the `getCookie()` helper function I wrote, and pass it in the request header.

On the backend, Django checks if `otp_code == PickupOTP.code`. If it matches, it marks `is_verified = True`, records the `verified_at` timestamp, and marks the listing as `completed`. The frontend then shows a green success state and reloads the page."

---

## 7. Role-Based Access Control — How Permissions Work

**What to say:**

"One of the biggest challenges was making sure users could only see and do things relevant to their role. I handled this with a combination of Django decorators and view-level permission checks.

For example, the donor dashboard view checks: is this user logged in? Are they a donor? If not, redirect them. If yes, only show them their own listings and claims — nobody else's data. I wrote this logic at the start of every view using `request.user.role`."

---

## 8. The Full Application Flow — Step by Step

**What to say:**

"Let me walk you through the complete lifecycle of a food donation on this platform:"

```
[Step 1] Donor logs in → Goes to "Post Food" → Fills form (food type, quantity, expiry time)
           → Listing created with status='active'
           → Immediately appears on the live map for all NGOs

[Step 2] NGO logs in → Sees listings on map (Leaflet.js + OpenStreetMap)
           → Clicks "Claim Now" on a listing
           → Claim object created with status='pending'
           → Listing locked (status='claimed') — prevents double-booking

[Step 3] Donor sees notification on dashboard: "NGO XYZ wants your food"
           → Donor clicks Approve → Claim status changes to 'approved'
           → If Reject: listing goes back to 'active' for others

[Step 4] NGO goes to Claims Manager → Sees approved claim
           → Selects a volunteer from dropdown → Clicks "Assign"
           → PickupAssignment created
           → Django Signal FIRES AUTOMATICALLY → PickupOTP generated
           → OTP shown to the volunteer (or shared via WhatsApp button)

[Step 5] Volunteer travels to Donor's location
           → Tells Donor the 6-digit OTP
           → Donor enters OTP in dashboard → Clicks "Verify & Handover"
           → Backend checks OTP → If correct: marks PickupOTP.is_verified=True
           → Listing marked 'completed' → Transaction done ✓
```

---

## 9. The Frontend — Dashboards & Responsive Design

**What to say:**

"I built three completely separate dashboards using a single `base.html` template that all pages extend from. The base template contains the navbar, sidebar, dark mode toggle, and all shared styles. Each dashboard then fills in its own `{% block content %}`.

The entire frontend is styled with **Tailwind CSS**, which is a utility-first CSS framework. Instead of writing `button { background: green; padding: 10px; }`, I write classes directly in the HTML like `bg-green-500 px-4 py-2`. This made it extremely fast to build and iterate on the UI.

I also implemented **dark mode** — the app detects the user's system preference and switches between a light and dark theme automatically. All color values use CSS variables so they change together.

The design uses cards, badges, and status indicators throughout. For example, on the donor dashboard you can see all live listings in green cards, pending claims highlighted in orange, and completed transactions in the history section — all at a glance."

---

## 10. The Map Feature — Leaflet.js

**What to say:**

"For the NGO Claimant dashboard, I integrated an **interactive map** using Leaflet.js with OpenStreetMap tiles. This is completely free — no Google Maps API key needed.

I wrote a JavaScript endpoint in Django (`/listings/api/`) that returns all active listings as JSON. The map JavaScript fetches this data, then places a **green marker** for each listing with a popup showing the food type, quantity, and a Claim button. NGOs can visually see which restaurant is closest to them."

---

## 11. Deployment — Taking It Live

**What to say:**

"Deploying to production was one of the more challenging parts of the project because Vercel is a serverless platform — it doesn't work like a traditional server.

Here are the problems I faced and how I solved them:

1. **Static files not loading** — On a normal Django server, `python manage.py collectstatic` puts files in a folder and they're served. On Vercel, there's no persistent file system. I solved this by adding **WhiteNoise**, which compresses and serves static files directly from the app's memory on every request.

2. **Database** — SQLite is a local file, it can't be used in production. I switched to **Supabase** — a cloud PostgreSQL database. I used Django's `dj-database-url` library to read the database URL from an environment variable, which keeps the credentials out of the code.

3. **Environment Variables** — Secret keys, database URLs, and API keys are never hardcoded. I use a `.env` file locally and set them in Vercel's dashboard for production. Django's `python-dotenv` library reads `.env` files automatically.

The `vercel.json` file tells Vercel how to build and route the Django app using their serverless functions."

---

## 12. Difficulties I Faced & How I Solved Them

**What to say:**

"No project goes perfectly. Here are the real challenges I hit:"

| Challenge | What Happened | How I Fixed It |
|---|---|---|
| **Double-booking food** | Two NGOs could claim the same listing at the same millisecond | Changed listing status to `claimed` immediately on first claim, making it disappear from the marketplace |
| **OTP Security** | Initially used Python's `random` module | Switched to `secrets.randbelow()` which uses the OS's cryptographic RNG |
| **Volunteer Credentials** | No way to email volunteers login credentials | Built a WhatsApp share button that pre-fills a message with the volunteer's username and password |
| **Vercel Static Files** | CSS/JS not loading after deployment | Added WhiteNoise middleware and ran `collectstatic` as part of the build script |
| **CSRF Errors on AJAX** | POST requests from JavaScript were failing | Learned about Django's CSRF protection, wrote `getCookie()` helper, added `X-CSRFToken` header |
| **Role confusion** | Anonymous users could access dashboard URLs directly | Added `@login_required` decorator and `role` checks at the top of every view |

---

## 13. AI Integration — Google Gemini

**What to say:**

"I also integrated **Google's Gemini AI** through the `google-generativeai` Python library. The analytics module sends donation history data to Gemini and asks it to identify patterns — things like 'Hotel ABC consistently donates cooked food on Friday evenings.'

This is useful for NGOs. If the AI can predict that a restaurant is likely to have surplus food tomorrow, the NGO can pre-arrange a vehicle and a volunteer instead of scrambling last minute. It turns the system from reactive to **proactive**."

---

## 14. Potential Teacher Questions — Answers

**Q: Why Django and not something like Node.js or Flask?**
> "Django comes with an admin panel, ORM, authentication, form validation, CSRF protection — all built in. For a data-heavy application like this, Django's 'batteries included' philosophy saved me a huge amount of time. Flask is more minimal and would have required me to plug in third-party libraries for all of that."

**Q: Explain CSRF. Why is it important here?**
> "CSRF stands for Cross-Site Request Forgery. It's a type of attack where a malicious website tricks a logged-in user's browser into making unwanted requests to your site. Django generates a unique token per session and requires it on every POST request. Without it, someone could build a fake website that submits forms to FoodSaver on behalf of unsuspecting users. I handle this in my JavaScript by reading the CSRF token from the browser cookie and including it in every AJAX POST."

**Q: What is a Django Signal and where did you use it?**
> "A Django Signal is like a callback that listens to model events. I used `post_save` on the `PickupAssignment` model. Every time a new assignment is saved, a signal fires a function that automatically generates a secure OTP and saves it. This decouples the OTP logic from the view — the view doesn't need to know about OTP creation, it just saves the assignment and the signal handles the rest."

**Q: How do you prevent a random person from accessing the donor dashboard?**
> "Two layers. First, Python's `@login_required` decorator on every view — if you're not logged in, you get redirected to login. Second, inside each view I check `request.user.role`. If a Claimant tries to access the Donor dashboard URL directly, they're redirected away. The role check happens server-side, so you can't bypass it by just changing a URL."

**Q: What is WhiteNoise and why did you need it?**
> "Normally Django has a setting `DEBUG=True` where it serves static files itself. In production, it doesn't do this — it expects a separate web server like Nginx to serve them. Since I'm on Vercel's serverless platform, I don't have Nginx. WhiteNoise is a Python library that allows Django itself to serve static files compressed and efficiently, even in production. It's added as middleware in `settings.py`."

**Q: How does the map work?**
> "I wrote a Django view at `/listings/api/` that returns all active listings as JSON. On the frontend, Leaflet.js (a JavaScript mapping library) initializes a map using free OpenStreetMap tiles, then fetches that JSON and places a marker at each listing's coordinates. Each marker has a popup with food details and a claim button."

**Q: How is the trust score used?**
> "Every User has a `trust_score` field that starts at 5.0. If a Donor repeatedly rejects claims from a specific NGO for no good reason, the trust score decreases. Conversely, completed transactions build trust. It's a reputation system that encourages accountability on both sides."

---

## 15. Closing Statement

**What to say:**

"FoodSaver is a full-stack, multi-role web application backed by a PostgreSQL database, deployed on cloud infrastructure, with real-time map integration, AI-powered analytics, and a cryptographically secure OTP handover system.

Every single design decision — from choosing `secrets` over `random`, to using signals instead of forgetting OTPs, to deploying on serverless — was made with scalability, security, and real-world usability in mind.

This isn't just a college project. The architecture is production-ready and can be scaled to multiple cities simply by extending the location model. I'm very proud of what I built here, and I'm happy to answer any questions."
