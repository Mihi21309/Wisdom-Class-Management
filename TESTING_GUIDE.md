# 📖 Student Dashboard Testing Guide

## Step 1: Start the App

### Option A: Android Emulator (Recommended)
```bash
# In VS Code Terminal:
flutter run
```
- First time will take 2-3 minutes
- Should open Android emulator automatically
- Wait for "Restarted app on device"

### Option B: Physical Device
1. Connect Android phone via USB
2. Enable "Developer Mode" on phone
3. Run: `flutter run`

---

## Step 2: Login to App

1. **Splash Screen** appears → Wait 2-3 seconds
2. **Login Screen** shows → Enter credentials:
   - **Email**: Use any email (example: `student1@example.com`)
   - **Password**: `Password123!` (or any password ≥8 chars)
   - Click **Sign In**

**First time?** The email/password will be created automatically (Firebase auto-registers)

### Example Credentials for Testing:
```
Email: student1@example.com
Password: Password123!
```

---

## Step 3: Create Firebase Test Data

### 🔴 IMPORTANT: Get Your Student UID First

After logging in:
1. Open Firebase Console: https://console.firebase.google.com
2. Select your project: **wisdom-class-management**
3. Go to **Authentication** → Click the student email you just created
4. Copy the **User UID** (long string like: `abc123def456...`)
5. **Save this UID** - you'll use it multiple times

---

## Step 4: Add Test Data to Firebase

Go to Firebase Console → **Firestore Database**

### Step 4.1: Create Student Profile

1. Click **+ Start collection**
2. **Collection ID**: `students`
3. **Document ID**: Paste your **User UID** (from Step 3)
4. Add these fields:

| Field | Type | Value |
|-------|------|-------|
| `name` | string | `John Doe` |
| `email` | string | `student1@example.com` |
| `phone` | string | `5551234567` |
| `enrollmentDate` | timestamp | Today's date |
| `enrolledBatches` | array | `["batch1"]` |
| `profilePictureUrl` | string | (leave empty) |

**Save** ✓

---

### Step 4.2: Create a Batch (Classroom)

1. Click **+ Add collection** → Collection ID: `batches`
2. **Document ID**: `batch1`
3. Add these fields:

| Field | Type | Value |
|-------|------|-------|
| `name` | string | `Grade 10 Science` |
| `year` | number | `2024` |
| `description` | string | `10th grade science class` |
| `subjectsOffered` | array | `["subj1", "subj2"]` |
| `enrolledStudents` | array | `["<YOUR_USER_UID>"]` |
| `createdAt` | timestamp | Today's date |

**Save** ✓

---

### Step 4.3: Create Subjects

1. Click **+ Add collection** → Collection ID: `subjects`

#### Subject 1:
- **Document ID**: `subj1`
- Fields:
  - `name`: `Physics`
  - `code`: `PHY101`
  - `teacher`: `Mr. Smith`

**Save** ✓

#### Subject 2:
- **Document ID**: `subj2`
- Fields:
  - `name`: `Mathematics`
  - `code`: `MATH101`
  - `teacher`: `Mrs. Johnson`

**Save** ✓

---

### Step 4.4: Create Zoom Classes

1. Click **+ Add collection** → Collection ID: `zoomClasses`

#### Class 1 (Today - Morning):
- **Document ID**: `class1`
- Fields:
  - `classTitle`: `Physics Lecture`
  - `batchId`: `batch1`
  - `subjectId`: `subj1`
  - `zoomLink`: `https://zoom.us/j/123456789`
  - `scheduledDateTime`: **Today at 10:00 AM** (set as timestamp)
  - `durationMinutes`: `60`
  - `description`: `Introduction to Motion`
  - `createdAt`: Today's date

**Save** ✓

#### Class 2 (Tomorrow):
- **Document ID**: `class2`
- Fields:
  - `classTitle`: `Math Tutorial`
  - `batchId`: `batch1`
  - `subjectId`: `subj2`
  - `zoomLink`: `https://zoom.us/j/987654321`
  - `scheduledDateTime`: **Tomorrow at 2:00 PM**
  - `durationMinutes`: `45`
  - `description`: `Algebra Basics`
  - `createdAt`: Today's date

**Save** ✓

---

### Step 4.5: Add Attendance Records

1. Click **+ Add collection** → Collection ID: `attendance`

#### Record 1 (Present):
- **Document ID**: `att1`
- Fields:
  - `studentId`: `<YOUR_USER_UID>`
  - `batchId`: `batch1`
  - `subjectId`: `subj1`
  - `date`: **Today's date**
  - `status`: `present`
  - `month`: `12` (December - adjust to current month)
  - `year`: `2024` (adjust to current year)

**Save** ✓

