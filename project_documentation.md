# FoodSaver: Zero-Waste Food Redistribution Platform

## Overview
**FoodSaver** is a comprehensive web application designed to bridge the gap between food surplus and food scarcity. It provides a digitized supply chain that allows restaurants, event organizers, and individuals to donate excess food seamlessly to verified NGOs, orphanages, and shelters. 

The platform operates on a role-based architecture, ensuring security, transparency, and efficiency in the food redistribution process.

---

## Technical Architecture & Stack
- **Backend Framework:** Django (Python)
- **Frontend:** HTML, Tailwind CSS, Leaflet.js (for interactive mapping)
- **Database:** Supabase (PostgreSQL) for production, SQLite for local development
- **Deployment & Hosting:** Vercel (Serverless Functions)
- **Static File Management:** WhiteNoise (for handling CSS/JS/Images efficiently in serverless environments)
- **Authentication:** Django’s built-in session-based authentication with a custom user model supporting Role-Based Access Control (RBAC).

---

## The 3 Core Roles

1. **Donor (Restaurants / Event Organizers / Individuals)**
   - Responsible for listing surplus food items.
   - Monitors incoming claims from NGOs.
   - Holds the authority to manually approve or reject a claim.
   - Facilitates the physical handover of the food using a secure OTP system.

2. **Claimant (NGOs / Orphanages / Shelter Homes)**
   - Has access to an interactive live map to find nearby available food listings.
   - Places claims on food lots they need.
   - Manages a roster of internal volunteers.
   - Assigns a specific volunteer to execute the pickup once the Donor approves the claim.

3. **Volunteer (Delivery Agents)**
   - Field agents managed by the NGOs.
   - Receive pickup assignments on their dedicated dashboard.
   - Travel to the Donor's location, verify the food, and submit a secure OTP to complete the transfer.

---

## The Core Application Flow (Step-by-Step Scenario)

This is the primary workflow of the application, demonstrating how food moves from a Restaurant to an NGO seamlessly.

### Step 1: The Restaurant Posts Food (Donor Action)
A restaurant finishes a large catering event and has 20kg of surplus cooked food. 
- The Restaurant logs in as a **Donor** and navigates to `Post Food`.
- They provide food details (type of food, quantity in kg, expiration time, and brief description).
- The moment they hit submit, this listing goes **Live** and appears on the platform’s interactive map for all nearby NGOs.

### Step 2: The NGO Discovers and Claims (Claimant Action)
An NGO looking to feed people logs into their **Claimant Dashboard**.
- They see the Restaurant's 20kg listing on their map or in the "Urgent Listings" feed.
- They review the details and click **"Claim Now"**.
- A request is sent to the Restaurant. Up until this point, the listing is locked so no other NGO can claim it simultaneously.

### Step 3: Donor Approval (Donor Action)
- The Restaurant receives a notification that an NGO wishes to pick up the food.
- They check the NGO's profile and click **"Approve"**.
- *Note: If they reject it, the food listing goes back to the live map for other NGOs.*

### Step 4: NGO Appoints a Volunteer (Claimant Action)
Now that the claim is approved, the NGO needs to send someone to physically collect the food.
- The NGO goes to their **Claims Manager** dashboard.
- Under the "Ready for Assignment" section, they select one of their active **Volunteers** from a dropdown menu and click "Assign".
- The system generates a highly secure **6-digit OTP**. This OTP is given exclusively to the selected Volunteer.

### Step 5: Transfer via Secure OTP (Volunteer & Donor Action)
- The Volunteer arrives at the Restaurant's location.
- The Volunteer tells the Restaurant the **6-digit OTP**.
- The Restaurant logs into their dashboard, enters the OTP provided by the Volunteer, and clicks **"Verify"**.
- If the OTP matches, the database marks the transaction as **"Completed"**.

---

## Key Features Built into the Platform

*   **Interactive Maps:** Powered by Leaflet.js and OpenStreetMap, claimants can visually see where food is located geographically relative to their organization.
*   **Role-Based Dashboards:** Every user type (Donor, Claimant, Volunteer) sees a completely customized interface specific to their required actions.
*   **Preventing Double-Booking:** Once an NGO claims a listing, its status immediately changes to "Pending", removing it from the public marketplace so two NGOs don't drive to the same restaurant for the same food.
*   **Secure Handoffs:** The OTP generation ensures that food is only handed over to verified volunteers tied to the NGO, preventing theft and ensuring accountability.

---

## How to Run This Project Locally (For the Presentation)

If you need to demonstrate the code running locally on your laptop:
1. Ensure Python is installed.
2. Activate your virtual environment and install dependencies: `pip install -r requirements.txt`
3. Run the server: `python manage.py runserver`
4. Access the site at `http://127.0.0.1:8000`

*Presenters Note: The live site is currently hosted seamlessly on Vercel utilizing a cloud PostgreSQL database for high availability.*
