
# Food Saver - Project Technical Documentation

> [!NOTE]
> This document is designed to give you a senior-developer level understanding of the **Food Saver** project. It covers the architecture, tech stack, database schema, and key user flows to help you explain the project confidently in interviews or presentations.

## 1. Executive Summary
**Food Saver** is a web-based platform designed to bridge the gap between food surplus (from restaurants/hotels) and food scarcity (NGOs/Shelters). It digitizes the food donation supply chain using a role-based system, real-time logistics tracking via OTPs, and AI-powered surplus prediction.

## 2. Technology Stack

### Backend
-   **Framework**: **Django 6.0** (Python). Chosen for its "batteries-included" approach, robust security (CSRF/XSS protection), and rapid development of Admin/Auth features.
-   **Database**: **SQLite** (Development). Easy to set up; scalable to PostgreSQL for production.
-   **AI Integration**: **Google Gemini Pro** (via `google-generativeai`). Used for analyzing donation patterns and predicting future surplus.

### Frontend
-   **Styling**: **Tailwind CSS** (via CDN). Utility-first CSS framework for rapid, responsive UI development. Features a dark-mode ready color palette (`primary: #13ec13`, `background-dark: #102210`).
-   **Templating**: **Django Templates (DTL)**. Server-side rendering for SEO friendliness and direct integration with backend logic.
-   **Icons**: **Google Material Symbols**.

## 3. System Architecture
The project follows the standard **Django MVT (Model-View-Template)** architecture:
-   **Model**: Defines the data structure (e.g., `User`, `Listing`).
-   **View**: Handles business logic (e.g., `approve_claim`, `verify_otp`).
-   **Template**: Renders the UI (e.g., `base.html`, `donor_dashboard.html`).

### Folder Structure
-   `foodsaver/`: Project settings, URL routing (`urls.py`), AI Core (`ai_core.py`).
-   `users/`: Handles Authentication, Role Management, and Volunteer Portal.
-   `listings/`: Core domain logic (Donations, Claims, Pickups).
-   `analytics/`: (Placeholder) For future data visualization features.
-   `templates/`: HTML files with inheritance (`base.html` is the parent).

## 4. Key Modules & Features

### A. Role-Based Authentication (`users` app)
The system supports four distinct user roles, implemented via a custom `User` model inheriting from `AbstractUser`.
1.  **Donors**: Restaurants/Hotels who post food.
2.  **Claimants**: NGOs/Shelters who claim food.
3.  **Volunteers**: Individuals assigned by NGOs to pick up food.
4.  **Admin**: System oversight.

**Key Code**: `users/models.py` defines `role` choices. `users/views.py` handles custom login redirection based on these roles.

### B. Food Donation & Claim Lifecycle (`listings` app)
This is the core workflow of the application:
1.  **Creation**: Donor posts a `Listing` (Food Type, Qty, Expiry).
2.  **Active**: Visible to Claimants. Auto-expires if `timezone.now() > expiry_time`.
3.  **Claim**: Claimant clicks "Claim". Status becomes `active` -> `pending` (waitlist) or `approved`.
4.  **Approval**: Donor approves a claim. Status -> `approved`.
5.  **Assignment**: NGO assigns a `Volunteer`. A `PickupAssignment` is created.
6.  **Verification**: System generates a 6-digit `PickupOTP`.
7.  **Pickup**: Volunteer picks up food, enters OTP. Status -> `picked_up`.
8.  **Delivery**: Volunteer marks as delivered. Status -> `completed`.

**Why this design?**
-   **Traceability**: Every step (Approved, Assigned, Picked Up, Delivered) is tracked in the database.
-   **Security**: The **OTP mechanism** ensures food is handed over to the *correct* verified volunteer, preventing theft or loss.

### C. Logistics & OTP Verification
-   **Model**: `PickupOTP` is a One-to-One link with `PickupAssignment`.
-   **Logic**: When a volunteer is assigned, an OTP is generated (logic likely in `signals.py` or `models.py` save method).
-   **Security**: The API `verify_pickup_otp` checks the code and marks the timestamp.

### D. AI Surplus Prediction
-   **File**: `foodsaver/ai_core.py`.
-   **Function**: `get_surplus_prediction(listings_data)`.
-   **Logic**: Constructs a prompt with recent donation history and asks Gemini Pro to predict tomorrow's surplus.
-   **Use Case**: Helps NGOs plan logistics in advance by predicting availability.

## 5. Database Schema (Key Models)

### `User` (Custom)
-   `username`, `email`, `password`
-   `role` (Enum: Donor, Claimant, Volunteer)
-   `institution_name`, `trust_score`

### `Listing`
-   `donor` (FK to User)
-   `food_type`, `quantity_kg`, `expiry_time`
-   `status` (Active, Claimed, Completed, Expired)

### `Claim`
-   `listing` (FK), `claimant` (FK)
-   `status` (Pending, Approved, Rejected)

### `PickupAssignment`
-   `claim` (FK), `volunteer` (FK)
-   `status` (Assigned, Picked Up, Delivered)

### `PickupOTP`
-   `assignment` (OneToOne)
-   `code` (6-digit string), `is_verified` (Bool)

## 6. Deployment & Scalability Plan (Interview Points)
Currently running locally with `runserver` and SQLite. For production, you would:
-   **Database**: Switch to **PostgreSQL** for concurrent write handling.
-   **Server**: Use **Gunicorn** or **Uvicorn** behind Nginx.
-   **Async Tasks**: Move Email sending and AI prediction to **Celery + Redis** to avoid blocking the main thread.
-   **Environment**: Set `DEBUG=False` and use strict `ALLOWED_HOSTS`.

---

## 7. How to Explain This Project
"I built **Food Saver**, a full-stack Django application to reduce food waste. It connects restaurants with NGOs. I implemented a robust **role-based auth system** for different stakeholders and a **secure logistics flow** using OTP verification for food pickups. I also integrated **Google's Gemini AI** to analyze donation patterns and predict food surplus, helping NGOs plan better. The frontend is built with **Tailwind CSS** for responsiveness."