#### Record 2 (Absent):
- **Document ID**: `att2`
- Fields:
  - `studentId`: `<YOUR_USER_UID>`
  - `batchId`: `batch1`
  - `subjectId`: `subj2`
  - `date`: **Yesterday's date**
  - `status`: `absent`
  - `month`: `12`
  - `year`: `2024`

**Save** ✓

#### Record 3 (Leave):
- **Document ID**: `att3`
- Fields:
  - `studentId`: `<YOUR_USER_UID>`
  - `batchId`: `batch1`
  - `subjectId`: `subj1`
  - `date`: **2 days ago**
  - `status`: `leave`
  - `month`: `12`
  - `year`: `2024`

**Save** ✓

---

## Step 5: Test Each Dashboard Tab

Go back to your phone/emulator and refresh (or restart the app).

### ✅ Home Tab
You should see:
- ✅ "Welcome, John Doe! 👋"
- ✅ "1 Active Batches" card
- ✅ "2 Upcoming Classes" card
- ✅ Today's classes section with "Physics Lecture" if scheduled for today
- ✅ Attendance overview showing "Grade 10 Science" with attendance percentage

**Expected**: ~66% attendance (2 present, 1 absent out of 3)

---

### ✅ Classes Tab
You should see:
- ✅ Card: "Grade 10 Science" (expandable)
- Click to expand:
  - ✅ Description: "10th grade science class"
  - ✅ "2 subjects" listed
  - ✅ Physics class with "Join Class" button
  - ✅ Math class with "Join Class" button
  - ✅ Status badges (LIVE/UPCOMING/ENDED)

**Click "Join Class"** → Should open Zoom link in browser

---

### ✅ Attendance Tab
You should see:
- ✅ Month selector showing current month
- ✅ Card: "Grade 10 Science"
- ✅ Overall attendance percentage
- ✅ Two sections (Physics, Math)
- ✅ Color-coded attendance:
  - 🟢 Green = Present
  - 🔴 Red = Absent
  - 🟠 Orange = Leave

**Try clicking** left/right arrows to change months → Should show "No attendance records for this month" if you go to other months

---

### ✅ Profile Tab
You should see:
- ✅ Profile card with avatar
- ✅ Name: "John Doe"
- ✅ Email: "student1@example.com"
- ✅ Phone: "5551234567"
- ✅ Enrollment date
- ✅ Section: "Enrolled Batches (1)"
  - ✅ "Grade 10 Science" listed
- ✅ "Edit Profile" button
- ✅ "Sign Out" button

**Click "Edit Profile"**:
- Change name to "Jane Doe"
- Change phone to "5559876543"
- Click "Save Changes"
- Go back to Profile tab → Should show updated info

**Click "Sign Out"** → Should return to Login screen

---

## Step 6: Troubleshooting

### Issue: Login fails
**Solution**: 
- Check internet connection
- Verify email format is correct
- Make sure Firebase Authentication is enabled in console

### Issue: No data shows on dashboard
**Solution**:
1. Make sure your **User UID** matches exactly in:
   - `/students/` document
   - `/attendance/` studentId field
   - `/batches/` enrolledStudents array
2. Check Firestore collections exist (go to Firebase Console)
3. Restart app: `flutter run`

### Issue: Zoom link doesn't open
**Solution**:
- Add `url_launcher` to `pubspec.yaml` (already added ✓)
- Make sure link format is: `https://zoom.us/j/...`

### Issue: Attendance shows 0%
**Solution**:
1. Check attendance records exist in Firestore
2. Verify `month` and `year` match current month/year
3. Verify `studentId` matches your **User UID** exactly
4. Try clicking month selector arrows to refresh

---

## Step 7: Common Issues & Fixes

### "No classes enrolled" appears
→ Check that `/students/<UID>` has `enrolledBatches: ["batch1"]`

### Classes tab is empty
→ Check `/batches/batch1` has `enrolledStudents: ["<YOUR_UID>"]`

### Zoom class doesn't show status (LIVE/UPCOMING)
→ Restart app - status is calculated at startup

### Profile doesn't update after edit
→ Check internet - wait 2 seconds for Firestore sync

---

## Final Checklist ✓

- [ ] Created Firebase student document
- [ ] Created batch "batch1"
- [ ] Created 2 subjects
- [ ] Created 2 Zoom classes
- [ ] Created 3 attendance records
- [ ] Logged in with test account
- [ ] Home tab shows data
- [ ] Classes tab shows batch & zoom links
- [ ] Attendance tab shows records with colors
- [ ] Profile tab shows student info
- [ ] Edit profile works
- [ ] Sign out works

---

## Next Steps After Testing

If everything works ✓:
1. Create a teacher dashboard (Phase 2)
2. Add ability to mark attendance via teacher app
3. Add student enrollment/signup flow
4. Add profile picture upload to Firebase Storage
5. Add push notifications for class reminders

**Questions?** Check the plan.md file for architecture details.
