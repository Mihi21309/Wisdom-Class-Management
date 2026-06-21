# 🚀 Quick Start: Add Test Data to Firebase

## Step 1: Login & Get Your User UID

### On Your Phone:
1. You should see the **Login Screen**
2. Enter:
   - **Email**: `student1@example.com`
   - **Password**: `Password123!`
3. Click **Sign In**

**⏳ Wait 5 seconds** - it will either:
- ✅ Redirect to dashboard (if data exists - won't happen yet)
- ❌ Show an error (that's OK - we need to add data first)

---

## Step 2: Get Your Unique User ID

### In Firebase Console:

1. Open: https://console.firebase.google.com
2. Click your project: **wisdom-class-management**
3. Left menu → **Authentication**
4. Find email: `student1@example.com`
5. **Copy the User ID** (looks like: `abc123def456xyz...`)

**⚠️ SAVE THIS UID - USE IT IN ALL STEPS BELOW**

---

## Step 3: Create Student Profile

### In Firebase Console:

1. Left menu → **Firestore Database**
2. Click **+ Create collection**
3. **Collection name**: `students`
4. **Document ID**: Paste your **User UID** from Step 2
5. Click **Auto ID** → change to your UID

### Add These Fields:

| Field Name | Type | Value |
|-----------|------|-------|
| `name` | string | `John Doe` |
| `email` | string | `student1@example.com` |
| `phone` | string | `9876543210` |
| `enrollmentDate` | timestamp | Today's date |
| `enrolledBatches` | array | Add one element: `batch1` |

**Click Save ✓**

---

## Step 4: Create Batch (Classroom)

### In Firestore:

1. Click **+ Add collection**
2. **Collection name**: `batches`
3. **Document ID**: `batch1`

### Add These Fields:

| Field Name | Type | Value |
|-----------|------|-------|
| `name` | string | `Grade 10 Science` |
| `year` | number | `2024` |
| `description` | string | `Complete 10th grade science curriculum` |
| `subjectsOffered` | array | Add 2 elements: `subj1` , `subj2` |
| `enrolledStudents` | array | Add 1 element: Paste your **User UID** |
| `createdAt` | timestamp | Today's date |

**Click Save ✓**

---

## Step 5: Create Subjects

### Subject 1:

1. Click **+ Add collection**
2. **Collection name**: `subjects`
3. **Document ID**: `subj1`

Add fields:
- `name` = `Physics`
- `code` = `PHY101`
- `teacher` = `Mr. Smith`

**Save ✓**

### Subject 2:

1. Same steps, **Document ID**: `subj2`

Add fields:
- `name` = `Mathematics`
- `code` = `MATH101`
- `teacher` = `Mrs. Johnson`

**Save ✓**

---

## Step 6: Create Zoom Classes

### Class 1 (Today at Morning):

1. Click **+ Add collection**
2. **Collection name**: `zoomClasses`
3. **Document ID**: `class1`

Add fields:

| Field | Type | Value |
|-------|------|-------|
| `classTitle` | string | `Physics Lecture` |
| `batchId` | string | `batch1` |
| `subjectId` | string | `subj1` |
| `zoomLink` | string | `https://zoom.us/j/123456789` |
| `scheduledDateTime` | timestamp | **Today at 10:00 AM** |
| `durationMinutes` | number | `60` |
| `description` | string | `Introduction to Motion` |
| `createdAt` | timestamp | Today's date |

**Save ✓**

### Class 2 (Tomorrow):

1. **Document ID**: `class2`

Add fields:

| Field | Type | Value |
|-------|------|-------|
| `classTitle` | string | `Math Tutorial` |
| `batchId` | string | `batch1` |
| `subjectId` | string | `subj2` |
| `zoomLink` | string | `https://zoom.us/j/987654321` |
| `scheduledDateTime` | timestamp | **Tomorrow at 2:00 PM** |
| `durationMinutes` | number | `45` |
| `description` | string | `Algebra Basics` |
| `createdAt` | timestamp | Today's date |

**Save ✓**

---

## Step 7: Add Attendance Records

### Record 1 (Present):

1. Click **+ Add collection**
2. **Collection name**: `attendance`
3. **Document ID**: `att1`

Add fields:

| Field | Type | Value |
|-------|------|-------|
| `studentId` | string | Paste your **User UID** |
| `batchId` | string | `batch1` |
| `subjectId` | string | `subj1` |
| `date` | timestamp | Today's date |
| `status` | string | `present` |
| `month` | number | `12` *(current month)* |
| `year` | number | `2024` *(current year)* |

**Save ✓**

### Record 2 (Absent):

1. **Document ID**: `att2`

Add fields:

| Field | Type | Value |
|-------|------|-------|
| `studentId` | string | Paste your **User UID** |
| `batchId` | string | `batch1` |
| `subjectId` | string | `subj2` |
| `date` | timestamp | Yesterday's date |
| `status` | string | `absent` |
| `month` | number | `12` |
| `year` | number | `2024` |

**Save ✓**

### Record 3 (Leave):

1. **Document ID**: `att3`

Add fields:

| Field | Type | Value |
|-------|------|-------|
| `studentId` | string | Paste your **User UID** |
| `batchId` | string | `batch1` |
| `subjectId` | string | `subj1` |
| `date` | timestamp | 2 days ago |
| `status` | string | `leave` |
| `month` | number | `12` |
| `year` | number | `2024` |

**Save ✓**

---

## Step 8: Test the App! 🎉

### Back on Your Phone:

1. **Restart the app**: Close and reopen it
2. **Login** with same credentials
3. You should now see the **Student Dashboard**

### What to Expect:

✅ **Home Tab**: Welcome message, stats, today's classes  
✅ **Classes Tab**: "Grade 10 Science" batch with subjects  
✅ **Attendance Tab**: Attendance records with color coding  
✅ **Profile Tab**: Your profile info with edit option

---

## 🎯 Checklist

- [ ] Logged into app with `student1@example.com`
- [ ] Copied User UID from Firebase Auth
- [ ] Created `students` document with your UID
- [ ] Created `batches/batch1` with your UID in enrolledStudents
- [ ] Created `subjects/subj1` and `subjects/subj2`
- [ ] Created `zoomClasses/class1` and `zoomClasses/class2`
- [ ] Created `attendance/att1`, `att2`, `att3` with your UID
- [ ] Restarted app on phone
- [ ] Dashboard shows data ✓

---

## ❓ Need Help?

If dashboard shows "No data":
1. Check that your **User UID** matches in:
   - `/students/` document ID
   - `/batches/batch1` in `enrolledStudents` array
   - All `/attendance/` documents in `studentId` field
2. Check month/year in attendance records match today

If still stuck, check TESTING_GUIDE.md for detailed troubleshooting.

---

**You've got this! 🚀**
